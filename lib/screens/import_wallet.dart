import 'dart:convert';

import 'package:d_allegro/http_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:d_allegro/providers/wallet_provider.dart';
import 'package:web3dart/web3dart.dart';

class ImportWallet extends StatefulWidget {
  const ImportWallet({Key? key}) : super(key: key);

  @override
  _ImportWalletState createState() => _ImportWalletState();
}

class _ImportWalletState extends State<ImportWallet> {
  bool isVerified = false;
  String verificationText = '';

  Future<void> showWalletErrorDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cannot import wallet'),
          content:
              const Text('There was a problem with importing wallet. Try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void navigateToSettings() {
    Navigator.pushReplacementNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    void verifyMnemonic() async {
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);

      final privateKey = await walletProvider.getPrivateKey(verificationText);
      EthereumAddress address = await walletProvider.getPublicKey(privateKey);

      final response = await dio.post(
        '$apiURL/update_wallet_address',
        data: jsonEncode({
          'walletAddress': address.hex,
        }),
      );

      if (response.statusCode == 200) {
        navigateToSettings();
      } else {
        if (context.mounted) {
          showWalletErrorDialog(context);
        }
      }      
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Import from Seed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please Enter your mnemonic phrase:',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 24.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  verificationText = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter mnemonic phrase',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: verifyMnemonic,
              child: const Text('Import'),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}