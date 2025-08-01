import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;

  const SearchFilterWidget({
    Key? key,
    required this.onSearchChanged,
    required this.onFilterTap,
    this.hasActiveFilters = false,
  }) : super(key: key);

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearchFocused
                      ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                      : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
                  width: _isSearchFocused ? 2 : 1,
                ),
              ),
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isSearchFocused = hasFocus;
                  });
                },
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by patient ID, date, or findings...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.textDisabledDark
                              : AppTheme.textDisabledLight,
                        ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        size: 20,
                        color: _isSearchFocused
                            ? (isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight)
                            : (isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight),
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged('');
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              size: 20,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Filter button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onFilterTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: widget.hasActiveFilters
                      ? (isDark
                          ? AppTheme.primaryDark.withValues(alpha: 0.1)
                          : AppTheme.primaryLight.withValues(alpha: 0.1))
                      : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.hasActiveFilters
                        ? (isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight)
                        : (isDark
                            ? AppTheme.dividerDark
                            : AppTheme.dividerLight),
                    width: widget.hasActiveFilters ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    CustomIconWidget(
                      iconName: 'tune',
                      size: 24,
                      color: widget.hasActiveFilters
                          ? (isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight)
                          : (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight),
                    ),
                    if (widget.hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.secondaryDark
                                : AppTheme.secondaryLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
