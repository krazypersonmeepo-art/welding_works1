import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'otp_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  bool agree = false;
  bool isSubmitting = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool hasUpper = false;
  bool hasLower = false;
  bool hasNumber = false;
  bool hasSpecial = false;
  bool hasMinLength = false;

  bool showPasswordRequirements = false;

  bool showFirstNameError = false;
  bool showMiddleNameError = false;
  bool showLastNameError = false;
  bool showEmailError = false;
  bool showConfirmPasswordError = false;
  static const String traineeQualification = "SMAW NC 1";

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RegExp nameRegex = RegExp(r"^[a-zA-Z .-]+$");

  bool _hasMinTwoLetters(String value) {
    final lettersOnly = value.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    return lettersOnly.length >= 2;
  }

  bool isFormValid() {
    return firstNameController.text.isNotEmpty &&
        nameRegex.hasMatch(firstNameController.text) &&
        _hasMinTwoLetters(firstNameController.text) &&
        (middleNameController.text.isEmpty ||
            (nameRegex.hasMatch(middleNameController.text) &&
                _hasMinTwoLetters(middleNameController.text))) &&
        lastNameController.text.isNotEmpty &&
        nameRegex.hasMatch(lastNameController.text) &&
        _hasMinTwoLetters(lastNameController.text) &&
        emailController.text.isNotEmpty &&
        emailController.text.endsWith("@gmail.com") &&
        hasUpper &&
        hasLower &&
        hasNumber &&
        hasSpecial &&
        hasMinLength &&
        confirmPasswordController.text == passwordController.text &&
        agree &&
        !isSubmitting;
  }

  Future<void> registerUser() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final url = Uri.parse("${AppConfig.weldingApi}/register.php");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": firstNameController.text.trim(),
          "middle_name": middleNameController.text.trim(),
          "last_name": lastNameController.text.trim(),
          "email": emailController.text.trim().toLowerCase(),
          "password": passwordController.text,
          "role": "trainer",
          "qualification": traineeQualification,
          "status": "active",
          "score": 0,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Server returned ${response.statusCode}");
      }

      if (!mounted) return;
      try {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpPage(email: emailController.text.trim()),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Registration failed")),
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
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tesdaBlue = Color(0xFF0B3D91);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: tesdaBlue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Get Started",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: tesdaBlue,
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    showFirstNameError = value.isNotEmpty &&
                        (!nameRegex.hasMatch(value) || !_hasMinTwoLetters(value));
                  });
                },
              ),
              if (showFirstNameError)
                buildFieldError(
                  "Minimum 2 letters. Only letters, space, - and . allowed",
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: middleNameController,
                decoration: InputDecoration(
                  labelText: "Middle Name (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    showMiddleNameError = value.isNotEmpty &&
                        (!nameRegex.hasMatch(value) || !_hasMinTwoLetters(value));
                  });
                },
              ),
              if (showMiddleNameError)
                buildFieldError(
                  "Minimum 2 letters if provided. Only letters, space, - and . allowed",
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: "Last Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    showLastNameError = value.isNotEmpty &&
                        (!nameRegex.hasMatch(value) || !_hasMinTwoLetters(value));
                  });
                },
              ),
              if (showLastNameError)
                buildFieldError(
                  "Minimum 2 letters. Only letters, space, - and . allowed",
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email (Gmail only)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    showEmailError =
                        value.isNotEmpty && !value.endsWith("@gmail.com");
                  });
                },
              ),
              if (showEmailError) buildFieldError("Only Gmail accounts allowed"),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    showPasswordRequirements = value.isNotEmpty;
                    hasUpper = RegExp(r'[A-Z]').hasMatch(value);
                    hasLower = RegExp(r'[a-z]').hasMatch(value);
                    hasNumber = RegExp(r'[0-9]').hasMatch(value);
                    hasSpecial =
                        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
                    hasMinLength = value.length >= 8;
                    showConfirmPasswordError =
                        confirmPasswordController.text.isNotEmpty &&
                            confirmPasswordController.text != value;
                  });
                },
                validator: (_) => null,
              ),
              const SizedBox(height: 10),
              if (showPasswordRequirements &&
                  !(hasUpper && hasLower && hasNumber && hasSpecial && hasMinLength))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRequirement("1 Uppercase Letter", hasUpper),
                    buildRequirement("1 Lowercase Letter", hasLower),
                    buildRequirement("1 Number", hasNumber),
                    buildRequirement("1 Special Character", hasSpecial),
                    buildRequirement("Minimum 8 Characters", hasMinLength),
                  ],
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Re-enter Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    showConfirmPasswordError =
                        value.isNotEmpty && value != passwordController.text;
                  });
                },
              ),
              if (showConfirmPasswordError)
                buildFieldError("Passwords do not match"),
              const SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    activeColor: tesdaBlue,
                    value: agree,
                    onChanged: (value) {
                      setState(() {
                        agree = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "I agree to the processing of Personal data",
                      style: TextStyle(fontSize: 13),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tesdaBlue,
                  ),
                  onPressed: isFormValid() ? registerUser : null,
                  child: Text(
                    isSubmitting ? "Signing up..." : "Sign up",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRequirement(String text, bool condition) {
    if (condition) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 13,
        ),
      ),
    );
  }
}

Widget buildFieldError(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 13,
      ),
    ),
  );
}
