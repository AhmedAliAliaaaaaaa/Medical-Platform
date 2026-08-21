import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/enhanced_card.dart';
import '../../models/doctor.dart';
import '../../models/medical_case.dart';

class ChatScreen extends StatefulWidget {
  final Doctor? doctor;
  final MedicalCase? medicalCase;

  const ChatScreen({super.key, this.doctor, this.medicalCase});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadMessages();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    // Mock messages - replace with actual API call
    setState(() {
      _messages = [
        ChatMessage(
          id: '1',
          senderId: widget.doctor?.id.toString() ?? '1',
          senderName: widget.doctor?.user.fullName ?? 'Dr. Smith',
          message: 'مرحباً، كيف يمكنني مساعدتك اليوم؟',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isFromDoctor: true,
          messageType: MessageType.text,
        ),
        ChatMessage(
          id: '2',
          senderId: 'patient',
          senderName: 'أنت',
          message: 'أعاني من ألم في الصدر منذ يومين',
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 45),
          ),
          isFromDoctor: false,
          messageType: MessageType.text,
        ),
        ChatMessage(
          id: '3',
          senderId: widget.doctor?.id.toString() ?? '1',
          senderName: widget.doctor?.user.fullName ?? 'Dr. Smith',
          message: 'هل يمكنك وصف الألم بالتفصيل؟ هل هو ألم حاد أم مستمر؟',
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 30),
          ),
          isFromDoctor: true,
          messageType: MessageType.text,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: _buildAppBar(isRTL),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Case Info Banner (if applicable)
                if (widget.medicalCase != null) _buildCaseInfoBanner(isRTL),

                // Messages List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator(isRTL);
                      }
                      return _buildMessageBubble(_messages[index], isRTL);
                    },
                  ),
                ),

                // Message Input
                _buildMessageInput(isRTL),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isRTL) {
    return AppBar(
      backgroundColor: AppTheme.cardBackground,
      elevation: 1,
      title: Row(
        children: [
          // Doctor Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryBlue,
            child:
                widget.doctor?.profilePicture != null
                    ? ClipOval(
                      child: Image.network(
                        widget.doctor!.profilePicture!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: AppTheme.textLight,
                            size: 24,
                          );
                        },
                      ),
                    )
                    : const Icon(
                      Icons.person,
                      color: AppTheme.textLight,
                      size: 24,
                    ),
          ),
          const SizedBox(width: 12),

          // Doctor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor?.user.fullName ?? (isRTL ? 'الطبيب' : 'Doctor'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isOnline ? AppTheme.primaryGreen : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isOnline
                          ? (isRTL ? 'متصل' : 'Online')
                          : (isRTL ? 'غير متصل' : 'Offline'),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {
            _startVideoCall();
          },
          tooltip: isRTL ? 'مكالمة فيديو' : 'Video Call',
        ),
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            _startVoiceCall();
          },
          tooltip: isRTL ? 'مكالمة صوتية' : 'Voice Call',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view_profile':
                _viewDoctorProfile();
                break;
              case 'case_details':
                _viewCaseDetails();
                break;
              case 'end_consultation':
                _endConsultation();
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'view_profile',
                  child: Text(isRTL ? 'عرض الملف الشخصي' : 'View Profile'),
                ),
                if (widget.medicalCase != null)
                  PopupMenuItem(
                    value: 'case_details',
                    child: Text(isRTL ? 'تفاصيل الحالة' : 'Case Details'),
                  ),
                PopupMenuItem(
                  value: 'end_consultation',
                  child: Text(isRTL ? 'إنهاء الاستشارة' : 'End Consultation'),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildCaseInfoBanner(bool isRTL) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medical_services,
            color: AppTheme.textLight,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.medicalCase!.title,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isRTL ? 'استشارة طبية' : 'Medical Consultation',
                  style: TextStyle(
                    color: AppTheme.textLight.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.textLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getPriorityText(widget.medicalCase!.priority, isRTL),
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isRTL) {
    final isFromCurrentUser = !message.isFromDoctor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryBlue,
              child: const Icon(
                Icons.person,
                color: AppTheme.textLight,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isFromCurrentUser
                        ? AppTheme.primaryBlue
                        : AppTheme.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromCurrentUser ? 16 : 4),
                  bottomRight: Radius.circular(isFromCurrentUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkGray.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.messageType == MessageType.image)
                    _buildImageMessage(message)
                  else if (message.messageType == MessageType.file)
                    _buildFileMessage(message, isRTL)
                  else
                    Text(
                      message.message,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            isFromCurrentUser
                                ? AppTheme.textLight
                                : AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isFromCurrentUser
                              ? AppTheme.textLight.withOpacity(0.7)
                              : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(
                Icons.person,
                color: AppTheme.textLight,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageMessage(ChatMessage message) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        message.message, // URL of the image
        width: 200,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 200,
            height: 150,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
          );
        },
      ),
    );
  }

  Widget _buildFileMessage(ChatMessage message, bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 8),
          Text(
            message.fileName ?? (isRTL ? 'ملف' : 'File'),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isRTL) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryBlue,
            child: const Icon(
              Icons.person,
              color: AppTheme.textLight,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRTL ? 'يكتب...' : 'Typing...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[400]!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(top: BorderSide(color: AppTheme.lightGray, width: 1)),
      ),
      child: Row(
        children: [
          // Attachment Button
          IconButton(
            icon: const Icon(Icons.attach_file),
            color: AppTheme.primaryBlue,
            onPressed: _showAttachmentOptions,
          ),

          // Message Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: isRTL ? 'اكتب رسالة...' : 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (text) {
                  // Handle typing indicator
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send Button
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: AppTheme.textLight,
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'patient',
      senderName: 'أنت',
      message: message,
      timestamp: DateTime.now(),
      isFromDoctor: false,
      messageType: MessageType.text,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    _scrollToBottom();
    _simulateDoctorResponse();
  }

  void _simulateDoctorResponse() {
    // Simulate typing indicator
    setState(() {
      _isTyping = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              senderId: widget.doctor?.id.toString() ?? '1',
              senderName: widget.doctor?.user.fullName ?? 'Dr. Smith',
              message:
                  'شكراً لك على المعلومات. سأقوم بمراجعة حالتك والرد عليك قريباً.',
              timestamp: DateTime.now(),
              isFromDoctor: true,
              messageType: MessageType.text,
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRTL ? 'إرفاق ملف' : 'Attach File',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.camera_alt,
                    label: isRTL ? 'كاميرا' : 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _attachImage(ImageSource.camera);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.photo_library,
                    label: isRTL ? 'معرض الصور' : 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _attachImage(ImageSource.gallery);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.attach_file,
                    label: isRTL ? 'ملف' : 'File',
                    onTap: () {
                      Navigator.pop(context);
                      _attachFile();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  void _attachImage(ImageSource source) {
    // Implement image attachment
  }

  void _attachFile() {
    // Implement file attachment
  }

  void _startVideoCall() {
    // Implement video call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video call feature coming soon'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _startVoiceCall() {
    // Implement voice call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice call feature coming soon'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _viewDoctorProfile() {
    // Navigate to doctor profile
  }

  void _viewCaseDetails() {
    // Navigate to case details
  }

  void _endConsultation() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isRTL ? 'إنهاء الاستشارة' : 'End Consultation',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            isRTL
                ? 'هل أنت متأكد من إنهاء الاستشارة؟'
                : 'Are you sure you want to end the consultation?',
            style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'إلغاء' : 'Cancel',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isRTL ? 'إنهاء' : 'End',
                style: const TextStyle(color: AppTheme.textLight),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getPriorityText(String priority, bool isRTL) {
    switch (priority) {
      case 'normal':
        return isRTL ? 'عادي' : 'Normal';
      case 'high':
        return isRTL ? 'مرتفع' : 'High';
      case 'urgent':
        return isRTL ? 'عاجل' : 'Urgent';
      default:
        return priority;
    }
  }
}

// Chat Message Model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromDoctor;
  final MessageType messageType;
  final String? fileName;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isFromDoctor,
    required this.messageType,
    this.fileName,
  });
}

enum MessageType { text, image, file, voice }

enum ImageSource { camera, gallery }
