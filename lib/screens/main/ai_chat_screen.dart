import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/constants/arabic_tex_reshaper.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/rtl_tex.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/screens/main/image_crop_screen.dart';
import 'package:salah_online_platform/services/math_ai_service.dart';

class _AiMessage {
  _AiMessage.user({required this.image, required this.branch})
      : fromUser = true,
        text = null;

  _AiMessage.ai({required this.image, required this.branch}) : fromUser = false;

  final bool fromUser;
  final MathBranch branch;
  final Uint8List image; // صورة السؤال (في رد الـ AI بنحتاجها لإعادة المحاولة)
  String? text;
  bool isLoading = false;
  bool isError = false;
}

/// شات الطالب مع مساعد الرياضيات: يختار الفرع، يصوّر السؤال ويقصه، ويستلم الحل.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final List<_AiMessage> _messages = [];
  MathBranch? _branch;
  bool _isSending = false;

  // الصورة اللي الطالب اختارها ولسه ما اتبعتتش: الأصلية (لإعادة القص) وبعد القص.
  Uint8List? _draftOriginal;
  Uint8List? _draft;

  // بعد ما السؤال يتحل بنعرض زرار "حل سؤال تاني" بدل أزرار اختيار الصورة.
  bool _showSolveAnother = false;

  bool get _isDark => PlatformCubit.get(context).isDarkMode;
  Color get _primary => Components.setBgColor(_isDark);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image;
    try {
      image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );
    } catch (e) {
      debugPrint('AI chat pick image error: $e');
      _showSnack('مش قادر أفتح الكاميرا أو المعرض');
      return;
    }
    if (image == null || !mounted) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    // لو لغى القص، الصورة ما بتتضافش.
    final cropped = await _openCropper(bytes);
    if (cropped == null || !mounted) return;
    setState(() {
      _draftOriginal = bytes;
      _draft = cropped;
    });
  }

  Future<Uint8List?> _openCropper(Uint8List bytes) {
    return Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => ImageCropScreen(image: bytes, primaryColor: _primary),
      ),
    );
  }

  Future<void> _recrop() async {
    final original = _draftOriginal;
    if (original == null) return;
    final cropped = await _openCropper(original);
    if (cropped == null || !mounted) return;
    setState(() => _draft = cropped);
  }

  void _deleteDraft() {
    setState(() {
      _draft = null;
      _draftOriginal = null;
    });
  }

  Future<void> _sendDraft() async {
    final branch = _branch;
    final image = _draft;
    if (image == null) return;
    if (branch == null) {
      _showSnack('اختار الفرع الأول يا هندسة');
      return;
    }

    final reply = _AiMessage.ai(image: image, branch: branch);
    setState(() {
      _messages.add(_AiMessage.user(image: image, branch: branch));
      _messages.add(reply);
      _draft = null;
      _draftOriginal = null;
    });
    await _solve(reply);
  }

  Future<void> _solve(_AiMessage reply) async {
    setState(() {
      _isSending = true;
      _showSolveAnother = false;
      reply
        ..isLoading = true
        ..isError = false
        ..text = null;
    });
    _scrollToBottom();

    try {
      final solution = await MathAiService.solve(
        branchId: reply.branch.id,
        image: reply.image,
      );
      reply.text = solution;
    } catch (e) {
      reply
        ..isError = true
        ..text = e is MathAiException ? e.message : 'حدث خطأ غير متوقع';
    }

    if (!mounted) return;
    setState(() {
      reply.isLoading = false;
      _isSending = false;
      _showSolveAnother = true;
    });
    _scrollToBottom();
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _draft = null;
      _draftOriginal = null;
      _showSolveAnother = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDark ? AppColors.darkBgColor : AppColors.lightBgColor;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          title: const Text(
            'مساعد الرياضيات الذكي',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            if ((_messages.isNotEmpty || _draft != null) && !_isSending)
              IconButton(
                tooltip: 'محادثة جديدة',
                icon: const Icon(Icons.refresh),
                onPressed: _startNewChat,
              ),
          ],
        ),
        body: Column(
          children: [
            _buildBranchSelector(),
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final m = _messages[i];
                        return m.fromUser
                            ? _buildUserBubble(m)
                            : _buildAiBubble(m);
                      },
                    ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: _isDark ? AppColors.darkBorder : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: _isDark ? Colors.white12 : AppColors.lightBborder,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: mathBranches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final b = mathBranches[i];
          final selected = _branch?.id == b.id;
          return ChoiceChip(
            label: Text(b.label),
            selected: selected,
            showCheckmark: false,
            selectedColor: _primary,
            backgroundColor: _isDark ? AppColors.darkBgColor : Colors.white,
            side: BorderSide(color: selected ? _primary : Colors.grey),
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : (_isDark ? Colors.white70 : Colors.black87),
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: _isSending ? null : (_) => setState(() => _branch = b),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final textColor = _isDark ? Colors.white70 : Colors.black54;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _primary.withValues(alpha: 0.15),
              child: Icon(Icons.auto_awesome, size: 40, color: _primary),
            ),
            const SizedBox(height: 16),
            Text(
              'أهلاً يا هندسة 👋',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '١. اختار فرع السؤال من فوق\n'
              '٢. صوّر السؤال أو ارفع صورته\n'
              '٣. استلم الحل خطوة بخطوة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.9, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBubble(_AiMessage m) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(16),
            topEnd: Radius.circular(16),
            bottomEnd: Radius.circular(16),
            bottomStart: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                m.image,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
              child: Text(
                'فرع ${m.branch.label}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiBubble(_AiMessage m) {
    final textColor = _isDark ? Colors.white : Colors.black87;
    Widget child;
    if (m.isLoading) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
          ),
          const SizedBox(width: 12),
          Text('جاري الحل…', style: TextStyle(color: textColor)),
        ],
      );
    } else if (m.isError) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  m.text ?? '',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _isSending ? null : () => _solve(m),
            icon: Icon(Icons.refresh, color: _primary),
            label: Text('حاول تاني', style: TextStyle(color: _primary)),
          ),
        ],
      );
    } else {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GptMarkdown(
            m.text ?? '',
            textDirection: TextDirection.rtl,
            useDollarSignsForLatex: true,
            isStreaming: false,
            latexBuilder: _buildLatex,
            style: TextStyle(color: textColor, fontSize: 15, height: 1.7),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: IconButton(
              tooltip: 'نسخ الحل',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.copy, size: 18, color: textColor),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: m.text ?? ''));
                _showSnack('تم نسخ الحل');
              },
            ),
          ),
        ],
      );
    }

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        width: m.isLoading ? null : double.infinity,
        decoration: BoxDecoration(
          color: _isDark ? AppColors.darkBorder : Colors.white,
          border: Border.all(
            color: _isDark ? Colors.white12 : AppColors.lightBborder,
          ),
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(16),
            topEnd: Radius.circular(16),
            bottomStart: Radius.circular(16),
            bottomEnd: Radius.circular(4),
          ),
        ),
        child: child,
      ),
    );
  }

  /// المعادلات بتتقري من اليمين للشمال: rtlTex بيعكس ترتيب المعادلة في الـ TeX
  /// نفسه، وflutter_math_fork بيرسمها من الشمال لليمين (Directionality.ltr)
  /// عشان الحروف المفردة زي "(" ما تتعكسش مرة تانية.
  Widget _buildLatex(
    BuildContext context,
    String tex,
    TextStyle textStyle,
    bool inline,
  ) {
    final color = textStyle.color ?? (_isDark ? Colors.white : Colors.black87);
    const font = FontOptions(fontFamily: 'Main');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Math.tex(
        reshapeArabicInTex(rtlTex(tex)),
        textStyle: textStyle,
        mathStyle: MathStyle.display,
        textScaleFactor: 1,
        settings: const TexParserSettings(strict: Strict.ignore),
        options: MathOptions(
          sizeUnderTextStyle: MathSize.large,
          color: color,
          fontSize: textStyle.fontSize ?? 15,
          mathFontOptions: font,
          textFontOptions: font,
          style: MathStyle.display,
        ),
        // لو المعادلة مش سليمة نعرض الـ TeX الأصلي (من غير reshape) كنص عادي.
        onErrorFallback: (_) => Text(
          tex,
          textDirection: TextDirection.ltr,
          style: textStyle.copyWith(color: color),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    final Widget content;
    if (_showSolveAnother && _draft == null) {
      content = SizedBox(
        width: double.infinity,
        child: _inputButton(
          icon: Icons.add_a_photo,
          label: 'حل سؤال تاني',
          onPressed: () => setState(() => _showSolveAnother = false),
        ),
      );
    } else if (_draft != null) {
      content = _buildDraftPreview(_draft!);
    } else {
      content = _buildPickButtons();
    }

    return Container(
      decoration: BoxDecoration(
        color: _isDark ? AppColors.darkBorder : Colors.white,
        border: Border(
          top: BorderSide(
            color: _isDark ? Colors.white12 : AppColors.lightBborder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(padding: const EdgeInsets.all(12), child: content),
      ),
    );
  }

  Widget _buildPickButtons() {
    final canUseCamera = _picker.supportsImageSource(ImageSource.camera);
    return Row(
      children: [
        if (canUseCamera) ...[
          Expanded(
            child: _inputButton(
              icon: Icons.camera_alt,
              label: 'صوّر السؤال',
              onPressed: () => _pickImage(ImageSource.camera),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: _inputButton(
            icon: Icons.photo_library,
            label: 'من المعرض',
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildDraftPreview(Uint8List image) {
    final hintColor = _isDark ? Colors.white70 : Colors.black54;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: _isDark ? Colors.black26 : Colors.black12,
                constraints: BoxConstraints(
                  maxHeight: 140,
                  maxWidth: MediaQuery.sizeOf(context).width * 0.5,
                ),
                child: Image.memory(image, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _draftAction(
                    icon: Icons.crop,
                    label: 'قص تاني',
                    color: _primary,
                    onPressed: _recrop,
                  ),
                  _draftAction(
                    icon: Icons.delete_outline,
                    label: 'امسح الصورة',
                    color: Colors.red,
                    onPressed: _deleteDraft,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_branch == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'اختار فرع السؤال من فوق الأول',
              style: TextStyle(color: hintColor, fontSize: 13),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: _inputButton(
            icon: Icons.auto_awesome,
            label:
                _branch == null ? 'حل السؤال' : 'حل السؤال (${_branch!.label})',
            onPressed: _branch == null ? null : _sendDraft,
          ),
        ),
      ],
    );
  }

  Widget _draftAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: _isSending ? null : onPressed,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
    );
  }

  Widget _inputButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: _isSending ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
