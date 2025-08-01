import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class StorageUsageWidget extends StatelessWidget {
  final Map<String, dynamic> storageData;

  const StorageUsageWidget({
    Key? key,
    required this.storageData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double usedPercentage =
        (storageData["usedGB"] as double) / (storageData["totalGB"] as double);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Storage Usage",
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${(storageData["usedGB"] as double).toStringAsFixed(1)} GB / ${(storageData["totalGB"] as double).toStringAsFixed(0)} GB",
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 1.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.dividerColor,
              borderRadius: BorderRadius.circular(0.5.h),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: usedPercentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: usedPercentage > 0.8
                      ? AppTheme.getWarningColor(true)
                      : AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(0.5.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStorageItem(
                  "Audio Files",
                  "${(storageData["audioFilesGB"] as double).toStringAsFixed(1)} GB",
                  AppTheme.lightTheme.primaryColor,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStorageItem(
                  "Analysis Data",
                  "${(storageData["analysisDataGB"] as double).toStringAsFixed(1)} GB",
                  AppTheme.getSuccessColor(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Padding(
          padding: EdgeInsets.only(left: 5.w),
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
