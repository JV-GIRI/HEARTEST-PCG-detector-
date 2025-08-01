import 'dart:convert';
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'
    if (dart.library.io) 'path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_toggle_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/storage_usage_widget.dart';

class UserProfileSettings extends StatefulWidget {
  const UserProfileSettings({Key? key}) : super(key: key);

  @override
  State<UserProfileSettings> createState() => _UserProfileSettingsState();
}

class _UserProfileSettingsState extends State<UserProfileSettings>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isRecordingCalibration = false;
  bool _biometricEnabled = true;
  bool _autoAnalysis = true;
  bool _emergencyNotifications = true;
  bool _analysisAlerts = true;
  bool _systemUpdates = false;
  double _recordingDuration = 30.0;
  double _qualityThreshold = 0.8;

  // Mock user profile data
  final Map<String, dynamic> _userProfile = {
    "id": 1,
    "name": "Dr. Sarah Johnson",
    "email": "sarah.johnson@cardioscope.com",
    "specialty": "Interventional Cardiology",
    "licenseNumber": "MD-2024-8901",
    "isVerified": true,
    "avatar":
        "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
    "phone": "+1 (555) 123-4567",
    "institution": "CardioScope Medical Center",
    "yearsExperience": 12,
    "joinDate": "2024-01-15",
  };

  // Mock storage data
  final Map<String, dynamic> _storageData = {
    "usedGB": 2.4,
    "totalGB": 16.0,
    "audioFilesGB": 1.8,
    "analysisDataGB": 0.6,
  };

  // Mock emergency contacts
  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      "id": 1,
      "name": "Dr. Michael Chen",
      "relationship": "Colleague",
      "phone": "+1 (555) 987-6543",
      "email": "m.chen@cardioscope.com",
    },
    {
      "id": 2,
      "name": "CardioScope Emergency",
      "relationship": "Medical Support",
      "phone": "+1 (800) 911-HEART",
      "email": "emergency@cardioscope.com",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCamera();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb) {
        final hasPermission = await _requestCameraPermission();
        if (!hasPermission) return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // Silent fail - camera not available
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.auto);
      }
    } catch (e) {
      // Settings not supported on this platform
    }
  }

  Future<void> _captureDocument() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Document captured successfully"),
            backgroundColor: AppTheme.getSuccessColor(true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to capture document"),
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    try {
      final exportData = {
        "profile": _userProfile,
        "settings": {
          "biometricEnabled": _biometricEnabled,
          "autoAnalysis": _autoAnalysis,
          "recordingDuration": _recordingDuration,
          "qualityThreshold": _qualityThreshold,
        },
        "storage": _storageData,
        "emergencyContacts": _emergencyContacts,
        "exportDate": DateTime.now().toIso8601String(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final filename =
          "cardioscope_data_export_${DateTime.now().millisecondsSinceEpoch}.json";

      await _downloadFile(jsonString, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Data exported successfully"),
            backgroundColor: AppTheme.getSuccessColor(true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Export failed. Please try again."),
          ),
        );
      }
    }
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }

  Future<void> _uploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Document uploaded successfully"),
              backgroundColor: AppTheme.getSuccessColor(true),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload failed. Please try again."),
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Account",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This action cannot be undone. All your data will be permanently deleted:",
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              "• Audio recordings and analysis results\n• Medical credentials and profile\n• Settings and preferences\n• Emergency contacts",
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login-screen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text("Delete Account"),
          ),
        ],
      ),
    );
  }

  void _calibrateMicrophone() {
    setState(() {
      _isRecordingCalibration = true;
    });

    // Simulate calibration process
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRecordingCalibration = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Microphone calibrated successfully"),
            backgroundColor: AppTheme.getSuccessColor(true),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile Settings"),
        leading: IconButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/recording-dashboard'),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/recording-history');
            },
            icon: CustomIconWidget(
              iconName: 'history',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Profile"),
            Tab(text: "Settings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          ProfileHeaderWidget(
            userProfile: _userProfile,
            onEditPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Edit profile functionality")),
              );
            },
          ),
          SizedBox(height: 2.h),
          SettingsSectionWidget(
            title: "Account Information",
            children: [
              SettingsItemWidget(
                iconName: 'email',
                title: "Email Address",
                subtitle: _userProfile["email"] as String,
                onTap: () {},
              ),
              SettingsItemWidget(
                iconName: 'phone',
                title: "Phone Number",
                subtitle: _userProfile["phone"] as String,
                onTap: () {},
              ),
              SettingsItemWidget(
                iconName: 'business',
                title: "Institution",
                subtitle: _userProfile["institution"] as String,
                onTap: () {},
              ),
              SettingsItemWidget(
                iconName: 'work',
                title: "Experience",
                subtitle:
                    "${_userProfile["yearsExperience"]} years in practice",
                isLast: true,
                onTap: () {},
              ),
            ],
          ),
          SettingsSectionWidget(
            title: "Medical Credentials",
            subtitle: "Verify and manage your professional credentials",
            children: [
              SettingsItemWidget(
                iconName: 'camera_alt',
                title: "Capture License Document",
                subtitle: "Take a photo of your medical license",
                onTap: _captureDocument,
              ),
              SettingsItemWidget(
                iconName: 'upload_file',
                title: "Upload Document",
                subtitle: "Upload from device storage",
                onTap: _uploadDocument,
              ),
              SettingsItemWidget(
                iconName: 'verified_user',
                title: "Verification Status",
                subtitle: _userProfile["isVerified"] as bool
                    ? "Verified on ${DateTime.parse(_userProfile["joinDate"] as String).toString().split(' ')[0]}"
                    : "Pending verification",
                trailing: CustomIconWidget(
                  iconName: _userProfile["isVerified"] as bool
                      ? 'check_circle'
                      : 'pending',
                  color: _userProfile["isVerified"] as bool
                      ? AppTheme.getSuccessColor(true)
                      : AppTheme.getWarningColor(true),
                  size: 20,
                ),
                isLast: true,
              ),
            ],
          ),
          SettingsSectionWidget(
            title: "Security",
            children: [
              BiometricToggleWidget(
                initialValue: _biometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                },
              ),
              SettingsItemWidget(
                iconName: 'lock',
                title: "Change Password",
                subtitle: "Update your account password",
                onTap: () {},
              ),
              SettingsItemWidget(
                iconName: 'security',
                title: "Two-Factor Authentication",
                subtitle: "Add extra security to your account",
                isLast: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SettingsSectionWidget(
            title: "Recording Preferences",
            subtitle: "Configure audio recording and analysis settings",
            children: [
              SettingsItemWidget(
                iconName: 'mic',
                title: _isRecordingCalibration
                    ? "Calibrating..."
                    : "Microphone Calibration",
                subtitle: _isRecordingCalibration
                    ? "Please speak normally for calibration"
                    : "Optimize microphone for heart sound recording",
                trailing: _isRecordingCalibration
                    ? SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      )
                    : null,
                onTap: _isRecordingCalibration ? null : _calibrateMicrophone,
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Default Recording Duration: ${_recordingDuration.toInt()}s",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _recordingDuration,
                      min: 10,
                      max: 120,
                      divisions: 11,
                      onChanged: (value) {
                        setState(() {
                          _recordingDuration = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SettingsItemWidget(
                iconName: 'auto_awesome',
                title: "Auto-Analysis",
                subtitle: "Automatically analyze recordings after capture",
                trailing: Switch(
                  value: _autoAnalysis,
                  onChanged: (value) {
                    setState(() {
                      _autoAnalysis = value;
                    });
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quality Threshold: ${(_qualityThreshold * 100).toInt()}%",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _qualityThreshold,
                      min: 0.5,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _qualityThreshold = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SettingsSectionWidget(
            title: "Data Management",
            children: [
              StorageUsageWidget(storageData: _storageData),
              SettingsItemWidget(
                iconName: 'download',
                title: "Export Data",
                subtitle: "Download all recordings and analysis results",
                onTap: _exportData,
              ),
              SettingsItemWidget(
                iconName: 'cloud_sync',
                title: "Backup Settings",
                subtitle: "Configure automatic data backup",
                onTap: () {},
              ),
              SettingsItemWidget(
                iconName: 'delete_forever',
                title: "Clear Cache",
                subtitle: "Free up space by clearing temporary files",
                isLast: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Cache cleared successfully"),
                      backgroundColor: AppTheme.getSuccessColor(true),
                    ),
                  );
                },
              ),
            ],
          ),
          SettingsSectionWidget(
            title: "Notifications",
            children: [
              SettingsItemWidget(
                iconName: 'notifications',
                title: "Analysis Completion",
                subtitle: "Get notified when analysis is complete",
                trailing: Switch(
                  value: _analysisAlerts,
                  onChanged: (value) {
                    setState(() {
                      _analysisAlerts = value;
                    });
                  },
                ),
              ),
              SettingsItemWidget(
                iconName: 'emergency',
                title: "Emergency Findings",
                subtitle: "Critical alerts for abnormal heart sounds",
                trailing: Switch(
                  value: _emergencyNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emergencyNotifications = value;
                    });
                  },
                ),
              ),
              SettingsItemWidget(
                iconName: 'system_update',
                title: "System Updates",
                subtitle: "App updates and new features",
                trailing: Switch(
                  value: _systemUpdates,
                  onChanged: (value) {
                    setState(() {
                      _systemUpdates = value;
                    });
                  },
                ),
                isLast: true,
              ),
            ],
          ),
          SettingsSectionWidget(
            title: "Emergency Contacts",
            subtitle: "Contacts notified for critical findings",
            children: [
              ...(_emergencyContacts as List).asMap().entries.map((entry) {
                final index = entry.key;
                final contact = entry.value as Map<String, dynamic>;
                final isLast = index == _emergencyContacts.length - 1;

                return SettingsItemWidget(
                  iconName: 'contact_emergency',
                  title: contact["name"] as String,
                  subtitle: "${contact["relationship"]} • ${contact["phone"]}",
                  isLast: isLast && _emergencyContacts.length < 3,
                  onTap: () {},
                );
              }).toList(),
              if (_emergencyContacts.length < 3)
                SettingsItemWidget(
                  iconName: 'add_circle',
                  title: "Add Emergency Contact",
                  subtitle: "Add up to 3 emergency contacts",
                  isLast: true,
                  onTap: () {},
                ),
            ],
          ),
          SettingsSectionWidget(
            title: "Support & Legal",
            children: [
              SettingsItemWidget(
                iconName: 'help',
                title: "Help & Documentation",
                subtitle: "User guides and troubleshooting",
                onTap: () {},
              ),
              SettingsItemWidget(
                iconName: 'feedback',
                title: "Send Feedback",
                subtitle: "Help us improve CardioScope AI",
                onTap: () {},
              ),
              SettingsItemWidget(
                iconName: 'privacy_tip',
                title: "Privacy Policy",
                subtitle: "How we handle your medical data",
                onTap: () {},
              ),
              SettingsItemWidget(
                iconName: 'gavel',
                title: "Terms of Service",
                subtitle: "Legal terms and conditions",
                onTap: () {},
              ),
              SettingsItemWidget(
                iconName: 'info',
                title: "About CardioScope AI",
                subtitle: "Version 1.0.0 • Build 2024080120",
                isLast: true,
                onTap: () {},
              ),
            ],
          ),
          SettingsSectionWidget(
            title: "Account Actions",
            children: [
              SettingsItemWidget(
                iconName: 'logout',
                title: "Sign Out",
                subtitle: "Sign out of your account",
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login-screen');
                },
              ),
              SettingsItemWidget(
                iconName: 'delete_forever',
                title: "Delete Account",
                subtitle: "Permanently delete your account and data",
                iconColor: AppTheme.lightTheme.colorScheme.error,
                isLast: true,
                onTap: _showDeleteAccountDialog,
              ),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
