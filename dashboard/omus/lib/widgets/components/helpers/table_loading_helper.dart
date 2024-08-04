// import "package:flutter/material.dart";
// import "package:gizpdp/services/odata_response.dart";
// import "package:gizpdp/widgets/components/buttons/text_button.dart";
// import "package:gizpdp/widgets/components/helpers/form_loading_helper.dart";
// import "package:gizpdp/widgets/components/progress_indicator/custom_circular_progress.dart";
// import "package:gizpdp/widgets/components/tables/odata_table.dart";

// abstract class OdataModelHelper {}

// @immutable
// class ValueContainer<T, H> {
//   const ValueContainer({
//     required this.oDataModel,
//     required this.helperModel,
//   });

//   final ODataResponse<T> oDataModel;
//   final H? helperModel;
// }

// class TableLoadingHelperCallbacks {
//   TableLoadingHelperCallbacks({
//     required this.resetODataTable,
//     required this.deleteById,
//     required this.searchFilter,
//     required this.advancedFilters,
//     required this.sortByColumn,
//     required this.onPageChange,
//     required this.onItemsPerPageChange,
//     required this.onAsyncCall,
//   });

//   final void Function() resetODataTable;
//   void Function(String id) deleteById;
//   final void Function(
//     String queryText,
//     List<String> keys,
//   ) searchFilter;
//   final void Function(
//     List<List<FilterItem>> filters,
//   ) advancedFilters;
//   final void Function({
//     required String fieldName,
//     required int columnIndex,
//     required bool isAscending,
//   }) sortByColumn;
//   final void Function(int pageIndex) onPageChange;
//   final void Function(int itemsPerPage) onItemsPerPageChange;
//   final void Function(
//     Future<void> Function() asyncFunction, {
//     bool reloadData,
//   }) onAsyncCall;
// }

// class TableLoadingHelperBuilderParams<T, H> {
//   TableLoadingHelperBuilderParams({
//     required this.value,
//     required this.oDataQueryBuilder,
//     required this.dataTableState,
//     required this.loading,
//     required this.callbacks,
//     required this.extraAsyncFunction,
//   });
//   final ValueContainer<T, H> value;
//   final ODataQueryBuilder oDataQueryBuilder;
//   final DataTableStateHelper dataTableState;
//   final LoadingStatus loading;
//   final TableLoadingHelperCallbacks callbacks;
//   final ExtraAsyncFunction extraAsyncFunction;
// }

// class TableLoadingHelper<T, H> extends StatefulWidget {
//   const TableLoadingHelper({
//     super.key,
//     required this.defaultSortByKey,
//     required this.getOData,
//     this.loadHelper,
//     required this.deleteById,
//     required this.builder,
//   });

//   final String defaultSortByKey;

//   final Future<ODataResponse<T>> Function(
//     ODataQueryBuilder queryBuilder,
//   ) getOData;
//   final Future<H> Function()? loadHelper;
//   final Future<void> Function(String id) deleteById;

//   final Widget Function(TableLoadingHelperBuilderParams<T, H> params) builder;

//   @override
//   State createState() => _TableLoadingHelperState<T, H>();
// }

// class _TableLoadingHelperState<T, H> extends State<TableLoadingHelper<T, H>> {
//   LoadingStatus initialLoadingStatus = const LoadingStatus.byDefault();
//   LoadingStatus loadingStatus = const LoadingStatus.byDefault();

//   ODataQueryBuilder oDataQueryBuilder = ODataQueryBuilder.defaultTableState();
//   DataTableStateHelper dataTableState = DataTableStateHelper.byDefault();
//   ODataResponse<T>? oDataResponse;
//   ValueContainer<T, H>? value;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       initialLoad(oDataQueryBuilder);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (initialLoadingStatus.loading) {
//       return const Center(
//         child: CustomCircularProgressIndicator(),
//       );
//     }
//     if (initialLoadingStatus.errorCode != null) {
//       return Center(
//         child: Column(
//           children: [
//             Text(initialLoadingStatus.errorCode!),
//             TextButtonPrimary(
//               title: const Text("Try again"),
//               onPressed: () {
//                 initialLoad(oDataQueryBuilder);
//               },
//             ),
//           ],
//         ),
//       );
//     }
//     if (oDataResponse == null) {
//       return Center(
//         child: Column(
//           children: [
//             const Text("Model not found"),
//             TextButtonPrimary(
//               title: const Text("Fatal error"),
//               onPressed: () {
//                 initialLoad(oDataQueryBuilder);
//               },
//             ),
//           ],
//         ),
//       );
//     }
//     return widget.builder(
//       TableLoadingHelperBuilderParams<T, H>(
//         value: value!,
//         oDataQueryBuilder: oDataQueryBuilder,
//         dataTableState: dataTableState,
//         loading: loadingStatus,
//         callbacks: TableLoadingHelperCallbacks(
//           resetODataTable: resetODataTable,
//           deleteById: deleteById,
//           searchFilter: searchFilter,
//           advancedFilters: advancedFilters,
//           sortByColumn: sortByColumn,
//           onPageChange: onPageChange,
//           onItemsPerPageChange: onItemsPerPageChange,
//           onAsyncCall: (asyncFunction, {reloadData = false}) async {
//             try {
//               setState(() {
//                 loadingStatus = const LoadingStatus.loading();
//               });
//               await asyncFunction();
//               setState(() {
//                 loadingStatus = const LoadingStatus.success();
//               });
//               if (reloadData) reloadODataTable();
//             } catch (e) {
//               setState(() {
//                 loadingStatus = LoadingStatus.error("$e");
//               });
//             }
//           },
//         ),
//         extraAsyncFunction: extraAsyncFunction,
//       ),
//     );
//   }

//   Future<void> initialLoad(
//     ODataQueryBuilder targetQueryBuilder,
//   ) async {
//     try {
//       setState(() {
//         initialLoadingStatus = const LoadingStatus.loading();
//       });
//       final targetQueryBuilder = oDataQueryBuilder.copyWith(
//         sortCriteria: [
//           OrderbyItem(fieldName: widget.defaultSortByKey),
//         ],
//       );
//       final response = await widget.getOData(
//         targetQueryBuilder,
//       );
//       final helperModel = await widget.loadHelper?.call();
//       setState(() {
//         dataTableState = dataTableState.copyWith(
//           fetches: dataTableState.fetches + 1,
//         );
//         initialLoadingStatus = const LoadingStatus.success();
//         value = ValueContainer(oDataModel: response, helperModel: helperModel);
//         oDataResponse = response;
//       });
//     } catch (e) {
//       setState(() {
//         initialLoadingStatus = LoadingStatus.error("$e");
//       });
//     }
//   }

//   Future<void> fetchOdataTable(
//     ODataQueryBuilder targetQueryBuilder,
//   ) async {
//     try {
//       setState(() {
//         loadingStatus = const LoadingStatus.loading();
//       });
//       final response = await widget.getOData(
//         targetQueryBuilder,
//       );
//       setState(() {
//         dataTableState = dataTableState.copyWith(
//           fetches: dataTableState.fetches + 1,
//         );
//         oDataQueryBuilder = targetQueryBuilder;
//         loadingStatus = const LoadingStatus.success();

//         value = ValueContainer(oDataModel: response, helperModel: value?.helperModel);
//         oDataResponse = response;
//       });
//     } catch (e) {
//       setState(() {
//         loadingStatus = LoadingStatus.error("$e");
//       });
//     }
//   }

//   void resetODataTable() {
//     oDataQueryBuilder = ODataQueryBuilder.defaultTableState().copyWith(
//       sortCriteria: [
//         OrderbyItem(fieldName: widget.defaultSortByKey),
//       ],
//     );
//     dataTableState = DataTableStateHelper.byDefault();
//     fetchOdataTable(oDataQueryBuilder.copyWith());
//   }

//   void reloadODataTable() {
//     fetchOdataTable(oDataQueryBuilder.copyWith());
//   }

//   Future<void> deleteById(String id) async {
//     try {
//       setState(() {
//         loadingStatus = const LoadingStatus.loading();
//       });
//       await widget.deleteById(id);
//       fetchOdataTable(oDataQueryBuilder);
//     } catch (e) {
//       setState(() {
//         loadingStatus = LoadingStatus.error("$e");
//       });
//     }
//   }

//   void searchFilter(String queryText, List<String> keys) {
//     final targetQueryBuilder = oDataQueryBuilder.copyWith(
//       searchFilter: keys
//           .map(
//             (value) => FilterItem(
//               fieldName: value,
//               operation: FilterOperation.contains,
//               value: queryText,
//             ),
//           )
//           .toList(),
//       pageIndex: 1,
//     );
//     fetchOdataTable(targetQueryBuilder);
//   }

//   void advancedFilters(List<List<FilterItem>> filters) {
//     final targetQueryBuilder = oDataQueryBuilder.copyWith(
//       advancedFilters: filters,
//       pageIndex: 1,
//     );
//     fetchOdataTable(targetQueryBuilder);
//   }

//   void sortByColumn({
//     required String fieldName,
//     required int columnIndex,
//     required bool isAscending,
//   }) {
//     final targetQueryBuilder = oDataQueryBuilder.copyWith(
//       sortCriteria: [
//         OrderbyItem(
//           fieldName: fieldName,
//           isAscending: isAscending,
//         ),
//       ],
//       pageIndex: 1,
//     );

//     dataTableState = dataTableState.copyWith(
//       sortColumnIndex: columnIndex,
//       sortAscending: isAscending,
//     );
//     fetchOdataTable(targetQueryBuilder);
//   }

//   void onPageChange(int pageIndex) {
//     final targetQueryBuilder = oDataQueryBuilder.copyWith(
//       pageIndex: pageIndex,
//     );
//     fetchOdataTable(targetQueryBuilder);
//   }

//   void onItemsPerPageChange(int itemsPerPage) {
//     final targetQueryBuilder = oDataQueryBuilder.copyWith(
//       itemsPerPage: itemsPerPage,
//       pageIndex: 1,
//     );
//     fetchOdataTable(targetQueryBuilder);
//   }

//   Future<void> extraAsyncFunction(Future<void> Function() function) async {
//     setState(() {
//       loadingStatus = const LoadingStatus.loading();
//     });
//     try {
//       await function();
//       setState(() {
//         loadingStatus = const LoadingStatus.success();
//       });
//     } catch (e) {
//       setState(() {
//         loadingStatus = LoadingStatus.error("$e");
//       });
//     }
//   }
// }
