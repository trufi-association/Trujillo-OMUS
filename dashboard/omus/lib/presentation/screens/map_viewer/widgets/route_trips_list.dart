import 'package:flutter/material.dart';
import 'package:omus/data/models/gtfs_models.dart';

/// Widget that displays a list of routes with checkboxes for selection.
class RouteTripsList extends StatefulWidget {
  final Gtfs gtfsData;
  final List<String> tripsSelection;
  final void Function(bool?, String) onChanged;

  const RouteTripsList({
    super.key,
    required this.gtfsData,
    required this.tripsSelection,
    required this.onChanged,
  });

  @override
  RouteTripsListState createState() => RouteTripsListState();
}

class RouteTripsListState extends State<RouteTripsList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ListView(
        children: widget.gtfsData.routes.map((route) {
          return CheckboxListTile(
            title: Text(route.routeShortName),
            contentPadding: const EdgeInsets.all(0),
            value: widget.tripsSelection.contains(route.routeId),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              widget.onChanged(value, route.routeId);
            },
          );
        }).toList(),
      ),
    );
  }
}
