// import 'package:flutter/material.dart';
// import '../widgets/datetime.dart';

// class IssueAddScreen extends StatefulWidget {
//   const IssueAddScreen({super.key});

//   @override
//   State<StatefulWidget> createState() {
//     return _IssueAddScreenState();
//   }
// }

// class _IssueAddScreenState extends State<IssueAddScreen> {
//   DateTime _selectedDate = DateTime.now();

//   //Date Picker
//   void _openDatePicker() async {
//     final now = DateTime.now();
//     final firstDate = DateTime(now.year - 1, now.month, now.day);
//     final lastDate = DateTime(now.year + 1, now.month, now.day);

//     final pickedDate = await showDatePicker(
//       context: context,
//       firstDate: firstDate,
//       lastDate: lastDate,
//     );

//     setState(() {
//       _selectedDate = pickedDate!;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add New Issue')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Column(
//                     children: [
//                       Text('Raised Date'),
//                       TextButton.icon(
//                         onPressed: _openDatePicker,
//                         label: Text(dateformatter.format(_selectedDate)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class IssueAddScreen extends StatefulWidget {
  @override
  _IssueAddScreenState createState() => _IssueAddScreenState();
}

class _IssueAddScreenState extends State<IssueAddScreen> {
  final _formKey = GlobalKey<FormState>();

  // Example Dropdown Data
  final List<String> companies = ["Company A", "Company B", "Company C"];
  final List<String> priorities = ["1", "2", "3"];
  final List<String> yesNo = ["Yes", "No"];
  final List<String> modules = ["Module 1", "Module 2", "Module 3"];
  final List<String> responsibleParties = ["Team A", "Team B", "Team C"];
  final List<String> statusList = ["Open", "In Progress", "Closed"];

  DateTime? issueRaiseDate = DateTime.now();
  DateTime? issueAge;
  DateTime? deadline = DateTime.now();
  DateTime? completeDate = DateTime.now();

  Future<void> _pickDate(BuildContext context, DateTime? initial,
      Function(DateTime) onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: EdgeInsets.all(12), child: child),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Issue Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Row 1: Issue Raise Date + Company Name
              _buildCard(
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text("Issue Raise Date"),
                        subtitle: Text(
                          issueRaiseDate == null
                              ? "Select Date"
                              : issueRaiseDate.toString().split(' ')[0],
                        ),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _pickDate(context, issueRaiseDate,
                            (date) => setState(() => issueRaiseDate = date)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: _inputStyle("Company Name"),
                        items: companies
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),
              ),

              // Row 2: Issue Raised by + Priority + Repetitive + Repeat Count
              _buildCard(
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: TextFormField(
                            decoration: _inputStyle("Raised by"))),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: _inputStyle("Priority"),
                        items: priorities
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) {},
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: _inputStyle("Repetitive"),
                        items: yesNo
                            .map((y) =>
                                DropdownMenuItem(value: y, child: Text(y)))
                            .toList(),
                        onChanged: (val) {},
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: _inputStyle("Repeat Count"),
                        items: List.generate(10, (i) => (i + 1).toString())
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),
              ),

              // Issue Details (Full width)
              _buildCard(
                child: TextFormField(
                  maxLines: 3,
                  decoration: _inputStyle("Issue Details"),
                ),
              ),

              // Row 3: Module + Page/Topic + Via
              _buildCard(
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: _inputStyle("Module"),
                        items: modules
                            .map((m) =>
                                DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (val) {},
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                        child: TextFormField(
                            decoration: _inputStyle("Page/Topic"))),
                    SizedBox(width: 8),
                    Expanded(
                        child:
                            TextFormField(decoration: _inputStyle("Via"))),
                  ],
                ),
              ),

              // Row 4: Responsible Party + Person
              _buildCard(
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: _inputStyle("Responsible Party"),
                        items: responsibleParties
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (val) {},
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                        child: TextFormField(
                            decoration: _inputStyle("Responsible Person"))),
                  ],
                ),
              ),

              // Row 5: GMS Status + Logic Status
              _buildCard(
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: _inputStyle("GMS Status"),
                        items: statusList
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) {},
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: _inputStyle("Logic Status"),
                        items: statusList
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),
              ),

              // Row 6: Issue Age + Deadline + Complete Date
              _buildCard(
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text("Issue Age"),
                        subtitle: Text(issueAge == null
                            ? "Select"
                            : issueAge.toString().split(' ')[0]),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _pickDate(context, issueAge,
                            (date) => setState(() => issueAge = date)),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text("Deadline"),
                        subtitle: Text(deadline == null
                            ? "Select"
                            : deadline.toString().split(' ')[0]),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _pickDate(context, deadline,
                            (date) => setState(() => deadline = date)),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text("Complete Date"),
                        subtitle: Text(completeDate == null
                            ? "Select"
                            : completeDate.toString().split(' ')[0]),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _pickDate(context, completeDate,
                            (date) => setState(() => completeDate = date)),
                      ),
                    ),
                  ],
                ),
              ),

              // Comments (Full width)
              _buildCard(
                child: TextFormField(
                  maxLines: 3,
                  decoration: _inputStyle("Comments"),
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save Issue Logic
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text("Save Issue",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
