class PartnerAppChannelMessage {
  String type;
  PartnerAppChannelMessage({required this.type});

  static PartnerAppChannelMessage fromJson(Map<String, dynamic> json) {
    return PartnerAppChannelMessage(
      type: json['type'],
    );
  }
}
