import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:izlyclient/izlyclient.dart';
import 'package:latlong2/latlong.dart';
import 'package:onyx/core/res.dart';
import 'package:onyx/screens/map/map_export.dart';
import 'package:onyx/screens/map/widgets/popup_widgets/restaurant_pop_up_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MapWidget extends StatefulWidget {
  const MapWidget(
      {super.key,
      this.batiments = const [],
      this.polylines = const [],
      this.restaurant = const [],
      required this.onTapNavigate,
      this.mapController,
      this.center});

  final List<BatimentModel> batiments;
  final List<RestaurantModel> restaurant;
  final List<Polyline> polylines;
  final LatLng? center;
  final AnimatedMapController? mapController;
  final void Function(LatLng) onTapNavigate;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  late AnimatedMapController mapController;

  @override
  void initState() {
    mapController = widget.mapController ??
        AnimatedMapController(
          vsync: this,
          curve: Curves.easeInOut,
          duration: Res.animationDuration,
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PopupController popupLayerController = PopupController();
    List<Marker> markers = [
      for (var element in widget.batiments)
        Marker(
          alignment: Alignment.center,
          point: element.position,
          child: Icon(
            Icons.location_on_rounded,
            size: 20.sp,
            color: Colors.red,
            semanticLabel: element.name,
          ),
        ),
      for (var element in widget.restaurant)
        Marker(
          alignment: Alignment.center,
          point: LatLng(element.lat, element.lon),
          child: Icon(
            Icons.restaurant_rounded,
            size: 20.sp,
            color: Colors.green,
            semanticLabel: element.name,
          ),
        ),
    ];

    if (widget.center == null) {
      GeolocationLogic.getCurrentLocation(
              askPermission: false, context: context)
          .then((value) async {
        if (value != null) {
          mapController.centerOnPoint(value, zoom: 16.5);
        }
      });
    }
    return Stack(
      children: [
        PopupScope(
          popupController: popupLayerController,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: widget.center ?? MapRes.center,
              initialZoom: 16.5,
              maxZoom: MapRes.maxZoom,
              minZoom: 0,
              onTap: (_, __) => popupLayerController.hideAllPopups(),
            ),
            mapController: mapController.mapController,
            children: [
              TileLayer(
                tileProvider: FMTC.instance("mapStore").getTileProvider(
                      settings: FMTCTileProviderSettings(
                        cachedValidDuration: const Duration(days: 999999),
                        behavior: CacheBehavior.cacheFirst,
                      ),
                    ),
                urlTemplate: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'fr.onyx.lyon1',
              ),
              if (widget.polylines.isNotEmpty &&
                  !widget.polylines.any((element) => element.points.isEmpty))
                PolylineLayer(
                  polylines: widget.polylines,
                  polylineCulling: true,
                ),
              if (!kIsWeb &&
                  !(Platform.isLinux || Platform.isMacOS || Platform.isWindows))
                const CustomCurrentLocationLayerWidget(),
              if (markers.isNotEmpty)
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 120,
                    rotate: false,
                    size: const Size(40, 40),
                    spiderfyCluster: false,
                    disableClusteringAtZoom: 15,
                    zoomToBoundsOnClick: false,
                    alignment: Alignment.center,
                    maxZoom: 15,
                    padding: const EdgeInsets.all(50),
                    markers: markers,
                    popupOptions: PopupOptions(
                      popupSnap: PopupSnap.markerTop,
                      popupController: popupLayerController,
                      popupBuilder: (context, marker) {
                        int index = widget.batiments.indexWhere(
                            (element) => element.position == marker.point);
                        if (index != -1) {
                          return BatimentPopupWidget(
                            element: widget.batiments[index],
                            onTap: widget.onTapNavigate,
                            popupController: popupLayerController,
                          );
                        } else {
                          index = widget.restaurant.indexWhere((element) =>
                              element.lat == marker.point.latitude &&
                              element.lon == marker.point.longitude);
                          return RestaurantPopUpWidget(
                            element: widget.restaurant[index],
                            onTap: widget.onTapNavigate,
                            popupController: popupLayerController,
                          );
                        }
                      },
                    ),
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).colorScheme.background,
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!kIsWeb &&
                  !Platform.isLinux &&
                  !Platform.isMacOS &&
                  !Platform.isWindows)
                Padding(
                  padding: EdgeInsets.all(2.h),
                  child: IconButton(
                      onPressed: () {
                        GeolocationLogic.getCurrentLocation(
                                askPermission: true, context: context)
                            .then((value) {
                          setState(() {
                            if ((value != null)) {
                              mapController.centerOnPoint(value, zoom: 15);
                            }
                          });
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.background),
                      ),
                      icon: Icon(
                        Icons.location_searching_rounded,
                        size: 25.sp,
                        color: Theme.of(context).primaryColor,
                      )),
                ),
              Padding(
                padding: EdgeInsets.all(2.h),
                child: IconButton(
                    onPressed: () {
                      mapController.centerOnPoint(MapRes.center, zoom: 16.5);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.background),
                    ),
                    icon: Icon(
                      Icons.location_city_rounded,
                      size: 25.sp,
                      color: Theme.of(context).primaryColor,
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
