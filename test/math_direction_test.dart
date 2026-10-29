import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salah_online_platform/constants/arabic_tex_reshaper.dart';
import 'package:salah_online_platform/constants/rtl_tex.dart';

// المعادلة اللي ظهرت معكوسة في الشات.
const _tex = r'\vec{س} = (ن^2 - 12ن + 9)\vec{ى}';

void main() {
  testWidgets('equation reads right-to-left on an RTL screen', (t) async {
    // نفس اللي بيعمله _buildLatex في شاشة الشات.
    await t.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Math.tex(
                  reshapeArabicInTex(rtlTex(_tex)),
                  settings: const TexParserSettings(strict: Strict.ignore),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // أول ظهور لكل رمز من الشمال لليمين.
    final x = <String, double>{};
    for (final e in find.byType(RichText).evaluate()) {
      final text = (e.widget as RichText).text.toPlainText();
      x.putIfAbsent(text, () => t.getTopLeft(find.byWidget(e.widget)).dx);
    }

    final seen = reshapeArabicInTex('س');
    final ya = reshapeArabicInTex('ى');
    // على الشاشة: ى (9 + ن12 − ²ن) = س  ← بتتقري: س = (ن² − 12ن + 9) ى
    expect(x[ya]!, lessThan(x['(']!));
    expect(x['(']!, lessThan(x['9']!));
    expect(x['9']!, lessThan(x[')']!));
    expect(x[')']!, lessThan(x['=']!));
    expect(x['=']!, lessThan(x[seen]!));
  });
}
