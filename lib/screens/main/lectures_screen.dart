// ignore_for_file: must_be_immutable

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/models/viedo_model.dart';

import '../../generated/l10n.dart';
import 'lecture_details_screen.dart';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  /// `null` => no revision category selected (no data).
  String? _selectedType;

  // ---- Memoized grouping (recomputed only when the source list changes) ----
  List<VideoModel>? _cachedSource;
  int _cachedLength = -1;
  List<VideoModel> _revisions = [];
  List<String> _typeNames = [];

  /// Builds the grouped data only when the source list changes.
  ///
  /// [PlatformCubit.getVideos] reuses the same list instance (it clears then
  /// re-fills it), so identity alone isn't enough — we also compare the length
  /// so the grouping is rebuilt when a refresh repopulates the list.
  void _recomputeIfNeeded(List<VideoModel> videoList) {
    if (identical(_cachedSource, videoList) &&
        _cachedLength == videoList.length) {
      return;
    }
    _cachedSource = videoList;
    _cachedLength = videoList.length;

    _revisions =
        videoList.where((element) => element.isChapter == true).toList();

    // Distinct, non-empty revision types => the filter categories.
    final names = <String>{};
    for (final video in _revisions) {
      final name = video.verType?.trim() ?? '';
      if (name.isNotEmpty) names.add(name);
    }
    _typeNames = names.toList()..sort();

    // Select the first type by default, and re-select it if the current
    // selection no longer exists after a refresh.
    if (_typeNames.isEmpty) {
      _selectedType = null;
    } else if (_selectedType == null || !_typeNames.contains(_selectedType)) {
      _selectedType = _typeNames.first;
    }
  }

  List<VideoModel> get _visibleRevisions {
    if (_selectedType == null) return const [];
    return _revisions
        .where((element) => (element.verType?.trim() ?? '') == _selectedType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformCubit, PlatformStates>(
      // Only rebuild for states that actually affect this screen, instead of
      // every emit in the app (which caused unnecessary re-renders).
      buildWhen: (previous, current) =>
          current is PlatformGetVideosSuccessState ||
          current is PlatformGetVideosLoadingState ||
          current is PlatformGetVideosFailState ||
          current is PlatformChangeModeState ||
          current is PlatfomrRefreshState,
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        _recomputeIfNeeded(cubit.videoList);

        final vidoes = _visibleRevisions;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).chapters,
                  style: AppTextStyles.headStyle,
                ),
                const SizedBox(height: 12.0),
                if (_typeNames.isNotEmpty)
                  _RevisionsFilterBar(
                    typeNames: _typeNames,
                    selectedType: _selectedType,
                    isDarkMode: cubit.isDarkMode,
                    onSelected: (type) {
                      if (_selectedType != type) {
                        setState(() => _selectedType = type);
                      }
                    },
                  ),
                if (_typeNames.isNotEmpty) const SizedBox(height: 12.0),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => cubit.getVideos(),
                    color: Components.setBgColor(cubit.isDarkMode),
                    child: ConditionalBuilder(
                      condition: vidoes.isEmpty,
                      builder: (context) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Container(
                            height: 250,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: cubit.isDarkMode
                                  ? Colors.black.withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Components.setBgColor(
                                              cubit.isDarkMode)
                                          .withValues(alpha: 0.12),
                                    ),
                                    child: Icon(
                                      Icons.video_library_outlined,
                                      size: 36,
                                      color: Components.setBgColor(
                                          cubit.isDarkMode),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    S.of(context).no_chapters_yet,
                                    style: AppTextStyles.body2Style.copyWith(
                                      color: cubit.isDarkMode
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.black.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      fallback: (context) {
                        return ListView.separated(
                          // Keyed to the active filter so the list state resets
                          // cleanly when switching categories.
                          key: ValueKey(_selectedType ?? '__none__'),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final video = vidoes[index];
                            return TweenAnimationBuilder<double>(
                              key: ValueKey(video.chapId),
                              // Capped so long lists don't get sluggish entrances.
                              duration: Duration(
                                milliseconds: 400 + (index.clamp(0, 6) * 100),
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: BuildLecturesWidget(
                                cubit: cubit,
                                imgUrl: video.thumbnail,
                                title: video.title,
                                subTitle: video.subTitle,
                                isDarkMode: cubit.isDarkMode,
                                chapId: video.chapId,
                                price: video.price,
                                prevPrice: video.prevPrice,
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8.0),
                          itemCount: vidoes.length,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal, modern pill-style filter bar for the revision categories.
class _RevisionsFilterBar extends StatelessWidget {
  const _RevisionsFilterBar({
    required this.typeNames,
    required this.selectedType,
    required this.isDarkMode,
    required this.onSelected,
  });

  final List<String> typeNames;
  final String? selectedType;
  final bool isDarkMode;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: typeNames.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final name = typeNames[index];
          return _FilterPill(
            label: name,
            icon: Constants.mathIcon(name),
            selected: selectedType == name,
            isDarkMode: isDarkMode,
            onTap: () => onSelected(name),
          );
        },
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDarkMode,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Components.setBgColor(isDarkMode);
    final unselectedFg = isDarkMode
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.black.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: selected
              ? primary
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? primary : primary.withValues(alpha: 0.25),
            width: 1.4,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : primary,
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: AppTextStyles.body2Style.copyWith(
                color: selected ? Colors.white : unselectedFg,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildLecturesWidget extends StatelessWidget {
  BuildLecturesWidget({
    super.key,
    required this.imgUrl,
    required this.isDarkMode,
    required this.title,
    required this.chapId,
    required this.cubit,
    this.subTitle,
    this.price,
    this.prevPrice,
  });
  String imgUrl;
  String title;
  String? subTitle;
  bool isDarkMode;
  String chapId;
  PlatformCubit cubit;
  int? price;
  int? prevPrice;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Components.push(
          context: context,
          widget: VideoDetails(
            cubit: cubit,
            thumbnail: imgUrl,
            chapId: chapId,
            title: title,
            prevPrice: prevPrice,
            price: price,
            subTitle: subTitle,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: DefaultImage(
                imgUrl: imgUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body1Style.copyWith(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subTitle != null && subTitle!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                subTitle!,
                textAlign: TextAlign.start,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body2Style,
              ),
            ),
        ],
      ),
    );
  }
}

/*
class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformCubit, PlatformStates>(
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        final mutedColor = cubit.isDarkMode
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.45);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).chapters,
                  style: AppTextStyles.headStyle,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => cubit.getVideos(),
                    color: Components.setBgColor(cubit.isDarkMode),
                    child: ConditionalBuilder(
                      condition: cubit.videoList.isEmpty,
                      builder: (context) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Container(
                            height: 250,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: cubit.isDarkMode
                                  ? Colors.black.withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Components.setBgColor(
                                              cubit.isDarkMode)
                                          .withValues(alpha: 0.12),
                                    ),
                                    child: Icon(
                                      Icons.menu_book_outlined,
                                      size: 36,
                                      color: Components.setBgColor(
                                          cubit.isDarkMode),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    S.of(context).no_chapters_yet,
                                    style: AppTextStyles.body2Style.copyWith(
                                      color: cubit.isDarkMode
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.black.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.refresh_rounded,
                                          size: 18, color: mutedColor),
                                      const SizedBox(width: 6.0),
                                      Text(
                                        S.of(context).pull_refresh,
                                        style:
                                            AppTextStyles.body2Style.copyWith(
                                          fontSize: 13.0,
                                          color: mutedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      fallback: (context) {
                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final video = cubit.videoList[index];
                            return TweenAnimationBuilder<double>(
                              key: ValueKey(video.chapId),
                              // Capped so long lists don't get sluggish entrances.
                              duration: Duration(
                                milliseconds: 400 + (index.clamp(0, 6) * 100),
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: BuildLecturesWidget(
                                cubit: cubit,
                                imgUrl: video.thumbnail,
                                title: video.title,
                                subTitle: video.subTitle,
                                price: video.price,
                                prevPrice: video.prevPrice,
                                isDarkMode: cubit.isDarkMode,
                                chapId: video.chapId,
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8.0),
                          itemCount: cubit.videoList.length,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BuildLecturesWidget extends StatelessWidget {
  BuildLecturesWidget({
    super.key,
    required this.imgUrl,
    required this.isDarkMode,
    required this.title,
    required this.chapId,
    required this.cubit,
    this.subTitle,
    this.price,
    this.prevPrice,
  });
  String imgUrl;
  String title;
  int? prevPrice;
  int? price;
  String? subTitle;
  bool isDarkMode;
  String chapId;
  PlatformCubit cubit;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Components.push(
          context: context,
          widget: VideoDetails(
            cubit: cubit,
            thumbnail: imgUrl,
            chapId: chapId,
            title: title,
            prevPrice: prevPrice,
            price: price,
            subTitle: subTitle,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: DefaultImage(
                imgUrl: imgUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body1Style.copyWith(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subTitle != null && subTitle!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                subTitle!,
                textAlign: TextAlign.start,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body2Style,
              ),
            ),
        ],
      ),
    );
  }
}
*/
