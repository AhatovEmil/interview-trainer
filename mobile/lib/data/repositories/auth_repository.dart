import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../domain/models/profile.dart';

class AuthRepository {
  const AuthRepository({required ApiClient client, required TokenStorage tokens})
      : _client = client,
        _tokens = tokens;

  final ApiClient _client;
  final TokenStorage _tokens;

  Future<void> register({required String email, required String password}) async {
    final Map<String, dynamic> data = await _client.post(
      '/auth/register',
      body: <String, dynamic>{'email': email, 'password': password},
      skipAuth: true,
    );
    await _saveTokens(data);
  }

  Future<void> login({required String email, required String password}) async {
    final Map<String, dynamic> data = await _client.post(
      '/auth/login',
      body: <String, dynamic>{'email': email, 'password': password},
      skipAuth: true,
    );
    await _saveTokens(data);
  }

  Future<void> logout() => _tokens.clear();

  Future<bool> get hasSession => _tokens.hasSession;

  Future<UserProfile> me() async => UserProfile.fromJson(await _client.get('/me'));

  Future<UserProfile> setSpecialization({
    required String specializationId,
    required int selfAssessedGrade,
  }) async {
    final Map<String, dynamic> data = await _client.patch(
      '/me',
      body: <String, dynamic>{
        'specialization_id': specializationId,
        'self_assessed_grade': selfAssessedGrade,
        'is_primary': true,
      },
    );
    return UserProfile.fromJson(data);
  }

  Future<void> _saveTokens(Map<String, dynamic> data) => _tokens.save(
        access: data['access_token'] as String,
        refresh: data['refresh_token'] as String,
      );
}
