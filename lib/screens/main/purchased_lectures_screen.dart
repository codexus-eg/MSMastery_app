// ignore_for_file: must_be_immutable

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/models/video_details_model.dart';

import '../../bloc/platformCubit.dart';
import '../../bloc/platformStates.dart';
import '../../constants/components.dart';
import '../../constants/styles.dart';
import '../../generated/l10n.dart';
import 'lectures_details_details_screen.dart';

class MyLecturesScreen extends StatefulWidget {
  MyLecturesScreen({
    super.key,
    required this.cubit,
  });
  PlatformCubit cubit;
  @override
  State<MyLecturesScreen> createState() => _MyLecturesScreenState();
}

class _MyLecturesScreenState extends State<MyLecturesScreen> {
  @override
  void initState() {
    super.initState();
    widget.cubit.getMyVideos();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformCubit, PlatformStates>(
        builder: (context, state) {
      var cubit = PlatformCubit.get(context);
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultBackBtn(
                  txt: S.of(context).my_lec,
                ),
                const SizedBox(height: 12.0),
                Expanded(
                  child: RefreshIndicator(
                    color: Components.setBgColor(cubit.isDarkMode),
                    onRefresh: () => cubit.getMyVideos(),
                    child: ConditionalBuilder(
                        condition: cubit.myVideos.isEmpty,
                        builder: (context) => ListView(
                              children: [
                                Center(
                                  child: Text(
                                    S.of(context).no_videos_yet,
                                    style: AppTextStyles.title2Style,
                                  ),
                                ),
                              ],
                            ),
                        fallback: (context) {
                          return ListView.separated(
                            itemBuilder: (context, index) =>
                                BuildLecturesWidget(
                              isDarkMode: cubit.isDarkMode,
                              vdm: cubit.myVideos[index],
                              cubit: cubit,
                            ),
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 12.0,
                            ),
                            itemCount: cubit.myVideos.length,
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class BuildLecturesWidget extends StatelessWidget {
  BuildLecturesWidget({
    super.key,
    required this.isDarkMode,
    required this.vdm,
    required this.cubit,
  });
  VideoDetailsModel vdm;
  bool isDarkMode;
  PlatformCubit cubit;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LectureDetailsDetailsScreen(
              price: vdm.price,
              dep: vdm.dep,
              thumbnail: vdm.thumbnail,
              subTitle: vdm.subTitle,
              title: vdm.title,
              lecId: vdm.lecId,
              chapId: vdm.chapId,
            ),
            settings: const RouteSettings(name: 'lectureDetails'),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: DefaultImage(
                imgUrl: vdm.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              bottom: 4.0,
            ),
            decoration: BoxDecoration(
              color: Components.setBgColor(isDarkMode),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22.0),
                bottomRight: Radius.circular(22.0),
              ),
            ),
            child: Text(
              vdm.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.title2Style.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
