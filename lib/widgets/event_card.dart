import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String eventName;
  final String eventType;
  final String price;
  final List<String> tags;

  final bool showButton;
  final VoidCallback? onButtonPressed;

  final bool cardClickable;
  final VoidCallback? onCardPressed;

  const EventCard({
    super.key,
    required this.imageUrl,
    required this.eventName,
    required this.eventType,
    required this.price,
    required this.tags,
    this.showButton = false,
    this.onButtonPressed,
    this.cardClickable = true,
    this.onCardPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: cardClickable ? onCardPressed : null, // <-- DIBENERIN DI SINI
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: size.height * 0.10,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      imageUrl,
                      width: double.infinity,
                      height: size.height * 0.10,
                      fit: BoxFit.cover,
                    ),
            ),

            Padding(
              padding: EdgeInsets.all(size.width * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Event Name + Price Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          eventName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.032,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        price,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: size.width * 0.032,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD64F5C),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.003),

                  Text(
                    eventType,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: size.width * 0.028,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: size.height * 0.006),

                  // --- Tags ---
                  Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    children: tags.map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.015,
                          vertical: size.height * 0.002,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5E5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.022,
                            color: const Color(0xFFD64F5C),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // --- BUTTON (optional) ---
                  if (showButton) ...[
                    SizedBox(height: size.height * 0.008),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD64F5C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.007,
                          ),
                          elevation: 0,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Lihat Kode QR',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.028,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
