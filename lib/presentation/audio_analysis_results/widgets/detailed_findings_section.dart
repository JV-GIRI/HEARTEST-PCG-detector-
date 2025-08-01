import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DetailedFindingsSection extends StatefulWidget {
  final List<Map<String, dynamic>> findings;

  const DetailedFindingsSection({
    Key? key,
    required this.findings,
  }) : super(key: key);

  @override
  State<DetailedFindingsSection> createState() =>
      _DetailedFindingsSectionState();
}

class _DetailedFindingsSectionState extends State<DetailedFindingsSection> {
  final Set<int> _expandedItems = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Findings',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.findings.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final finding = widget.findings[index];
              final isExpanded = _expandedItems.contains(index);

              return _buildFindingCard(finding, index, isExpanded);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFindingCard(
      Map<String, dynamic> finding, int index, bool isExpanded) {
    final title = finding['title'] as String? ?? '';
    final confidence = (finding['confidence'] as double? ?? 0.0);
    final status = finding['status'] as String? ?? 'normal';
    final description = finding['description'] as String? ?? '';
    final normalRange = finding['normalRange'] as String? ?? '';
    final currentValue = finding['currentValue'] as String? ?? '';

    Color statusColor = _getStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded
                    ? _expandedItems.remove(index)
                    : _expandedItems.add(index);
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getStatusIcon(status),
                      color: statusColor,
                      size: 5.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Text(
                              'Confidence: ',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            Text(
                              '${confidence.toInt()}%',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      description,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 2.h),
                  ],
                  if (currentValue.isNotEmpty || normalRange.isNotEmpty) ...[
                    Row(
                      children: [
                        if (currentValue.isNotEmpty) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Value',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  currentValue,
                                  style: AppTheme.lightTheme.textTheme.bodyLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (normalRange.isNotEmpty) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Normal Range',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  normalRange,
                                  style: AppTheme.lightTheme.textTheme.bodyLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'abnormal':
      case 'critical':
        return AppTheme.lightTheme.colorScheme.error;
      case 'warning':
      case 'borderline':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'normal':
      case 'healthy':
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'abnormal':
      case 'critical':
        return 'error';
      case 'warning':
      case 'borderline':
        return 'warning';
      case 'normal':
      case 'healthy':
      default:
        return 'check_circle';
    }
  }
}
