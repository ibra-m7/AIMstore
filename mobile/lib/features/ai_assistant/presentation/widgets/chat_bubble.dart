import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/chat_message.dart';
import 'typing_indicator.dart';

const _kMintBrand = Color(0xFF003399);
const _kMintDark = Color(0xFF2D6A4F);
const _kAssistBubbleBg = Color(0x1A003399); // خلفية زرقاء شديدة البهاء

TextStyle _cairo(double s,
        {FontWeight w = FontWeight.w500, Color? c, double? h}) =>
    TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: s,
      fontWeight: w,
      color: c,
      height: h,
    );

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return message.isUser
        ? _UserBubble(message: message)
        : _AssistantBubble(message: message);
  }
}

// ── فقاعة المستخدم (يمين في RTL) ───────────────────────────────────────────
class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 52, top: 4, bottom: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6BC489), _kMintBrand],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: _kMintBrand.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            message.content,
            style: _cairo(15,
                w: FontWeight.w600, c: Colors.white, h: 1.4),
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}

// ── فقاعة المساعد — حدود دائرية 15، خلفية باهتة، نص أخضر غامق ────────────────
class _AssistantBubble extends StatelessWidget {
  final ChatMessage message;
  const _AssistantBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 52, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(left: 8, bottom: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6BC489), _kMintBrand],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kMintBrand.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'ر',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: _kAssistBubbleBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _kMintBrand.withValues(alpha: 0.22),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kMintBrand.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: message.isLoading
                  ? const TypingIndicator(dotColor: _kMintBrand)
                  : Text(
                      message.content,
                      style: _cairo(15, c: _kMintDark, h: 1.5),
                      textDirection: TextDirection.rtl,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
