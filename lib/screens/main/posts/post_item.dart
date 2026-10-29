// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/models/comment_model.dart';
import 'package:salah_online_platform/models/posts_model.dart';
import 'package:salah_online_platform/models/user_model.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostItem extends StatefulWidget {
  PostItem({super.key, required this.post, required this.index});

  PostModel post;
  final int index;

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  var commentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {},
      builder: (context, state) {
        UserModel um = Constants.userBox.get('user');
        var cubit = PlatformCubit.get(context);
        return FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _slide,
            child: Card(
              color: cubit.isDarkMode
                  ? AppColors.darkBorder
                  : AppColors.lightBborder,
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28.0,
                          backgroundImage:
                              CachedNetworkImageProvider(Constants.teacherImg),
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'استاذ محمد صلاح',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                timeago.format(widget.post.date,
                                    locale: cubit.isAr ? 'ar' : 'en'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    myDivider(),
                    const SizedBox(height: 8.0),
                    defaultReadMoreText(
                      txt: widget.post.text,
                      isDarkMode: cubit.isDarkMode,
                    ),
                    SizedBox(height: 8.0),
                    if (widget.post.imageUrl != null &&
                        widget.post.imageUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          elevation: 0.0,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: DefaultImage(imgUrl: widget.post.imageUrl!),
                        ),
                      ),
                    GestureDetector(
                      onTap: () async {
                        await cubit.getLikesUsers(widget.post.likes);

                        cubit.scaffoldKey.currentState!.showBodyScrim(
                          true,
                          0.75,
                        );
                        cubit.scaffoldKey.currentState!.showBottomSheet(
                          (context) => likesBottomSheet(),
                          showDragHandle: true,
                          elevation: 4.0,
                          enableDrag: true,
                          backgroundColor: cubit.isDarkMode
                              ? AppColors.darkBgColor
                              : AppColors.lightBgColor,
                        );
                      },
                      child: Text(
                        '${widget.post.likes.length} ${S.of(context).likes} . ${widget.post.comments.values.fold(0, (sum, list) => sum + list.length)} ${S.of(context).comments}',
                        style: TextStyle(
                          color:
                              cubit.isDarkMode ? Colors.grey : Colors.black45,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    myDivider(),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // like, unlike
                            if (!cubit.isGuest()) {
                              if (widget.post.likes[um.code] != null) {
                                await cubit.removeLike(
                                  code: um.code!,
                                  postId: widget.post.id,
                                );
                                widget.post.likes.remove(um.code);
                              } else {
                                await cubit.addLike(
                                  code: um.code!,
                                  postId: widget.post.id,
                                );
                                widget.post.likes[um.code!] = DateTime.now();
                              }
                            } else {
                              Constants.showLoginDialog(
                                isDarkMode: cubit.isDarkMode,
                                context: context,
                              );
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.post.likes[um.code] != null
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: 26,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                S.of(context).like,
                                style: TextStyle(
                                  color: cubit.isDarkMode
                                      ? Colors.grey
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 30, // ارتفاع الخط
                          width: 1.5, // عرض الخط
                          color: Colors.grey, // لون الخط
                        ),
                        GestureDetector(
                          onTap: () async {
                            // comments Screen

                            List<MapEntry<String, CommentModel>> allComments =
                                [];
                            allComments = widget.post.comments.entries
                                .expand((entry) => entry.value.map(
                                    (comment) => MapEntry(entry.key, comment)))
                                .toList();
                            allComments.sort((a, b) =>
                                b.value.date!.compareTo(a.value.date!));
                            List<String> userIds =
                                widget.post.comments.keys.toList();
                            await cubit.getCommentUsers(userIds);

                            cubit.scaffoldKey.currentState!.showBodyScrim(
                              true,
                              0.75,
                            );

                            cubit.scaffoldKey.currentState!.showBottomSheet(
                              (context) => commentsBottomSheet(
                                um: um,
                                comments: allComments,
                                userIds: userIds,
                              ),
                              showDragHandle: true,
                              elevation: 4.0,
                              enableDrag: true,
                              backgroundColor: cubit.isDarkMode
                                  ? AppColors.darkBgColor
                                  : AppColors.lightBgColor,
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat,
                                color: Components.setBgColor(cubit.isDarkMode),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                S.of(context).comments,
                                style: TextStyle(
                                  color: cubit.isDarkMode
                                      ? Colors.grey
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )

                    /*
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18.0,
                          backgroundImage: CachedNetworkImageProvider(''),
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: SizedBox(
                            height: 30.0,
                            child: InkWell(
                              onTap: () {
                                /*
                                Components.push(
                                  context: context,
                                  widget: CommentsScreen(
                                    postComments: postModel.comments,
                                    postId: postModel.postId!,
                                    userModel: PlatformCubit.get(context)
                                        .getUserDataByUId(postModel.uId!),
                                  ),
                                );
                                */
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${S.of(context).write_comment} ...',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            /*
                            if (PlatformCubit.get(context).isLiked(index)) {
                              PlatformCubit.get(context).removeLikePost(
                                  PlatformCubit.get(context).userPosts[index].postId!);
                            } else {
                              PlatformCubit.get(context).likePost(
                                  PlatformCubit.get(context).userPosts[index].postId!);
                            }
                            */
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                /*
                                PlatformCubit.get(context).isLiked(index)
                                    ? IconlyBold.heart
                                    : 
                                    */
                                IconlyBroken.heart,
                                color: Colors.red,
                                size: 26,
                              ),
                              const SizedBox(width: 3.0),
                              Text(
                                S.of(context).like,
                                style: TextStyle(color: Colors.black45, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                 */
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ReadMoreText defaultReadMoreText({
    required String txt,
    int trimLines = 3,
    TextStyle? style,
    required bool isDarkMode,
  }) =>
      ReadMoreText(
        txt,
        // style: const TextStyle(height: 1.2),
        trimLines: trimLines,
        style: style,

        colorClickableText: Components.setBgColor(isDarkMode),
        trimCollapsedText: S.current.read_more,
        trimExpandedText: S.current.read_less,
        trimMode: TrimMode.Line,
      );

  Widget myDivider() => Container(
        color: Colors.grey,
        height: 1.0,
      );

  Widget commentsBottomSheet({
    required UserModel um,
    required List<MapEntry<String, CommentModel>> comments,
    required List<String> userIds,
  }) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        return Container(
          height: MediaQuery.sizeOf(context).height / 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ConditionalBuilder(
                    condition: comments.isNotEmpty,
                    builder: (context) {
                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        reverse: true,
                        itemBuilder: (context, index) => buildCommentItem(
                          comment: comments[index].value.comment!,
                          dateCreated: comments[index].value.date!,
                          imgUrl: comments[index].key == um.code
                              ? um.img!
                              : cubit.commentstds[comments[index].key]
                                      ?.imgUrl ??
                                  '',
                          name: comments[index].key == um.code
                              ? '${um.ar_fname}  ${um.ar_sname} ${um.ar_thname}'
                              : cubit.commentstds[comments[index].key]?.name ??
                                  'Unknown',
                          isAr: cubit.isAr,
                          isDarkMode: cubit.isDarkMode,
                        ),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16.0),
                        itemCount: comments.length,
                      );
                    },
                    fallback: (context) => Center(
                      child: Text(
                        S.of(context).no_comments_yet,
                        style: TextStyle(fontSize: 22.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      width: 1.0,
                      color: Colors.grey[400]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 8.0,
                          ),
                          child: TextFormField(
                            controller: commentController,
                            minLines: 1,
                            maxLines: 5,
                            onChanged: (value) {
                              cubit.changeCommentVal(value);
                            },
                            maxLength: 200,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: S.of(context).write_comment,
                              counterText: '',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50.0,
                        //   color: Constants.defaultColor,
                        child: IconButton(
                          onPressed: () async {
                            if (!cubit.isGuest()) {
                              if (cubit.commentVal.trim().isNotEmpty) {
                                CommentModel cm = CommentModel(
                                  comment: commentController.text.trim(),
                                  date: DateTime.now(),
                                );

                                FocusScope.of(context).unfocus();

                                await cubit.addComment(
                                  code: um.code!,
                                  postId: widget.post.id,
                                  cm: cm,
                                );

                                // ✅ التأكد من أن القائمة موجودة قبل الإضافة
                                if (!widget.post.comments
                                    .containsKey(um.code!)) {
                                  widget.post.comments[um.code!] = [];
                                }
                                widget.post.comments[um.code!]!.add(cm);

                                // ✅ بدل الـ clear()، نضيف العنصر الجديد مباشرة
                                comments.add(MapEntry(um.code!, cm));

                                // ✅ إعادة ترتيب القائمة فقط بدلاً من إعادة تحميلها بالكامل
                                comments.sort((a, b) =>
                                    b.value.date!.compareTo(a.value.date!));

                                cubit.changeCommentVal('');
                                commentController.clear();
                                cubit.rebuild();
                              }
                            }

                            /*
                            if (!cubit.isGuest()) {
                              if (cubit.commentVal.trim().isNotEmpty) {
                                CommentModel cm = CommentModel(
                                  comment: commentController.text.trim(),
                                  date: DateTime.now(),
                                );
                                //
                                FocusScope.of(context).unfocus();
                                await cubit.addComment(
                                  code: um.code!,
                                  postId: post.id,
                                  cm: cm,
                                );

                                comments.add(MapEntry(um.code!, cm));
                                comments.sort((a, b) =>
                                    b.value.date!.compareTo(a.value.date!));
                                // ✅ التأكد من أن القائمة موجودة قبل الإضافة
                                if (!post.comments.containsKey(um.code!)) {
                                  post.comments[um.code!] = [];
                                }
                                post.comments[um.code!]!.add(cm);

                                cubit.changeCommentVal('');
                                commentController.clear();
                                cubit.rebuild();
                              }
                            } 
                            */
                            else {
                              Constants.showLoginDialog(
                                isDarkMode: cubit.isDarkMode,
                                context: context,
                              );
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            color: cubit.commentVal.trim().isEmpty
                                ? Colors.grey[700]
                                : cubit.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget likesBottomSheet() {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        return Container(
          height: MediaQuery.sizeOf(context).height / 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ConditionalBuilder(
                    condition: cubit.likesUsers.isNotEmpty,
                    builder: (context) {
                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        reverse: true,
                        itemBuilder: (context, index) => buildLikeItem(
                          imgUrl: cubit.likesUsers[index].imgUrl,
                          name: cubit.likesUsers[index].name,
                          dateCreated: cubit.likesUsers[index].date!,
                          isAr: cubit.isAr,
                          isDarkMode: cubit.isDarkMode,
                        ),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16.0),
                        itemCount: cubit.likesUsers.length,
                      );
                    },
                    fallback: (context) => Center(
                      child: Text(
                        S.of(context).no_likes_yet,
                        style: TextStyle(fontSize: 22.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildLikeItem({
    required String imgUrl,
    required String name,
    required DateTime dateCreated,
    required bool isAr,
    required bool isDarkMode,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage: CachedNetworkImageProvider(
              imgUrl,
            ),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    //  fontSize: 16,
                  ),
                ),
                Text(
                  timeago.format(dateCreated, locale: isAr ? 'ar' : 'en'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
          )
        ],
      );

  Widget buildCommentItem({
    required String imgUrl,
    required String name,
    required String comment,
    required DateTime dateCreated,
    required bool isAr,
    required bool isDarkMode,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage: CachedNetworkImageProvider(
              imgUrl,
            ),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    //  fontSize: 16,
                  ),
                ),
                SizedBox(height: 2.0),
                defaultReadMoreText(
                  txt: comment,
                  trimLines: 2,
                  isDarkMode: isDarkMode,
                ),
                Text(
                  timeago.format(dateCreated, locale: isAr ? 'ar' : 'en'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                ),
              ],
            ),
          ),
        ],
      );
}
