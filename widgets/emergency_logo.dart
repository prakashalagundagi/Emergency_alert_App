import 'package:flutter/material.dart';

class EmergencyLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const EmergencyLogo({
    super.key,
    this.size = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: (color ?? Colors.red).withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color ?? Colors.red,
          width: 3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shield background
          Icon(
            Icons.security,
            size: size * 0.7,
            color: color ?? Colors.red,
          ),
          // SOS text
          Positioned(
            top: size * 0.35,
            child: Text(
              'SOS',
              style: TextStyle(
                fontSize: size * 0.15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Emergency cross
          Positioned(
            bottom: size * 0.25,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size * 0.06,
                    height: size * 0.2,
                    decoration: BoxDecoration(
                      color: color ?? Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    width: size * 0.2,
                    height: size * 0.06,
                    decoration: BoxDecoration(
                      color: color ?? Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleEmergencyIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const SimpleEmergencyIcon({
    super.key,
    this.size = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: (color ?? Colors.red).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.emergency,
        size: size * 0.8,
        color: color ?? Colors.red,
      ),
    );
  }
}
