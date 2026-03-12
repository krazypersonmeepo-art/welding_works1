import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'main.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController otpController = TextEditingController();

  Future<void> verifyOtp() async {
    try {
      final url = Uri.parse("${AppConfig.weldingApi}/verify_otp.php");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "otp": otpController.text,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Server error");
      }

      if (!mounted) return;
      try {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "OTP verified")),
        );

        if (data["status"] == "success") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
        }
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Server returned non-JSON. Check API URL. "
              "Status ${response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> resendOtp() async {
    try {
      final url = Uri.parse("${AppConfig.weldingApi}/resend_otp.php");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email}),
      );

      if (response.statusCode != 200) {
        throw Exception("Server error");
      }

      if (!mounted) return;
      try {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "OTP resent")),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Server returned non-JSON. Check API URL. "
              "Status ${response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Text("Enter OTP sent to your email"),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOtp,
              child: const Text("Verify"),
            ),
            TextButton(
              onPressed: resendOtp,
              child: const Text("Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
