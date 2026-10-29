// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/screens/main/Overlay.dart';

import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/generated/l10n.dart';

import '../models/RequsetsModel.dart';
import '../models/question_model.dart';
import '../screens/main/requests.dart';
import 'components.dart';

class BuildQuizItem extends StatelessWidget {
  BuildQuizItem({
    super.key,
    required this.questionModel,
    required this.queIdx,
    required this.length,
    required this.cubit,
    required this.isQuestionbank,
  });

  final QuestionModel questionModel;
  final int length;
  final int queIdx;
  final bool isQuestionbank;
  final PlatformCubit cubit;
  late final Color color = Components.setBgColor(cubit.isDarkMode);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformCubit, PlatformStates>(
      builder: (context, state) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: cubit.isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: cubit.isDarkMode ? 0.35 : 0.06),
                  blurRadius: 14.0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🟦 Header
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.appPrimaryColor,
                              AppColors.appSecondaryColor,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${queIdx + 1} ${S.of(context).of_} $length ${S.of(context).questionss}',
                                  style: AppTextStyles.body2Style.copyWith(
                                    color: Colors.grey,
                                    fontSize: 13.0,
                                  ),
                                ),
                                const Spacer(),
                                /*
                                _InfoChip(
                                  icon: (questionModel.options != null &&
                                          questionModel.options!.isNotEmpty)
                                      ? Icons.checklist_rounded
                                      : Icons.edit_note_rounded,
                                  label: '',
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 6.0),
                                */
                                _InfoChip(
                                  icon: Icons.military_tech_rounded,
                                  label:
                                      '${questionModel.degree} ${questionModel.degree == 1 ? S.of(context).degree : S.of(context).degrees}',
                                  color: AppColors.appPrimaryColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              questionModel.title,
                              style: AppTextStyles.title2Style,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12.0),

                // 🖼️ Question image
                if (questionModel.imgUrl != null)
                  GestureDetector(
                    onTap: () {
                      FullScreenImageViewer.showFullImage(
                        context,
                        questionModel.imgUrl,
                      );
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: questionModel.imgUrl!,
                            height: MediaQuery.of(context).size.height / 4,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  S.of(context).tap_to_zoom,
                                  style: AppTextStyles.body2Style.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12.0),

                // 🔹 Options or Written answer
                if (questionModel.options != null &&
                    questionModel.options!.isNotEmpty)
                  _buildMCQ(context)
                else
                  WrittenAnswerSection(
                    questionModel: questionModel,
                    cubit: cubit,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Multiple-choice
  Widget _buildMCQ(BuildContext context) {
    final selected = isQuestionbank
        ? cubit.stdQuestionbankAnsws[questionModel.id]
        : cubit.stdQuizAnsws[questionModel.id];

    return Column(
      children: List.generate(
        questionModel.options!.length,
        (ansIdx) => Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: _buildOption(context, ansIdx, selected),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, int ansIdx, int? selected) {
    final option = questionModel.options![ansIdx];
    final value = ansIdx + 1;
    final bool isSelected = selected == value;

    void select() {
      if (isQuestionbank) {
        cubit.selectQuestionbankAnswer(questionModel.id, value);
      } else {
        cubit.selectAnswer(questionModel.id, value);
      }
    }

    final Color idleBg =
        cubit.isDarkMode ? AppColors.darkBgColor : AppColors.lightBgColor;
    final Color idleBorder = cubit.isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return GestureDetector(
      onTap: select,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : idleBg,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected ? color : idleBorder,
            width: isSelected ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /*
            // 🔤 Letter / check badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 34.0,
              height: 34.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey,
                  width: 1.6,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20.0)
                  : SizedBox.shrink(),
            ),
            const SizedBox(width: 12.0),
*/
            // 📝 Option content (title and/or image)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (option.title != null)
                    Text(
                      option.title!,
                      style: AppTextStyles.body2Style.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  if (option.imgUrl != null) ...[
                    if (option.title != null) const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () {
                        FullScreenImageViewer.showFullImage(
                          context,
                          option.imgUrl,
                        );
                      },
                      child: DefaultImage(imgUrl: option.imgUrl!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: label.isEmpty ? 8.0 : 10.0,
        vertical: 5.0,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.0, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 5.0),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WrittenAnswerSection extends StatefulWidget {
  final QuestionModel questionModel;
  final PlatformCubit cubit;

  const WrittenAnswerSection({
    super.key,
    required this.questionModel,
    required this.cubit,
  });

  @override
  State<WrittenAnswerSection> createState() => _WrittenAnswerSectionState();
}

class _WrittenAnswerSectionState extends State<WrittenAnswerSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final existingText =
        widget.cubit.writtenAnswsMap[widget.questionModel.id]?.text ?? '';
    _controller = TextEditingController(text: existingText);
  }

  @override
  void didUpdateWidget(covariant WrittenAnswerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final latestText =
        widget.cubit.writtenAnswsMap[widget.questionModel.id]?.text ?? '';
    if (_controller.text != latestText) {
      _controller.text = latestText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.cubit;
    final questionModel = widget.questionModel;

    return BlocBuilder<PlatformCubit, PlatformStates>(
      builder: (context, state) {
        final answers = cubit.writtenAnswsMap[questionModel.id];
        final imageUrls = answers?.imagesUrl ?? [];

        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: cubit.isDarkMode
                ? AppColors.darkBorder
                : AppColors.lightBborder,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: Components.setBgColor(cubit.isDarkMode),
                    size: 22.0,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    S.of(context).your_answer,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),

              // ✏️ Text Answer
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '${S.of(context).write_your_answer}...',
                  filled: true,
                  fillColor: cubit.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  cubit.saveWrittenAnswer(questionModel.id, value);
                },
              ),
              const SizedBox(height: 12.0),

              if (state is WrittenAnswerUploading && state.isUploading)
                LinearProgressIndicator(
                  color: Components.setBgColor(cubit.isDarkMode),
                ),

              const SizedBox(height: 12.0),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: imageUrls.map((imgUrl) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();

                          FullScreenImageViewer.showFullImage(context, imgUrl);
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: imgUrl,
                                height: 120,
                                width: 120,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.zoom_in,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      S.of(context).tap_to_zoom,
                                      style: AppTextStyles.body2Style.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await _deleteSingleImage(context, imgUrl);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 12.0),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Components.setBgColor(cubit.isDarkMode),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add_a_photo_outlined,
                      color: Colors.white, size: 20),
                  label: Text(
                    S.of(context).upload_answ_img_here,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    if (imageUrls.length == 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("🚫 لا يمكنك رفع أكثر من 3 صور")),
                      );
                      return;
                    }

                    await _uploadImagesToFirebase(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImagesToFirebase(BuildContext context) async {
    final picker = ImagePicker();
    final um = Constants.userBox.get('user');
    final cubit = widget.cubit;
    final questionModel = widget.questionModel;

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).choose_img_source),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text("📷 ${S.of(context).take_photo}"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text("🖼️ ${S.of(context).choose_from_gallery}"),
          ),
        ],
      ),
    );

    if (source == null) return;

    final pickedFiles = source == ImageSource.gallery
        ? (await picker.pickMultiImage(imageQuality: 60))
            .take(3 -
                (cubit.writtenAnswsMap[questionModel.id]?.imagesUrl ?? [])
                    .length)
            .toList()
        : [await picker.pickImage(source: ImageSource.camera, imageQuality: 40)]
            .whereType<XFile>()
            .toList();

    if (pickedFiles.isEmpty) return;

    cubit.setUploading(true);

    for (var pickedFile in pickedFiles) {
      final file = File(pickedFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'written_answers/${questionModel.id}/${um.code}/$fileName';

      try {
        // 📤 محاولة الرفع إلى Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(path);
        final uploadTask = storageRef.putFile(file);
        await uploadTask.whenComplete(() async {
          final downloadUrl = await storageRef.getDownloadURL();
          cubit.addWrittenImage(questionModel.id, downloadUrl);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم رفع الصور بنجاح")),
        );
      } catch (e) {
        debugPrint('❌ Firebase upload failed, trying Supabase... $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ حدث خطأ أثناء رفع الصور")),
        );
/*
        try {
          // ✅ رفع الملف إلى Supabase كخطة بديلة
          

          await supabase.storage.from('data').upload(path, file);
          final downloadUrl = supabase.storage.from('data').getPublicUrl(path);

          cubit.addWrittenImage(questionModel.id, downloadUrl);
          debugPrint('✅ Uploaded to Supabase successfully');
        } catch (supabaseError) {
          debugPrint(
              '❌ Both Firebase and Supabase uploads failed: $supabaseError');
        }
        */
      }
    }

    cubit.setUploading(false);
  }

  Future<void> _deleteSingleImage(BuildContext context, String imgUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imgUrl);
      await ref.delete();

      widget.cubit.removeWrittenImage(widget.questionModel.id, imgUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ تم حذف الصورة بنجاح")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ أثناء حذف الصورة: $e")));
    }
  }
}

class DefaultTextButton extends StatelessWidget {
  DefaultTextButton({
    super.key,
    required this.txt,
    required this.onPressed,
    this.fontSize,
    this.color,
  });
  String txt;
  double? fontSize;
  void Function() onPressed;
  Color? color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        txt,
        style: AppTextStyles.body2Style.copyWith(
          decoration: TextDecoration.underline,
          fontSize: fontSize,
          decorationColor: color ?? AppColors.appPrimaryColor,
          color: color ?? AppColors.appPrimaryColor,
        ),
      ),
    );
  }
}

class DefaultTextField11 extends StatelessWidget {
  DefaultTextField11({
    super.key,
    required this.type,
    required this.label,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    required this.errStr,
    this.enabled = true,
    this.isPassword = false,
    this.preTxt,
    this.onChanged,
    this.onSubmit,
    this.suffixIcon,
    this.maxLength,
    this.maxLines,
    this.height,
    this.textAlign,
    this.inputFormatters,
  });
  TextInputType? type;
  TextEditingController controller;
  String label;
  String errStr;
  List<TextInputFormatter>? inputFormatters;

  TextInputAction textInputAction;
  Widget? suffixIcon;
  bool isPassword;
  bool enabled;
  int? maxLength;
  String? preTxt;

  int? maxLines;
  void Function(String)? onSubmit;
  void Function(String)? onChanged;
  TextAlign? textAlign;
  double? height;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformCubit, PlatformStates>(
        builder: (context, state) {
      var cubit = PlatformCubit.get(context);
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: TextFormField(
          onFieldSubmitted: onSubmit,
          enabled: enabled,
          textAlign: textAlign ?? TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          keyboardType: type,
          controller: controller,
          maxLines: maxLines ?? 1,
          style: AppTextStyles.body2Style,
          onChanged: onChanged,
          validator: (value) {
            if (value!.isEmpty) {
              return '$errStr ${S.of(context).is_req}';
            }
            return null;
          },
          obscureText: isPassword,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            prefixText: preTxt != null ? '$preTxt ' : null,
            counterText: '',
            contentPadding: EdgeInsetsDirectional.symmetric(
              horizontal: 12.0,
              vertical: height ?? 12,
            ),
            hintText: (label),
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: cubit.isDarkMode ? Colors.black : Colors.white,
            suffixIcon: suffixIcon,
            border: InputBorder.none,
          ),
        ),
      );
    });
  }
}

class DefaultButton extends StatelessWidget {
  DefaultButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.width,
    required this.isDarkMode,
    this.color,
    this.gradient,
    this.boxShadow,
  });
  Widget child;
  void Function() onPressed;
  double? width;
  bool isDarkMode;
  Color? color;
  LinearGradient? gradient;
  List<BoxShadow>? boxShadow;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: color ?? Components.setBgColor(isDarkMode),
          borderRadius: BorderRadius.circular(18.0),
          gradient: gradient,
          boxShadow: boxShadow,
        ),
        child: child,
      ),
    );
  }
}

class DefaultWaitedButton extends StatelessWidget {
  DefaultWaitedButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.txt,
    this.width,
    required this.isDarkMode,
  });
  bool isLoading;
  void Function() onPressed;
  String txt;
  double? width;
  bool isDarkMode;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DefaultButton(
        isDarkMode: isDarkMode,
        onPressed: onPressed,
        gradient: LinearGradient(
          colors: [
            Components.setBgColor(isDarkMode).withValues(alpha: 0.5),
            Components.setBgColor(isDarkMode),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Components.setBgColor(isDarkMode).withValues(alpha: .35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        width: width,
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      color: Components.setTextColor(isDarkMode),
                      strokeWidth: 2.8,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    S.of(context).loading,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body2Style
                        .copyWith(color: Components.setTextColor(isDarkMode)),
                  ),
                ],
              )
            : Text(
                txt,
                textAlign: TextAlign.center,
                style: AppTextStyles.body2Style
                    .copyWith(color: Components.setTextColor(isDarkMode)),
              ),
      ),
    );
  }
}

class BuildDefaultText extends StatelessWidget {
  BuildDefaultText({
    super.key,
    required this.txt,
  });
  String txt;
  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: const TextStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class DefaultImage extends StatelessWidget {
  DefaultImage({
    super.key,
    required this.imgUrl,
    this.width,
    this.height,
    this.fit,
  });
  String imgUrl;
  double? width;
  double? height;
  BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imgUrl,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Icon(
        Icons.error,
        color: Colors.red,
      ),
      width: width,
      height: height,
      fit: fit,
    );
  }
}

class DefaultBackBtn extends StatelessWidget {
  DefaultBackBtn({
    super.key,
    this.txt,
    this.onTap,
    this.textStyle,
    this.color,
    this.textAlign,
  });
  String? txt;
  Color? color;
  void Function()? onTap;
  TextStyle? textStyle;
  TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap ??
              () {
                Navigator.pop(context);
              },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_ios_new,
                color: color,
              ),
              Text(
                S.of(context).back,
                style: AppTextStyles.title2Style.copyWith(color: color),
              ),
            ],
          ),
        ),
        if (textStyle != null) const SizedBox(height: 12.0),
        if (txt != null)
          Text(
            txt!,
            textAlign: textAlign ?? TextAlign.start,
            style: textStyle ?? AppTextStyles.headStyle,
          ),
        const SizedBox(height: 12.0),
      ],
    );
  }
}

class Widgets {
  static Widget buildPendingBanner(bool isDarkMode) {
    const pendingColor = Color(0xFFFFA000);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pendingColor.withValues(alpha: isDarkMode ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: pendingColor.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: pendingColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    color: pendingColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  S.current.payment_pending_title,
                  style: AppTextStyles.title2Style.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            S.current.payment_pending_hint,
            style: AppTextStyles.body2Style.copyWith(fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

void requestOverlay2(
  RequsetsModel request,
  context2,
  String title,
  PlatformCubit cubit,
) {
  showDialog(
    context: context2,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Components.setBgColor(cubit.isDarkMode),
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  title,
                  style: AppTextStyles.title1Style.copyWith(
                      color: Components.setTextColor(cubit.isDarkMode)),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.0),
                color: cubit.isDarkMode
                    ? AppColors.darkBgColor
                    : AppColors.lightBgColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 65.0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context2, index) => ImagesIcons2(
                        index,
                        context2,
                        request.imageurl[index],
                        cubit.isDarkMode,
                      ),
                      separatorBuilder: (context2, index) => const SizedBox(
                        width: 5,
                      ),
                      itemCount: request.imageurl.length,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: TextFormField(
                      initialValue: request.request,
                      style: AppTextStyles.body2Style.copyWith(
                          color:
                              cubit.isDarkMode ? Colors.white : Colors.black),
                      enabled: false,
                      textAlign: TextAlign.start,
                      maxLines: 5,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor:
                            cubit.isDarkMode ? Colors.black : Colors.white,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    '${S.of(context).date} ${cubit.formatDate(request.date)}',
                    style: AppTextStyles.body2Style,
                  ),
                  const SizedBox(height: 32.0),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DefaultButton(
                        width: double.infinity,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        isDarkMode: cubit.isDarkMode,
                        child: Text(
                          S.of(context).cancel,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body2Style.copyWith(
                            color: Components.setTextColor(cubit.isDarkMode),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
