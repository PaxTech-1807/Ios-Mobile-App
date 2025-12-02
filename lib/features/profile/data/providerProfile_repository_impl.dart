import 'package:iosmobileapp/features/profile/data/providerProfile_service.dart';
import 'package:iosmobileapp/features/profile/domain/providerProfile.dart';
import 'package:iosmobileapp/features/profile/domain/providerProfile_repository.dart';

class ProviderprofileRepositoryImpl implements ProviderprofileRepository {
  final ProviderprofileService service;

  const ProviderprofileRepositoryImpl({required this.service});

  @override
  Future<ProviderProfile> getProfile({required int providerId}) {
    return service.getProfile(providerId: providerId);
  }
  @override
  Future<ProviderProfile> updateProfile(ProviderProfile profile) {
    return service.updateProfile(profile);
  }
  @override
  Future<ProviderProfile> updateProfileLocation({
    required String location,
  }) {
    return service.updateProfileLocation(location: location);
  }

  @override
  Future<ProviderProfile> getCurrentProfile() {
    return service.getCurrentProfile();
  }
}