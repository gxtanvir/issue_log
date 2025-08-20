import 'package:flutter/material.dart';

class IssueDetailsScreen extends StatefulWidget {
  @override
  _IssueDetailsScreenState createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends State<IssueDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown Data
  final List<String> companies = ["Company A", "Company B", "Company C"];
  final List<String> priorities = ["1", "2", "3"];
  final List<String> yesNo = ["Yes", "No"];
  final List<String> modules = ["Module 1", "Module 2", "Module 3"];
  final List<String> responsibleParties = ["Team A", "Team B", "Team C"];
  final List<String> statusList = ["Open", "In Progress", "Closed"];

  DateTime? issueRaiseDate;
  DateTime? issueAge;
  DateTime? deadline;
  DateTime? completeDate;

  Future<void> _pickDate(BuildContext context, Function(DateTime) onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade700, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text("Issue Details", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Card Container
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Date Picker
                      ListTile(
                        title: Text("Issue Raise Date"),
                        subtitle: Text(
                          issueRaiseDate == null
                              ? "Select Date"
                              : issueRaiseDate.toString().split(' ')[0],
                          style: TextStyle(color: Colors.black87),
                        ),
                        trailing: Icon(Icons.calendar_today, color: Colors.indigo),
                        onTap: () => _pickDate(context, (date) {
                          setState(() => issueRaiseDate = date);
                        }),
                      ),
                      SizedBox(height: 10),

                      DropdownButtonFormField(
                        decoration: _inputStyle("Company Name"),
                        items: companies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {},
                      ),
                      SizedBox(height: 10),

                      TextFormField(decoration: _inputStyle("Issue/Task Raised by")),
                      SizedBox(height: 10),

                      TextFormField(
                        decoration: _inputStyle("Issue Details"),
                        maxLines: 3,
                      ),
                      SizedBox(height: 10),

                      DropdownButtonFormField(
                        decoration: _inputStyle("Priority Level"),
                        items: priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (val) {},
                      ),
                      SizedBox(height: 10),

                      DropdownButtonFormField(
                        decoration: _inputStyle("Repetitive"),
                        items: yesNo.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                        onChanged: (val) {},
                      ),
                      SizedBox(height: 10),

                      DropdownButtonFormField(
                        decoration: _inputStyle("Repeat Count"),
                        items: List.generate(10, (i) => (i + 1).toString())
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {},
                      ),
                      SizedBox(height: 10),

                      DropdownButtonFormField(
                        decoration: _inputStyle("Module"),
                        items: modules.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (val) {},
                      ),
                      SizedBox(height: 10),

                      TextFormField(decoration: _inputStyle("Page/Topic")),
                      SizedBox(height: 10),

                      TextFormField(decoration: _inputStyle("Via")),
                      SizedBox(height: 10),

                      DropdownButtonFormField(
                        decoration: _inputStyle("Responsible Party"),
                        items: responsibleParties.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (val) {},
                      ),
                      SizedBox(height: 10),

                      TextFormField(decoration: _inputStyle("Responsible Person")),
                      SizedBox(height: 10),

                      DropdownButtonFormField(
                        decoration: _inputStyle("GMS Status"),
                        items: statusList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {},
                      ),
                      SizedBox(height: 10),

                      DropdownButtonFormField(
                        decoration: _inputStyle("Logic Status"),
                        items: statusList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {},
                      ),
                      SizedBox(height: 10),

                      ListTile(
                        title: Text("Issue Age"),
                        subtitle: Text(
                          issueAge == null ? "Select Date" : issueAge.toString().split(' ')[0],
                          style: TextStyle(color: Colors.black87),
                        ),
                        trailing: Icon(Icons.calendar_today, color: Colors.indigo),
                        onTap: () => _pickDate(context, (date) {
                          setState(() => issueAge = date);
                        }),
                      ),
                      SizedBox(height: 10),

                      ListTile(
                        title: Text("Deadline"),
                        subtitle: Text(
                          deadline == null ? "Select Date" : deadline.toString().split(' ')[0],
                          style: TextStyle(color: Colors.black87),
                        ),
                        trailing: Icon(Icons.calendar_today, color: Colors.indigo),
                        onTap: () => _pickDate(context, (date) {
                          setState(() => deadline = date);
                        }),
                      ),
                      SizedBox(height: 10),

                      ListTile(
                        title: Text("Complete Date"),
                        subtitle: Text(
                          completeDate == null ? "Select Date" : completeDate.toString().split(' ')[0],
                          style: TextStyle(color: Colors.black87),
                        ),
                        trailing: Icon(Icons.calendar_today, color: Colors.indigo),
                        onTap: () => _pickDate(context, (date) {
                          setState(() => completeDate = date);
                        }),
                      ),
                      SizedBox(height: 10),

                      TextFormField(
                        decoration: _inputStyle("Comments"),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Save Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.indigo.shade600,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save Logic
                    }
                  },
                  child: Text("Save Issue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
