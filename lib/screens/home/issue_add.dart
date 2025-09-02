import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:issue_log/services/api_service.dart';

class IssueAddScreen extends StatefulWidget {
  const IssueAddScreen({super.key});

  @override
  State<IssueAddScreen> createState() => _IssueAddScreenState();
}

class _IssueAddScreenState extends State<IssueAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final dateFormatter = DateFormat("yyyy-MM-dd");

  // Controllers
  final TextEditingController raisedByCtrl = TextEditingController();
  final TextEditingController issueDetailsCtrl = TextEditingController();
  final TextEditingController responsiblePersonCtrl = TextEditingController();
  final TextEditingController commentsCtrl = TextEditingController();

  // Dropdown values
  String? companyName;
  String? priority;
  String? module;
  String? via = 'Phone';
  String? responsibleParty = 'Logic';
  String? gmsStatus = 'Pending';

  // Dates
  DateTime? issueRaiseDate = DateTime.now();
  DateTime? deadline;
  DateTime? completeDate;

  String? _fmtDate(DateTime? d) => d?.toIso8601String().split("T").first;

  Future<void> _pickDate(
    Function(DateTime) onDatePicked, {
    DateTime? initialDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) onDatePicked(picked);
  }

  Future<void> _saveIssue() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      "issue_raise_date": _fmtDate(issueRaiseDate),
      "company_name": companyName,
      "raised_by": raisedByCtrl.text.trim(),
      "priority": priority,
      "issue_details": issueDetailsCtrl.text.trim(),
      "module": module,
      "via": via,
      "responsible_party": responsibleParty,
      "responsible_person":
          responsibleParty == "MIS"
              ? ApiService.name ?? ""
              : responsiblePersonCtrl.text.trim(),
      "gms_status": gmsStatus,
      "deadline": _fmtDate(deadline),
      "complete_date": _fmtDate(completeDate),
      "comments":
          commentsCtrl.text.trim().isNotEmpty ? commentsCtrl.text.trim() : null,
      "inserted_by": ApiService.username ?? "",
    };

    final token = ApiService.token ?? "";
    final uri = Uri.parse("${ApiService.baseUrl}issues/");

    try {
      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Issue saved successfully")),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed: ${res.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Network error")));
    }
  }

  // Reusable Widgets
  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Flexible(
      fit: FlexFit.loose,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    int maxLines, {
    bool readOnly = false,
  }) {
    return Flexible(
      fit: FlexFit.loose,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if ((label != "Comments") &&
              (value == null || value.trim().isEmpty)) {
            return "Required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerWidget(
    String label,
    DateTime? date,
    Function(DateTime) onPicked, {
    bool readOnly = false,
  }) {
    return Flexible(
      fit: FlexFit.loose,
      child: InkWell(
        onTap: readOnly ? null : () => _pickDate(onPicked, initialDate: date),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            date != null ? dateFormatter.format(date) : "Select Date",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Issue"),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Issue Date + Company
              Row(
                children: [
                  _buildDatePickerWidget(
                    "Issue Raise Date",
                    issueRaiseDate,
                    (d) => setState(() => issueRaiseDate = d),
                    readOnly: true,
                  ),
                  const SizedBox(width: 12),
                  _buildDropdown(
                    "Company Name",
                    companyName,
                    [
                      "GMS Composite",
                      "GMS Textile",
                      "GMS Trims",
                      "GMS Laboratory",
                    ],
                    (val) => setState(() => companyName = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Priority + Module
              Row(
                children: [
                  _buildDropdown("Priority", priority, [
                    "High",
                    "Medium",
                    "Regular",
                  ], (val) => setState(() => priority = val)),
                  const SizedBox(width: 12),
                  _buildDropdown("Module", module, [
                    'MM',
                    'TNA',
                    'Plan',
                    'Commercial',
                    'SCM',
                    'Inventory',
                    'Prod',
                    'S.Con',
                    'Printing',
                    'AOP',
                    "Wash",
                    "Embroidery",
                    "Laboratory",
                  ], (val) => setState(() => module = val)),
                ],
              ),
              const SizedBox(height: 16),

              // Raised By + Via
              Row(
                children: [
                  _buildTextField("Raised By", raisedByCtrl, 1),
                  const SizedBox(width: 12),
                  _buildDropdown("Via", via, [
                    "Phone",
                    "Email",
                    "Direct",
                  ], (val) => setState(() => via = val)),
                ],
              ),
              const SizedBox(height: 16),

              // Issue Details
              _buildTextField("Issue Details", issueDetailsCtrl, 3),
              const SizedBox(height: 16),

              // Responsible Party + Person
              Row(
                children: [
                  _buildDropdown(
                    "Responsible Party",
                    responsibleParty,
                    ["Logic", "MIS"],
                    (val) {
                      setState(() {
                        responsibleParty = val;
                        if (val == "MIS") {
                          responsiblePersonCtrl.text = ApiService.name ?? "";
                        } else {
                          responsiblePersonCtrl.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildTextField(
                    "Responsible Person",
                    responsiblePersonCtrl,
                    1,
                    readOnly: responsibleParty == 'MIS',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Deadline + Complete Date
              Row(
                children: [
                  _buildDatePickerWidget(
                    "Deadline",
                    deadline,
                    (d) => setState(() => deadline = d),
                  ),
                  const SizedBox(width: 12),
                  _buildDatePickerWidget(
                    "Complete Date",
                    completeDate,
                    (d) => setState(() => completeDate = d),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status
              _buildDropdown("Issue Status", gmsStatus, [
                "Pending",
                "Done",
              ], (val) => setState(() => gmsStatus = val)),
              const SizedBox(height: 16),

              // Comments
              _buildTextField("Comments", commentsCtrl, 2),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 56, 75, 112),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                onPressed: _saveIssue,
                child: const Text("Save", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
