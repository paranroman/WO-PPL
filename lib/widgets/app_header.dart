import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                "assets/logo/texticon.png",
                height: screenHeight * 0.03,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Text(
                  'E-VENTURE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),

              IconButton(
                onPressed: () {
                  // TODO: Implementasi fitur notifikasi nanti
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Fitur Notifikasi akan segera hadir!"),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFFD64F5C),
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        Divider(color: Colors.grey[400], thickness: 0.6),
      ],
    );
  }
}
