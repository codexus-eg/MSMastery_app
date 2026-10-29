import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/screens/update/cubit/update_states.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit() : super(const UpdateIdle());

  static UpdateCubit get(BuildContext context) =>
      BlocProvider.of<UpdateCubit>(context);

  final ShorebirdUpdater _updater = ShorebirdUpdater();
  Timer? _progressTicker;
  double _progress = 0;

  bool get _isShorebirdSupported {
    if (Platform.isWindows || Platform.isLinux) return false;
    return _updater.isAvailable;
  }

  Future<void> checkForUpdate() async {
    if (!_isShorebirdSupported) {
      emit(const UpdateUnavailable());
      return;
    }

    emit(const UpdateChecking());
    try {
      final status = await _updater.checkForUpdate();
      switch (status) {
        case UpdateStatus.upToDate:
          emit(const UpdateUpToDate());
          break;
        case UpdateStatus.outdated:
          emit(const UpdateAvailable());
          break;
        case UpdateStatus.restartRequired:
          emit(const UpdateReadyToRestart());
          break;
        case UpdateStatus.unavailable:
          emit(const UpdateUnavailable());
          break;
      }
    } catch (e) {
      debugPrint('checkForUpdate error: $e');
      emit(const UpdateUnavailable());
    }
  }

  Future<void> downloadUpdate() async {
    if (!_isShorebirdSupported) {
      emit(const UpdateUnavailable());
      return;
    }

    _startProgressTicker();
    emit(UpdateDownloading(_progress));

    try {
      await _updater.update();
      _stopProgressTicker();
      _progress = 1.0;
      emit(const UpdateDownloading(1.0));
      await Future.delayed(const Duration(milliseconds: 400));
      emit(const UpdateReadyToRestart());
    } catch (e) {
      _stopProgressTicker();
      debugPrint('downloadUpdate error: $e');
      emit(UpdateFailed(_friendlyError(e)));
    }
  }

  void _startProgressTicker() {
    _progress = 0;
    _progressTicker?.cancel();
    _progressTicker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_progress >= 0.92) return;
      final step = _progress < 0.5
          ? 0.025
          : _progress < 0.8
              ? 0.012
              : 0.005;
      _progress = (_progress + step).clamp(0.0, 0.92);
      emit(UpdateDownloading(_progress));
    });
  }

  void _stopProgressTicker() {
    _progressTicker?.cancel();
    _progressTicker = null;
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('unreachable')) {
      return 'تعذر الاتصال بالخادم، تحقق من اتصالك بالانترنت.';
    }
    return 'حدث خطأ أثناء تحميل التحديث، حاول مرة أخرى.';
  }

  @override
  Future<void> close() {
    _stopProgressTicker();
    return super.close();
  }
}
