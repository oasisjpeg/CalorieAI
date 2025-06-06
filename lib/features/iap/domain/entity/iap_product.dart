class IAPProduct {
  final String id;
  final String price;
  final String currencyCode;
  final double rawPrice;

  const IAPProduct({
    required this.id,
    required this.price,
    required this.currencyCode,
    required this.rawPrice,
  });

  @override
  String toString() => 'IAPProduct(id: $id, price: $price)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IAPProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
