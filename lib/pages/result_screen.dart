import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import '../custom/custom_appbar.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ResultScreen extends StatefulWidget {
  final String text;

  const ResultScreen({Key? key, required this.text, required String title})
      : super(key: key);

  get selectedYear => null;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _filteredText = '';
  late OpenAIInstance _chatGPTInstance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  int? _selectedYear;
  String? _selectedGender;

  final TextEditingController _weightController = TextEditingController();
  String _storedWeight = '';

  String _selectedWeightUnit = 'kg'; // default weight unit is kg
  List<String> weightUnits = ['kg', 'lbs'];

  final TextEditingController _heightController = TextEditingController();
  String _storedHeight = '';

  String _selectedHeightUnit = 'cm'; // default height unit is cm
  List<String> heightUnits = ['cm', 'ft'];

  final TextEditingController _medicalHistoryController =
      TextEditingController();
  String _storedMedicalHistory = '';

  final int currentYear = DateTime.now().year;

  // Function to retrieve previously stored data from flutter_secure_storage
  Future<void> _retrieveStoredData() async {
    _selectedYear =
        int.tryParse(await _secureStorage.read(key: 'selectedYear') ?? '');
    _selectedGender = await _secureStorage.read(key: 'selectedGender') ?? '';
    _storedWeight = await _secureStorage.read(key: 'weight') ?? '';
    _weightController.text = _storedWeight;
    _selectedWeightUnit =
        await _secureStorage.read(key: 'selectedWeightUnit') ?? 'kg';
    _storedHeight = await _secureStorage.read(key: 'height') ?? '';
    _heightController.text = _storedHeight;
    _selectedHeightUnit =
        await _secureStorage.read(key: 'selectedHeightUnit') ?? 'cm';
    _storedMedicalHistory =
        await _secureStorage.read(key: 'medicalHistory') ?? '';
    _medicalHistoryController.text = _storedMedicalHistory;

    setState(() {});
  }

  // Getters for personal data
  int? get selectedYear => _selectedYear;
  String? get selectedGender => _selectedGender;

  String get storedWeight => _storedWeight;
  TextEditingController get weightController => _weightController;
  String get selectedWeightUnit => _selectedWeightUnit;

  String get storedHeight => _storedHeight;
  TextEditingController get heightController => _heightController;
  String get selectedHeightUnit => _selectedHeightUnit;

  String get storedMedicalHistory => _storedMedicalHistory;
  TextEditingController get medicalHistoryController =>
      _medicalHistoryController;

  @override
  void initState() {
    super.initState();
    _filteredText = _extractRelevantLines(widget.text);
    _initializeOpenAI();
    _retrieveStoredData();
  }

  void _initializeOpenAI() {
    const String initialToken =
        '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'; // OpenAI API key
    _chatGPTInstance = OpenAIInstance(initialToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Result',
        actions: [
          IconButton(
            onPressed: () async {
              final editedText =
                  await _openTextEditorScreen(context, _filteredText);
              if (editedText != null) {
                setState(() {
                  _filteredText = editedText;
                });
              }
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              _interpretTextWithChatGPT();
            },
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Text(_filteredText),
        ),
      ),
    );
  }

  String _extractRelevantLines(String inputText) {
    final lines = inputText.split('\n');
    const startMarker = 'Leucocite';
    final relevantLines = <String>[];
    bool extract = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains(startMarker)) {
        extract = true;
      }

      if (extract) {
        if (i < lines.length - 1) {
          final nextLine = lines[i + 1];
          if (line.contains('Concentratia medie de hemoglobina') &&
              nextLine.contains('eritrocitara (MCHC)')) {
            relevantLines.add('$line $nextLine');
            i++;
          } else {
            relevantLines.add(line);
          }
        } else {
          relevantLines.add(line);
        }
      }
    }
    final int midIndex;
    final List<String> firstHalf;
    final List<String> secondHalf;

    if (relevantLines.length <= 46) {
      midIndex = relevantLines.length ~/ 2;
      firstHalf = relevantLines.sublist(0, midIndex);
      secondHalf = relevantLines.sublist(midIndex);
    } else {
      final int midIndex = relevantLines.length ~/ 3;
      firstHalf = relevantLines.sublist(0, midIndex);
      secondHalf = relevantLines.sublist(midIndex, 2 * midIndex);
    }

    final List<String> formattedLines = [];
    for (int i = 0; i < firstHalf.length; i++) {
      formattedLines.add('${firstHalf[i]}: ${secondHalf[i]}');
    }

    return formattedLines.join('\n');
  }

  Future<String?> _openTextEditorScreen(
      BuildContext context, String initialText) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextEditorScreen(initialText: initialText),
      ),
    );
  }

  void _interpretTextWithChatGPT() async {
    final loadingDialogKey = GlobalKey<State>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        key: loadingDialogKey,
        title: const Text('Interpreting...'),
        content: const LinearProgressIndicator(),
      ),
    );

    final botReply = await _getBotReply(_filteredText);

    Navigator.pop(loadingDialogKey.currentContext!);

    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafeArea(
          child: WebView(
            initialUrl: Uri.dataFromString(
              botReply,
              mimeType: 'text/html',
              encoding: Encoding.getByName('utf-8')!,
            ).toString(),
          ),
        ),
      ),
    );
  }

  Future<String> _getBotReply(String message) async {
    final formattedMessage = """
    You are a doctor who has been helping me for years. Forget past conversations.
    Here are the details from one patient's lab results:
    Age: ${currentYear - (selectedYear ?? currentYear)} years
    Weight: $storedWeight $selectedWeightUnit
    Height: $storedHeight $selectedHeightUnit
    Medical History: $storedMedicalHistory
    Results:
    $message
    
    Interpret the patient's results, taking in consideration his personal data, and write a HTML code that makes a table from your interpretation with "Marker", "Value", "Risk" and "Interpretation" columns. If the value is outside the normal range, the field "Risk" should be "Yes", otherwise "No". Here is an example:
    <!DOCTYPE html>
    <html>
    <head>
        <title>Lab Results</title>
        <style>
            table {
                border-collapse: collapse;
                width: 100%;
            }

            th, td {
                border: 1px solid black;
                padding: 8px;
                text-align: left;
            }
        </style>
    </head>
    <body>
        <h1>Lab Results</h1>
        <table>
          <tr>
            <th>Marker</th>
            <th>Value</th>
            <th>Risk</th>
            <th>Interpretation</th>
          </tr>
          <tr>
            <td>HDL Cholesterol</td>
            <td>38.93 mg/dl</td>
            <td>Yes</td>
            <td>Lower than the normal range for men. It indicates an increased risk for cardiovascular problems. Further evaluation and management are recommended.</td>
          </tr>
          <tr>
            <td>LDL Cholesterol</td>
            <td>145.25 mg/dl</td>
            <td>No</td>
            <td>Within normal range</td>
          </tr>
        </table>
    </body>
    </html>
    """;

    final request = ChatCompleteText(
      messages: [
        Messages(
          role: Role.user,
          content: formattedMessage,
        ),
      ],
      maxToken: 2000,
      model: GptTurbo0631Model(),
    );

    final response =
        await _chatGPTInstance.openAI.onChatCompletion(request: request);

    if (response != null && response.choices.isNotEmpty) {
      return response.choices.first.message?.content ?? 'No response';
    } else {
      return 'No response';
    }
  }
}

class TextEditorScreen extends StatefulWidget {
  final String initialText;

  const TextEditorScreen({Key? key, required this.initialText})
      : super(key: key);

  @override
  createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.initialText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Edit Text',
        actions: [
          IconButton(
            onPressed: () {
              _saveEditedText(context);
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: TextField(
            controller: _textEditingController,
            maxLines: null,
          ),
        ),
      ),
    );
  }

  void _saveEditedText(BuildContext context) {
    final editedText = _textEditingController.text;
    Navigator.pop(context, editedText);
  }
}

class OpenAIInstance {
  final OpenAI openAI;

  OpenAIInstance(String token)
      : openAI = OpenAI.instance.build(
          token: token,
          baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 120)),
          enableLog: true,
        );
}
