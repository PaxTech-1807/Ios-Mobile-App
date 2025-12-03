// lib/features/profile/domain/provider_profile.dart
class ProviderProfile {
  final int id;
  final int providerId;
  final String companyName;
  final String location;
  final String? email;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final ProfileSocials? socials;
  final List<PortfolioImage> portfolioImages;
  final String? description;
  final String? openTime;
  final String? closeTime;

  ProviderProfile({
    required this.id,
    required this.providerId,
    required this.companyName,
    required this.location,
    this.email,
    this.profileImageUrl,
    this.coverImageUrl,
    this.socials,
    this.portfolioImages = const [],
    this.description,
    this.openTime,
    this.closeTime,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] as int,
      providerId: json['providerId'] as int,
      companyName: json['companyName'] as String,
      location: json['location'] as String? ?? '',
      email: json['email'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      socials: json['socials'] != null
          ? ProfileSocials.fromJson(json['socials'] as Map<String, dynamic>)
          : null,
      portfolioImages:
          (json['portfolioImages'] as List<dynamic>?)
              ?.map((e) => PortfolioImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String?,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'companyName': companyName,
      'location': location,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'coverImageUrl': coverImageUrl,
      'socials': socials?.toJson(),
      'portfolioImages': portfolioImages.map((e) => e.toJson()).toList(),
      'description': description,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  /// Convierte a JSON para actualizar perfil (PUT request)
  /// Solo incluye campos modificables
  Map<String, dynamic> toUpdateJson() {
    return {
      'profileImageUrl': profileImageUrl,
      'coverImageUrl': coverImageUrl,
      'location': location,
      'companyName': companyName,
      'socials': socials?.toJson() ?? {},
      'portfolioImages': portfolioImages.map((e) => e.imageUrl).toList(),
      'description': description,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  ProviderProfile copyWith({
    int? id,
    int? providerId,
    String? companyName,
    String? location,
    String? email,
    String? profileImageUrl,
    String? coverImageUrl,
    ProfileSocials? socials,
    List<PortfolioImage>? portfolioImages,
    String? description,
    String? openTime,
    String? closeTime,
  }) {
    return ProviderProfile(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      socials: socials ?? this.socials,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      description: description ?? this.description,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }
}

class ProfileSocials {
  final String? additionalProp1;
  final String? additionalProp2;
  final String? additionalProp3;

  ProfileSocials({
    this.additionalProp1,
    this.additionalProp2,
    this.additionalProp3,
  });

  factory ProfileSocials.fromJson(Map<String, dynamic> json) {
    return ProfileSocials(
      additionalProp1: json['additionalProp1'] as String?,
      additionalProp2: json['additionalProp2'] as String?,
      additionalProp3: json['additionalProp3'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (additionalProp1 != null) 'additionalProp1': additionalProp1,
      if (additionalProp2 != null) 'additionalProp2': additionalProp2,
      if (additionalProp3 != null) 'additionalProp3': additionalProp3,
    };
  }
}

class PortfolioImage {
  final int id;
  final String imageUrl;

  PortfolioImage({required this.id, required this.imageUrl});

  factory PortfolioImage.fromJson(Map<String, dynamic> json) {
    return PortfolioImage(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'imageUrl': imageUrl};
  }
}
