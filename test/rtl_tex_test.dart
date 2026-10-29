import 'package:flutter_test/flutter_test.dart';
import 'package:salah_online_platform/constants/rtl_tex.dart';

void main() {
  test('reverses the row, mirrors brackets and moves exponents left', () {
    expect(
      rtlTex(r'\vec{س} = (ن^2 - 12ن + 9)\vec{ى}'),
      r'\vec{ى} ( 9 + ن 12 - {}^{2} ن ) = \vec{س}',
    );
  });

  test('keeps multi-digit numbers and decimals intact', () {
    expect(rtlTex('12.5 + 30'), '30 + 12.5');
  });

  test('recurses into fractions, roots and groups', () {
    expect(rtlTex(r'\frac{1}{س+2}'), r'\frac{1}{2 + س}');
    expect(rtlTex(r'\sqrt{س - 1}'), r'\sqrt{1 - س}');
    expect(rtlTex(r'\sqrt[3]{8}'), r'\sqrt[3]{8}');
    expect(rtlTex(r'\frac12'), r'\frac{1}{2}');
  });

  test('mirrors inequalities and arrows', () {
    expect(rtlTex(r'س \leq 5'), r'5 \geq س');
    expect(rtlTex('س < 5'), '5 > س');
    expect(rtlTex(r'س \to 0'), r'0 \leftarrow س');
  });

  test('big operators keep their limits in place', () {
    expect(rtlTex(r'\lim_{س \to 0} د(س)'), r'( س ) د \lim_{0 \leftarrow س}');
  });

  test('left/right delimiters are mirrored around reversed content', () {
    expect(rtlTex(r'\left[ 0, 1 \right)'), r'\left( 1 , 0 \right]');
  });

  test('matrix columns keep their order', () {
    expect(
      rtlTex(r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}'),
      r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}',
    );
  });

  test('Arabic text inside \\text keeps reading order', () {
    expect(rtlTex(r'\text{حيث س عدد}'), r'\text{عدد س حيث}');
  });

  test('style switches stay at the start', () {
    expect(rtlTex(r'\displaystyle س + 1'), r'\displaystyle 1 + س');
  });

  test('malformed TeX is returned unchanged', () {
    expect(rtlTex(r'\frac{1}{2'), r'\frac{1}{2');
    expect(rtlTex(r'س }'), r'س }');
  });
}
