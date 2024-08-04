// import "package:flutter/material.dart";
// import "package:omus/widgets/components/custom_icons.dart";

// class ReloadButton extends StatelessWidget {
//   const ReloadButton({
//     super.key,
//     required this.onReload,
//   });
//   final VoidCallback onReload;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       width: 48,
//       height: 48,
//       margin: const EdgeInsets.only(
//         top: 6,
//         right: 10,
//       ),
//       child: ElevatedButton(
//         onPressed: onReload,
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           padding: EdgeInsets.zero,
//           minimumSize: const Size(40, 40),
//           backgroundColor: theme.colorScheme.primary,
//           foregroundColor: theme.colorScheme.onPrimary,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         child: const Icon(
//           CustomIcons.sync,
//         ),
//       ),
//     );
//   }
// }
