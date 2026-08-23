import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const DartMasterApp());
}

class DartMasterApp extends StatefulWidget {
  const DartMasterApp({super.key});

  @override
  State<DartMasterApp> createState() => _DartMasterAppState();
}

class _DartMasterAppState extends State<DartMasterApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isFirstTime = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppState();
  }

  // تحميل البيانات المخزنة محلياً عند فتح التطبيق
  Future<void> _loadAppState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
      bool? isDark = prefs.getBool('isDarkMode');
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      }
      _isLoading = false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
        prefs.setBool('isDarkMode', false);
      } else {
        _themeMode = ThemeMode.dark;
        prefs.setBool('isDarkMode', true);
      }
    });
  }

  Future<void> _completeWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    setState(() {
      _isFirstTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    bool isDarkMode = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: _isFirstTime
          ? WelcomeScreen(
              onToggleTheme: _toggleTheme,
              isDarkMode: isDarkMode,
              onStart: _completeWelcome,
            )
          : SimulatorScreen(
              onToggleTheme: _toggleTheme,
              isDarkMode: isDarkMode,
            ),
    );
  }
}

// -------------------------------------------------------------
// 1. Welcome Screen
// -------------------------------------------------------------
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final VoidCallback onStart;

  const WelcomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.code_rounded,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Welcome to Dart Master",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Practice Dart programming, test your knowledge with interactive quizzes, and build your skills.",
                style: TextStyle(
                  fontSize: 15,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: const Text(
                    "Start Coding 🚀",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. Syntax Highlighter Controller
// -------------------------------------------------------------
class AdvancedCodeController extends TextEditingController {
  final bool isDark;

  AdvancedCodeController({required this.isDark});

  @override
  TextSpan buildTextSpan(
      {required BuildContext context, TextStyle? style, required bool withComposing}) {
    List<TextSpan> children = [];
    String textToParse = text;

    final keywords = RegExp(
        r'\b(void|main|var|String|int|double|bool|List|Map|class|async|await|Future|if|else|for|while|return|print)\b');
    final numbers = RegExp(r'\b\d+\b');
    final strings = RegExp(r'"[^"]*"|\x27[^\x27]*\x27');
    final comments = RegExp(r'//.*');

    final pattern = RegExp(
      '${keywords.pattern}|${numbers.pattern}|${strings.pattern}|${comments.pattern}',
    );

    int currentPosition = 0;

    pattern.allMatches(textToParse).forEach((match) {
      if (match.start > currentPosition) {
        children.add(TextSpan(
          text: textToParse.substring(currentPosition, match.start),
          style: style,
        ));
      }

      String matchedText = match.group(0)!;
      TextStyle matchedStyle = style ?? const TextStyle();

      if (keywords.hasMatch(matchedText)) {
        matchedStyle = matchedStyle.copyWith(
            color: isDark ? const Color(0xFFFF79C6) : Colors.purple,
            fontWeight: FontWeight.bold);
      } else if (strings.hasMatch(matchedText)) {
        matchedStyle = matchedStyle.copyWith(
            color: isDark ? const Color(0xFFF1FA8C) : Colors.orange[800]);
      } else if (numbers.hasMatch(matchedText)) {
        matchedStyle = matchedStyle.copyWith(
            color: isDark ? const Color(0xFFBD93F9) : Colors.deepPurple);
      } else if (comments.hasMatch(matchedText)) {
        matchedStyle = matchedStyle.copyWith(
            color: Colors.grey, fontStyle: FontStyle.italic);
      }

      children.add(TextSpan(text: matchedText, style: matchedStyle));
      currentPosition = match.end;
    });

    if (currentPosition < textToParse.length) {
      children.add(TextSpan(
        text: textToParse.substring(currentPosition),
        style: style,
      ));
    }

    return TextSpan(style: style, children: children);
  }
}

// -------------------------------------------------------------
// 3. Quiz Question Model
// -------------------------------------------------------------
class QuizQuestion {
  final String questionAr;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.questionAr,
    required this.options,
    required this.correctIndex,
  });
}

// -------------------------------------------------------------
// 4. Main Simulator Screen
// -------------------------------------------------------------
class SimulatorScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const SimulatorScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  late AdvancedCodeController _codeController;
  String _result = "";
  bool _isSuccess = true;
  int _score = 0;
  bool _isQuizMode = false;
  double _editorFontSize = 15.0;

  int _quizIndex = 0;
  int? _selectedOption;

  final List<QuizQuestion> _quizzes = [
    QuizQuestion(
      questionAr: "ما هي الكلمة المفتاحية المستخدمة لطباعة النصوص في Dart؟",
      options: ["console.log", "print", "echo", "System.out.println"],
      correctIndex: 1,
    ),
    QuizQuestion(
      questionAr: "أي من التالي يمثل تعريفا صحبحاً لمتغير نصي؟",
      options: ["int x = 'Hi';", "String s = 'Hello';", "var s = 10;", "bool b = 'true';"],
      correctIndex: 1,
    ),
    QuizQuestion(
      questionAr: "ما هو نوع البيانات المستخدم لتمثيل الأرقام العشرية؟",
      options: ["int", "String", "double", "bool"],
      correctIndex: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _codeController = AdvancedCodeController(isDark: widget.isDarkMode);
    _result = "// المحاكي جاهز...";
    _loadScore();
  }

  Future<void> _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = prefs.getInt('userScore') ?? 0;
    });
  }

  Future<void> _addScore(int points) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _score += points;
    });
    await prefs.setInt('userScore', _score);
  }

  void _verifyQuiz() {
    if (_selectedOption == null) return;
    if (_selectedOption == _quizzes[_quizIndex].correctIndex) {
      _addScore(5);
      setState(() {
        _result = "✅ إجابة صحيحة! (+5 نقاط)";
        _isSuccess = true;
      });
    } else {
      setState(() {
        _result = "❌ إجابة خاطئة، حاول مجدداً.";
        _isSuccess = false;
      });
    }
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "⚙️ إعدادات محرر الأكواد",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text("حجم الخط: ${_editorFontSize.toInt()}"),
                  Slider(
                    value: _editorFontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 12,
                    onChanged: (val) {
                      setModalState(() => _editorFontSize = val);
                      setState(() => _editorFontSize = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = widget.isDarkMode;
    Color statusColor = _isSuccess ? Colors.greenAccent : Colors.redAccent;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isQuizMode ? "اختبار المعلومات (Quiz)" : "محاكي Dart التفاعلي"),
          actions: [
            IconButton(
              icon: Icon(_isQuizMode ? Icons.code : Icons.quiz),
              tooltip: _isQuizMode ? "الوضع البرمجي" : "وضع الاختبارات",
              onPressed: () => setState(() => _isQuizMode = !_isQuizMode),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsModal,
            ),
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: widget.onToggleTheme,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("🏆 النقاط: $_score", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (_isQuizMode)
                    Text("سؤال ${_quizIndex + 1}/${_quizzes.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 15),

              if (_isQuizMode) ...[
                Text(_quizzes[_quizIndex].questionAr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...List.generate(_quizzes[_quizIndex].options.length, (index) {
                  bool isSelected = _selectedOption == index;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withAlpha(40) : Colors.transparent,
                      border: Border.all(color: isSelected ? Colors.blue : Colors.grey.withAlpha(100), width: isSelected ? 2 : 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _selectedOption = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_quizzes[_quizIndex].options[index], style: const TextStyle(fontSize: 15))),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _verifyQuiz,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size.fromHeight(45)),
                  child: const Text("تأكيد الإجابة", style: TextStyle(color: Colors.white)),
                ),
                if (_quizIndex < _quizzes.length - 1)
                  TextButton(
                    onPressed: () => setState(() {
                      _quizIndex++;
                      _selectedOption = null;
                      _result = "// اختر الإجابة...";
                    }),
                    child: const Text("السؤال التالي ←"),
                  )
              ] else ...[
                SizedBox(
                  height: 300,
                  child: TextField(
                    controller: _codeController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isDark ? Colors.lightGreenAccent : Colors.black87,
                      fontSize: _editorFontSize,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                      hintText: '// اكتب كود Dart هنا...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_codeController.text.contains("print")) {
                        _addScore(10);
                        setState(() {
                          _result = "✅ تم التنفيذ بنجاح! (+10 نقاط)";
                          _isSuccess = true;
                        });
                      } else {
                        setState(() {
                          _result = "❌ الكود يحتوي خطأ أو لا يطبع شيئاً.";
                          _isSuccess = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("تشغيل الكود"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                ),
              ],

              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withAlpha(128)),
                ),
                child: Text(_result, style: TextStyle(color: statusColor, fontFamily: 'monospace')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
