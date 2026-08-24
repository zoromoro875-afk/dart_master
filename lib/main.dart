import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const DartMasterApp());
}

class Lesson {
  final String id;
  final String titleAr;
  final String titleEn;
  final String contentAr;
  final String contentEn;
  final String initialCode;
  final String expectedKeyword;

  Lesson({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.contentAr,
    required this.contentEn,
    required this.initialCode,
    required this.expectedKeyword,
  });
}

class DartMasterApp extends StatefulWidget {
  const DartMasterApp({super.key});

  @override
  State<DartMasterApp> createState() => _DartMasterAppState();
}

class _DartMasterAppState extends State<DartMasterApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'ar';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'ar';
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
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    });
  }

  Future<void> _toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = _language == 'ar' ? 'en' : 'ar';
      prefs.setString('language', _language);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Dart Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: _themeMode,
      home: HomeScreen(
        language: _language,
        onToggleTheme: _toggleTheme,
        onToggleLanguage: _toggleLanguage,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String language;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLanguage;

  const HomeScreen({
    super.key,
    required this.language,
    required this.onToggleTheme,
    required this.onToggleLanguage,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _score = 0;
  int _currentIndex = 0;

  final List<Lesson> _lessons = [
    Lesson(
      id: 'lesson_1',
      titleAr: '1. طباعة النصوص',
      titleEn: '1. Printing Text',
      contentAr: 'تُستخدم الدالة print() لطباعة النصوص والمخرجات على الشاشة.',
      contentEn: 'The print() function is used to output text to the console.',
      initialCode: 'print("Hello Dart");',
      expectedKeyword: 'Hello',
    ),
    Lesson(
      id: 'lesson_2',
      titleAr: '2. المتغيرات (Variables)',
      titleEn: '2. Variables',
      contentAr: 'تُستخدم var لإنشاء متغير يخزن البيانات كالأسماء أو الأرقام.',
      contentEn: 'Use var to create a variable that stores data like names or numbers.',
      initialCode: 'var name = "Mustapha";\nprint(name);',
      expectedKeyword: 'Mustapha',
    ),
    Lesson(
      id: 'lesson_3',
      titleAr: '3. الأرقام والحساب',
      titleEn: '3. Numbers & Math',
      contentAr: 'يمكنك إجراء العمليات الحسابية المباشرة داخل الدالة print.',
      contentEn: 'You can perform mathematical operations directly inside print.',
      initialCode: 'var a = 10;\nvar b = 20;\nprint(a + b);',
      expectedKeyword: '30',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = prefs.getInt('userScore') ?? 0;
    });
  }

  void _updateScore(int newScore) {
    setState(() {
      _score = newScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = widget.language == 'ar';

    final List<Widget> pages = [
      LessonsListScreen(
        lessons: _lessons,
        language: widget.language,
        score: _score,
        onScoreUpdated: _updateScore,
      ),
      CodeRunnerScreen(
        language: widget.language,
        score: _score,
        onScoreUpdated: _updateScore,
      ),
    ];

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'Dart Master' : 'Dart Master'),
          actions: [
            TextButton(
              onPressed: widget.onToggleLanguage,
              child: Text(isAr ? 'EN' : 'عربي', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: widget.onToggleTheme,
            ),
          ],
        ),
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book),
              label: isAr ? 'الدروس' : 'Lessons',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.code),
              label: isAr ? 'المحاكي' : 'Runner',
            ),
          ],
        ),
      ),
    );
  }
}

class LessonsListScreen extends StatelessWidget {
  final List<Lesson> lessons;
  final String language;
  final int score;
  final Function(int) onScoreUpdated;

  const LessonsListScreen({
    super.key,
    required this.lessons,
    required this.language,
    required this.score,
    required this.onScoreUpdated,
  });

  @override
  Widget build(BuildContext context) {
    bool isAr = language == 'ar';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'المسار التعليمي 📚' : 'Learning Path 📚',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                isAr ? 'النقاط: $score 🏆' : 'Score: $score 🏆',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(isAr ? lesson.titleAr : lesson.titleEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(isAr ? lesson.contentAr : lesson.contentEn, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonDetailScreen(
                            lesson: lesson,
                            language: language,
                            score: score,
                            onScoreUpdated: onScoreUpdated,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final String language;
  final int score;
  final Function(int) onScoreUpdated;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.language,
    required this.score,
    required this.onScoreUpdated,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late TextEditingController _codeController;
  String _output = '';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.lesson.initialCode);
  }

  Future<void> _addScore(int points) async {
    final prefs = await SharedPreferences.getInstance();
    int newScore = widget.score + points;
    await prefs.setInt('userScore', newScore);
    widget.onScoreUpdated(newScore);
  }

  void _verifyLesson() {
    final code = _codeController.text.trim();
    bool isAr = widget.language == 'ar';

    if (code.contains(widget.lesson.expectedKeyword)) {
      setState(() {
        _output = isAr ? 'إجابة صحيحة! أحسنت 🎯 (+15 نقطة)' : 'Correct Answer! Well done 🎯 (+15 pts)';
        _isSuccess = true;
      });
      _addScore(15);
    } else {
      setState(() {
        _output = isAr ? 'حاول مرة أخرى، الكود لم يحقق المطلوب.' : 'Try again, code output does not match.';
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = widget.language == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? widget.lesson.titleAr : widget.lesson.titleEn),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? widget.lesson.contentAr : widget.lesson.contentEn,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _verifyLesson,
                  icon: const Icon(Icons.check_circle),
                  label: Text(isAr ? 'تحقق من الحل' : 'Verify Solution'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              if (_output.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _isSuccess ? Colors.green : Colors.red),
                  ),
                  child: Text(_output, style: TextStyle(color: _isSuccess ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CodeRunnerScreen extends StatefulWidget {
  final String language;
  final int score;
  final Function(int) onScoreUpdated;

  const CodeRunnerScreen({
    super.key,
    required this.language,
    required this.score,
    required this.onScoreUpdated,
  });

  @override
  State<CodeRunnerScreen> createState() => _CodeRunnerScreenState();
}

class _CodeRunnerScreenState extends State<CodeRunnerScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _output = '';
  bool _isSuccess = false;
  final Set<String> _executedCodes = {};

  Future<void> _addScore(int points) async {
    final prefs = await SharedPreferences.getInstance();
    int newScore = widget.score + points;
    await prefs.setInt('userScore', newScore);
    widget.onScoreUpdated(newScore);
  }

  void _runCode() {
    final code = _codeController.text.trim();
    bool isAr = widget.language == 'ar';

    if (code.isEmpty) {
      setState(() {
        _output = isAr ? 'الرجاء كتابة كود أولاً' : 'Please enter code first';
        _isSuccess = false;
      });
      return;
    }

    final printRegex = RegExp(r"^print\s*\(\s*(['" r'"])(.*?)\1\s*\)\s*;?$');
    if (printRegex.hasMatch(code)) {
      final match = printRegex.firstMatch(code);
      final printedText = match?.group(2) ?? '';

      setState(() {
        _output = printedText.isEmpty ? '(Empty output)' : printedText;
        _isSuccess = true;
      });

      if (!_executedCodes.contains(code) && printedText.isNotEmpty) {
        _executedCodes.add(code);
        _addScore(10);
      }
    } else {
      setState(() {
        _output = isAr ? 'خطأ في القواعد: استخدم الشكل الصحيح print("نص");' : 'Syntax Error: Use print("text"); format';
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = widget.language == 'ar';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'النقاط: ${widget.score} 🏆' : 'Score: ${widget.score} 🏆',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _codeController,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
              decoration: InputDecoration(
                hintText: isAr ? 'اكتب كود Dart هنا...\nمثال: print("Hello World");' : 'Write Dart code here...\nExample: print("Hello World");',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _runCode,
              icon: const Icon(Icons.play_arrow),
              label: Text(isAr ? 'تشغيل الكود' : 'Run Code'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _isSuccess ? Colors.green : Colors.red),
            ),
            child: Text(
              _output.isEmpty ? (isAr ? 'النتيجة تظهر هنا' : 'Output appears here') : _output,
              style: TextStyle(fontFamily: 'monospace', color: _isSuccess ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
