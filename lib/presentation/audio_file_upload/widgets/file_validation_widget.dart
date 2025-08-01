import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FileValidationWidget extends StatelessWidget {
  final List<Map<String, dynamic>> validationResults;
  final VoidCallback onDismiss;

  const FileValidationWidget({
    Key? key,
    required this.validationResults,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (validationResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 2.h),
          ..._buildValidationItems(context),
          SizedBox(height: 2.h),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hasErrors =
        validationResults.any((result) => result['type'] == 'error');
    final hasWarnings =
        validationResults.any((result) => result['type'] == 'warning');

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: _getHeaderColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: hasErrors
                ? 'error'
                : hasWarnings
                    ? 'warning'
                    : 'check_circle',
            color: _getHeaderColor(),
            size: 5.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasErrors
                    ? 'File Validation Failed'
                    : hasWarnings
                        ? 'File Quality Warning'
                        : 'Files Validated',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getHeaderColor(),
                ),
              ),
              Text(
                '${validationResults.length} issue${validationResults.length > 1 ? 's' : ''} found',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onDismiss,
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 4.w,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildValidationItems(BuildContext context) {
    return validationResults
        .map((result) => _buildValidationItem(context, result))
        .toList();
  }

  Widget _buildValidationItem(
      BuildContext context, Map<String, dynamic> result) {
    final isError = result['type'] == 'error';
    final isWarning = result['type'] == 'warning';

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _getItemBackgroundColor(result['type']),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getItemBorderColor(result['type']),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: isError
                ? 'error_outline'
                : isWarning
                    ? 'warning_amber'
                    : 'info_outline',
            color: _getItemIconColor(result['type']),
            size: 4.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['fileName'] ?? 'Unknown file',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  result['message'] ?? 'Validation issue detected',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (result['suggestion'] != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    'Suggestion: ${result['suggestion']}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getItemIconColor(result['type']),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final hasErrors =
        validationResults.any((result) => result['type'] == 'error');

    return SizedBox(
      width: double.infinity,
      child: hasErrors
          ? OutlinedButton(
              onPressed: onDismiss,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightTheme.colorScheme.error,
                side: BorderSide(color: AppTheme.lightTheme.colorScheme.error),
              ),
              child: Text('Fix Issues Before Upload'),
            )
          : ElevatedButton(
              onPressed: onDismiss,
              child: Text('Continue with Upload'),
            ),
    );
  }

  Color _getBorderColor() {
    final hasErrors =
        validationResults.any((result) => result['type'] == 'error');
    final hasWarnings =
        validationResults.any((result) => result['type'] == 'warning');

    if (hasErrors) return AppTheme.lightTheme.colorScheme.error;
    if (hasWarnings) return AppTheme.lightTheme.colorScheme.tertiary;
    return AppTheme.lightTheme.colorScheme.secondary;
  }

  Color _getHeaderColor() {
    final hasErrors =
        validationResults.any((result) => result['type'] == 'error');
    final hasWarnings =
        validationResults.any((result) => result['type'] == 'warning');

    if (hasErrors) return AppTheme.lightTheme.colorScheme.error;
    if (hasWarnings) return AppTheme.lightTheme.colorScheme.tertiary;
    return AppTheme.lightTheme.colorScheme.secondary;
  }

  Color _getItemBackgroundColor(String type) {
    switch (type) {
      case 'error':
        return AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.05);
      case 'warning':
        return AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.05);
      default:
        return AppTheme.lightTheme.colorScheme.secondary
            .withValues(alpha: 0.05);
    }
  }

  Color _getItemBorderColor(String type) {
    switch (type) {
      case 'error':
        return AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.2);
      case 'warning':
        return AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.2);
      default:
        return AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2);
    }
  }

  Color _getItemIconColor(String type) {
    switch (type) {
      case 'error':
        return AppTheme.lightTheme.colorScheme.error;
      case 'warning':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }
}
