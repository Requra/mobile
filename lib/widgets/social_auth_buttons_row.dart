import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialAuthButtonsRow extends StatelessWidget {
  const SocialAuthButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final borderStyle = OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    );

    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('or continue with'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: borderStyle,
                onPressed: () {},
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const SweepGradient(
                    colors: [
                      Color(0xFF4285F4),
                      Color(0xFFEA4335),
                      Color(0xFFFBBC05),
                      Color(0xFF34A853),
                      Color(0xFF4285F4),
                    ],
                    stops: [0.0, 0.28, 0.52, 0.78, 1.0],
                  ).createShader(bounds),
                  child: const FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: borderStyle,
                onPressed: () {},
                child: const FaIcon(
                  FontAwesomeIcons.github,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
