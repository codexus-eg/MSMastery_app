/// يحوّل معادلة LaTeX بحيث لما flutter_math_fork يرسمها (من الشمال لليمين)
/// تتقري من اليمين للشمال زي كتب المنهج المصري:
///   • ترتيب عناصر كل سطر بيتعكس (جوه الكسور والجذور والأقواس كمان).
///   • الأسس والرموز السفلية بتتحط على شمال الأساس.
///   • الرموز اللي ليها اتجاه بتتعكس: ( ) [ ] < > ≤ ≥ ← →.
///   • الأرقام (زي 12) بتفضل زي ما هي.
///   • أعمدة المصفوفات مش بتتعكس عشان معنى المصفوفة ما يتغيرش.
/// لو الـ TeX مش سليم بيرجع زي ما هو.
library;

String rtlTex(String tex) {
  try {
    final parser = _RtlTexParser(tex);
    final out = parser.parseList();
    return parser.done ? out : tex;
  } catch (_) {
    return tex;
  }
}

class _Atom {
  _Atom(this.base, {this.bigOp = false});
  String base;
  final bool bigOp;
  String? sup;
  String? sub;

  String render() {
    if (sup == null && sub == null) return base;
    final scripts =
        '${sup != null ? '^{$sup}' : ''}${sub != null ? '_{$sub}' : ''}';
    // المؤثرات الكبيرة (∑ ∫ نهـا) حدودها تفضل مكانها.
    return bigOp ? '$base$scripts' : '{}$scripts $base';
  }
}

const Map<String, String> _mirrorChars = {
  '(': ')', ')': '(', '[': ']', ']': '[', '<': '>', '>': '<',
  '→': '←', '←': '→',
};

const Map<String, String> _mirrorCommands = {
  'to': 'leftarrow', 'rightarrow': 'leftarrow', 'leftarrow': 'rightarrow',
  'Rightarrow': 'Leftarrow', 'Leftarrow': 'Rightarrow',
  'longrightarrow': 'longleftarrow', 'longleftarrow': 'longrightarrow',
  'Longrightarrow': 'Longleftarrow', 'Longleftarrow': 'Longrightarrow',
  'implies': 'impliedby', 'impliedby': 'implies',
  'leq': 'geq', 'geq': 'leq', 'le': 'ge', 'ge': 'le',
  'leqslant': 'geqslant', 'geqslant': 'leqslant',
  'nleq': 'ngeq', 'ngeq': 'nleq', 'lt': 'gt', 'gt': 'lt',
  'll': 'gg', 'gg': 'll',
  'subset': 'supset', 'supset': 'subset',
  'subseteq': 'supseteq', 'supseteq': 'subseteq',
  'in': 'ni', 'ni': 'in',
  'langle': 'rangle', 'rangle': 'langle',
  'lfloor': 'rfloor', 'rfloor': 'lfloor',
  'lceil': 'rceil', 'rceil': 'lceil',
  '{': '}', '}': '{',
};

const Set<String> _oneArg = {
  'vec', 'overrightarrow', 'overleftarrow', 'hat', 'widehat', 'bar',
  'overline', 'underline', 'tilde', 'widetilde', 'dot', 'ddot', 'mathbf',
  'mathit', 'boldsymbol', 'bm', 'mathbb', 'mathcal', 'mathsf', 'mathscr',
  'pmb', 'underbrace', 'overbrace', 'cancel', 'boxed',
};

const Set<String> _twoArg = {
  'frac', 'dfrac', 'tfrac', 'cfrac', 'binom', 'dbinom', 'tbinom',
  'overset', 'underset', 'stackrel',
};

const Set<String> _textCommands = {
  'text', 'textbf', 'textit', 'textrm', 'textnormal', 'mathrm',
  'operatorname', 'mbox', 'hbox',
};

const Set<String> _bigOps = {
  'sum', 'prod', 'coprod', 'int', 'iint', 'iiint', 'oint', 'lim', 'limsup',
  'liminf', 'max', 'min', 'sup', 'inf', 'bigcup', 'bigcap', 'bigoplus',
  'bigotimes',
};

const Set<String> _delimCommands = {
  'big', 'Big', 'bigg', 'Bigg', 'bigl', 'bigr', 'Bigl', 'Bigr', 'biggl',
  'biggr', 'Biggl', 'Biggr', 'middle',
};

// أوامر بتأثر على اللي بعدها، فلازم تفضل في أول السطر.
const Set<String> _switches = {
  'displaystyle', 'textstyle', 'scriptstyle', 'scriptscriptstyle', 'rm',
  'bf', 'it', 'sf', 'tt', 'cal',
};

final RegExp _arabic = RegExp(r'[ء-يـً-ْ]');
final RegExp _letter = RegExp(r'[a-zA-Z]');

bool _isDigit(String c) =>
    (c.compareTo('0') >= 0 && c.compareTo('9') <= 0) ||
    (c.compareTo('٠') >= 0 && c.compareTo('٩') <= 0);

class _RtlTexParser {
  _RtlTexParser(this.s);
  final String s;
  int pos = 0;

  bool get done => pos >= s.length;
  String get ch => s[pos];

  /// يقرا لحد آخر النص أو `}` أو `\right` أو `\end` ويرجع السطر معكوس.
  /// `&` و `\\` فواصل: كل خانة بتتعكس لوحدها وترتيب الخانات بيفضل زي ما هو.
  String parseList() {
    final pieces = <String>[];
    final prefix = <String>[];
    var atoms = <_Atom>[];

    void flush() {
      pieces.add([...prefix, ...atoms.reversed.map((a) => a.render())]
          .join(' '));
      atoms = [];
      prefix.clear();
    }

    _Atom lastAtom() {
      if (atoms.isEmpty) atoms.add(_Atom('{}'));
      return atoms.last;
    }

    while (!done) {
      final c = ch;
      if (c == '}') break;
      if (c.trim().isEmpty) {
        pos++;
        continue;
      }
      if (c == '&') {
        flush();
        pieces.add('&');
        pos++;
        continue;
      }
      if (c == r'\') {
        final name = _peekCommand();
        if (name == 'right' || name == 'end') break;
        if (name == r'\') {
          flush();
          pieces.add(r'\\');
          pos += 2;
          continue;
        }
        if (_switches.contains(name)) {
          _readCommand();
          prefix.add('\\$name');
          continue;
        }
        if ((name == 'limits' || name == 'nolimits') && atoms.isNotEmpty) {
          _readCommand();
          atoms.last.base += '\\$name';
          continue;
        }
      }
      if (c == '^' || c == '_') {
        pos++;
        final arg = _parseArg();
        final atom = lastAtom();
        if (c == '^') {
          atom.sup = atom.sup == null ? arg : '${atom.sup} $arg';
        } else {
          atom.sub = arg;
        }
        continue;
      }
      if (c == "'") {
        pos++;
        final atom = lastAtom();
        atom.sup = '${atom.sup ?? ''}\\prime ';
        continue;
      }
      atoms.add(_parseAtom());
    }
    flush();
    return pieces.join(' ');
  }

  _Atom _parseAtom() {
    final c = ch;
    if (c == '{') {
      pos++;
      final inner = parseList();
      _expect('}');
      return _Atom('{$inner}');
    }
    if (c == r'\') return _parseCommand();
    if (_isDigit(c)) {
      final start = pos;
      while (!done && (_isDigit(ch) || ch == '.')) {
        pos++;
      }
      return _Atom(s.substring(start, pos));
    }
    if (_arabic.hasMatch(c)) {
      final start = pos;
      while (!done && _arabic.hasMatch(ch)) {
        pos++;
      }
      return _Atom(s.substring(start, pos));
    }
    pos++;
    return _Atom(_mirrorChars[c] ?? c);
  }

  _Atom _parseCommand() {
    final name = _readCommand();
    final cmd = '\\$name';

    if (name == 'left') {
      final open = _readDelim();
      final inner = parseList();
      if (_readCommand() != 'right') throw const FormatException();
      final close = _readDelim();
      return _Atom('\\left${_mirrorDelim(close)} $inner \\right${_mirrorDelim(open)}');
    }
    if (name == 'begin') {
      final env = _readRawGroup();
      var head = '\\begin{$env}';
      if (env == 'array') head += '{${_readRawGroup()}}';
      final inner = parseList();
      if (_readCommand() != 'end') throw const FormatException();
      return _Atom('$head $inner \\end{${_readRawGroup()}}');
    }
    if (_textCommands.contains(name)) {
      final raw = _readRawGroup();
      // الكلام العربي جوه \text: ترتيب الكلمات بيتعكس عشان تتقري صح.
      final text = _arabic.hasMatch(raw)
          ? raw.split(' ').reversed.join(' ')
          : raw;
      return _Atom('$cmd{$text}');
    }
    if (_twoArg.contains(name)) {
      final a = _parseArg();
      final b = _parseArg();
      return _Atom('$cmd{$a}{$b}');
    }
    if (name == 'sqrt') {
      _skipSpaces();
      var index = '';
      if (!done && ch == '[') {
        final start = ++pos;
        var depth = 0;
        while (!done && !(ch == ']' && depth == 0)) {
          if (ch == '{') depth++;
          if (ch == '}') depth--;
          pos++;
        }
        _expect(']');
        index = '[${rtlTex(s.substring(start, pos - 1))}]';
      }
      return _Atom('\\sqrt$index{${_parseArg()}}');
    }
    if (_oneArg.contains(name)) return _Atom('$cmd{${_parseArg()}}');
    if (_delimCommands.contains(name)) {
      return _Atom('$cmd${_mirrorDelim(_readDelim())}');
    }
    if (_bigOps.contains(name)) return _Atom(cmd, bigOp: true);
    final mirrored = _mirrorCommands[name];
    return _Atom(mirrored != null ? '\\$mirrored' : cmd);
  }

  /// معامل أمر: `{...}` أو عنصر واحد (في `\frac12` كل رقم معامل لوحده).
  String _parseArg() {
    _skipSpaces();
    if (done) throw const FormatException();
    if (ch == '{') {
      pos++;
      final inner = parseList();
      _expect('}');
      return inner;
    }
    if (_isDigit(ch)) return s[pos++];
    return _parseAtom().render();
  }

  String _mirrorDelim(String d) {
    if (d.startsWith(r'\')) {
      final m = _mirrorCommands[d.substring(1)];
      return m != null ? '\\$m' : d;
    }
    return _mirrorChars[d] ?? d;
  }

  String _readDelim() {
    _skipSpaces();
    if (done) throw const FormatException();
    if (ch == r'\') return '\\${_readCommand()}';
    return s[pos++];
  }

  String? _peekCommand() {
    if (pos + 1 >= s.length) return null;
    var end = pos + 1;
    if (!_letter.hasMatch(s[end])) return s[end];
    while (end < s.length && _letter.hasMatch(s[end])) {
      end++;
    }
    return s.substring(pos + 1, end);
  }

  String _readCommand() {
    _skipSpaces();
    if (done || ch != r'\') throw const FormatException();
    final name = _peekCommand();
    if (name == null) throw const FormatException();
    pos += 1 + name.length;
    return name;
  }

  String _readRawGroup() {
    _skipSpaces();
    _expect('{');
    final start = pos;
    var depth = 0;
    while (!done && !(ch == '}' && depth == 0)) {
      if (ch == '{') depth++;
      if (ch == '}') depth--;
      pos++;
    }
    _expect('}');
    return s.substring(start, pos - 1);
  }

  void _skipSpaces() {
    while (!done && ch.trim().isEmpty) {
      pos++;
    }
  }

  void _expect(String c) {
    if (done || ch != c) throw const FormatException();
    pos++;
  }
}
