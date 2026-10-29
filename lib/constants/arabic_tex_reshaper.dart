/// يجهّز الحروف العربية داخل معادلات LaTeX قبل رسمها بـ flutter_math_fork.
///
/// flutter_math_fork يرسم كل حرف في المعادلة كـ widget منفصل ومن الشمال لليمين،
/// فكلمة زي "جتا" بتظهر حروف مقطعة ومعكوسة. الحل: نحوّل كل حرف لشكله المتصل
/// (Arabic Presentation Forms-B: أول/وسط/آخر الكلمة) ونعكس ترتيب حروف الكلمة،
/// فلما تترسم الحروف جنب بعض من الشمال لليمين تبان متصلة ومقروءة صح.
library;

// الأشكال: [منفصل، آخر، أول، وسط]. الحروف اللي بتتصل بما قبلها بس ليها شكلين.
final Map<int, List<int>> _forms = _buildForms();

// الحروف U+0621..U+064A مرتبة بنفس ترتيب أشكالها في البلوك U+FE80..U+FEF4،
// وكل حرف بياخد 1 (ء) أو 2 (يتصل بما قبله بس) أو 4 (يتصل من الناحيتين) خانات.
Map<int, List<int>> _buildForms() {
  const letters = [
    [0x0621, 1], [0x0622, 2], [0x0623, 2], [0x0624, 2], [0x0625, 2], // ء آ أ ؤ إ
    [0x0626, 4], [0x0627, 2], [0x0628, 4], [0x0629, 2], [0x062A, 4], // ئ ا ب ة ت
    [0x062B, 4], [0x062C, 4], [0x062D, 4], [0x062E, 4], [0x062F, 2], // ث ج ح خ د
    [0x0630, 2], [0x0631, 2], [0x0632, 2], [0x0633, 4], [0x0634, 4], // ذ ر ز س ش
    [0x0635, 4], [0x0636, 4], [0x0637, 4], [0x0638, 4], [0x0639, 4], // ص ض ط ظ ع
    [0x063A, 4], [0x0641, 4], [0x0642, 4], [0x0643, 4], [0x0644, 4], // غ ف ق ك ل
    [0x0645, 4], [0x0646, 4], [0x0647, 4], [0x0648, 2], [0x0649, 2], // م ن ه و ى
    [0x064A, 4], // ي
  ];
  final forms = <int, List<int>>{};
  var next = 0xFE80;
  for (final l in letters) {
    final count = l[1];
    forms[l[0]] = List.generate(count, (i) => next + i);
    next += count;
  }
  return forms;
}

const int _tatweel = 0x0640; // ـ (زي اللي في "هـ")
const int _lam = 0x0644;

// لام + ألف → ليجاتشر [منفصل، آخر].
const Map<int, List<int>> _lamAlef = {
  0x0622: [0xFEF5, 0xFEF6], // لآ
  0x0623: [0xFEF7, 0xFEF8], // لأ
  0x0625: [0xFEF9, 0xFEFA], // لإ
  0x0627: [0xFEFB, 0xFEFC], // لا
};

final RegExp _arabicRun = RegExp(r'[ء-يـً-ْ]+');
final RegExp _harakat = RegExp(r'[ً-ْ]');

bool _isArabic(int c) => c == _tatweel || _forms.containsKey(c);

/// الحرف يقدر يتوصل بالحرف اللي بعده (يعني ليه شكل أول/وسط).
bool _joinsNext(int c) => c == _tatweel || (_forms[c]?.length ?? 0) == 4;

/// الحرف يقدر يتوصل بالحرف اللي قبله.
bool _joinsPrev(int c) => c == _tatweel || (_forms[c]?.length ?? 0) >= 2;

/// يحوّل كل كلمة عربية داخل الـ TeX لأشكالها المتصلة بترتيب معكوس.
/// أوامر LaTeX كلها حروف لاتينية فمش بتتأثر.
String reshapeArabicInTex(String tex) {
  if (!tex.codeUnits.any(_isArabic)) return tex;
  return tex.replaceAllMapped(
    _arabicRun,
    (m) => _reshapeWord(m[0]!.replaceAll(_harakat, '')),
  );
}

String _reshapeWord(String word) {
  final chars = word.codeUnits;
  final out = <int>[];
  for (var i = 0; i < chars.length; i++) {
    final c = chars[i];
    final prev = i > 0 ? chars[i - 1] : null;
    final next = i + 1 < chars.length ? chars[i + 1] : null;
    final connectsPrev = prev != null && _joinsNext(prev) && _joinsPrev(c);

    if (c == _lam && next != null && _lamAlef.containsKey(next)) {
      out.add(_lamAlef[next]![connectsPrev ? 1 : 0]);
      i++; // الألف اتدمجت في الليجاتشر
      continue;
    }
    if (c == _tatweel) {
      out.add(c);
      continue;
    }

    final forms = _forms[c]!;
    final connectsNext = next != null && _joinsNext(c) && _joinsPrev(next);
    final index = switch ((connectsPrev, connectsNext)) {
      (true, true) => 3,
      (false, true) => 2,
      (true, false) => 1,
      (false, false) => 0,
    };
    out.add(forms[index]);
  }
  return String.fromCharCodes(out.reversed);
}
