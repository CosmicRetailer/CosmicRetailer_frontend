import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:hex/hex.dart';
import 'package:flutter/foundation.dart';

abstract class WalletAddressService {
  String generateMnemonic();
  Future<String> getPrivateKey(String mnemonic);
  Future<EthereumAddress> getPublicKey(String privateKey);
}

class WalletProvider extends ChangeNotifier implements WalletAddressService {

  String? privateKey;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> loadPrivateKey() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // privateKey = prefs.getString('privateKey');
    privateKey = await _secureStorage.read(key: 'privateKey');
  }

  Future<void> setPrivateKey(String privateKey) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('privateKey', privateKey);
    // notifyListeners();
    await _secureStorage.write(key: 'privateKey', value: privateKey);
    notifyListeners();
  }

  Future<void> deletePrivateKey() async {
    await _secureStorage.delete(key: 'privateKey');
    notifyListeners();
  }

  @override
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  @override
  Future<String> getPrivateKey(String mnemonic) async {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final master = await ED25519_HD_KEY.getMasterKeyFromSeed(seed);
    final privateKey = HEX.encode(master.key);

    await setPrivateKey(privateKey);
    
    return privateKey;
  }

  @override
  Future<EthereumAddress> getPublicKey(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.address;
    return address;
  }
}