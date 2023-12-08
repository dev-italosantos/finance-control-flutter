import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_investment_control/models/asset_model.dart';
import 'package:provider/provider.dart';

class AssetProvider extends ChangeNotifier {
  List<Asset> _assets = [];
  List<Asset> get assets => _assets;
  Asset? selectedAsset;


  void addAsset(Asset asset) {
    _assets.add(asset);
    notifyListeners();
  }

  void updateAssets(List<Asset> updatedAssets) {
    _assets = List.from(updatedAssets);
    notifyListeners();
  }

  void removeAsset(Asset asset) {
    _assets.remove(asset);
    notifyListeners();
  }

  Asset? findAssetByTicker(String ticker) {
    return assets.firstWhereOrNull((asset) => asset.ticker == ticker);
  }

  void setSelectedAsset(Asset? asset) {
    selectedAsset = asset;
    notifyListeners();
  }
  // Adicione outros métodos conforme necessário

  static AssetProvider of(BuildContext context, {bool listen = false}) {
    return Provider.of<AssetProvider>(context, listen: listen);
  }
}
