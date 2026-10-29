import 'dart:typed_data';

import 'package:dio/dio.dart';

/// فرع رياضيات يرسل الـ [id] الخاص به إلى الـ backend.
class MathBranch {
  const MathBranch(this.id, this.label, this.sub);
  final String id;
  final String label;
  final String sub;
}

/// نفس قائمة الفروع الموجودة في الموقع (src/lib/branches.ts) والـ backend (prompts/index.js).
const List<MathBranch> mathBranches = [
  MathBranch('algebra', 'الجبر', 'المعادلات والمصفوفات'),
  MathBranch('solidGeometry', 'الهندسة الفراغية', 'المتجهات والمستويات'),
  MathBranch('differentiation', 'التفاضل', 'المشتقات ومعدلات التغير'),
  MathBranch('integration', 'التكامل', 'المساحات والحجوم'),
  MathBranch('statics', 'الاستاتيكا', 'الاتزان والعزوم'),
  MathBranch('dynamics', 'الديناميكا', 'الحركة والعجلة'),
];

class MathAiException implements Exception {
  MathAiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// عميل الـ backend الخاص بمساعد الرياضيات (POST /solve).
class MathAiService {
  static const String baseUrl = 'https://math-model-production.up.railway.app';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 90),
      // نتعامل مع أكواد الخطأ بأنفسنا لاستخراج الرسالة العربية من الـ backend.
      validateStatus: (_) => true,
    ),
  );

  /// يرسل صورة السؤال مع الفرع ويرجع الحل (Markdown + LaTeX).
  static Future<String> solve({
    required String branchId,
    required Uint8List image,
  }) async {
    // الصورة بعد القص ممكن تبقى PNG أو JPEG، فبنبعت النوع الصح للـ backend.
    final isPng = image.length > 1 && image[0] == 0x89 && image[1] == 0x50;
    final form = FormData.fromMap({
      'branch': branchId,
      'image': MultipartFile.fromBytes(
        image,
        filename: isPng ? 'question.png' : 'question.jpg',
        contentType: DioMediaType('image', isPng ? 'png' : 'jpeg'),
      ),
    });

    final Response res;
    try {
      res = await _dio.post('/solve', data: form);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw MathAiException('السيرفر أخد وقت طويل — جرب تاني يا هندسة');
      }
      throw MathAiException(
          'فشل الاتصال بالخادم — تأكد من الإنترنت وحاول مرة أخرى');
    }

    final data = res.data;
    final status = res.statusCode ?? 0;

    if (status >= 200 && status < 300 && data is Map) {
      final solution = data['solution'];
      if (solution is String && solution.trim().isNotEmpty) return solution;
      throw MathAiException('الـ AI مرجعش حل — جرب تصور السؤال تاني بشكل أوضح');
    }

    String? errorMsg;
    if (data is Map) {
      errorMsg = (data['error'] ?? data['message'])?.toString();
    }
    throw MathAiException(errorMsg ?? 'فشل في حل السؤال (كود: $status)');
  }
}
