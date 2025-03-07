import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const StrokeApp());
}

class StrokeApp extends StatelessWidget {
  const StrokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StrokeForm(),
    );
  }
}

class StrokeForm extends StatefulWidget {
  const StrokeForm({super.key});

  @override
  _StrokeFormState createState() => _StrokeFormState();
}

class _StrokeFormState extends State<StrokeForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController glucoseController = TextEditingController();

  String gender = "Male";
  String married = "Yes";
  String workType = "Private";
  String residence = "Urban";
  String smoking = "Never Smoked";

  bool _isLoading = false;

  Future<void> _predictStroke() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.230:8000/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "age": double.tryParse(ageController.text) ?? 0,
          "avg_glucose_level": double.tryParse(glucoseController.text) ?? 0,
          "bmi": double.tryParse(bmiController.text) ?? 0,
          "hypertension": 0,
          "heart_disease": 0,
          "gender_Male": gender == "Male" ? 1 : 0,
          "gender_Other": gender == "Other" ? 1 : 0,
          "ever_married_Yes": married == "Yes" ? 1 : 0,
          "work_type_Private": workType == "Private" ? 1 : 0,
          "work_type_Self-employed": workType == "Self-employed" ? 1 : 0,
          "work_type_Never_worked": workType == "Never worked" ? 1 : 0,
          "work_type_children": workType == "Children" ? 1 : 0,
          "Residence_type_Urban": residence == "Urban" ? 1 : 0,
          "smoking_status_formerly smoked":
              smoking == "Formerly Smoked" ? 1 : 0,
          "smoking_status_never smoked": smoking == "Never Smoked" ? 1 : 0,
          "smoking_status_smokes": smoking == "Smokes" ? 1 : 0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showResult(
          "Stroke Prediction: ${data['stroke_prediction']} (Probability: ${data['probability']})",
        );
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("An error occurred: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResult(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Prediction Result"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items:
          items.map((String item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stroke Prediction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Age", ageController),
                _buildTextField("Glucose Level", glucoseController),
                _buildTextField("BMI", bmiController),
                const SizedBox(height: 20),

                _buildDropdown("Gender", gender, [
                  "Male",
                  "Female",
                  "Other",
                ], (newValue) => setState(() => gender = newValue!)),
                _buildDropdown(
                  "Married",
                  married,
                  ["Yes", "No"],
                  (newValue) => setState(() => married = newValue!),
                ),
                _buildDropdown(
                  "Work Type",
                  workType,
                  ["Private", "Self-employed", "Never worked", "Children"],
                  (newValue) => setState(() => workType = newValue!),
                ),
                _buildDropdown(
                  "Residence Type",
                  residence,
                  ["Urban", "Rural"],
                  (newValue) => setState(() => residence = newValue!),
                ),
                _buildDropdown(
                  "Smoking Status",
                  smoking,
                  ["Never Smoked", "Formerly Smoked", "Smokes"],
                  (newValue) => setState(() => smoking = newValue!),
                ),

                const SizedBox(height: 20),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _predictStroke,
                      child: const Text("Predict"),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
