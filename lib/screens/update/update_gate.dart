import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/screens/splash/splash_screen.dart';
import 'package:salah_online_platform/screens/update/cubit/update_cubit.dart';
import 'package:salah_online_platform/screens/update/cubit/update_states.dart';
import 'package:salah_online_platform/screens/update/update_screen.dart';

class UpdateGate extends StatelessWidget {
  final PlatformCubit cubit;
  const UpdateGate({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpdateCubit>(
      create: (_) => UpdateCubit()..checkForUpdate(),
      child: _UpdateGateView(cubit: cubit),
    );
  }
}

class _UpdateGateView extends StatefulWidget {
  final PlatformCubit cubit;
  const _UpdateGateView({required this.cubit});

  @override
  State<_UpdateGateView> createState() => _UpdateGateViewState();
}

class _UpdateGateViewState extends State<_UpdateGateView> {
  bool _skipUpdate = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateCubit, UpdateState>(
      builder: (context, state) {
        if (_skipUpdate ||
            state is UpdateUpToDate ||
            state is UpdateUnavailable) {
          return SplashScreen(cubit: widget.cubit);
        }

        if (state is UpdateAvailable ||
            state is UpdateDownloading ||
            state is UpdateReadyToRestart ||
            state is UpdateFailed) {
          return UpdateScreen(
            onSkip: () => setState(() => _skipUpdate = true),
          );
        }

        // Idle / Checking — show a minimal loader so users see something.
        return const _CheckingView();
      },
    );
  }
}

class _CheckingView extends StatelessWidget {
  const _CheckingView();

  @override
  Widget build(BuildContext context) {
    final platform = PlatformCubit.get(context);
    final fontFamily = platform.isAr ? 'Cairo' : 'Roboto';
    return Scaffold(
      backgroundColor: const Color(0xfffafbfd),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset('assets/logo.png'),
              ),
              const SizedBox(height: 26),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              const SizedBox(height: 16),
              Text(
                platform.isAr
                    ? 'جاري التحقق من التحديثات...'
                    : 'Checking for updates...',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
