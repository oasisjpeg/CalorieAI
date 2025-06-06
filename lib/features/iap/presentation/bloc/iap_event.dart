import 'package:equatable/equatable.dart';

abstract class IAPEvent extends Equatable {
  const IAPEvent();

  @override
  List<Object?> get props => [];
}

class LoadIAPStatus extends IAPEvent {
  const LoadIAPStatus();
}

class PurchaseProduct extends IAPEvent {
  final String productId;
  
  const PurchaseProduct(this.productId);
  
  @override
  List<Object?> get props => [productId];
}

class RestorePurchases extends IAPEvent {
  const RestorePurchases();
}

class CheckAnalysisAccess extends IAPEvent {
  const CheckAnalysisAccess();
}

class RecordAnalysisPerformed extends IAPEvent {
  const RecordAnalysisPerformed();
}

class CheckRecipeFinderAccess extends IAPEvent {
  const CheckRecipeFinderAccess();
}

class ResetAnalysisCounter extends IAPEvent {
  const ResetAnalysisCounter();
}
