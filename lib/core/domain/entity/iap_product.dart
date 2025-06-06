import 'package:equatable/equatable.dart';

class IAPProduct extends Equatable {
  final String id;
  final String title;
  final String description;
  final String price;
  final String currencyCode;
  final double rawPrice;

  const IAPProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.rawPrice,
  });

  @override
  List<Object> get props => [id, title, description, price, currencyCode, rawPrice];
}
