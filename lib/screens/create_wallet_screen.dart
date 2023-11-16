import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:d_allegro/providers/wallet_provider.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({Key? key, required Null Function(dynamic credentials) onCreateWallet}) : super(key: key);

  @override
  _CreateWalletScreenState createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  
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

      // TODO: endpoint for saving wallet address

      Navigator.pop(context);
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
              onPressed: () => copyToClipboard(),
              icon: const Icon(Icons.copy),
              label: const Text('Copy to clipboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                textStyle: const TextStyle(fontSize: 20.0),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}