import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/asset_model.dart';
import 'package:provider/provider.dart';

class AssetProvider extends ChangeNotifier {
  List<Asset> _assets = [];
  List<Asset> get assets => _assets;
  Asset? selectedAsset;

  void updateAssets(List<Asset> newAssets) {
    _assets = List.from(newAssets);
    notifyListeners();
  }

  void removeAsset(Asset asset) {
    _assets.remove(asset);
    notifyListeners();
  }

  static AssetProvider of(BuildContext context, {bool listen = false}) {
    return Provider.of<AssetProvider>(context, listen: listen);
  }
}
