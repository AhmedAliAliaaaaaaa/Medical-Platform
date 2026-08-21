import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:doctor_app/utils/app_theme.dart';

class FilePickerWidget extends StatefulWidget {
  final Function(List<File>) onFilesChanged;
  final List<File> initialFiles;

  const FilePickerWidget({
    super.key,
    required this.onFilesChanged,
    this.initialFiles = const [],
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  List<File> _attachedFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _attachedFiles = List.from(widget.initialFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.attach_file, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'المرفقات (اختياري)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Upload Buttons
            _buildUploadButtons(),

            // Attached Files List
            if (_attachedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAttachedFilesList(),
            ],

            // Tips
            const SizedBox(height: 12),
            _buildTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButtons() {
    return Column(
      children: [
        // Primary Upload Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('صور'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('كاميرا'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Document Upload Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _pickDocuments,
            icon: const Icon(Icons.description),
            label: const Text('مستندات طبية (PDF, DOC)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachedFilesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.folder_open,
                size: 20, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Text(
              'الملفات المرفقة (${_attachedFiles.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            if (_attachedFiles.isNotEmpty)
              TextButton.icon(
                onPressed: _clearAllFiles,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('مسح الكل'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Files List
        ...List.generate(_attachedFiles.length, (index) {
          final file = _attachedFiles[index];
          final fileName = file.path.split('/').last;
          final fileSize = _getFileSize(file);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                // File Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getFileColor(fileName),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getFileIcon(fileName),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // File Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        fileSize,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Remove Button
                IconButton(
                  onPressed: () => _removeFile(index),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  iconSize: 20,
                  tooltip: 'حذف الملف',
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'نصائح مهمة:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• ارفق صور واضحة للأعراض أو المنطقة المصابة\n'
            '• أضف التقارير الطبية والتحاليل إن وجدت\n'
            '• تأكد من وضوح النصوص في الصور\n'
            '• الحد الأقصى لحجم الملف: 10 ميجابايت',
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // File Operations
  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        final newFiles = images.map((image) => File(image.path)).toList();
        _addFiles(newFiles);
      }
    } catch (e) {
      _showError('خطأ في اختيار الصور: ${e.toString()}');
    }
  }

  Future<void> _pickCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        _addFiles([File(image.path)]);
      }
    } catch (e) {
      _showError('خطأ في التقاط الصورة: ${e.toString()}');
    }
  }

  Future<void> _pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final newFiles = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
        _addFiles(newFiles);
      }
    } catch (e) {
      _showError('خطأ في اختيار المستندات: ${e.toString()}');
    }
  }

  void _addFiles(List<File> newFiles) {
    setState(() {
      _attachedFiles.addAll(newFiles);
    });
    widget.onFilesChanged(_attachedFiles);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${newFiles.length} ملف'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
    widget.onFilesChanged(_attachedFiles);
  }

  void _clearAllFiles() {
    setState(() {
      _attachedFiles.clear();
    });
    widget.onFilesChanged(_attachedFiles);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف جميع الملفات'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Helper Methods
  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'txt':
        return Colors.grey;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'غير معروف';
    }
  }
}
