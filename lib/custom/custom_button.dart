import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Icon buttonIcon;

  CustomButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
    required this.buttonIcon,
  }) : super(key: key);

  final ButtonStyle customButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.pink.shade900,
    minimumSize: const Size(90, 50),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: customButtonStyle,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buttonIcon,
          const SizedBox(width: 10), // some spacing between icon and text
          Text(
            buttonText,
            style: const TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }
}
