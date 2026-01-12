import 'package:flutter/foundation.dart';

abstract class ChatState {}

class ChatInitialState extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatLoadedState extends ChatState {
  final List<dynamic> messages;
  ChatLoadedState({required this.messages});
}

class ChatErrorState extends ChatState {
  final String error;
  ChatErrorState({required this.error});
}
