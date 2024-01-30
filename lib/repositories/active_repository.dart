import 'package:flutter_investment_control/core/app_icons.dart';
import 'package:flutter_investment_control/models/active_model.dart';

class ActiveRepository {
  static List<Active> tabela = [
    Active(
      icon: AppIcons.btc,
      name: 'Bitcoin',
      acronym: 'BTC',
      price: 22777,
    ),
    Active(
      icon: AppIcons.btc,
      name: 'Ethereum',
      acronym: 'ETH',
      price: 2095,
    ),
    Active(
      icon: AppIcons.btc,
      name: 'Polygon',
      acronym: 'MATIC',
      price: 0.807449,
    ),
    Active(
      icon: AppIcons.btc,
      name: 'Solana',
      acronym: 'SOL',
      price: 61.75,
    ),
    Active(
      icon: AppIcons.btc,
      name: 'Chainlink',
      acronym: 'LINK',
      price: 15.30,
    )
  ];
}
