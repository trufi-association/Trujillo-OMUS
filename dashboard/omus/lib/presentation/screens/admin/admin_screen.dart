import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:omus/presentation/widgets/common/general_app_bar.dart';
import 'package:omus/presentation/screens/admin/chart_admin_screen.dart';
import 'package:omus/presentation/screens/gtfs/gtfs_admin_screen.dart';
import 'package:omus/presentation/screens/image_manager/image_manager_screen.dart';

/// Admin dashboard screen with navigation to different admin sections.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const GeneralAppBar(title: ''),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          _buildGradientOverlay(),
          _buildAdminButtons(context),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        'assets/background.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(153, 17, 81, 134),
              Color.fromARGB(125, 0, 0, 0),
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButtons(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            shrinkWrap: true,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  AdminCategoryButton(
                    onTap: () => _showFullScreenPopup(
                      context,
                      'GTFS',
                      builder: (_, __) => GTFSAdminScreen(),
                    ),
                    title: 'GTFS',
                    svgString: _gtfsSvg,
                  ),
                  AdminCategoryButton(
                    onTap: () => _showFullScreenPopup(
                      context,
                      'Tableros',
                      builder: (_, __) => const ChartAdminScreen(),
                    ),
                    title: 'Tableros',
                    svgString: _dashboardSvg,
                  ),
                  AdminCategoryButton(
                    onTap: () => _showFullScreenPopup(
                      context,
                      'Reportes',
                      builder: (_, __) => const ImageManagerScreen(),
                    ),
                    title: 'Reportes',
                    svgString: _reportsSvg,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const String _gtfsSvg = '''
<svg width="200" height="200" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <polyline points="30,150 70,100 120,140 170,60" stroke="#007acc" stroke-width="6" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
    <circle cx="30" cy="150" r="8" fill="#007acc" stroke="white" stroke-width="3"/>
    <circle cx="70" cy="100" r="8" fill="#007acc" stroke="white" stroke-width="3"/>
    <circle cx="120" cy="140" r="8" fill="#007acc" stroke="white" stroke-width="3"/>
    <circle cx="170" cy="60" r="8" fill="#007acc" stroke="white" stroke-width="3"/>
    <path d="M170 50 C160 50, 155 60, 170 85 C185 60, 180 50, 170 50 Z" fill="red"/>
    <circle cx="170" cy="60" r="5" fill="white"/>
</svg>
''';

  static const String _dashboardSvg = '''
<svg width="200" height="200" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <rect x="40" y="110" width="25" height="50" fill="#007acc"/>
    <rect x="75" y="80" width="25" height="80" fill="#007acc"/>
    <rect x="110" y="50" width="25" height="110" fill="#007acc"/>
    <rect x="145" y="90" width="25" height="70" fill="#007acc"/>
    <g transform="translate(60,60)">
        <polygon fill="#555" points="0,-20 17,-10 17,10 0,20 -17,10 -17,-10"/>
        <circle cx="0" cy="0" r="8" fill="#f5f5f5"/>
    </g>
</svg>
''';

  static const String _reportsSvg = '''
<svg width="200" height="200" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <rect x="30" y="50" width="120" height="80" fill="white" stroke="#007acc" stroke-width="4" rx="5"/>
    <polygon points="40,120 80,80 100,100 130,70 140,120" fill="#007acc"/>
    <circle cx="50" cy="65" r="8" fill="#007acc"/>
    <g transform="translate(130,120)">
        <circle cx="0" cy="0" r="20" fill="none" stroke="#555" stroke-width="4"/>
        <line x1="15" y1="15" x2="30" y2="30" stroke="#555" stroke-width="4" stroke-linecap="round"/>
    </g>
</svg>
''';
}

/// Button widget for admin categories with hover effect.
class AdminCategoryButton extends StatefulWidget {
  const AdminCategoryButton({
    super.key,
    required this.svgString,
    required this.title,
    required this.onTap,
  });

  final String svgString;
  final String title;
  final VoidCallback? onTap;

  @override
  State<AdminCategoryButton> createState() => _AdminCategoryButtonState();
}

class _AdminCategoryButtonState extends State<AdminCategoryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 200,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _isHovered
                  ? const Color(0xFF0077AE)
                  : const Color.fromRGBO(255, 255, 255, 0.8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(
                  widget.svgString,
                  theme: const SvgTheme(currentColor: Colors.red),
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 30),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: _isHovered ? Colors.white : Colors.black,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a full screen popup dialog with the given content.
void _showFullScreenPopup(
  BuildContext context,
  String title, {
  required Widget Function(BuildContext, BoxConstraints) builder,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: const Color(0xFFD4DFE9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(builder: builder),
              ),
            ],
          ),
        ),
      );
    },
  );
}
