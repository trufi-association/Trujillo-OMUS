import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omus/core/router/app_router.dart';

/// General app bar widget with OMUS logo and partner logos.
class GeneralAppBar extends StatelessWidget {
  const GeneralAppBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.go(AppRoutes.home),
          child: SizedBox(
            height: 50,
            child: Image.asset(
              'assets/Logo_OMUS.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          width: 500,
          child: Image.asset(
            'assets/logos.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
