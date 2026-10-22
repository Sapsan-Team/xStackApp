import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/constants/api_constants.dart';
import 'package:xstackapp/core/network/dio_client.dart';
import 'package:xstackapp/features/chat/domain/entities/chat.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(dioClientProvider));
});

abstract interface class ChatRepository {
  Future<List<ChatSummary>> getChats();

  Future<List<ChatMessage>> getMessages(String chatId, {int limit = 60});

  Future<ChatMessage> sendMessage(String chatId, String content);

  Future<void> markRead(String chatId, {String? messageId});

  Future<List<UserSearchResult>> searchUsers(String query, {int limit = 20});

  Future<ChatDetails> getChatDetails(String chatId);

  Future<ChatDetails> createDirectChat(String userId);

  Future<ChatDetails> createGroupChat(String title, List<String> memberUserIds);
}

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._client);

  final DioClient _client;

  @override
  Future<List<ChatSummary>> getChats() async {
    final response = await _client.get<dynamic>(ApiConstants.chats);
    final data = response.data as List<dynamic>? ?? const [];
    return data
        .map((e) => ChatSummary.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<ChatMessage>> getMessages(String chatId, {int limit = 60}) async {
    final response = await _client.get<dynamic>(
      ApiConstants.messages(chatId),
      queryParameters: {'limit': limit},
    );
    final data = response.data as List<dynamic>? ?? const [];
    final messages = data
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    // Threads render oldest-first (newest at the bottom), so normalise the
    // order instead of trusting what the backend happens to return.
    return messages..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<ChatMessage> sendMessage(String chatId, String content) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.messages(chatId),
      data: {'content': content},
    );
    return ChatMessage.fromJson(response.data!);
  }

  @override
  Future<void> markRead(String chatId, {String? messageId}) async {
    await _client.post<dynamic>(
      '/api/chats/$chatId/read',
      data: {'messageId': ?messageId},
    );
  }

  @override
  Future<List<UserSearchResult>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    final response = await _client.get<dynamic>(
      ApiConstants.userSearch,
      queryParameters: {'q': query, 'limit': limit},
    );
    final data = response.data as List<dynamic>? ?? const [];
    return data
        .map((e) => UserSearchResult.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ChatDetails> getChatDetails(String chatId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.chats}/$chatId',
    );
    return ChatDetails.fromJson(response.data!);
  }

  @override
  Future<ChatDetails> createDirectChat(String userId) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.directChat,
      data: {'recipientUserId': userId},
    );
    return ChatDetails.fromJson(response.data!);
  }

  @override
  Future<ChatDetails> createGroupChat(
    String title,
    List<String> memberUserIds,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.groupChat,
      data: {
        'title': title,
        if (memberUserIds.isNotEmpty) 'memberUserIds': memberUserIds,
      },
    );
    return ChatDetails.fromJson(response.data!);
  }
}
