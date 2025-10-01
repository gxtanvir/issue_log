import 'package:flutter/material.dart';
import 'package:issue_log/services/api_service.dart';
import '../home/issue_details.dart';

class UpcomingDeadlineScreen extends StatefulWidget {
  const UpcomingDeadlineScreen({super.key});

  @override
  State<UpcomingDeadlineScreen> createState() => _UpcomingDeadlineScreenState();
}

class _UpcomingDeadlineScreenState extends State<UpcomingDeadlineScreen> {
  bool _loading = true;
  List<dynamic> _issues = [];
  var selectedDays = 7;

  @override
  void initState() {
    super.initState();
    _loadIssues(selectedDays);
  }

  Future<void> _loadIssues(int day) async {
    try {
      final data = await ApiService.fetchUpcomingDeadlineIssues(day);
      setState(() {
        _issues = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading issues: $e")));
    }
  }

  // A helper function to format names
  String _formatName(String name) {
    if (name.isEmpty) return '';
    return name
        .split(' ')
        .map(
          (word) =>
              word.isEmpty
                  ? ''
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String _shortTitle(String? text) {
    if (text == null) return "";
    return text.length > 40 ? text.substring(0, 40) + "..." : text;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming Deadlines")),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _issues.isEmpty
              ? const Center(child: Text("No upcoming deadlines"))
              : Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Expanded(
                      child: DropdownButton<int>(
                        value: selectedDays,
                        items:
                            [3, 7, 15].map((d) {
                              return DropdownMenuItem<int>(
                                value: d,
                                child: Text("$d days"),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDays = value!;
                          });
                          _loadIssues(selectedDays);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    child: Text(
                      "Total ${_issues.length} issues have deadline for next $selectedDays days.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 95, 93, 93),
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 6,
                    endIndent: 6,
                  ),
                  width < 600
                      ? Expanded(
                        child: ListView.builder(
                          itemCount: _issues.length,
                          itemBuilder: (context, index) {
                            final issue = _issues[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final updatedIssue = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              IssueDetailsScreen(issue: issue),
                                    ),
                                  );
                                  if (updatedIssue != null)
                                    _loadIssues(selectedDays);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (_shortTitle(issue["issue_details"])),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF384B70),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Deadline: ${issue["deadline"] ?? "N/A"}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Issue Of: ${_formatName(issue["inserted_by_name"])}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Raised By: ${issue["raised_by"] ?? "N/A"}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Raised On: ${issue["issue_raise_date"] ?? "-"}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: width < 950 ? 1.6 : 5,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 6,
                              ),
                          itemCount: _issues.length,

                          itemBuilder: (context, index) {
                            final issue = _issues[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final updatedIssue = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              IssueDetailsScreen(issue: issue),
                                    ),
                                  );
                                  if (updatedIssue != null)
                                    _loadIssues(selectedDays);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (_shortTitle(issue["issue_details"])),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF384B70),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Deadline: ${issue["deadline"] ?? "N/A"}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Issue Of: ${_formatName(issue["inserted_by_name"])}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Company: ${issue["company_name"]}",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Priority: ${issue["priority"] ?? "N/A"}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Module: ${issue["module"]}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Raised By: ${_formatName(issue["raised_by"])}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                ],
              ),
    );
  }
}
