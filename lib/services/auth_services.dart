import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AuthException implements Exception {
  String msg;
  AuthException(this.msg);
}

class AuthServices extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool isLoading = true;

  AuthServices() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  registrar(String mail, String pass) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: mail, password: pass);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('Fallo Pass');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Email ya en uso');
      }
    }
  }

  login(String mail, String pass) async {
    try {
      await _auth.signInWithEmailAndPassword(email: mail, password: pass);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Email no encontrado. Registrate!');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Incorrecto. Intenta nuevamente!');
      }
    }
  }

  logout() async {
    await _auth.signOut();
    _getUser();
  }
}
