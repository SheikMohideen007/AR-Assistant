import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:ar_assistant/api/api_client.dart';
import 'package:ar_assistant/api/api_config.dart';
import 'package:uuid/uuid.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final List<dynamic> _messages = [];

  ChatBloc() : super(ChatInitialState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<AddHeaderMessageEvent>(_onAddHeaderMessage);
    on<PickImageEvent>(_onPickImage);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final loadingId = "loading_${Uuid().v4()}";
    try {
      _messages.add({
        "id": loadingId,
        "authorId": "user2",
        "text": "",
        "metadata": {"loading": true},
      });
      emit(ChatLoadedState(messages: List.from(_messages)));

      final response = await ApiClient().dio.post(
        ApiConfig.QUERY_REQUEST,
        data: {'question': event.text, 'thread_id': 'default'},
      );

      _messages.removeWhere((msg) => msg["id"] == loadingId);

      if (response.statusCode == 500) {
        _messages.add({
          "id": Uuid().v4(),
          "authorId": "user2",
          "text": "Sorry, there was an error processing your request.",
        });
      } else {
        _messages.add({
          "id": Uuid().v4(),
          "authorId": "user2",
          "text": response.data['answer'],
        });
      }
      emit(ChatLoadedState(messages: List.from(_messages)));
    } catch (e) {
      emit(ChatErrorState(error: "Something went wrong."));
    }
  }

  void _onAddHeaderMessage(
    AddHeaderMessageEvent event,
    Emitter<ChatState> emit,
  ) {
    _messages.add({
      "id": "quick-reports-header",
      "authorId": "system",
      "metadata": {"type": "quick_reports_header"},
    });
    emit(ChatLoadedState(messages: List.from(_messages)));
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<ChatState> emit,
  ) async {}
}
