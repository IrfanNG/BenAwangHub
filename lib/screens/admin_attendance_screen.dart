import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_family_members_screen.dart';

class AdminAttendanceScreen extends StatelessWidget {
  final String eventId;

  const AdminAttendanceScreen({super.key, required this.eventId});

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
                                      ),
                                    ),
                                  ],
                                ),
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
          );
        },
      ),
    );
  }
}
