import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FileSelectionBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> selectedFiles;
  final VoidCallback onClearSelection;
  final VoidCallback onUpload;
  final bool isUploading;
  final double uploadProgress;

  const FileSelectionBottomSheet({
    Key? key,
    required this.selectedFiles,
    required this.onClearSelection,
    required this.onUpload,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedFiles.isEmpty && !isUploading) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            SizedBox(height: 2.h),
            if (isUploading) ...[
              _buildUploadProgress(context),
            ] else ...[
              _buildSelectionHeader(context),
              SizedBox(height: 2.h),
              _buildSelectedFilesList(context),
              SizedBox(height: 2.h),
              _buildActionButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 12.w,
      height: 0.5.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSelectionHeader(BuildContext context) {
    final totalSize = _calculateTotalSize();

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.lightTheme.primaryColor,
            size: 5.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedFiles.length} file${selectedFiles.length > 1 ? 's' : ''} selected',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Total size: $totalSize',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onClearSelection,
          child: Text(
            'Clear',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFilesList(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 20.h),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: selectedFiles.length,
        separatorBuilder: (context, index) => SizedBox(height: 1.h),
        itemBuilder: (context, index) {
          final file = selectedFiles[index];
          return _buildSelectedFileItem(context, file);
        },
      ),
    );
  }

  Widget _buildSelectedFileItem(
      BuildContext context, Map<String, dynamic> file) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomIconWidget(
              iconName: 'audiotrack',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['name'],
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      file['duration'],
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '•',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      file['size'],
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (file['quality'] == 'high')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'HD',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onClearSelection,
            child: Text('Cancel'),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: selectedFiles.isNotEmpty ? onUpload : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'upload',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                    'Upload ${selectedFiles.length} file${selectedFiles.length > 1 ? 's' : ''}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadProgress(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'cloud_upload',
                color: AppTheme.lightTheme.primaryColor,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uploading files...',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(uploadProgress * 100).toInt()}% complete',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        LinearProgressIndicator(
          value: uploadProgress,
          backgroundColor:
              AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          valueColor:
              AlwaysStoppedAnimation<Color>(AppTheme.lightTheme.primaryColor),
        ),
        SizedBox(height: 2.h),
        Text(
          'Please don\'t close the app while uploading',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _calculateTotalSize() {
    double totalMB = 0.0;
    for (final file in selectedFiles) {
      final sizeStr = file['size'] as String;
      final sizeValue =
          double.tryParse(sizeStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      totalMB += sizeValue;
    }
    return '${totalMB.toStringAsFixed(1)} MB';
  }
}
