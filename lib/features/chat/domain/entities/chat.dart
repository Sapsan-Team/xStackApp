class ChatSummary {
  const ChatSummary({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.currentUserRole,
    this.title,
    this.avatarUrl,
    this.lastMessage,
    this.unreadCount = 0,
    this.otherMemberId,
    this.otherMemberUsername,
    this.otherMemberPhone,
    this.otherMemberDisplayName,
  });

  final String id;
  final String type;
  final String? title;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String currentUserRole;
  final ChatLastMessage? lastMessage;
  final int unreadCount;
  final String? otherMemberId;
  final String? otherMemberUsername;
  final String? otherMemberPhone;
  final String? otherMemberDisplayName;

  bool get isGroup => type == 'group' || type == 'channel';

  String get displayName {
    if (title != null && title!.trim().isNotEmpty) return title!;
    if (otherMemberDisplayName != null &&
        otherMemberDisplayName!.trim().isNotEmpty) {
      return otherMemberDisplayName!;
    }
    if (otherMemberUsername != null && otherMemberUsername!.trim().isNotEmpty) {
      return otherMemberUsername!;
    }
    if (otherMemberPhone != null && otherMemberPhone!.trim().isNotEmpty) {
      return otherMemberPhone!;
    }
    return 'untitled';
  }

  /// What the sidebar prints before the name: "#" for groups, "@" for people.
  String get sigil => isGroup ? '#' : '@';

  String get handle {
    if (isGroup) return title ?? 'untitled';
    if (otherMemberUsername != null && otherMemberUsername!.isNotEmpty) {
      return '@${otherMemberUsername!}';
    }
    return otherMemberPhone ?? 'direct';
  }

  ChatSummary copyWith({
    String? title,
    ChatLastMessage? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return ChatSummary(
      id: id,
      type: type,
      title: title ?? this.title,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentUserRole: currentUserRole,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      otherMemberId: otherMemberId,
      otherMemberUsername: otherMemberUsername,
      otherMemberPhone: otherMemberPhone,
      otherMemberDisplayName: otherMemberDisplayName,
    );
  }

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'private',
      title: json['title'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      currentUserRole: json['currentUserRole'] as String? ?? 'member',
      lastMessage: json['lastMessage'] == null
          ? null
          : ChatLastMessage.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            ),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      otherMemberId: json['otherMemberId'] as String?,
      otherMemberUsername: json['otherMemberUsername'] as String?,
      otherMemberPhone: json['otherMemberPhone'] as String?,
      otherMemberDisplayName: json['otherMemberDisplayName'] as String?,
    );
  }
}

class ChatLastMessage {
  const ChatLastMessage({
    required this.id,
    required this.createdAt,
    required this.isRead,
    required this.isDeleted,
    this.senderId,
    this.senderName,
    this.content,
  });

  final String id;
  final String? senderId;
  final String? senderName;
  final String? content;
  final DateTime createdAt;
  final bool isRead;
  final bool isDeleted;

  factory ChatLastMessage.fromJson(Map<String, dynamic> json) {
    return ChatLastMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.createdAt,
    required this.updatedAt,
    required this.isRead,
    required this.isEdited,
    required this.isDeleted,
    required this.isMine,
    this.senderId,
    this.senderName,
    this.senderUsername,
    this.content,
    this.isPending = false,
  });

  final String id;
  final String chatId;
  final String? senderId;
  final String? senderName;
  final String? senderUsername;
  final String? content;
  final bool isRead;
  final bool isEdited;
  final bool isDeleted;
  final bool isMine;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Optimistically rendered messages use a deterministic local id and are
  /// replaced with the server copy when the request completes.
  final bool isPending;

  ChatMessage copyWith({
    Object? content = _unset,
    bool? isRead,
    bool? isEdited,
    bool? isDeleted,
    bool? isMine,
    DateTime? updatedAt,
  }) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderUsername: senderUsername,
      content: content == _unset ? this.content : content as String?,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      isMine: isMine ?? this.isMine,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPending: isPending,
    );
  }

  String get authorName {
    final name = senderName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final username = senderUsername?.trim();
    if (username != null && username.isNotEmpty) return username;
    return isMine ? 'you' : 'user';
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      senderUsername: json['senderUsername'] as String?,
      content: json['content'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isEdited: json['isEdited'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isMine: json['isMine'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory ChatMessage.pending({
    required String chatId,
    required String content,
    required DateTime createdAt,
    String? senderName,
  }) {
    return ChatMessage(
      id: 'pending-$createdAt',
      chatId: chatId,
      content: content,
      isRead: false,
      isEdited: false,
      isDeleted: false,
      isMine: true,
      isPending: true,
      senderName: senderName,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}

class ChatMember {
  const ChatMember({
    required this.userId,
    required this.phoneNumber,
    required this.role,
    required this.joinedAt,
    this.username,
    this.displayName,
  });

  final String userId;
  final String phoneNumber;
  final String role;
  final DateTime joinedAt;
  final String? username;
  final String? displayName;

  String get name {
    final display = displayName?.trim();
    if (display != null && display.isNotEmpty) return display;
    final user = username?.trim();
    if (user != null && user.isNotEmpty) return user;
    return phoneNumber;
  }

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      userId: json['userId'] as String,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}

class ChatDetails {
  const ChatDetails({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.currentUserRole,
    required this.members,
    this.title,
    this.avatarUrl,
    this.otherMemberId,
    this.otherMemberUsername,
    this.otherMemberPhone,
    this.otherMemberDisplayName,
  });

  final String id;
  final String type;
  final String? title;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String currentUserRole;
  final List<ChatMember> members;
  final String? otherMemberId;
  final String? otherMemberUsername;
  final String? otherMemberPhone;
  final String? otherMemberDisplayName;

  bool get isGroup => type == 'group' || type == 'channel';

  String get displayName {
    if (title != null && title!.trim().isNotEmpty) return title!;
    if (otherMemberDisplayName != null &&
        otherMemberDisplayName!.trim().isNotEmpty) {
      return otherMemberDisplayName!;
    }
    if (otherMemberUsername != null && otherMemberUsername!.isNotEmpty) {
      return otherMemberUsername!;
    }
    return otherMemberPhone ?? 'untitled';
  }

  factory ChatDetails.fromJson(Map<String, dynamic> json) {
    return ChatDetails(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'private',
      title: json['title'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      currentUserRole: json['currentUserRole'] as String? ?? 'member',
      members: (json['members'] as List<dynamic>? ?? [])
          .map((e) => ChatMember.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      otherMemberId: json['otherMemberId'] as String?,
      otherMemberUsername: json['otherMemberUsername'] as String?,
      otherMemberPhone: json['otherMemberPhone'] as String?,
      otherMemberDisplayName: json['otherMemberDisplayName'] as String?,
    );
  }
}

class UserSearchResult {
  const UserSearchResult({
    required this.id,
    required this.phoneNumber,
    this.username,
    this.displayName,
    this.bio,
  });

  final String id;
  final String phoneNumber;
  final String? username;
  final String? displayName;
  final String? bio;

  String get name {
    final display = displayName?.trim();
    if (display != null && display.isNotEmpty) return display;
    final user = username?.trim();
    if (user != null && user.isNotEmpty) return user;
    return phoneNumber;
  }

  String get handle {
    final user = username?.trim();
    if (user != null && user.isNotEmpty) return '@$user';
    return phoneNumber;
  }

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
    );
  }
}

/// Sentinel for [ChatMessage.copyWith] so callers can distinguish "leave the
/// content untouched" from "set the content to null" (soft delete).
const Object _unset = Object();
