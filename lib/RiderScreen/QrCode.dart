/*
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:hive/hive.dart';  // Agar Hive use karna hai to uncomment kar dena

class QRGeneratorScreen extends StatefulWidget {
  final String userId;  // final rakha better practice ke liye

  const QRGeneratorScreen({
    super.key,
    required this.userId,
  });

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  late TextEditingController _idController;
  late String _qrData;

  @override
  void initState() {
    super.initState();
    // Widget se aaya userId ko default value bana diya
    _qrData = widget.userId.isNotEmpty ? widget.userId : "No ID provided";

    _idController = TextEditingController(text: _qrData);

    // Optional: Agar Hive se userId load karna ho to yahan kar sakte ho
    // _loadFromHive();
  }

  // Example: Agar Hive se load karna ho (future mein use karne ke liye)
  // Future<void> _loadFromHive() async {
  //   var box = await Hive.openBox('userData');
  //   final savedId = box.get('userId') as String?;
  //   if (savedId != null && savedId.isNotEmpty) {
  //     setState(() {
  //       _qrData = savedId;
  //       _idController.text = savedId;
  //     });
  //   }
  // }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your QR Code"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User ko dikhao ki yeh uska ID hai
            Text(
              "Your User ID: ${widget.userId}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),



            const SizedBox(height: 40),

            if (_qrData.isNotEmpty)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 280.0,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            Text(
              "QR contains: $_qrData",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Optional: Save to Hive button (agar chahiye to)
            // ElevatedButton.icon(
            //   icon: const Icon(Icons.save),
            //   label: const Text("Save this ID"),
            //   onPressed: () async {
            //     var box = await Hive.openBox('userData');
            //     await box.put('userId', _qrData);
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text("ID saved successfully!")),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';


class QRGeneratorScreen extends StatefulWidget {
  final String userId;
  const QRGeneratorScreen({
    super.key,
    required this.userId,
  });
  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final primaryColor = const Color(0xFF006970);
  final primaryDark = const Color(0xFF004C52);
  final primaryLight = const Color(0xFF3399A0);
  final backgroundLight = const Color(0xFFF5FAFA);
  late String _qrData;
  @override
  void initState() {
    super.initState();
    _qrData = widget.userId.trim().isNotEmpty
        ? widget.userId.trim()
        : "No ID provided";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text("Your QR Code"),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header / Instruction
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Share this QR with others",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Let people scan to send you money instantly",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // QR Card
                  Card(
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: QrImageView(
                              data: _qrData,
                              version: QrVersions.auto,
                              size: 260.0,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: primaryColor,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.circle,
                                color: primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Your User ID",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _qrData,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}