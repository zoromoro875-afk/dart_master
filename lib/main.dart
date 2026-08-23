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
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
        prefs.setBool('isDarkMode', false);
      } else {
        _themeMode = ThemeMode.dark;
        prefs.setBool('isDarkMode', true);
      }
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
      home: CodeRunnerScreen(
        language: _language,
        onToggleTheme: _toggleTheme,
        onToggleLanguage: _toggleLanguage,
      ),
    );
  }
}

class CodeRunnerScreen extends StatefulWidget {
  final String language;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLanguage;

  const CodeRunnerScreen({
    super.key,
    required this.language,
    required this.onToggleTheme,
    required this.onToggleLanguage,
  });

  @override
  State<CodeRunnerScreen> createState() => _CodeRunnerScreenState();
}

class _CodeRunnerScreenState extends State<CodeRunnerScreen> {
  final TextEditingController _codeController = TextEditingController();
  int _score = 0;
  String _output = '';
  bool _isSuccess = false;
  final Set<String> _executedCodes = {};

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

  Future<void> _addScore(int points) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _score += points;
      prefs.setInt('userScore', _score);
    });
  }

  void _runCode() {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _output = widget.language == 'ar' ? 'الرجاء كتابة كود أولاً' : 'Please enter code first';
        _isSuccess = false;
      });
      return;
    }

    // التحقق السليم من كود print
    final printRegex = RegExp(r"^print\s*\(\s*(['" r'"])(.*?)\1\s*\)\s*;?$');
    if (printRegex.hasMatch(code)) {
      final match = printRegex.firstMatch(code);
      final printedText = match?.group(2) ?? '';

      setState(() {
        _output = printedText.isEmpty ? '(Empty output)' : printedText;
        _isSuccess = true;
      });

      // إعطاء نقاط مرة واحدة فقط لنفس الكود غير الفارغ
      if (!_executedCodes.contains(code) && printedText.isNotEmpty) {
        _executedCodes.add(code);
        _addScore(10);
      }
    } else {
      setState(() {
        _output = widget.language == 'ar'
            ? 'خطأ في القواعد: استخدم الشكل الصحيح print("نص");'
            : 'Syntax Error: Use print("text"); format';
        _isSuccess = false;
      });
    }
  }

  @overrideWidget build(BuildContext context) {
    bool isAr = widget.language == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'محاكي Dart التفاعلي' : 'Dart Interactive Runner'),
          actions: [
            TextButton(
              onPressed: widget.onToggleLanguage,
              child: Text(
                isAr ? 'EN' : 'عربي',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: widget.onToggleTheme,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'النقاط: $_score 🏆' : 'Score: $_score 🏆',
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
                  keyboardType: TextInputType.multiline,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
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
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: _isSuccess ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
