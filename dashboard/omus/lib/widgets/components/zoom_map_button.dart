import "package:flutter/material.dart";
import "package:omus/widgets/components/fleaflet_map_controller.dart";

class ZoomInOutMapButton extends StatefulWidget {
  const ZoomInOutMapButton({
    super.key,
    required this.leafletMapController,
  });

  final LeafletMapController leafletMapController;

  @override
  State<ZoomInOutMapButton> createState() => _ZoomInOutMapButtonState();
}

class _ZoomInOutMapButtonState extends State<ZoomInOutMapButton> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            _ZoomMapButton(
              isZoomIn: true,
              onTap: () {
                widget.leafletMapController.moveAnimated(
                  destLocation: widget.leafletMapController.mapController.camera.center,
                  destZoom: widget.leafletMapController.mapController.camera.zoom + 1,
                  vsync: this,
                );
              },
            ),
            Container(
              width: 18,
              height: 1,
              color: Colors.grey[400],
            ),
            _ZoomMapButton(
              isZoomIn: false,
              onTap: () {
                widget.leafletMapController.moveAnimated(
                  destLocation: widget.leafletMapController.mapController.camera.center,
                  destZoom: widget.leafletMapController.mapController.camera.zoom - 1,
                  vsync: this,
                );
              },
            ),
          ],
        ),
      );
}

class _ZoomMapButton extends StatefulWidget {
  const _ZoomMapButton({
    required this.isZoomIn,
    required this.onTap,
  });

  final bool isZoomIn;
  final GestureTapCallback onTap;

  @override
  State<_ZoomMapButton> createState() => _ZoomMapButtonState();
}

class _ZoomMapButtonState extends State<_ZoomMapButton> {
  bool isHoverHighlight = false;

  @override
  Widget build(BuildContext context) => FocusableActionDetector(
        onShowHoverHighlight: (value) {
          setState(() {
            isHoverHighlight = value;
          });
        },
        child: InkWell(
          onTap: widget.onTap,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              widget.isZoomIn ? Icons.add : Icons.remove,
              color: isHoverHighlight ? Colors.black : Colors.grey[700],
              size: isHoverHighlight ? 22 : 18,
            ),
          ),
        ),
      );
}
