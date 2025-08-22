import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IssueAddScreen extends StatefulWidget {
  @override
  _IssueAddScreenState createState() => _IssueAddScreenState();
}

class _IssueAddScreenState extends State<IssueAddScreen> {
  DateTime? issueRaiseDate = DateTime.now();
  DateTime? deadline = DateTime.now();
  DateTime? completeDate = DateTime.now();

  String? companyName;
  String? priority;
  String? repetitive;
  String? repeatCount;
  String? responsibleParty;
  String? gmsStatus;
  String? logicStatus;

  final TextEditingController raisedByCtrl = TextEditingController();
  final TextEditingController issueDetailsCtrl = TextEditingController();
  final TextEditingController moduleCtrl = TextEditingController();
  final TextEditingController pageCtrl = TextEditingController();
  final TextEditingController viaCtrl = TextEditingController();
  final TextEditingController responsiblePersonCtrl = TextEditingController();
  final TextEditingController commentsCtrl = TextEditingController();

  /// Format dates as YYYY-MM-DD
  String? _fmtDate(DateTime? d) => d?.toIso8601String().split('T').first;

  /// Pick date helper
  Future<void> _pickDate(BuildContext context, Function(DateTime) onDatePicked,
      {DateTime? initialDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDatePicked(picked);
    }
  }

  Widget _buildDropdown(String hint, String? value, List<String> items,
      Function(String?) onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      String hint, DateTime? date, Function(DateTime) onDatePicked) {
    return Expanded(
      child: InkWell(
        onTap: () => _pickDate(context, onDatePicked, initialDate: date),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(date != null
              ? "${date.day}/${date.month}/${date.year}"
              : "Select Date"),
        ),
      ),
    );
  }

  /// POST Issue to Django API
  Future<void> _saveIssue() async {
    if (issueRaiseDate == null || companyName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select Issue Raise Date and Company Name')),
      );
      return;
    }

    // NOTE: change URL depending on environment
    // Android emulator -> http://10.0.2.2:8000
    // iOS simulator -> http://localhost:8000
    const String baseUrl = "https://gxtanvir.pythonanywhere.com";
    final uri = Uri.parse('$baseUrl/api/issues/');

    final body = {
      "issue_raise_date": _fmtDate(issueRaiseDate),
      "company_name": companyName,
      "raised_by": raisedByCtrl.text.trim(),
      "priority": priority != null ? int.tryParse(priority!) : null,
      "repetitive": repetitive == null ? null : (repetitive == "Yes"),
      "repeat_count": repeatCount != null ? int.tryParse(repeatCount!) : null,
      "issue_details": issueDetailsCtrl.text.trim(),
      "module": moduleCtrl.text.trim(),
      "page_topic": pageCtrl.text.trim(),
      "via": viaCtrl.text.trim(),
      "responsible_party": responsibleParty,
      "responsible_person": responsiblePersonCtrl.text.trim(),
      "gms_status": gmsStatus,
      "logic_status": logicStatus,
      "deadline": _fmtDate(deadline),
      "complete_date": _fmtDate(completeDate),
      "comments": commentsCtrl.text.trim(),
    };

    try {
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Issue saved successfully")),
        );
        Navigator.of(context).pop(true);
      } else {
        debugPrint("Failed ${res.statusCode}: ${res.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${res.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Issue"),
        backgroundColor: Color.fromARGB(255, 56, 75, 112),
        foregroundColor: Colors.white,
        elevation: 16,
        shadowColor: Color(0xff908484),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Row 1
            Row(
              children: [
                _buildDatePicker("Issue Raise Date", issueRaiseDate,
                    (d) => setState(() => issueRaiseDate = d)),
                const SizedBox(width: 12),
                _buildDropdown(
                    "Company Name",
                    companyName,
                    ["GMS Composit", "GMS Textile", "GMS Trims", "GMS Labratory"],
                    (val) => setState(() => companyName = val)),
              ],
            ),
            const SizedBox(height: 16),

            // Row 2
            Row(
              children: [
                _buildTextField("Raised by", raisedByCtrl),
                const SizedBox(width: 6),
                _buildDropdown("Priority Level", priority, ["1", "2", "3"],
                    (val) => setState(() => priority = val)),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildDropdown("Repetitive", repetitive, ["Yes", "No"],
                    (val) => setState(() => repetitive = val)),
                const SizedBox(width: 6),
                _buildDropdown(
                    "Repeat Count",
                    repeatCount,
                    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
                    (val) => setState(() => repeatCount = val)),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: issueDetailsCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Issue Details",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildTextField("Module", moduleCtrl),
                const SizedBox(width: 6),
                _buildTextField("Page/Topic", pageCtrl),
                const SizedBox(width: 6),
                _buildTextField("Via", viaCtrl),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildDropdown("Responsible Party", responsibleParty,
                    ["MIS", "LOGIC"], (val) => setState(() => responsibleParty = val)),
                const SizedBox(width: 12),
                _buildTextField("Responsible Person", responsiblePersonCtrl),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildDropdown("GMS Status", gmsStatus, ["Done", "Pending"],
                    (val) => setState(() => gmsStatus = val)),
                const SizedBox(width: 12),
                _buildDropdown("Logic Status", logicStatus, ["Done", "Pending"],
                    (val) => setState(() => logicStatus = val)),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildDatePicker(
                    "Deadline", deadline, (d) => setState(() => deadline = d)),
                const SizedBox(width: 12),
                _buildDatePicker("Complete Date", completeDate,
                    (d) => setState(() => completeDate = d)),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: commentsCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Comments",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 56, 75, 112),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              onPressed: _saveIssue,
              child: const Text("Save", style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}
