import 'package:flutter/material.dart';
import '../../services/messaging_api_service.dart';
import '../../utils/constants.dart';

class MessagesScreen extends StatefulWidget {
  final String userType;
  const MessagesScreen({super.key, this.userType = 'doctor'});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _messages = [];
  List<dynamic> _recipients = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await MessagingApiService.getMessages(widget.userType);
      if (!mounted) return;
      setState(() {
        _messages = data['messages'] as List<dynamic>? ?? [];
        _recipients = data['recipients'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _compose() async {
    if (_recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد مديرون متاحون للمراسلة')),
      );
      return;
    }
    final subject = TextEditingController();
    final body = TextEditingController();
    int recipientId = _recipients.first['id'] as int;
    final sent = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('مراسلة الإدارة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: recipientId,
                  decoration: const InputDecoration(labelText: 'المدير'),
                  items: _recipients.map((recipient) {
                    return DropdownMenuItem<int>(
                      value: recipient['id'] as int,
                      child: Text(recipient['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => recipientId = value);
                    }
                  },
                ),
                TextField(
                  controller: subject,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
                TextField(
                  controller: body,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'نص الرسالة'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                if (subject.text.trim().isEmpty || body.text.trim().isEmpty) {
                  return;
                }
                await MessagingApiService.sendMessage(
                  userType: widget.userType,
                  recipientId: recipientId,
                  subject: subject.text.trim(),
                  body: body.text.trim(),
                );
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
    subject.dispose();
    body.dispose();
    if (sent == true) {
      await _load();
    }
  }

  Future<void> _markRead(Map<String, dynamic> message) async {
    if (message['is_read'] == true) return;
    await MessagingApiService.markAsRead(
      userType: widget.userType,
      messageId: message['id'] as int,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userType == 'admin' ? 'مراسلات الإدارة' : 'صندوق الرسائل'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(onPressed: _compose, icon: const Icon(Icons.edit)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _messages.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('لا توجد رسائل')),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = Map<String, dynamic>.from(
                              _messages[index] as Map,
                            );
                            final sender =
                                message['sender'] as Map<String, dynamic>;
                            return Card(
                              color: message['is_read'] == true
                                  ? null
                                  : AppColors.primary.withOpacity(0.08),
                              child: ListTile(
                                onTap: () => _markRead(message),
                                leading: Icon(
                                  message['is_read'] == true
                                      ? Icons.mail_outline
                                      : Icons.mark_email_unread,
                                  color: AppColors.primary,
                                ),
                                title: Text(message['subject'] as String),
                                subtitle: Text(
                                  '${sender['name']}\n${message['body']}',
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
