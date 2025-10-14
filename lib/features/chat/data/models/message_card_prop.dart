import 'package:equatable/equatable.dart';

import '../../../../core/types/enum.dart' show Sender;

class MessageCardProp extends Equatable {
  final String text;
  final DateTime timestamp;
  final Sender sender;

  const MessageCardProp({
    required this.text,
    required this.timestamp,
    required this.sender,
  });

  @override
  List<Object> get props => [text, timestamp, sender];
}
