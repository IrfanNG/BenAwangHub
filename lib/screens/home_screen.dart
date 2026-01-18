import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_create_event_screen.dart';
import 'event_detail_screen.dart';
import 'admin_payment_screen.dart';
import 'profile_screen.dart';
import '../services/user_role_service.dart';
import 'qr_scan_screen.dart';
import 'admin_edit_event_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use theme values
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            floating: false,
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            // Clean Bottom Border for AppBar when scrolled
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.grey.shade100, height: 1),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                "BenAwang Hub",
                style: TextStyle(
                  color: Colors.black, // Stark black
                  fontWeight: FontWeight.w800, // Extra bold
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              FutureBuilder<bool>(
                future: UserRoleService.isAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.data != true) return const SizedBox();
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.black,
                        ),
                        tooltip: 'Create Event',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminCreateEventScreen(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.payments_outlined,
                          color: Colors.black,
                        ),
                        tooltip: 'Payments',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminPaymentScreen(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                tooltip: 'Scan QR',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScanScreen()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: Colors.black,
                  ),
                  tooltip: 'Profile',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
              ),
            ],
          ),

          // Subheader
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upcoming Events",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Your family gatherings timeline",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),

          FutureBuilder<bool>(
            future: UserRoleService.isAdmin(),
            builder: (context, adminSnap) {
              final isAdmin = adminSnap.data == true;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("events")
                    .orderBy("date")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "Error loading events",
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey.shade200,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No upcoming events",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.only(bottom: 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return Dismissible(
                          key: Key(doc.id),
                          direction: isAdmin
                              ? DismissDirection.horizontal
                              : DismissDirection.none,
                          background: Container(color: Colors.blueGrey),
                          secondaryBackground: Container(color: Colors.red),
                          confirmDismiss: (direction) async {
                            if (!isAdmin) return false;
                            if (direction == DismissDirection.startToEnd) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AdminEditEventScreen(eventId: doc.id),
                                ),
                              );
                              return false;
                            }
                            if (direction == DismissDirection.endToStart) {
                              return await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete Event"),
                                  content: const Text(
                                    "Are you sure you want to delete this event?",
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return false;
                          },
                          onDismissed: (_) async {
                            await FirebaseFirestore.instance
                                .collection("events")
                                .doc(doc.id)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Event deleted")),
                            );
                          },
                          child: _EventTile(data: data, docId: doc.id),
                        );
                      }, childCount: snapshot.data!.docs.length),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const _EventTile({required this.data, required this.docId});

  @override
  Widget build(BuildContext context) {
    // Parse date if possible or just use string
    String day = "";
    String month = "";
    if (data["date"] != null) {
      try {
        final d = DateTime.parse(data["date"]);
        day = d.day.toString();
        // Month abbreviation
        const months = [
          "JAN",
          "FEB",
          "MAR",
          "APR",
          "MAY",
          "JUN",
          "JUL",
          "AUG",
          "SEP",
          "OCT",
          "NOV",
          "DEC",
        ];
        month = months[d.month - 1];
      } catch (e) {
        day = "--";
        month = "---";
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: docId)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300), // Visible border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Column
            Container(
              width: 50,
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                children: [
                  Text(
                    month,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600, // Darker contrast
                    ),
                  ),
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["title"] ?? "Untitled Event",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600, // Darker
                      ),
                      const SizedBox(width: 6),
                      Text(
                        data["date"] ?? "TBA",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700, // Darker
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade600, // Darker
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data["location"] ?? "TBA",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700, // Darker
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            const Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
              ), // Darker
            ),
          ],
        ),
      ),
    );
  }
}
