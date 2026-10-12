import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/constants/api_constants.dart';
import 'package:xstackapp/core/network/dio_client.dart';
import 'package:xstackapp/features/auth/data/models/auth_token_model.dart';
import 'package:xstackapp/features/auth/data/models/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient: dioClient);
});

abstract interface class AuthRemoteDataSource {
  Future<AuthTokenModel> login({
    required String phoneNumber,
    required String password,
  });

  Future<AuthTokenModel> register({
    required String phoneNumber,
    required String password,
    String? username,
    String? displayName,
  });

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<AuthTokenModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {
        'phoneNumber': phoneNumber,
        'password': password,
      },
    );

    return AuthTokenModel.fromJson(response.data!);
  }

  @override
  Future<AuthTokenModel> register({
    required String phoneNumber,
    required String password,
    String? username,
    String? displayName,
  }) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'phoneNumber': phoneNumber,
        'password': password,
        if (username != null && username.isNotEmpty) 'username': username,
        if (displayName != null && displayName.isNotEmpty) 'displayName': displayName,
      },
    );

    return AuthTokenModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      ApiConstants.me,
    );

    return UserModel.fromJson(response.data!);
  }
}
