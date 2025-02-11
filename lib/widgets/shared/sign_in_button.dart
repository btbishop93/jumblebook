import 'package:flutter/material.dart';

class SignInButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final VoidCallback onPressed;

  const SignInButton({
    required this.text,
    this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: theme.outlinedButtonTheme.style,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                child: icon,
              ),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 24), // Balance the icon width
            ],
          ),
        ),
      ),
    );
  }
}
