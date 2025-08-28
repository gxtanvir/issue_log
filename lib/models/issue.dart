import 'package:intl/intl.dart';

void dateFormatter = DateFormat.yMd();

class Issue {
  Issue({
    required this.id,
    required this.raiseDate,
    required this.company,
    required this.raisedBy,
    required this.priority,
    required this.details,
    required this.module,
    required this.via,
    required this.responParty,
    required this.responPerson,
    required this.status,
    required this.deadline,
    required this.complDate,
    required this.comments,
  });

  final String id;
  final DateTime raiseDate;
  final String company;
  final String raisedBy;
  final String priority;
  final String details;
  final String module;
  final String via;
  final String responParty;
  final String responPerson;
  final String status;
  final DateTime deadline;
  final DateTime complDate;
  final String comments;
}
