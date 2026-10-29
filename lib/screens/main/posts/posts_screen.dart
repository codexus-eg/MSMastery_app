// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/network/local/shared_pref_helper.dart';
import 'package:salah_online_platform/screens/main/posts/post_item.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({
    super.key,
  });
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();

    PlatformCubit.get(context).getPosts();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    SharedPrefHelper.saveData(
        key: 'postsCount', value: PlatformCubit.get(context).postsCount);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          PlatformCubit.get(context).getPosts(loadMore: true);
        }
      });
      //  PlatformCubit.get(context).getPosts(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);

        return Scaffold(
          key: cubit.scaffoldKey,
          backgroundColor:
              cubit.isDarkMode ? AppColors.darkBgColor : AppColors.lightBgColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultBackBtn(
                    txt: S.of(context).posts,
                  ),
                  SizedBox(height: 12.0),
                  Expanded(
                    child: RefreshIndicator(
                      color: Components.setBgColor(cubit.isDarkMode),
                      onRefresh: () => cubit.getPosts(),
                      child: cubit.posts.isEmpty
                          ? Center(
                              child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Text(
                                  S.of(context).no_posts_yet,
                                  style: AppTextStyles.title1Style,
                                ),
                              ),
                            )
                          : ListView.separated(
                              physics: AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                              itemBuilder: (context, index) {
                                return PostItem(
                                  index: index,
                                  post: cubit.posts[index],
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 4.0),
                              itemCount: cubit.posts.length,
                            ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
