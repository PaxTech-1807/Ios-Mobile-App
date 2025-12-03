class Discount {
  final int? id;
  final String title;
  final String subtitle;
  final String content;
  final String discountType; // "PERCENTAGE"
  final double discountValue;
  final int providerProfileId;

  Discount({
    this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.discountType,
    required this.discountValue,
    required this.providerProfileId,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'] as int?,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      content: json['content'] as String,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      providerProfileId: json['providerProfileId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'discountType': discountType,
      'discountValue': discountValue,
      'providerProfileId': providerProfileId,
    };
  }

  Discount copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? content,
    String? discountType,
    double? discountValue,
    int? providerProfileId,
  }) {
    return Discount(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      providerProfileId: providerProfileId ?? this.providerProfileId,
    );
  }
}

