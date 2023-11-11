import 'package:flutter/widgets.dart';

/// A mock authentication service
class CosmicRetailerAuth extends ChangeNotifier {
  bool _signedIn = false;
  String _token = '';
  bool get signedIn => _signedIn;
  String get token => _token;

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _signedIn = false;
    notifyListeners();
  }

  Future<bool> signIn(String username, String password, String tokenac) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _token = tokenac;
    _signedIn = true;
    notifyListeners();
    return _signedIn;
  }

  @override
  bool operator ==(Object other) =>
      other is CosmicRetailerAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}

class CosmicRetailerAuthScope extends InheritedNotifier<CosmicRetailerAuth> {
  const CosmicRetailerAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static CosmicRetailerAuth of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CosmicRetailerAuthScope>()!
      .notifier!;
}
