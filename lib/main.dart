import 'package:d_allegro/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wallet_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the private key
  final walletProvider = WalletProvider();
  walletProvider.loadPrivateKey();

  runApp(
    ChangeNotifierProvider<WalletProvider>.value(
      value: walletProvider,
      child: const CosmicRetailer(),
    )
  );
}
