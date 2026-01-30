import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
import 'admin_family_members_screen.dart';
=======
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1

class AdminAttendanceScreen extends StatelessWidget {
  final String eventId;

  const AdminAttendanceScreen({super.key, required this.eventId});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),
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

<<<<<<< HEAD
          final registrations = regSnap.data!.docs;

          // Calculate total people (Adults + Kids)
          int totalPax = 0;
          int attendedPax = 0;

          for (var doc in registrations) {
            final data = doc.data() as Map<String, dynamic>;
            final int adults = (data["adults"] ?? 0) as int;
            final int kids = (data["kids"] ?? 0) as int;
            final int pax = adults + kids;

            totalPax += pax;

            if (data["checkedInAt"] != null) {
              attendedPax += pax;
            }
          }

          if (registrations.isEmpty) {
            return const Center(
              child: Text(
                "No registrations yet",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return Column(
            children: [
              // Dashboard / Counters
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Checked In (Pax)",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "$attendedPax",
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  "/$totalPax",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        CircularProgressIndicator(
                          value: totalPax > 0 ? attendedPax / totalPax : 0,
                          backgroundColor: Colors.grey.shade100,
                          color: Colors.black, // Stark black for progress
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Grouped Grid by Family
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85, // Adjust for card height
                  ),
                  itemCount: 6, // 6 families
                  itemBuilder: (context, index) {
                    final families = [
                      "Makngah biah",
                      "Pak Long",
                      "Mak Su",
                      "Pak Ngah",
                      "Tok Wan",
                      "Opah",
                    ];
                    final familyName = families[index];

                    // Filter registrations for this family
                    final familyRegs = registrations.where((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      return d["familyName"] == familyName;
                    }).toList();

                    // Calculate totals (Pax)
                    int famTotalPax = 0;
                    int famAttendedPax = 0;

                    for (var r in familyRegs) {
                      final d = r.data() as Map<String, dynamic>;
                      final int pax =
                          ((d["adults"] ?? 0) as int) +
                          ((d["kids"] ?? 0) as int);
                      famTotalPax += pax;

                      if (d["checkedInAt"] != null) {
                        famAttendedPax += pax;
                      }
                    }

                    final int famNotCheckedIn = famTotalPax - famAttendedPax;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminFamilyMembersScreen(
                                familyName: familyName,
                                registrations: familyRegs,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.family_restroom,
                                  color: Colors.blue.shade700,
                                  size: 24,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                familyName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$famAttendedPax/$famTotalPax Checked in",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "$famNotCheckedIn Not checked in",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red.shade400,
=======
          final totalRegistrations = regSnap.data!.docs.length;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("attendance")
                .where("eventId", isEqualTo: eventId)
                .snapshots(),
            builder: (context, attSnap) {
              final attendedCount = attSnap.hasData
                  ? attSnap.data!.docs.length
                  : 0;

              if (regSnap.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No registrations yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: [
                  // Dashboard / Counters
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Checked In",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      "$attendedCount",
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      "/$totalRegistrations",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade400,
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
                                      ),
                                    ),
                                  ],
                                ),
<<<<<<< HEAD
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
=======
                              ],
                            ),
                            // Optional: Minimal Radial Chart could go here, or just keep text
                            CircularProgressIndicator(
                              value: totalRegistrations > 0
                                  ? attendedCount / totalRegistrations
                                  : 0,
                              backgroundColor: Colors.grey.shade100,
                              color: Colors.black, // Stark black for progress
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: regSnap.data!.docs.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final regDoc = regSnap.data!.docs[index];
                        final userId = regDoc.id;

                        return _AttendanceTile(
                          eventId: eventId,
                          userId: userId,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
          );
        },
      ),
    );
  }
}
<<<<<<< HEAD
=======

class _AttendanceTile extends StatelessWidget {
  final String eventId;
  final String userId;

  const _AttendanceTile({required this.eventId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
      builder: (context, userSnap) {
        final name = userSnap.hasData && userSnap.data!.exists
            ? (userSnap.data!.data() as Map<String, dynamic>)["name"] ??
                  "Unknown"
            : "Loading...";

        // Initials for avatar
        final initials = name.isNotEmpty
            ? name.trim().split(' ').take(2).map((e) => e[0]).join()
            : "?";

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

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: isPresent
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                child: Text(
                  initials.toUpperCase(),
                  style: TextStyle(
                    color: isPresent
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                isPresent
                    ? "Checked in at ${_formatTime(checkedInAt)}"
                    : "Not checked in",
                style: TextStyle(
                  color: isPresent ? Colors.green : Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),
              trailing: isPresent
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return "";
    final d = ts.toDate();
    return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }
}
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
