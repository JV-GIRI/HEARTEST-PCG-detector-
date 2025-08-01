import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const FilterBottomSheetWidget({
    Key? key,
    required this.currentFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _selectedDateRange = _filters['dateRange'] as DateTimeRange?;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Filter Recordings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Section
                  _buildSectionTitle(context, 'Date Range'),
                  SizedBox(height: 1.h),
                  _buildDateRangeSelector(context, isDark),

                  SizedBox(height: 3.h),

                  // Analysis Status Section
                  _buildSectionTitle(context, 'Analysis Status'),
                  SizedBox(height: 1.h),
                  _buildStatusFilters(context, isDark),

                  SizedBox(height: 3.h),

                  // Confidence Level Section
                  _buildSectionTitle(context, 'Confidence Level'),
                  SizedBox(height: 1.h),
                  _buildConfidenceFilter(context, isDark),

                  SizedBox(height: 3.h),

                  // Abnormality Types Section
                  _buildSectionTitle(context, 'Abnormality Types'),
                  SizedBox(height: 1.h),
                  _buildAbnormalityFilters(context, isDark),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color:
                  isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _selectDateRange,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'date_range',
                size: 20,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  _selectedDateRange != null
                      ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                      : 'Select date range',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _selectedDateRange != null
                            ? (isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight)
                            : (isDark
                                ? AppTheme.textDisabledDark
                                : AppTheme.textDisabledLight),
                      ),
                ),
              ),
              if (_selectedDateRange != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDateRange = null;
                      _filters.remove('dateRange');
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    size: 20,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters(BuildContext context, bool isDark) {
    final List<String> statuses = [
      'completed',
      'analyzing',
      'pending',
      'failed'
    ];
    final List<String> selectedStatuses =
        (_filters['statuses'] as List<String>?) ?? [];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: statuses.map((status) {
        final bool isSelected = selectedStatuses.contains(status);
        return FilterChip(
          label: Text(_capitalizeFirst(status)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedStatuses.add(status);
              } else {
                selectedStatuses.remove(status);
              }
              _filters['statuses'] = selectedStatuses;
            });
          },
          backgroundColor:
              isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          selectedColor: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
              .withValues(alpha: 0.2),
          checkmarkColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                    : (isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight),
              ),
        );
      }).toList(),
    );
  }

  Widget _buildConfidenceFilter(BuildContext context, bool isDark) {
    final double minConfidence = (_filters['minConfidence'] as double?) ?? 0.0;
    final double maxConfidence = (_filters['maxConfidence'] as double?) ?? 1.0;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Min: ${(minConfidence * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Text(
              'Max: ${(maxConfidence * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(minConfidence, maxConfidence),
          onChanged: (RangeValues values) {
            setState(() {
              _filters['minConfidence'] = values.start;
              _filters['maxConfidence'] = values.end;
            });
          },
          divisions: 10,
          labels: RangeLabels(
            '${(minConfidence * 100).toInt()}%',
            '${(maxConfidence * 100).toInt()}%',
          ),
        ),
      ],
    );
  }

  Widget _buildAbnormalityFilters(BuildContext context, bool isDark) {
    final List<String> abnormalityTypes = [
      'Normal',
      'Murmur',
      'Arrhythmia',
      'Tachycardia',
      'Bradycardia',
      'Gallop',
      'Click',
    ];
    final List<String> selectedAbnormalities =
        (_filters['abnormalityTypes'] as List<String>?) ?? [];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: abnormalityTypes.map((type) {
        final bool isSelected = selectedAbnormalities.contains(type);
        return FilterChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedAbnormalities.add(type);
              } else {
                selectedAbnormalities.remove(type);
              }
              _filters['abnormalityTypes'] = selectedAbnormalities;
            });
          },
          backgroundColor:
              isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          selectedColor: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
              .withValues(alpha: 0.2),
          checkmarkColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                    : (isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight),
              ),
        );
      }).toList(),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.primaryDark
                      : AppTheme.primaryLight,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _filters['dateRange'] = picked;
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _selectedDateRange = null;
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_filters);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  String _capitalizeFirst(String text) {
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }
}
