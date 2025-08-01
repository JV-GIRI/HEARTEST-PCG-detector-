
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/file_browser_widget.dart';
import './widgets/file_preview_widget.dart';
import './widgets/file_selection_bottom_sheet.dart';
import './widgets/file_validation_widget.dart';

class AudioFileUpload extends StatefulWidget {
  const AudioFileUpload({Key? key}) : super(key: key);

  @override
  State<AudioFileUpload> createState() => _AudioFileUploadState();
}

class _AudioFileUploadState extends State<AudioFileUpload> {
  List<String> _selectedFileIds = [];
  List<Map<String, dynamic>> _validationResults = [];
  Map<String, dynamic>? _previewFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Mock audio files data
  final List<Map<String, dynamic>> _audioFiles = [
    {
      "id": "file_001",
      "name": "heart_recording_001.wav",
      "duration": "0:45",
      "size": "2.3 MB",
      "date": "01/15/2025",
      "quality": "high",
      "sampleRate": "44.1 kHz",
      "bitDepth": "16-bit",
      "channels": "mono",
      "path": "/storage/audio/heart_recording_001.wav"
    },
    {
      "id": "file_002",
      "name": "cardiac_assessment_002.wav",
      "duration": "1:12",
      "size": "4.1 MB",
      "date": "01/14/2025",
      "quality": "high",
      "sampleRate": "44.1 kHz",
      "bitDepth": "16-bit",
      "channels": "mono",
      "path": "/storage/audio/cardiac_assessment_002.wav"
    },
    {
      "id": "file_003",
      "name": "patient_heart_sounds.wav",
      "duration": "0:38",
      "size": "1.8 MB",
      "date": "01/13/2025",
      "quality": "standard",
      "sampleRate": "22.05 kHz",
      "bitDepth": "16-bit",
      "channels": "mono",
      "path": "/storage/audio/patient_heart_sounds.wav"
    },
    {
      "id": "file_004",
      "name": "murmur_detection_004.wav",
      "duration": "2:05",
      "size": "6.7 MB",
      "date": "01/12/2025",
      "quality": "high",
      "sampleRate": "44.1 kHz",
      "bitDepth": "24-bit",
      "channels": "stereo",
      "path": "/storage/audio/murmur_detection_004.wav"
    },
    {
      "id": "file_005",
      "name": "baseline_recording.wav",
      "duration": "0:28",
      "size": "1.2 MB",
      "date": "01/11/2025",
      "quality": "standard",
      "sampleRate": "22.05 kHz",
      "bitDepth": "16-bit",
      "channels": "mono",
      "path": "/storage/audio/baseline_recording.wav"
    },
    {
      "id": "file_006",
      "name": "arrhythmia_sample.wav",
      "duration": "1:33",
      "size": "5.2 MB",
      "date": "01/10/2025",
      "quality": "high",
      "sampleRate": "44.1 kHz",
      "bitDepth": "16-bit",
      "channels": "mono",
      "path": "/storage/audio/arrhythmia_sample.wav"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: FileBrowserWidget(
                          audioFiles: _audioFiles,
                          selectedFiles: _selectedFileIds,
                          onFileSelected: _handleFileSelection,
                          onRefresh: _refreshFileList,
                        ),
                      ),
                      if (_validationResults.isNotEmpty)
                        FileValidationWidget(
                          validationResults: _validationResults,
                          onDismiss: _dismissValidation,
                        ),
                    ],
                  ),
                  if (_selectedFileIds.isNotEmpty || _isUploading)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: FileSelectionBottomSheet(
                        selectedFiles: _getSelectedFiles(),
                        onClearSelection: _clearSelection,
                        onUpload: _handleUpload,
                        isUploading: _isUploading,
                        uploadProgress: _uploadProgress,
                      ),
                    ),
                  if (_previewFile != null)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: FilePreviewWidget(
                          file: _previewFile!,
                          onClose: _closePreview,
                          onUpload: _uploadFromPreview,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickFilesFromDevice,
        icon: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.colorScheme.onSecondary,
          size: 5.w,
        ),
        label: Text('Browse Files'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Audio Files',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Select heart sound recordings for analysis',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedFileIds.isNotEmpty && !_isUploading)
            TextButton(
              onPressed: _handleUpload,
              child: Text(
                'Upload',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleFileSelection(String fileId) {
    setState(() {
      if (_selectedFileIds.contains(fileId)) {
        _selectedFileIds.remove(fileId);
      } else {
        if (_selectedFileIds.length < 10) {
          _selectedFileIds.add(fileId);
          _validateSelectedFiles();
        } else {
          _showMaxFilesDialog();
        }
      }
    });
  }

  void _refreshFileList() {
    setState(() {
      // In a real app, this would refresh the file list from storage
      _selectedFileIds.clear();
      _validationResults.clear();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFileIds.clear();
      _validationResults.clear();
    });
  }

  void _dismissValidation() {
    setState(() {
      _validationResults.clear();
    });
  }

  void _closePreview() {
    setState(() {
      _previewFile = null;
    });
  }

  void _uploadFromPreview() {
    if (_previewFile != null) {
      setState(() {
        _selectedFileIds = [_previewFile!['id']];
        _previewFile = null;
      });
      _handleUpload();
    }
  }

  List<Map<String, dynamic>> _getSelectedFiles() {
    return _audioFiles
        .where((file) => _selectedFileIds.contains(file['id']))
        .toList();
  }

  void _validateSelectedFiles() {
    final selectedFiles = _getSelectedFiles();
    final results = <Map<String, dynamic>>[];

    for (final file in selectedFiles) {
      // Simulate file validation
      if (file['quality'] == 'standard') {
        results.add({
          'type': 'warning',
          'fileName': file['name'],
          'message': 'Low sample rate detected (${file['sampleRate']})',
          'suggestion':
              'Consider using recordings with 44.1 kHz or higher for better analysis accuracy',
        });
      }

      if (file['channels'] == 'stereo') {
        results.add({
          'type': 'warning',
          'fileName': file['name'],
          'message': 'Stereo recording detected',
          'suggestion': 'Mono recordings are recommended for cardiac analysis',
        });
      }

      final duration = file['duration'] as String;
      final seconds = _parseDuration(duration);
      if (seconds < 30) {
        results.add({
          'type': 'error',
          'fileName': file['name'],
          'message': 'Recording too short (${file['duration']})',
          'suggestion':
              'Minimum 30 seconds required for accurate cardiac analysis',
        });
      }
    }

    setState(() {
      _validationResults = results;
    });
  }

  int _parseDuration(String duration) {
    final parts = duration.split(':');
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;
    return minutes * 60 + seconds;
  }

  Future<void> _pickFilesFromDevice() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav'],
        allowMultiple: true,
      );

      if (result != null) {
        final newFiles = <Map<String, dynamic>>[];

        for (final file in result.files) {
          final fileName = file.name;
          final fileSize = file.size;
          final filePath = kIsWeb ? fileName : file.path!;

          // Simulate file processing
          final newFile = {
            "id": "picked_${DateTime.now().millisecondsSinceEpoch}",
            "name": fileName,
            "duration": "1:00", // Would be calculated from actual file
            "size": "${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB",
            "date":
                "${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().year}",
            "quality": "high",
            "sampleRate": "44.1 kHz",
            "bitDepth": "16-bit",
            "channels": "mono",
            "path": filePath,
          };

          newFiles.add(newFile);
        }

        setState(() {
          _audioFiles.addAll(newFiles);
        });

        _showFilesPickedSnackBar(newFiles.length);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick files. Please try again.');
    }
  }

  Future<void> _handleUpload() async {
    final hasErrors =
        _validationResults.any((result) => result['type'] == 'error');

    if (hasErrors) {
      _showErrorSnackBar('Please fix validation errors before uploading');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _uploadProgress = i / 100.0;
        });
      }

      // Simulate successful upload
      await Future.delayed(const Duration(milliseconds: 500));

      _showSuccessSnackBar(
          '${_selectedFileIds.length} file${_selectedFileIds.length > 1 ? 's' : ''} uploaded successfully');

      // Navigate to analysis results
      Navigator.pushReplacementNamed(context, '/audio-analysis-results');
    } catch (e) {
      _showErrorSnackBar('Upload failed. Please try again.');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _selectedFileIds.clear();
        _validationResults.clear();
      });
    }
  }

  void _showMaxFilesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Maximum Files Reached'),
        content: Text(
            'You can upload up to 10 files at once. Please remove some files or upload in batches.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFilesPickedSnackBar(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('$count file${count > 1 ? 's' : ''} added to upload queue'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.onSecondary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.lightTheme.colorScheme.onError,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
