import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:omus/data/models/category_report.dart';

/// Widget that displays a tabbed container for report items.
class CustomReportContainer extends StatefulWidget {
  final List<ReportItem> reportItems;

  const CustomReportContainer({
    super.key,
    required this.reportItems,
  });

  @override
  State<CustomReportContainer> createState() => _CustomReportContainerState();
}

class _CustomReportContainerState extends State<CustomReportContainer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.reportItems.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: widget.reportItems.map((report) {
            return Tooltip(
              message: report.description,
              child: Tab(
                text: report.title,
              ),
            );
          }).toList(),
        ),
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: widget.reportItems
                .map(
                  (report) => _PersistentTabContent(
                    key: PageStorageKey(report.title),
                    url: report.url,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _PersistentTabContent extends StatefulWidget {
  final String url;

  const _PersistentTabContent({
    required Key key,
    required this.url,
  }) : super(key: key);

  @override
  _PersistentTabContentState createState() => _PersistentTabContentState();
}

class _PersistentTabContentState extends State<_PersistentTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(widget.url),
      ),
    );
  }
}
