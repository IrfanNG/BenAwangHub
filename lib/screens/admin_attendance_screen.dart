import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAttendanceScreen extends StatelessWidget {
  final String eventId;

  const AdminAttendanceScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("events")
            .doc(eventId)
            .collection("registrations")
            .snapshots(),
        builder: (context, regSnap) {
          if (!regSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (regSnap.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No registrations",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: regSnap.data!.docs.length,
            itemBuilder: (context, index) {
              final regDoc = regSnap.data!.docs[index];
              final userId = regDoc.id;

              return _AttendanceTile(
                eventId: eventId,
                userId: userId,
              );
            },
          );
        },
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final String eventId;
  final String userId;

  const _AttendanceTile({
    required this.eventId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get(),
      builder: (context, userSnap) {
        final name = userSnap.hasData && userSnap.data!.exists
            ? (userSnap.data!.data() as Map<String, dynamic>)["name"] ?? "Unknown"
            : "Loading...";

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("attendance")
              .doc("${eventId}_$userId")
              .get(),
          builder: (context, attSnap) {
            final isPresent = attSnap.hasData && attSnap.data!.exists;
            final checkedInAt = isPresent
                ? (attSnap.data!.data() as Map<String, dynamic>)["checkedInAt"]
                : null;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPresent
                      ? Colors.green.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPresent ? Icons.check_circle : Icons.hourglass_bottom,
                    color: isPresent ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPresent
                              ? "Checked in"
                              : "Not checked in",
                          style: TextStyle(
                            fontSize: 13,
                            color: isPresent
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isPresent && checkedInAt != null)
                    Text(
                      _formatTime(checkedInAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(Timestamp ts) {
    final d = ts.toDate();
    return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }
}
