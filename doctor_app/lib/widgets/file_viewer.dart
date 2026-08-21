import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../utils/constants.dart';
import '../utils/helpers.dart';

class FileViewer extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const FileViewer({super.key, required this.fileUrl, required this.fileName});

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  bool _isLoading = true;
  String? _localFilePath;
  VideoPlayerController? _videoController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeViewer();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeViewer() async {
    try {
      final fileExtension = widget.fileName.split('.').last.toLowerCase();

      if (_isVideoFile(fileExtension)) {
        await _initializeVideoPlayer();
      } else if (_isPdfFile(fileExtension)) {
        await _downloadFile();
      } else if (_isImageFile(fileExtension)) {
        // Images are loaded directly from network
        setState(() => _isLoading = false);
      } else {
        // For other file types, we'll show download option
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _error = 'خطأ في تحميل الملف: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.fileUrl),
      );
      await _videoController!.initialize();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'خطأ في تحميل الفيديو: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile() async {
    try {
      final response = await http.get(Uri.parse(widget.fileUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/${widget.fileName}');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _localFilePath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception('فشل في تحميل الملف');
      }
    } catch (e) {
      setState(() {
        _error = 'خطأ في تحميل الملف: $e';
        _isLoading = false;
      });
    }
  }

  bool _isImageFile(String extension) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  bool _isVideoFile(String extension) {
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'].contains(extension);
  }

  bool _isPdfFile(String extension) {
    return extension == 'pdf';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text(
          widget.fileName,
          style: const TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.black.withOpacity(0.8),
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadToDevice,
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: _shareFile),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    final fileExtension = widget.fileName.split('.').last.toLowerCase();

    if (_isImageFile(fileExtension)) {
      return _buildImageViewer();
    } else if (_isVideoFile(fileExtension)) {
      return _buildVideoViewer();
    } else if (_isPdfFile(fileExtension)) {
      return _buildPdfViewer();
    } else {
      return _buildUnsupportedFileWidget();
    }
  }

  Widget _buildImageViewer() {
    return Center(
      child: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 4.0,
        child: CachedNetworkImage(
          imageUrl: widget.fileUrl,
          placeholder:
              (context, url) => const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
          errorWidget:
              (context, url, error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: AppColors.error, size: 64),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  Text(
                    'خطأ في تحميل الصورة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildVideoViewer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(_videoController!),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.black.withOpacity(0.7),
                child: VideoProgressIndicator(
                  _videoController!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: AppColors.greyLight,
                    backgroundColor: AppColors.grey,
                  ),
                ),
              ),
            ),
            Center(
              child: IconButton(
                iconSize: 64,
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: AppColors.white.withOpacity(0.8),
                ),
                onPressed: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_localFilePath == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    return PDFView(
      filePath: _localFilePath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      defaultPage: 0,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        // PDF rendered successfully
      },
      onError: (error) {
        setState(() {
          _error = 'خطأ في عرض PDF: $error';
        });
      },
      onPageError: (page, error) {
        setState(() {
          _error = 'خطأ في الصفحة $page: $error';
        });
      },
    );
  }

  Widget _buildUnsupportedFileWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: AppConstants.extraLargeIconSize,
              color: AppColors.white.withOpacity(0.7),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            Text(
              'نوع الملف غير مدعوم للعرض',
              style: AppTextStyles.heading4.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              widget.fileName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            ElevatedButton.icon(
              onPressed: _downloadToDevice,
              icon: const Icon(Icons.download),
              label: const Text('تحميل الملف'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppConstants.extraLargeIconSize,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            Text(
              'خطأ في تحميل الملف',
              style: AppTextStyles.heading4.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _initializeViewer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadToDevice() async {
    try {
      if (await canLaunchUrl(Uri.parse(widget.fileUrl))) {
        await launchUrl(
          Uri.parse(widget.fileUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        AppHelpers.showErrorSnackBar(context, 'لا يمكن فتح الملف');
      }
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'خطأ في تحميل الملف: $e');
    }
  }

  Future<void> _shareFile() async {
    try {
      // TODO: Implement file sharing
      AppHelpers.showInfoSnackBar(context, 'ميزة المشاركة قيد التطوير');
    } catch (e) {
      AppHelpers.showErrorSnackBar(context, 'خطأ في مشاركة الملف: $e');
    }
  }
}
