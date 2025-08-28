import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:issue_log/models/issue.dart';
import 'package:issue_log/screens/widgets/datetime.dart';

class IssueAddScreen extends StatefulWidget {
  const IssueAddScreen({super.key});

  @override
  State<IssueAddScreen> createState() {
    return _IssueAddScreenState();
  }
}

class _IssueAddScreenState extends State<IssueAddScreen> {
  bool _isAdd = true;
  DateTime _slecetedDate = DateTime.now();
  String _company = "";
  String _raisedBy = "";
  String _issueDetails = "";
  String _resPerson = "";
  String _comments = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // @override
    // initState() {
    //   super.initState();
    //   if (widget.addOrUpdate == "add") {
    //     _isAdd = true;
    //   }

    //   if (widget.addOrUpdate == "update") {
    //     _isAdd = false;
    //   }
    // }

    // Date Picker
    void _openDatePicker() async {
      final now = DateTime.now();
      final firstDate = DateTime(now.year - 1, now.month, now.day);
      final lastDate = DateTime(now.year + 1, now.month, now.day);
      final pickedDate = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: firstDate,
          lastDate: lastDate);

      setState(() {
        _slecetedDate = pickedDate!;
      });
    }

    // Build Date Picker
    Widget _buildDatePicker(String label, int flex) {
      return Expanded(
        flex: flex,
        child: InkWell(
          onTap: _openDatePicker,
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.calendar_month),
              labelText: label,
            ),
            child: Text(
              dateformatter.format(_slecetedDate),
            ),
          ),
        ),
      );
    }

    // Add Issue Method
    void _addIssue() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        print(
            " $_issueDetails $_slecetedDate $_company $_raisedBy $_resPerson $_comments");
      }
    }

    // Dropdown Menu
    Widget _buildDropDown(String value, String hint, int flex,
        List<String> items, Function(String?) onChanged) {
      return Flexible(
        flex: flex,
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          value: value,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      );
    }

    // Text Filed
    Widget _buildTextFiled(String hint, int flex, Function(String?) onSaved) {
      return Flexible(
        flex: flex,
        child: TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty || value.length > 20) {
              return "Invalid Type";
            }
            return null;
          },
          onSaved: onSaved,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Issue"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildDatePicker('Issue Raise Date', 2),
                    const SizedBox(width: 8),
                    _buildDropDown('GMS Composite', 'Select Company', 3,
                        ['GMS Composite', 'GMS Textile', 'GMS Trims'], (value) {
                      setState(() {
                        value = value;
                      });
                    })
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDropDown(
                      'High',
                      'Priority Level',
                      1,
                      ['High', 'Medium', 'Rregular'],
                      (value) {
                        setState(() {
                          value = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildDropDown('MM', 'Module', 1, [
                      'MM',
                      'TNA',
                      'Plan',
                      'Commcercial',
                      'SCM',
                      'Inventory',
                      'Prod',
                      'S.Con',
                      'Printing',
                      'AOP',
                      "Wash",
                      "Embroidery",
                      "Labratory"
                    ], (value) {
                      setState(() {
                        value = value;
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildTextFiled('Raised By', 2, (value) {
                      _raisedBy = value!.trim();
                    }),
                    const SizedBox(width: 8),
                    _buildDropDown(
                        'Phone', 'Via', 2, ['Phone', 'Email', 'Direct'],
                        (value) {
                      setState(() {
                        value = value;
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelText: 'Issue Details',
                    hintText: 'Enter your issue details here',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        value.trim().length > 500) {
                      return "Invalid Type";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _issueDetails = value!.trim();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildDropDown('Logic', 'Logic', 2, ['Logic', 'MIS'],
                        (value) {
                      setState(() {
                        value = value;
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildTextFiled('Responsible Person', 2, (value) {
                      _issueDetails = value!.trim();
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildDatePicker('Deadline', 2),
                    const SizedBox(width: 8),
                    _buildDatePicker('Complete Date', 2),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDropDown(
                    'Pending', 'Issue Status', 0, ['Pending', 'Done'], (value) {
                  setState(() {
                    value = value;
                  });
                }),
                const SizedBox(height: 16),
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Comments',
                    hintText: 'Enter comments here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  onSaved: (value) {
                    _comments = value!.trim();
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 56, 75, 112),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                  ),
                  onPressed: _addIssue,
                  child: const Text("Save", style: TextStyle(fontSize: 18)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class IssueAddScreen extends StatefulWidget {
//   @override
//   _IssueAddScreenState createState() => _IssueAddScreenState();
// }

// class _IssueAddScreenState extends State<IssueAddScreen> {
//   DateTime? issueRaiseDate = DateTime.now();
//   DateTime? deadline = DateTime.now();
//   DateTime? completeDate = DateTime.now();

//   String? companyName;
//   String? priority;
//   String? responsibleParty;
//   String? gmsStatus;

//   final TextEditingController raisedByCtrl = TextEditingController();
//   final TextEditingController issueDetailsCtrl = TextEditingController();
//   final TextEditingController moduleCtrl = TextEditingController();
//   final TextEditingController viaCtrl = TextEditingController();
//   final TextEditingController responsiblePersonCtrl = TextEditingController();
//   final TextEditingController commentsCtrl = TextEditingController();

//   /// Format dates as YYYY-MM-DD
//   String? _fmtDate(DateTime? d) => d?.toIso8601String().split('T').first;

//   /// Pick date helper
//   Future<void> _pickDate(BuildContext context, Function(DateTime) onDatePicked,
//       {DateTime? initialDate}) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       onDatePicked(picked);
//     }
//   }

//   Widget _buildDropdown(String hint, String? value, List<String> items,
//       Function(String?) onChanged) {
//     return Expanded(
//       child: DropdownButtonFormField<String>(
//         value: value,
//         decoration: InputDecoration(
//           labelText: hint,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         items: items
//             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//             .toList(),
//         onChanged: onChanged,
//       ),
//     );
//   }

//   Widget _buildTextField(String hint, TextEditingController controller) {
//     return Expanded(
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: hint,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       ),
//     );
//   }

//   Widget _buildDatePicker(
//       String hint, DateTime? date, Function(DateTime) onDatePicked) {
//     return Expanded(
//       child: InkWell(
//         onTap: () => _pickDate(context, onDatePicked, initialDate: date),
//         child: InputDecorator(
//           decoration: InputDecoration(
//             labelText: hint,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           child: Text(date != null
//               ? "${date.day}/${date.month}/${date.year}"
//               : "Select Date"),
//         ),
//       ),
//     );
//   }

//   /// POST Issue to Django API
//   Future<void> _saveIssue() async {
//     if (issueRaiseDate == null || companyName == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please select Issue Raise Date and Company Name')),
//       );
//       return;
//     }

//     const String baseUrl = "https://gxtanvir.pythonanywhere.com";
//     final uri = Uri.parse('$baseUrl/api/issues/');

//     final body = {
//       "issue_raise_date": _fmtDate(issueRaiseDate),
//       "company_name": companyName,
//       "raised_by": raisedByCtrl.text.trim(),
//       "priority": priority != null ? int.tryParse(priority!) : null,
//       "issue_details": issueDetailsCtrl.text.trim(),
//       "module": moduleCtrl.text.trim(),
//       "via": viaCtrl.text.trim(),
//       "responsible_party": responsibleParty,
//       "responsible_person": responsiblePersonCtrl.text.trim(),
//       "gms_status": gmsStatus,
//       "deadline": _fmtDate(deadline),
//       "complete_date": _fmtDate(completeDate),
//       "comments": commentsCtrl.text.trim(),
//     };

//     try {
//       final res = await http.post(
//         uri,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       if (res.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Issue saved successfully")),
//         );
//         Navigator.of(context).pop(true);
//       } else {
//         debugPrint("Failed ${res.statusCode}: ${res.body}");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed: ${res.statusCode}")),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Network error")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add New Issue"),
//         backgroundColor: Color.fromARGB(255, 56, 75, 112),
//         foregroundColor: Colors.white,
//         elevation: 16,
//         shadowColor: Color(0xff908484),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Row 1
//             Row(
//               children: [
//                 _buildDatePicker("Issue Raise Date", issueRaiseDate,
//                     (d) => setState(() => issueRaiseDate = d)),
//                 const SizedBox(width: 12),
//                 _buildDropdown(
//                     "Company Name",
//                     companyName,
//                     [
//                       "GMS Composit",
//                       "GMS Textile",
//                       "GMS Trims",
//                       "GMS Labratory"
//                     ],
//                     (val) => setState(() => companyName = val)),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Row 2
//             Row(
//               children: [
//                 _buildTextField("Raised by", raisedByCtrl),
//                 const SizedBox(width: 6),
//                 _buildDropdown("Priority Level", priority, ["1", "2", "3"],
//                     (val) => setState(() => priority = val)),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Issue Details
//             TextFormField(
//               controller: issueDetailsCtrl,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 labelText: "Issue Details",
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//               ),
//             ),
//             const SizedBox(height: 16),

//             Row(
//               children: [
//                 _buildTextField("Module", moduleCtrl),
//                 const SizedBox(width: 6),
//                 _buildTextField("Via", viaCtrl),
//               ],
//             ),
//             const SizedBox(height: 16),

//             Row(
//               children: [
//                 _buildDropdown(
//                     "Responsible Party",
//                     responsibleParty,
//                     ["MIS", "LOGIC"],
//                     (val) => setState(() => responsibleParty = val)),
//                 const SizedBox(width: 12),
//                 _buildTextField("Responsible Person", responsiblePersonCtrl),
//               ],
//             ),
//             const SizedBox(height: 16),

//             Row(
//               children: [
//                 _buildDropdown("GMS Status", gmsStatus, ["Done", "Pending"],
//                     (val) => setState(() => gmsStatus = val)),
//               ],
//             ),
//             const SizedBox(height: 16),

//             Row(
//               children: [
//                 _buildDatePicker(
//                     "Deadline", deadline, (d) => setState(() => deadline = d)),
//                 const SizedBox(width: 12),
//                 _buildDatePicker("Complete Date", completeDate,
//                     (d) => setState(() => completeDate = d)),
//               ],
//             ),
//             const SizedBox(height: 16),

//             TextFormField(
//               controller: commentsCtrl,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 labelText: "Comments",
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//               ),
//             ),
//             const SizedBox(height: 24),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color.fromARGB(255, 56, 75, 112),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//               ),
//               onPressed: _saveIssue,
//               child: const Text("Save", style: TextStyle(fontSize: 18)),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
