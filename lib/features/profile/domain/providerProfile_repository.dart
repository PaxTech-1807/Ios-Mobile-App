import 'package:iosmobileapp/features/profile/domain/providerProfile.dart';

abstract class ProviderprofileRepository {
  Future<ProviderProfile> getProfile({required int providerId});
  Future<ProviderProfile> updateProfile(ProviderProfile profile);
  Future<ProviderProfile> updateProfileLocation({
    required String location,
  });
  Future<ProviderProfile> getCurrentProfile();
}