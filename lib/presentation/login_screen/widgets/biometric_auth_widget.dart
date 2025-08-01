import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/app_export.dart';

class BiometricAuthWidget extends StatelessWidget {
  final VoidCallback onBiometricAuth;
  final bool isLoading;

  const BiometricAuthWidget({
    super.key,
    required this.onBiometricAuth,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show biometric options on web
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Biometric Header
          Text(
            'Quick Medical Access',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Use biometric authentication for faster secure access',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Biometric Options Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Face ID / Touch ID for iOS
              if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                _BiometricButton(
                  iconName: 'face',
                  label: 'Face ID',
                  onPressed: isLoading ? null : onBiometricAuth,
                  context: context,
                ),
                _BiometricButton(
                  iconName: 'fingerprint',
                  label: 'Touch ID',
                  onPressed: isLoading ? null : onBiometricAuth,
                  context: context,
                ),
              ],
              
              // Fingerprint for Android
              if (Theme.of(context).platform == TargetPlatform.android) ...[
                _BiometricButton(
                  iconName: 'fingerprint',
                  label: 'Fingerprint',
                  onPressed: isLoading ? null : onBiometricAuth,
                  context: context,
                ),
                _BiometricButton(
                  iconName: 'face',
                  label: 'Face Unlock',
                  onPressed: isLoading ? null : onBiometricAuth,
                  context: context,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          // HIPAA Compliance Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'privacy_tip',
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Biometric data secured with medical-grade encryption',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BiometricButton extends StatelessWidget {
  final String iconName;
  final String label;
  final VoidCallback? onPressed;
  final BuildContext context;

  const _BiometricButton({
    required this.iconName,
    required this.label,
    required this.onPressed,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: onPressed != null 
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onPressed != null
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onPressed,
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  size: 28,
                  color: onPressed != null
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: onPressed != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}