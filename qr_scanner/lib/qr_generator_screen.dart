import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  String qrData = "";
  String selectedType = 'text';
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'phone': TextEditingController(),
    'email': TextEditingController(),
    'url': TextEditingController(),
  };

  String _generateQRData() {
    switch (selectedType) {
      case 'contact':
        return '''BEGIN:VCARD
        VERSION:3.0
        FN:${_controllers['name']?.text}
        TEL:${_controllers['phone']?.text} 
        EMAIL:${_controllers['email']?.text}
        END:VCARD''';
      case 'url':
        String url = _controllers['url']?.text ?? '';
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'http://$url';
        }
        return url;
      default:
        return _textController.text;
    }
  }

  Future<void> _shareQRCode() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/qr_code.png';
    final capture = await _screenshotController.capture();
    if (capture == null) return;

    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(capture);
    await Share.shareXFiles([XFile(imagePath)], text: 'Share QR Code');
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.cyanAccent),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.cyanAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.cyanAccent),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (_) {
          setState(() {
            qrData = _generateQRData();
          });
        },
      ),
    );
  }

  Widget _buildInputFields() {
    switch (selectedType) {
      case 'contact':
        return Column(
          children: [
            _buildTextField(_controllers['name']!, "Name"),
            _buildTextField(_controllers['phone']!, "Phone"),
            _buildTextField(_controllers['email']!, "Email"),
          ],
        );
      case 'url':
        return _buildTextField(_controllers['url']!, "URL");
      default:
        return _buildTextField(_textController, "Enter Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1E),
        elevation: 5,
        title: Text(
          'Generate QR Code',
          style: GoogleFonts.poppins(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                color: const Color(0xFF2A2A3D),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        value: selectedType,
                        dropdownColor: const Color(0xFF2A2A3D),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent),
                        items: const [
                          DropdownMenuItem(
                            value: 'text',
                            child: Text("Text", style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'url',
                            child: Text("URL", style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'contact',
                            child: Text("Contact", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                            qrData = '';
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildInputFields(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (qrData.isNotEmpty)
                Column(
                  children: [
                    Card(
                      color: const Color(0xFF2A2A3D),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Screenshot(
                              controller: _screenshotController,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 200,
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _shareQRCode,
                      icon: const Icon(Icons.share, color: Colors.black),
                      label: const Text('Share QR Code',
                          style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
