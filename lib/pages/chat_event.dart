import 'package:flutter/foundation.dart';

abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String text;
  SendMessageEvent({required this.text});
}

class AddHeaderMessageEvent extends ChatEvent {}

class PickImageEvent extends ChatEvent {
  final bool fromCamera;
  PickImageEvent({required this.fromCamera});
}
