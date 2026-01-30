import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:omus/core/extensions/list_extensions.dart';
import 'package:omus/data/models/map_data_container.dart';
import 'package:omus/env.dart';
import 'package:omus/services/models/report.dart';

/// Widget that displays detailed information about a selected report.
class CurrentReportRender extends StatelessWidget {
  const CurrentReportRender({
    super.key,
    required this.currentReport,
    required this.helper,
    this.onPressed,
  });

  final Report currentReport;
  final MapDataContainer helper;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300, maxWidth: 1000),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentReport.images?.length == 1)
                Flexible(
                  flex: 1,
                  child: InstaImageViewer(
                    child: CachedNetworkImage(
                      fit: BoxFit.contain,
                      imageUrl:
                          '$apiUrl/Categories/proxy?url=${Uri.encodeComponent(currentReport.images?.first ?? "")}',
                      placeholder: (context, url) => const SizedBox(
                          width: 100,
                          child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              Flexible(
                flex: 2,
                child: Stack(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildInfoRow('ID: ', '${currentReport.id}'),
                              const SizedBox(height: 8.0),
                              _buildInfoRow(
                                'Categoría: ',
                                helper.allCategories
                                        .findOrNull((value) =>
                                            value.id == currentReport.categoryId)
                                        ?.categoryName ??
                                    '-',
                              ),
                              const SizedBox(height: 4.0),
                              _buildInfoRow(
                                'Actor involucrado: ',
                                helper.actors
                                        .findOrNull((value) =>
                                            value.id ==
                                            currentReport.involvedActorId)
                                        ?.name ??
                                    '-',
                              ),
                              const SizedBox(height: 4.0),
                              _buildInfoRow(
                                'Víctima: ',
                                helper.actors
                                        .findOrNull((value) =>
                                            value.id ==
                                            currentReport.victimActorId)
                                        ?.name ??
                                    '-',
                              ),
                              const SizedBox(height: 4.0),
                              _buildInfoRow(
                                'Descripción: ',
                                '${currentReport.description}',
                              ),
                              const SizedBox(height: 4.0),
                              _buildInfoRow(
                                'Fecha: ',
                                currentReport.reportDate != null
                                    ? DateFormat('yyyy-MM-dd kk:mm').format(
                                        currentReport.reportDate!
                                            .add(DateTime.now().timeZoneOffset))
                                    : '-',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: onPressed,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
