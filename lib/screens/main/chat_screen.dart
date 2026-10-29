// ignore_for_file: must_be_immutable

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/constants/voice_rec_srvice.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/generated/l10n.dart';

import '../../constants/constants.dart';
import '../../models/ChatModel.dart';
import '../../models/user_model.dart';
import 'Overlay.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.requestTitle,
    required this.requestId,
    required this.requestState,
    this.token,
  });
  final String requestTitle;
  final String requestState;

  final String requestId;
  final String? token;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final VoiceNoteService _voiceNoteService = VoiceNoteService();
  String? _currentlyPlayingUrl;

  bool _isRecording = false;
  bool isLoading = false;
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _playOrPauseVoice(String audioUrl) async {
    if (_currentlyPlayingUrl == audioUrl && _isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_currentlyPlayingUrl != audioUrl) {
        await _audioPlayer.setSourceUrl(audioUrl);
      }
      setState(() {
        _isPlaying = true;
        _currentlyPlayingUrl = audioUrl;
      });
      await _audioPlayer.play(UrlSource(audioUrl));
    }
  }

  void _handleMicButtonPress() async {
    if (_isRecording) {
      setState(() => isLoading = true);
      // Stop recording and upload the file
      final filePath = await _voiceNoteService.stopRecording();
      if (filePath != null) {
        final audioUrl = await _voiceNoteService.uploadVoiceNote(filePath);
        debugPrint('Uploaded audio URL: $audioUrl');
        UserModel um = Constants.userBox.get('user');
        String id = um.code!;

        await PlatformCubit.get(context).addMessage(
          widget.requestId,
          '',
          id,
          'voice',
          audioUrl,
        );
        setState(() {
          isLoading = false;
          _isRecording = false;
        });

        if (widget.token != null && widget.token!.isNotEmpty) {
          await PlatformCubit.get(context).sendNotification(
            userToken: widget.token!,
            title: 'New Message',
            body: 'Voice Note',
            dataPayload: {
              'type': 'request',
              'id': widget.requestId,
              'title': 'سؤال',
              'state': widget.requestState,
              'token': um.pushToken ?? '',
            },
          );
        }

        // Send the audio message
        // Call your existing `addMessage` function here
      }
    } else {
      // Start recording
      await _voiceNoteService.startRecording();
      setState(() {
        isLoading = false;
        _isRecording = true;
      });
    }
  }

  /// Cancel recording if user closes the screen
  void _cancelRecording() async {
    if (_isRecording) {
      await _voiceNoteService.stopRecording(); // Stop and discard recording
      setState(() {
        _isRecording = false;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cancelRecording();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    PlatformCubit.get(context).getChat(widget.requestId);
    _audioPlayer.onPlayerComplete.listen((state) {
      setState(() {
        _isPlaying = false;
        _currentlyPlayingUrl = null;
      });
    });
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd', 'en').format(dateTime);
  }

  String formatTime(DateTime dateTime) {
    return DateFormat(
      'hh:mm a',
    ).format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformGetRequestsSuccessState) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final cubb = PlatformCubit.get(context);
        return Scaffold(
          body: SafeArea(
            child: Container(
              /*
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    cubb.isDarkMode
                        ? Constants.wallpaberDark
                        : Constants.wallpaberLight,
                  ),
                ),
              ),
              */
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Components.setBgColor(cubb.isDarkMode),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 28,
                            color: Components.setTextColor(cubb.isDarkMode),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.requestTitle,
                                style: AppTextStyles.title2Style.copyWith(
                                  color:
                                      Components.setTextColor(cubb.isDarkMode),
                                ),
                              ),
                              if (widget.requestState != 'ended')
                                Text(
                                  S.of(context).donot_click_finish,
                                  style: AppTextStyles.body2Style.copyWith(
                                    color: Colors.grey[300],
                                    fontSize: 12.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (widget.requestState != 'ended')
                          DefaultTextButton(
                            txt: S.of(context).complete,
                            fontSize: 20.0,
                            color: Components.setTextColor(cubb.isDarkMode),
                            onPressed: () {
                              AppStatusDialog.show(
                                context: context,
                                status: AppDialogStatus.info,
                                title: 'بقولك ايه',
                                primaryActionText: S.of(context).confirm,
                                message: "This chat will be read only",
                                onPrimaryAction: () {
                                  cubb.updateRequest2(
                                      widget.requestId, "ended");
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _groupMessagesByDate(cubb.messages).length,
                      itemBuilder: (context, index) {
                        final dateGroup =
                            _groupMessagesByDate(cubb.messages)[index];
                        final messages =
                            dateGroup['messages'] as List<ChatModel>;
                        final date =
                            DateTime.parse(dateGroup['date'] as String);

                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                child: Text(
                                  timeago.format(
                                    date,
                                    locale: cubb.isAr ? 'ar' : 'en',
                                  ),
                                  style: AppTextStyles.body2Style.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            ...messages.map((message) {
                              UserModel um = Constants.userBox.get('user');
                              final isMe = message.id == um.code;
                              return _buildMessage(
                                message,
                                context,
                                cubb.isDarkMode,
                                isMe,
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                  widget.requestState != "ended"
                      ? Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24.0),
                              topRight: Radius.circular(24.0),
                            ),
                            color: cubb.isDarkMode
                                ? AppColors.darkBorder
                                : AppColors.lightBborder,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: state is PickImageState2
                                    ? Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          color: cubb.isDarkMode
                                              ? AppColors.darkBorder
                                              : AppColors.lightBborder,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                FullScreenImageViewer
                                                    .showFullImage2(
                                                        context, cubb.img);
                                              },
                                              child: SizedBox(
                                                width: 55,
                                                height: 55,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.file(
                                                    cubb.img!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12.0),
                                            TextButton(
                                              onPressed: () {
                                                cubb.swap();
                                              },
                                              child: Text(
                                                S.of(context).cancel,
                                                style: AppTextStyles.title2Style
                                                    .copyWith(
                                                        color: Components
                                                            .setBgColor(cubb
                                                                .isDarkMode)),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : DefaultTextField11(
                                        type: TextInputType.multiline,
                                        textInputAction:
                                            TextInputAction.newline,
                                        onChanged: (value) {
                                          cubb.ChangeSendIcon(value);
                                        },
                                        label: S.of(context).enter_msg,
                                        controller: cubb.chatController,
                                        errStr: S.of(context).enter_msg,
                                        maxLines: 3,
                                      ),
                              ),
                              const SizedBox(width: 8),
                              cubb.isTyping || cubb.img != null
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.send_rounded,
                                        size: 32,
                                        color: Components.setBgColor(
                                          cubb.isDarkMode,
                                        ),
                                      ),
                                      onPressed: () async {
                                        UserModel um =
                                            Constants.userBox.get('user');
                                        String imageUrl = "";

                                        if (cubb.isTyping || cubb.img != null) {
                                          if (cubb.img != null) {
                                            imageUrl =
                                                await cubb.uploadChatimage(
                                                    id: "ChatImages",
                                                    file: cubb.img);
                                          }

                                          await cubb.addMessage(
                                            widget.requestId,
                                            cubb.chatController.text.trim(),
                                            um.code!,
                                            imageUrl.isNotEmpty ? 'img' : 'txt',
                                            imageUrl,
                                          );
                                        }
                                        String txt =
                                            cubb.chatController.text.trim();
                                        cubb.chatController.clear();
                                        cubb.img = null;
                                        cubb.ChangeSendIcon('');

                                        if (widget.token != null &&
                                            widget.token!.isNotEmpty) {
                                          await PlatformCubit.get(context)
                                              .sendNotification(
                                            userToken: widget.token!,
                                            title: 'New Message',
                                            body: imageUrl.isNotEmpty
                                                ? 'Image'
                                                : txt,
                                            imageUrl: imageUrl,
                                            dataPayload: {
                                              'type': 'request',
                                              'id': widget.requestId,
                                              'title': 'سؤال',
                                              'state': widget.requestState,
                                              'token': um.pushToken ?? '',
                                            },
                                          );
                                        }
                                      },
                                    )
                                  : isLoading
                                      ? SizedBox(
                                          width: 30.0,
                                          height: 30.0,
                                          child: CircularProgressIndicator(
                                            color: Components.setBgColor(
                                              cubb.isDarkMode,
                                            ),
                                          ),
                                        )
                                      : IconButton(
                                          icon: Icon(
                                            _isRecording
                                                ? Icons.stop_circle_outlined
                                                : Icons.mic,
                                            size: 28.0,
                                          ),
                                          color: _isRecording
                                              ? Colors.red
                                              : Components.setBgColor(
                                                  cubb.isDarkMode),
                                          onPressed: _handleMicButtonPress,
                                        ),
                              IconButton(
                                icon: Icon(Icons.add_photo_alternate_rounded,
                                    size: 32.0,
                                    color:
                                        Components.setBgColor(cubb.isDarkMode)),
                                onPressed: () {
                                  cubb.pickChatImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(16.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cubb.isDarkMode
                                ? AppColors.darkBorder
                                : AppColors.lightBborder,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              style: AppTextStyles.body2Style,
                              S.of(context).cannot_send_message,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupMessagesByDate(List<ChatModel> messages) {
    Map<String, List<ChatModel>> groupedMessages = {};

    for (var message in messages) {
      String formattedDate = formatDate(message.time);
      if (groupedMessages.containsKey(formattedDate)) {
        groupedMessages[formattedDate]!.add(message);
      } else {
        groupedMessages[formattedDate] = [message];
      }
    }

    List<Map<String, dynamic>> groupedMessagesList =
        groupedMessages.entries.map((entry) {
      // Sort messages within each date group in descending order by time
      entry.value.sort((a, b) => a.time.compareTo(b.time));
      return {'date': entry.key, 'messages': entry.value};
    }).toList();

    // Sort the grouped messages in descending order by date
    groupedMessagesList.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA);
    });

    return groupedMessagesList;
  }

  Widget _buildMessage(
    ChatModel message,
    context,
    bool isDarkMode,
    bool isMe,
  ) {
    String formattedTime = formatTime(message.time);

    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe
                    ? Components.setBgColor(isDarkMode)
                    : (isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBborder),
                borderRadius: BorderRadiusDirectional.only(
                  topStart: const Radius.circular(16.0),
                  topEnd: const Radius.circular(16.0),
                  bottomStart: isMe ? const Radius.circular(16.0) : Radius.zero,
                  bottomEnd: isMe ? Radius.zero : const Radius.circular(16.0),
                ),
              ),
              child: message.type == 'img'
                  ? Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: InkWell(
                        onTap: () => FullScreenImageViewer.showFullImage(
                            context, message.imageUrl),
                        child: ClipRRect(
                          borderRadius: const BorderRadiusDirectional.only(
                            topStart: Radius.circular(16.0),
                            topEnd: Radius.circular(16.0),
                            bottomStart: Radius.circular(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                imageUrl: message.imageUrl!,
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                              Text(
                                formattedTime,
                                style: AppTextStyles.body2Style.copyWith(
                                  color: isMe || isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.black45,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : message.type == 'txt'
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.message!,
                                style: AppTextStyles.body2Style.copyWith(
                                  fontFamily: 'Cairo',
                                  color: isMe || isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                formattedTime,
                                style: AppTextStyles.body2Style.copyWith(
                                  color: isMe || isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.black45,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            _playOrPauseVoice(message.imageUrl!);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _currentlyPlayingUrl ==
                                                  message.imageUrl &&
                                              _isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: isMe || isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      S.of(context).voice_note,
                                      style: TextStyle(
                                        color: isMe || isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  formattedTime,
                                  style: AppTextStyles.body2Style.copyWith(
                                    color: isMe || isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.black45,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
