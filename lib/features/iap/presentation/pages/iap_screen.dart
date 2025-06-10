import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/core/domain/entity/iap_product.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_event.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_state.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class IAPScreen extends StatelessWidget {
  const IAPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).upgradeToPremium),
        elevation: 0,
      ),
      body: BlocConsumer<IAPBloc, IAPState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFeatureList(),
                const SizedBox(height: 24),
                _buildSubscriptionCard(context, state),
                const SizedBox(height: 24),
                _buildRestoreButton(context),
                const SizedBox(height: 16),
                _buildTermsText(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).unlockPremiumFeatures,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).getUnlimitedAccessToAllFeatures,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    return Builder(
      builder: (context) {
        final features = [
          S.of(context).unlimitedFoodAnalysis,
          S.of(context).accessToRecipeFinder,
          S.of(context).noAds,
          S.of(context).prioritySupport,
        ];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).premiumFeatures,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ...features.map((feature) => _buildFeatureItem(feature)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, IAPState state) {
    final hasProducts = state.availableProducts.isNotEmpty;
    final isPurchasing = state.isPurchasing;
    final isPremium = state.hasPremiumAccess;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).premium,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isPremium)
              _buildPremiumActive()
            else if (hasProducts)
              _buildPurchaseButton(context, state.availableProducts.first)
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 8),
            if (!isPremium)
              Text(
                S.of(context).cancelAnytime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(BuildContext context, IAPProduct product) {
    final isPurchasing = context.select<IAPBloc, bool>((bloc) => bloc.state.isPurchasing);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isPurchasing
            ? null
            : () => context.read<IAPBloc>().add(PurchaseProduct(product.id)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isPurchasing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                '${S.of(context).subscribeFor} ${product.price}/month',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumActive() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              S.of(context).premiumActive,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.read<IAPBloc>().add(const RestorePurchases()),
        child: Text(
          S.of(context).restorePurchases,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          S.of(context).subscriptionTerms,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
        ),
      ),
    );
  }
}
