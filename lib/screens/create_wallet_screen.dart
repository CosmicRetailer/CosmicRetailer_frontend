import 'dart:convert';

import 'package:d_allegro/http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:d_allegro/providers/wallet_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

class CreateWalletScreen extends StatefulWidget {
  final ValueChanged<void> onCreateWallet;
  final String nickname;
  const CreateWalletScreen({Key? key, required this.onCreateWallet, required this.nickname}) : super(key: key);

  @override
  _CreateWalletScreenState createState() => _CreateWalletScreenState(nickname);
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  String walletAddress = '';
  String nickname = '';
  
  _CreateWalletScreenState(this.nickname);

  Future<void> showWalletErrorDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cannot create wallet'),
          content:
              const Text('There was a problem with creating wallet. Try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/createWallet');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final mnemonic = walletProvider.generateMnemonic();
    final mnemonicWords = mnemonic.split(' ');

    Future<void> copyToClipboard() async {
      Clipboard.setData(ClipboardData(text: mnemonic));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mnemonic has been copied to clipboard'),
        ),
      );

      walletProvider.getPrivateKey(mnemonic).then((privateKey) async {
        EthereumAddress address = await walletProvider.getPublicKey(privateKey);
        setState(() {
          walletAddress = address.hex;
        });

        print('Wallet address: $walletAddress');
        print('Nickname: $nickname');
        print('Mnemonic: $mnemonic');
        final response = await http.post(
          Uri.parse('$apiURL/set_wallet_address'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            'nickname': nickname,
            'walletAddress': walletAddress,
          }),
        );

        if (response.statusCode == 200) {
          widget.onCreateWallet(null);
        } else {
          if (context.mounted) {
            showWalletErrorDialog(context);
          }
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Mnemonic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please save the following mnemonic words in a safe place:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 24.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                mnemonicWords.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${index + 1}. ${mnemonicWords[index]}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () {
                copyToClipboard();
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy to clipboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                textStyle: const TextStyle(fontSize: 21.0),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}