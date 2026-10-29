import 'package:flutter_test/flutter_test.dart';
import 'package:salah_online_platform/constants/arabic_tex_reshaper.dart';

String cps(List<int> codes) => String.fromCharCodes(codes);

void main() {
  test('leaves LaTeX without Arabic untouched', () {
    const tex = r'\frac{\sqrt{3}}{2} + \vec{v}';
    expect(reshapeArabicInTex(tex), tex);
  });

  test('curriculum function names become joined and reversed', () {
    expect(reshapeArabicInTex('جا'), cps([0xFE8E, 0xFE9F]));
    expect(reshapeArabicInTex('جتا'), cps([0xFE8E, 0xFE98, 0xFE9F]));
    expect(reshapeArabicInTex('قا'), cps([0xFE8E, 0xFED7]));
    expect(reshapeArabicInTex('لو'), cps([0xFEEE, 0xFEDF]));
    expect(reshapeArabicInTex('هـ'), cps([0x0640, 0xFEEB]));
  });

  test('single letters use the isolated form', () {
    expect(reshapeArabicInTex('ن'), cps([0xFEE5]));
  });

  test('right-joining letters break the connection', () {
    // د ا ر never connect to the following letter.
    expect(reshapeArabicInTex('دار'), cps([0xFEAD, 0xFE8D, 0xFEA9]));
  });

  test('lam-alef becomes a ligature', () {
    expect(reshapeArabicInTex('لا'), cps([0xFEFB]));
    expect(reshapeArabicInTex('ملا'), cps([0xFEFC, 0xFEE3]));
  });

  test('harakat are dropped before shaping', () {
    expect(reshapeArabicInTex('جَا'), reshapeArabicInTex('جا'));
  });

  test('only Arabic runs change inside a full equation', () {
    expect(
      reshapeArabicInTex(r'\vec{ن} = \frac{جا س}{2}'),
      '\\vec{${cps([0xFEE5])}} = \\frac{${cps([0xFE8E, 0xFE9F])} ${cps([0xFEB1])}}{2}',
    );
  });
}
