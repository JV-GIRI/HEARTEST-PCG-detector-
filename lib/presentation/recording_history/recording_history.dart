import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/recording_card_widget.dart';
import './widgets/search_filter_widget.dart';

class RecordingHistory extends StatefulWidget {
  const RecordingHistory({Key? key}) : super(key: key);

  @override
  State<RecordingHistory> createState() => _RecordingHistoryState();
}

class _RecordingHistoryState extends State<RecordingHistory>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // State variables
  List<Map<String, dynamic>> _allRecordings = [];
  List<Map<String, dynamic>> _filteredRecordings = [];
  Set<int> _selectedRecordings = {};
  Map<String, dynamic> _activeFilters = {};
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isMultiSelectMode = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _loadRecordings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadRecordings() {
    setState(() {
      _isLoading = true;
    });

    // Mock data for recordings
    _allRecordings = [
      {
        "id": 1,
        "patientName": "Sarah Johnson",
        "patientId": "PT-2024-001",
        "date": DateTime.now().subtract(const Duration(hours: 2)),
        "duration": "0:45",
        "status": "completed",
        "confidenceScore": 0.92,
        "abnormalityType": "Normal",
        "filePath": "/recordings/sarah_johnson_20240801.wav",
      },
      {
        "id": 2,
        "patientName": "Michael Chen",
        "patientId": "PT-2024-002",
        "date": DateTime.now().subtract(const Duration(days: 1)),
        "duration": "1:12",
        "status": "completed",
        "confidenceScore": 0.78,
        "abnormalityType": "Murmur",
        "filePath": "/recordings/michael_chen_20240731.wav",
      },
      {
        "id": 3,
        "patientName": "Emma Rodriguez",
        "patientId": "PT-2024-003",
        "date": DateTime.now().subtract(const Duration(days: 2)),
        "duration": "0:38",
        "status": "analyzing",
        "confidenceScore": 0.0,
        "abnormalityType": "Pending",
        "filePath": "/recordings/emma_rodriguez_20240730.wav",
      },
      {
        "id": 4,
        "patientName": "David Kim",
        "patientId": "PT-2024-004",
        "date": DateTime.now().subtract(const Duration(days: 3)),
        "duration": "1:05",
        "status": "completed",
        "confidenceScore": 0.65,
        "abnormalityType": "Arrhythmia",
        "filePath": "/recordings/david_kim_20240729.wav",
      },
      {
        "id": 5,
        "patientName": "Lisa Thompson",
        "patientId": "PT-2024-005",
        "date": DateTime.now().subtract(const Duration(days: 5)),
        "duration": "0:52",
        "status": "failed",
        "confidenceScore": 0.0,
        "abnormalityType": "Error",
        "filePath": "/recordings/lisa_thompson_20240727.wav",
      },
      {
        "id": 6,
        "patientName": "James Wilson",
        "patientId": "PT-2024-006",
        "date": DateTime.now().subtract(const Duration(days: 7)),
        "duration": "1:18",
        "status": "completed",
        "confidenceScore": 0.89,
        "abnormalityType": "Normal",
        "filePath": "/recordings/james_wilson_20240725.wav",
      },
      {
        "id": 7,
        "patientName": "Maria Garcia",
        "patientId": "PT-2024-007",
        "date": DateTime.now().subtract(const Duration(days: 10)),
        "duration": "0:41",
        "status": "completed",
        "confidenceScore": 0.73,
        "abnormalityType": "Tachycardia",
        "filePath": "/recordings/maria_garcia_20240722.wav",
      },
    ];

    _applyFiltersAndSearch();

    setState(() {
      _isLoading = false;
    });
  }

  void _applyFiltersAndSearch() {
    List<Map<String, dynamic>> filtered = List.from(_allRecordings);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((recording) {
        final patientName = (recording['patientName'] as String).toLowerCase();
        final patientId = (recording['patientId'] as String).toLowerCase();
        final abnormalityType =
            (recording['abnormalityType'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();

        return patientName.contains(query) ||
            patientId.contains(query) ||
            abnormalityType.contains(query);
      }).toList();
    }

    // Apply date range filter
    if (_activeFilters.containsKey('dateRange')) {
      final DateTimeRange dateRange =
          _activeFilters['dateRange'] as DateTimeRange;
      filtered = filtered.where((recording) {
        final recordingDate = recording['date'] as DateTime;
        return recordingDate
                .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            recordingDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply status filter
    if (_activeFilters.containsKey('statuses')) {
      final List<String> statuses = _activeFilters['statuses'] as List<String>;
      if (statuses.isNotEmpty) {
        filtered = filtered.where((recording) {
          return statuses.contains(recording['status'] as String);
        }).toList();
      }
    }

    // Apply confidence filter
    if (_activeFilters.containsKey('minConfidence') ||
        _activeFilters.containsKey('maxConfidence')) {
      final double minConfidence =
          (_activeFilters['minConfidence'] as double?) ?? 0.0;
      final double maxConfidence =
          (_activeFilters['maxConfidence'] as double?) ?? 1.0;

      filtered = filtered.where((recording) {
        final double confidence =
            (recording['confidenceScore'] as num).toDouble();
        return confidence >= minConfidence && confidence <= maxConfidence;
      }).toList();
    }

    // Apply abnormality type filter
    if (_activeFilters.containsKey('abnormalityTypes')) {
      final List<String> types =
          _activeFilters['abnormalityTypes'] as List<String>;
      if (types.isNotEmpty) {
        filtered = filtered.where((recording) {
          return types.contains(recording['abnormalityType'] as String);
        }).toList();
      }
    }

    setState(() {
      _filteredRecordings = filtered;
    });
  }

  void _onScroll() {
    // Implement infinite scroll if needed
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more recordings
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    _loadRecordings();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFiltersAndSearch();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => FilterBottomSheetWidget(
          currentFilters: _activeFilters,
          onFiltersApplied: (filters) {
            setState(() {
              _activeFilters = filters;
            });
            _applyFiltersAndSearch();
          },
        ),
      ),
    );
  }

  void _toggleRecordingSelection(int recordingId) {
    setState(() {
      if (_selectedRecordings.contains(recordingId)) {
        _selectedRecordings.remove(recordingId);
        if (_selectedRecordings.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedRecordings.add(recordingId);
        _isMultiSelectMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedRecordings.clear();
      _isMultiSelectMode = false;
    });
  }

  void _deleteSelectedRecordings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Recordings'),
        content: Text(
          'Are you sure you want to delete ${_selectedRecordings.length} recording(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _allRecordings.removeWhere((recording) =>
                    _selectedRecordings.contains(recording['id'] as int));
                _selectedRecordings.clear();
                _isMultiSelectMode = false;
              });
              _applyFiltersAndSearch();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recordings deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.errorDark
                  : AppTheme.errorLight,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportSelectedRecordings() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Exporting ${_selectedRecordings.length} recordings...')),
    );
    _clearSelection();
  }

  void _archiveSelectedRecordings() {
    // Implement archive functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Archived ${_selectedRecordings.length} recordings')),
    );
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('CardioScope AI'),
        centerTitle: true,
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              onPressed: _exportSelectedRecordings,
              icon: CustomIconWidget(
                iconName: 'file_download',
                size: 24,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            IconButton(
              onPressed: _archiveSelectedRecordings,
              icon: CustomIconWidget(
                iconName: 'archive',
                size: 24,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            IconButton(
              onPressed: _deleteSelectedRecordings,
              icon: CustomIconWidget(
                iconName: 'delete',
                size: 24,
                color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
              ),
            ),
            IconButton(
              onPressed: _clearSelection,
              icon: CustomIconWidget(
                iconName: 'close',
                size: 24,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/user-profile-settings'),
              icon: CustomIconWidget(
                iconName: 'person',
                size: 24,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(12.h),
          child: Column(
            children: [
              // Tab bar
              TabBar(
                controller: _tabController,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushNamed(context, '/recording-dashboard');
                  } else if (index == 2) {
                    Navigator.pushNamed(context, '/audio-analysis-results');
                  }
                },
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'History'),
                  Tab(text: 'Analysis'),
                ],
              ),

              // Search and filter
              SearchFilterWidget(
                onSearchChanged: _onSearchChanged,
                onFilterTap: _showFilterBottomSheet,
                hasActiveFilters: _activeFilters.isNotEmpty,
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              ),
            )
          : _filteredRecordings.isEmpty
              ? EmptyStateWidget(
                  onStartRecording: () {
                    Navigator.pushNamed(context, '/recording-dashboard');
                  },
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredRecordings.length,
                    itemBuilder: (context, index) {
                      final recording = _filteredRecordings[index];
                      final recordingId = recording['id'] as int;
                      final isSelected =
                          _selectedRecordings.contains(recordingId);

                      return RecordingCardWidget(
                        recording: recording,
                        isSelected: isSelected,
                        onTap: () {
                          if (_isMultiSelectMode) {
                            _toggleRecordingSelection(recordingId);
                          } else {
                            Navigator.pushNamed(
                                context, '/audio-analysis-results');
                          }
                        },
                        onPlay: () {
                          // Implement audio playback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Playing recording...')),
                          );
                        },
                        onAnalyze: () {
                          Navigator.pushNamed(
                              context, '/audio-analysis-results');
                        },
                        onShare: () {
                          // Implement share functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sharing recording...')),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Recording'),
                              content: Text(
                                  'Are you sure you want to delete this recording?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _allRecordings.removeWhere(
                                          (r) => r['id'] == recordingId);
                                    });
                                    _applyFiltersAndSearch();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Recording deleted')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? AppTheme.errorDark
                                        : AppTheme.errorLight,
                                  ),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onArchive: () {
                          // Implement archive functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Recording archived')),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: !_isMultiSelectMode
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recording-dashboard');
              },
              child: CustomIconWidget(
                iconName: 'mic',
                size: 28,
                color: isDark
                    ? AppTheme.onSecondaryDark
                    : AppTheme.onSecondaryLight,
              ),
            )
          : null,
    );
  }
}
