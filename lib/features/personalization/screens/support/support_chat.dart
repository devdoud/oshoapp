import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:osho/features/personalization/controllers/support_controller.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/common/widgets/loaders/loader.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final controller = Get.put(SupportController());
  final auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Corrected: No auto back arrow
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: OColors.primary,
              radius: 18,
              child: Icon(Iconsax.headphone, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'support_team'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'online'.tr,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: StreamBuilder(
              stream: controller.getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                   return Center(
                     child: Text(
                       'support_welcome'.tr, 
                       style: TextStyle(color: Colors.grey[500]), 
                       textAlign: TextAlign.center
                      ),
                   );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.senderId == auth.currentUser?.uid;
                    
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4), 
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                        decoration: BoxDecoration(
                          color: isUser ? OColors.primary : const Color(0xFFF5F5F5), 
                          borderRadius: BorderRadius.circular(16).copyWith(
                             bottomRight: isUser ? const Radius.circular(0) : null,
                             bottomLeft: !isUser ? const Radius.circular(0) : null,
                          ),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Enhanced Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              minLines: 1,
                              maxLines: 4, 
                              decoration: InputDecoration(
                                hintText: 'type_message'.tr,
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                            OLoaders.warningSnackBar(title: 'Bient\u00f4t disponible', message: 'Les pi\u00e8ces jointes arrivent bient\u00f4t.');
                          }, 
                            icon: Icon(Iconsax.attach_circle, color: Colors.grey[400]),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  GestureDetector(
                    onTap: () {
                        if (_messageController.text.trim().isNotEmpty) {
                           controller.sendMessage(_messageController.text.trim());
                           _messageController.clear();
                        }
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: OColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: OColors.primary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(Iconsax.send_24, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
