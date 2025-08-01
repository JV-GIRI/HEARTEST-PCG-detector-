import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class MedicalLogoWidget extends StatelessWidget {
  const MedicalLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo with Medical Theme
        Container(
          height: 18.0.h,
          width: 18.0.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'monitor_heart',
              size: 8.0.h,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        
        SizedBox(height: 3.0.h),
        
        // App Title
        Text(
          'CardioScope AI',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        
        SizedBox(height: 1.0.h),
        
        // Medical Subtitle
        Text(
          'Medical-Grade Heart Sound Analysis',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 0.5.h),
        
        // HIPAA Compliance Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.0.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'verified_user',
                size: 4.0.w,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(width: 1.0.w),
              Text(
                'HIPAA Compliant',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}