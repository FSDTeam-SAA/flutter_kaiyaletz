import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/key_constants.dart';
import '../common/models/session_status.dart';

/// One saved login, used for the multi-account switcher.
class StoredAccount {
  final String userId;
  final String accessToken;
  final String refreshToken;
  final String role;
  final String firstName;
  final String lastName;
  final String profileImage;
  final String username;
  final String email;

  const StoredAccount({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    this.firstName = '',
    this.lastName = '',
    this.profileImage = '',
    this.username = '',
    this.email = '',
  });

  factory StoredAccount.fromJson(Map<String, dynamic> json) => StoredAccount(
    userId: json['userId'] ?? '',
    accessToken: json['accessToken'] ?? '',
    refreshToken: json['refreshToken'] ?? '',
    role: json['role'] ?? '',
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    profileImage: json['profileImage'] ?? '',
    username: json['username'] ?? '',
    email: json['email'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'role': role,
    'firstName': firstName,
    'lastName': lastName,
    'profileImage': profileImage,
    'username': username,
    'email': email,
  };
}

/// Secure-storage wrapper for tokens + the current user's basic info.
/// Also supports keeping several logged-in accounts and switching between
/// them without re-entering credentials (drop this if you don't need it —
/// only [storeAuthData]/[getAccessToken]/[getRefreshToken]/[clearAuthData]
/// are used by [ApiClient]).
class AuthStorageService {
  final FlutterSecureStorage _secureStorage;

  AuthStorageService({FlutterSecureStorage? storage})
    : _secureStorage = storage ?? const FlutterSecureStorage();

  Future<void> storeAuthData(StoredAccount account) async {
    await Future.wait([
      _secureStorage.write(
        key: KeyConst.accessToken,
        value: account.accessToken,
      ),
      _secureStorage.write(
        key: KeyConst.refreshToken,
        value: account.refreshToken,
      ),
      _secureStorage.write(key: KeyConst.userId, value: account.userId),
      _secureStorage.write(key: KeyConst.role, value: account.role),
      _secureStorage.write(
        key: KeyConst.profileImage,
        value: account.profileImage,
      ),
      _secureStorage.write(key: KeyConst.firstName, value: account.firstName),
      _secureStorage.write(key: KeyConst.lastName, value: account.lastName),
      _secureStorage.write(key: KeyConst.username, value: account.username),
      _secureStorage.write(key: KeyConst.email, value: account.email),
    ]);

    await saveAccountToList(
      StoredAccount(
        userId: account.userId,
        accessToken: account.accessToken,
        refreshToken: account.refreshToken,
        role: account.role,
        firstName: account.firstName,
        lastName: account.lastName,
        profileImage: account.profileImage,
        username: account.username,
        email: account.email,
      ),
    );
  }

  // --- Multi-account management -----------------------------------------

  Future<void> saveAccountToList(StoredAccount account) async {
    final accounts = await getAccountsList();
    final index = accounts.indexWhere((a) => a.userId == account.userId);
    if (index != -1) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    await _secureStorage.write(
      key: KeyConst.accountsList,
      value: jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );
  }

  Future<List<StoredAccount>> getAccountsList() async {
    final jsonString = await _secureStorage.read(key: KeyConst.accountsList);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final list = jsonDecode(jsonString) as List;
      final accounts = list.map((j) => StoredAccount.fromJson(j)).toList();
      return accounts;
    } catch (_) {
      return [];
    }
  }

  Future<void> switchAccount(String userId) async {
    final accounts = await getAccountsList();
    final account = accounts.firstWhere((a) => a.userId == userId);
    await Future.wait([
      _secureStorage.write(
        key: KeyConst.accessToken,
        value: account.accessToken,
      ),
      _secureStorage.write(
        key: KeyConst.refreshToken,
        value: account.refreshToken,
      ),
      _secureStorage.write(key: KeyConst.userId, value: account.userId),
      _secureStorage.write(key: KeyConst.role, value: account.role),
      _secureStorage.write(
        key: KeyConst.profileImage,
        value: account.profileImage,
      ),
      _secureStorage.write(key: KeyConst.firstName, value: account.firstName),
      _secureStorage.write(key: KeyConst.lastName, value: account.lastName),
      _secureStorage.write(key: KeyConst.username, value: account.username),
      _secureStorage.write(key: KeyConst.email, value: account.email),
    ]);
  }

  /// Returns true if the removed account was the currently active one
  /// (caller should then log out / route to the login screen).
  Future<bool> removeAccount(String userId) async {
    final accounts = await getAccountsList();
    final updated = accounts.where((a) => a.userId != userId).toList();
    await _secureStorage.write(
      key: KeyConst.accountsList,
      value: jsonEncode(updated.map((a) => a.toJson()).toList()),
    );
    return await getUserId() == userId;
  }

  // --- Single fields ------------------------------------------------------

  Future<void> storeAccessToken({required String accessToken}) =>
      _secureStorage.write(key: KeyConst.accessToken, value: accessToken);

  Future<void> storeRefreshToken({required String refreshToken}) =>
      _secureStorage.write(key: KeyConst.refreshToken, value: refreshToken);

  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    final role = await _secureStorage.read(key: KeyConst.role);
    return accessToken != null &&
        accessToken.isNotEmpty &&
        role != null &&
        role.isNotEmpty;
  }

  Future<String?> getAccessToken() =>
      _secureStorage.read(key: KeyConst.accessToken);

  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: KeyConst.refreshToken);

  Future<String?> getUserId() => _secureStorage.read(key: KeyConst.userId);

  Future<String?> getFirstName() =>
      _secureStorage.read(key: KeyConst.firstName);

  Future<String?> getLastName() => _secureStorage.read(key: KeyConst.lastName);

  Future<String?> getUsername() => _secureStorage.read(key: KeyConst.username);

  Future<String?> getProfileImage() =>
      _secureStorage.read(key: KeyConst.profileImage);

  Future<String?> getEmail() => _secureStorage.read(key: KeyConst.email);

  Future<void> updateBasicInfo({
    required String firstName,
    required String lastName,
    String? profileImage,
  }) async {
    await Future.wait([
      _secureStorage.write(key: KeyConst.firstName, value: firstName),
      _secureStorage.write(key: KeyConst.lastName, value: lastName),
      if (profileImage != null)
        _secureStorage.write(key: KeyConst.profileImage, value: profileImage),
    ]);
  }

  Future<void> clearAuthData() async {
    await Future.wait([
      _secureStorage.delete(key: KeyConst.accessToken),
      _secureStorage.delete(key: KeyConst.refreshToken),
      _secureStorage.delete(key: KeyConst.userId),
      _secureStorage.delete(key: KeyConst.role),
    ]);
  }

  Future<bool> hasStoredAccounts() async =>
      (await getAccountsList()).isNotEmpty;
  Future<bool> hasAccessToken() async =>
      (await getAccessToken())?.isNotEmpty ?? false;
  Future<bool> hasRefreshToken() async =>
      (await getRefreshToken())?.isNotEmpty ?? false;

  Future<SessionStatus> currentSessionStatus() async {
    final hasAccess = await hasAccessToken();
    final hasRefresh = await hasRefreshToken();
    if (!hasAccess && !hasRefresh) return .guest;
    if (hasAccess || hasRefresh) {
      return .authenticated; // trust it until proven otherwise
    }
    return .expired;
  }
}
