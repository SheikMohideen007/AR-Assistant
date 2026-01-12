import 'dart:async';
import 'dart:math';

import 'package:ar_assistant/api/api_client.dart';
import 'package:ar_assistant/api/api_config.dart';
import 'package:ar_assistant/mock_data.dart';
import 'package:ar_assistant/services/voiceText.dart';
import 'package:ar_assistant/utils/drawer.dart';
import 'package:ar_assistant/utils/report_builders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import '../theme_controller.dart';
import '../main.dart';
import 'dart:io';
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:flyer_chat_text_message/flyer_chat_text_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

enum MessageStatus { sending, sent, failed }

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> storedMessages = [];
  final _chatController = InMemoryChatController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addHeaderMessage();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  sendQueryToAPI({required String text}) async {
    final loadingId = "loading_${Random().nextInt(999999)}";
    try {
      print('coming here');
      _chatController.insertMessage(
        TextMessage(
          id: loadingId,
          authorId: "user2",
          createdAt: DateTime.now(),
          text: "",
          metadata: {"loading": true},
        ),
      );
      final response = await ApiClient().dio.post(
        ApiConfig.QUERY_REQUEST,
        data: {'question': text, 'thread_id': Uuid().v4()},
      );
      print('coming here..after response');
      if (response.statusCode == 500) {
        final botMessage = TextMessage(
          id: Uuid().v4(),
          authorId: 'user2',
          createdAt: DateTime.now(),
          text:
              'Sorry, there was an error processing your request. Please try again later.',
        );
        _chatController.insertMessage(botMessage);
        print('coming here..if');
      } else {
        final msg = findMessageById(loadingId);
        if (msg != null) {
          _chatController.removeMessage(msg);
        }
        final botReply = response.data['answer'] as String;
        final botMessage = TextMessage(
          id: Uuid().v4(),
          authorId: 'user2',
          createdAt: DateTime.now(),
          text: botReply,
        );
        _chatController.insertMessage(botMessage);
        print('coming here..if');
      }
      print('coming here..done');
    } catch (e) {
      print('coming here .. catch..$e');
      final msg = findMessageById(loadingId);
      if (msg != null) {
        _chatController.removeMessage(msg);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: themeController.currentMode == AppThemeMode.dark
              ? Colors.white.withOpacity(0.7)
              : Colors.black,
          content: Text(
            'Something went wrong ...',
            style: TextStyle(
              color: themeController.currentMode == AppThemeMode.dark
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ),
      );
    }
  }

  void _addHeaderMessage() {
    final headerMessage = CustomMessage(
      authorId: 'system',
      createdAt: DateTime(2000),
      id: 'quick-reports-header',
      metadata: const {'type': 'quick_reports_header'},
    );
    _chatController.insertMessage(headerMessage);
  }

  final TextEditingController _textController = TextEditingController();
  bool _hasAnyMessage = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildCustomDrawer(context),
      appBar: AppBar(
        elevation: 0,
        title: Text("AR Assistant", style: theme.appBarTheme.titleTextStyle),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => VoiceToTextModal(
                    onSend: (text) {
                      setState(() {
                        _textController.text = text;
                      });
                    },
                  ),
                );
              },
              child: SizedBox(
                height: 40,
                width: 40,
                child: Image.asset('assets/voice-message.png'),
              ),
            ),
          ),
        ],
      ),
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return AnimatedBuilder(
            animation: themeController,
            builder: (BuildContext context, Widget? child) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Chat(
                  theme: themeController.currentMode == AppThemeMode.dark
                      ? ChatTheme.dark().copyWith(
                          colors: ChatTheme.dark().colors.copyWith(),
                        )
                      : ChatTheme.light().copyWith(
                          colors: ChatTheme.light().colors.copyWith(
                            primary: Colors.teal.shade700,
                          ),
                        ),

                  currentUserId: 'user1',
                  chatController: _chatController,
                  onMessageSend: (message) {
                    final textMessage = TextMessage(
                      id: Uuid().v4(),
                      authorId: 'user1',
                      createdAt: DateTime.now(),
                      text: message,
                      metadata: {'status': MessageStatus.sending.index},
                    );
                    _chatController.insertMessage(textMessage);
                    if (!_hasAnyMessage) {
                      setState(() => _hasAnyMessage = true);
                    }

                    _sendMessageWithRetry(textMessage);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  },

                  builders: Builders(
                    chatAnimatedListBuilder: (context, itemBuilder) {
                      return ChatAnimatedList(
                        scrollController: _scrollController,
                        itemBuilder: itemBuilder,
                        shouldScrollToEndWhenAtBottom: false,
                      );
                    },

                    composerBuilder: (context) {
                      return Composer(
                        textEditingController: _textController,
                        topWidget: _hasAnyMessage && !isKeyboardVisible
                            ? ReportBuilders.buildQuickChipsRow(context, (
                                reportText,
                              ) {
                                final textMessage = TextMessage(
                                  id: Uuid().v4(),
                                  authorId: 'user1',
                                  createdAt: DateTime.now(),
                                  text: reportText,
                                  metadata: {
                                    'status': MessageStatus.sending.index,
                                  },
                                );
                                _chatController.insertMessage(textMessage);
                                if (!_hasAnyMessage) {
                                  setState(() => _hasAnyMessage = true);
                                }

                                _sendMessageWithRetry(textMessage);
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                });
                              })
                            : SizedBox.shrink(),

                        hintText: !_hasAnyMessage
                            ? 'Ask about AR Reports...'
                            : 'Type a message...',
                      );
                    },
                    customMessageBuilder:
                        (
                          context,
                          message,
                          index, {
                          groupStatus,
                          required isSentByMe,
                        }) {
                          final type = message.metadata?['type'] as String?;

                          if (type == 'quick_reports_header') {
                            return !_hasAnyMessage
                                ? ReportBuilders.buildQuickReportsHeader(
                                    context,
                                    (reportText) {
                                      final textMessage = TextMessage(
                                        id: Uuid().v4(),
                                        authorId: 'user1',
                                        createdAt: DateTime.now(),
                                        text: reportText,
                                        metadata: {
                                          'status': MessageStatus.sending.index,
                                        },
                                      );
                                      _chatController.insertMessage(
                                        textMessage,
                                      );
                                      if (!_hasAnyMessage) {
                                        setState(() => _hasAnyMessage = true);
                                      }

                                      _sendMessageWithRetry(textMessage);
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            _scrollController.animateTo(
                                              _scrollController
                                                  .position
                                                  .maxScrollExtent,
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          });
                                    },
                                  )
                                : const SizedBox.shrink();
                          }

                          return const SizedBox.shrink();
                        },

                    textMessageBuilder:
                        (
                          context,
                          message,
                          index, {
                          required bool isSentByMe,
                          MessageGroupStatus? groupStatus,
                        }) {
                          final isLoading =
                              message.metadata?['loading'] == true;
                          final statusIndex =
                              message.metadata?['status'] as int?;
                          final status = statusIndex != null
                              ? MessageStatus.values[statusIndex]
                              : null;

                          if (isLoading) {
                            return Align(
                              alignment: isSentByMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      message.text,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  Shimmer.fromColors(
                                    baseColor:
                                        themeController.currentMode ==
                                            AppThemeMode.light
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700,
                                    highlightColor:
                                        themeController.currentMode ==
                                            AppThemeMode.light
                                        ? Colors.grey.shade100
                                        : Colors.grey.shade500,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 12,
                                      ),
                                      padding: const EdgeInsets.all(14),
                                      width: 160,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final showRetry =
                              isSentByMe && status == MessageStatus.failed;

                          Widget bubbleContent = Column(
                            crossAxisAlignment: isSentByMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              FlyerChatTextMessage(
                                message: message,
                                index: index,
                                showTime: false,
                                showStatus: true,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${message.createdAt.toString().split(' ')[0]} ${message.createdAt.toString().split(' ')[1].substring(0, 5)}",
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          );

                          Widget constrainedBubble = ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.82,
                            ),
                            child: bubbleContent,
                          );

                          Widget bubble = Align(
                            alignment: isSentByMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: constrainedBubble,
                            ),
                          );

                          if (!showRetry) {
                            return bubble;
                          }

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              bubble,
                              GestureDetector(
                                onTap: () => _sendMessageWithRetry(message),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.redAccent.withOpacity(0.4),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                    imageMessageBuilder:
                        (
                          context,
                          message,
                          index, {
                          required bool isSentByMe,
                          MessageGroupStatus? groupStatus,
                        }) => GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.zero,
                                  child: InstaImageViewer(
                                    child: Image.file(
                                      File(message.source),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: FlyerChatImageMessage(
                            message: message,
                            index: index,
                            showTime: true,
                            showStatus: true,
                          ),
                        ),
                  ),

                  resolveUser: (UserID id) async {
                    if (id == 'user1') {
                      return User(id: id, name: 'User 1');
                    }
                    return null;
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _setMessageStatus(String messageId, MessageStatus status) {
    final msg = findMessageById(messageId);
    if (msg == null) return;

    final newMetadata = Map<String, dynamic>.from(msg.metadata ?? {});
    newMetadata['status'] = status.index;

    final updated = msg.copyWith(metadata: newMetadata);
    _chatController.updateMessage(msg, updated);
  }

  Future<void> _sendMessageWithRetry(TextMessage userMessage) async {
    _setMessageStatus(userMessage.id, MessageStatus.sending);
    int seconds = 0;
    final loadingId = "loading_${Random().nextInt(9999999)}";

    try {
      await _chatController.insertMessage(
        TextMessage(
          id: loadingId,
          authorId: 'user2',
          createdAt: DateTime.now(),
          text: 'Thinking',
          metadata: {'loading': true},
        ),
      );

      // Start timer to update every second
      Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        seconds++;
        final String updatedText;
        if (seconds < 60) {
          updatedText = "Thinking for ${seconds}s";
        } else {
          updatedText = "Deep Thinking for ${seconds}s";
        }

        final msg = findMessageById(loadingId);

        final updated = TextMessage(
          id: loadingId,
          authorId: 'user2',
          createdAt: DateTime.now(),
          text: updatedText,
          metadata: {'loading': true},
        );
        _chatController.updateMessage(msg!, updated);
      });

      final response = await ApiClient().dio.post(
        ApiConfig.QUERY_REQUEST,
        data: {'question': userMessage.text, 'thread_id': Uuid().v4()},
      );
      timer.cancel();

      final loadingMsg = findMessageById(loadingId);
      if (loadingMsg != null) {
        await _chatController.removeMessage(loadingMsg);
      }

      if (response.statusCode == 200) {
        final answer = response.data['answer']?.toString() ?? 'No response';

        _setMessageStatus(userMessage.id, MessageStatus.sent);

        await _chatController.insertMessage(
          TextMessage(
            id: Uuid().v4(),
            authorId: 'user2',
            createdAt: DateTime.now(),
            text: answer,
          ),
        );
      } else {
        throw 'Server returned ${response.statusCode}';
      }
    } catch (e) {
      final loadingMsg = findMessageById(loadingId);
      if (loadingMsg != null) {
        await _chatController.removeMessage(loadingMsg);
      }

      print('coming here .. catch..$e');

      _setMessageStatus(userMessage.id, MessageStatus.failed);
      bool isConnectionTimeout = e.toString().toLowerCase().contains('timeout')
          ? true
          : false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isConnectionTimeout
                  ? "Connection timeout"
                  : "Failed to send message",
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _sendMessageWithRetry(userMessage),
            ),
          ),
        );
      }
    }
  }

  void showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Colors.blue),
                  title: Text("Take Photo"),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickFromCamera();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo, color: Colors.green),
                  title: Text("Pick from Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> pickFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    _chatController.insertMessage(
      ImageMessage(
        id: Uuid().v4(),
        authorId: 'user1',
        createdAt: DateTime.now(),
        source: photo.path,
      ),
    );
    if (!_hasAnyMessage) {
      setState(() => _hasAnyMessage = true);
    }
  }

  Future<void> pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    _chatController.insertMessage(
      ImageMessage(
        id: Uuid().v4(),
        authorId: 'user1',
        createdAt: DateTime.now(),
        source: image.path,
      ),
    );
    if (!_hasAnyMessage) {
      setState(() => _hasAnyMessage = true);
    }
  }

  Message? findMessageById(String id) {
    return _chatController.messages.firstWhere((m) => m.id == id);
  }
}
