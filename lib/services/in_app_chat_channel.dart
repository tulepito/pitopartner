class InAppChatChannelMessageData {
  String? userId;

  InAppChatChannelMessageData({required this.userId});

  static InAppChatChannelMessageData fromJson(Map<String, dynamic> json) {
    return InAppChatChannelMessageData(
      userId: json['userId'],
    );
  }
}

class InAppChatChannelMessage {
  String type;
  InAppChatChannelMessageData? data;

  InAppChatChannelMessage({required this.type, this.data});

  static InAppChatChannelMessage fromJson(Map<String, dynamic> json) {
    return InAppChatChannelMessage(
      type: json['type'],
      data: json['data'] != null
          ? InAppChatChannelMessageData.fromJson(json['data'])
          : null,
    );
  }
}
