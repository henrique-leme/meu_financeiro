import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../common/data/data_result.dart';
import '../common/data/data_exceptions.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService()
      : _auth = FirebaseAuth.instance,
        _functions = FirebaseFunctions.instance;

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  @override
  Future<DataResult<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        return DataResult.success(_createUserModelFromAuthUser(result.user!));
      }

      return DataResult.failure(const GeneralException());
    } on FirebaseAuthException catch (e) {
      return DataResult.failure(AuthException(code: e.code));
    }
  }

  @override
  Future<DataResult<UserModel>> signUp({
    String? name,
    required String email,
    required String password,
  }) async {
    try {
      await _functions.httpsCallable('registerUser').call({
        "email": email,
        "password": password,
        "displayName": name,
      });

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        return DataResult.success(_createUserModelFromAuthUser(result.user!));
      }

      return DataResult.failure(const GeneralException());
    } on FirebaseAuthException catch (e) {
      return DataResult.failure(AuthException(code: e.code));
    } on FirebaseFunctionsException catch (e) {
      return DataResult.failure(AuthException(code: e.code));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DataResult<String>> userToken() async {
    try {
      final token = await _auth.currentUser?.getIdToken();

      return DataResult.success(token ?? '');
    } catch (e) {
      return DataResult.success('');
    }
  }

  UserModel _createUserModelFromAuthUser(User user) {
    return UserModel(
      name: user.displayName,
      email: user.email,
      id: user.uid,
    );
  }

  Future<String?> getCurrentUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.displayName;
    }
    return null;
  }

  Future<String?> getCurrrentUserEmail() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.email;
    }
    return null;
  }
}
