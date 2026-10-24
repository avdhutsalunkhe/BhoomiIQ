import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../models/field_model.dart';
import '../services/agronomic_color_ramp.dart';
import '../theme/app_theme.dart';

class SatelliteMapCanvas extends StatefulWidget {
  final FarmFieldModel field;
  final List<FarmFieldModel>? allFields;
  final List<PixelModel> pixels;
  final String activeTab; // 'growth' | 'moisture' | 'ndre' | 'msavi2' | 'cari'
  final Function(PixelModel)? onPixelSelected;
  final Function(FarmFieldModel)? onFieldSelected;
  final PixelModel? selectedPixel;
  final bool isGradientMode;
  final ValueChanged<bool>? onToggleGradientMode;

  const SatelliteMapCanvas({
    super.key,
    required this.field,
    this.allFields,
    required this.pixels,
    required this.activeTab,
    this.onPixelSelected,
    this.onFieldSelected,
    this.selectedPixel,
    this.isGradientMode = true,
    this.onToggleGradientMode,
  });

  @override
  State<SatelliteMapCanvas> createState() => _SatelliteMapCanvasState();
}

class _SatelliteMapCanvasState extends State<SatelliteMapCanvas> {
  final MapController _mapController = MapController();
  
  // Basemap options: 'satellite' (Esri World Imagery) or 'osm' (OpenStreetMap)
  String _basemapType = 'satellite';
  bool _showAnalyticalOverlay = true;
  bool _isGradientMode = true;
  double _currentZoom = 17.8;

  @override
  void initState() {
    super.initState();
    _isGradientMode = widget.isGradientMode;
  }

  @override
  void didUpdateWidget(covariant SatelliteMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGradientMode != widget.isGradientMode) {
      setState(() => _isGradientMode = widget.isGradientMode);
    }
    if (oldWidget.field.id != widget.field.id) {
      _mapController.move(LatLng(widget.field.lat, widget.field.lng), 17.8);
      setState(() => _currentZoom = 17.8);
    }
  }

  /// Converts boundary coordinates to geographic LatLng points for any field
  List<LatLng> _getPointsForField(FarmFieldModel field) {
    final poly = field.boundaryPolygon;
    if (poly.isEmpty) {
      final cLat = field.lat;
      final cLng = field.lng;
      return [
        LatLng(cLat - 0.00045, cLng - 0.00035),
        LatLng(cLat + 0.00040, cLng + 0.00055),
        LatLng(cLat + 0.00020, cLng + 0.00075),
        LatLng(cLat - 0.00065, cLng - 0.00015),
      ];
    }

    final isRealGeo = poly.every((pt) => pt[0].abs() <= 90.0 && pt[1].abs() <= 180.0 && (pt[0] > 5.0 || pt[1] > 5.0));
    if (isRealGeo) {
      return poly.map((pt) => LatLng(pt[0], pt[1])).toList();
    }

    final cLat = field.lat;
    final cLng = field.lng;
    return poly.map((pt) {
      final latOffset = ((pt[1] - 50.0) / 100.0) * 0.0012;
      final lngOffset = ((pt[0] - 50.0) / 100.0) * 0.0016;
      return LatLng(cLat + latOffset, cLng + lngOffset);
    }).toList();
  }

  /// Ray-casting point-in-polygon algorithm
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude) &&
          (point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }

  /// Handles user taps on the map and identifies which 10m Sentinel-2 pixel or plot was clicked
  void _handleMapTap(LatLng point, List<LatLng> activeBoundaryPoints) {
    // 1. Check if an active pixel was tapped
    if (_showAnalyticalOverlay && widget.pixels.isNotEmpty) {
      if (activeBoundaryPoints.length == 4) {
        final orderedCorners = ParcelMeshUtils.orderQuadrilateral(activeBoundaryPoints);
        final cLat = activeBoundaryPoints.map((p) => p.latitude).reduce((a, b) => a + b) / 4.0;
        final cLng = activeBoundaryPoints.map((p) => p.longitude).reduce((a, b) => a + b) / 4.0;
        final centroid = LatLng(cLat, cLng);

        final tl = ParcelMeshUtils.inset(orderedCorners[0], centroid, 0.02);
        final tr = ParcelMeshUtils.inset(orderedCorners[1], centroid, 0.02);
        final br = ParcelMeshUtils.inset(orderedCorners[2], centroid, 0.02);
        final bl = ParcelMeshUtils.inset(orderedCorners[3], centroid, 0.02);

        const cols = 3;
        const rows = 6;
        for (int c = 0; c < cols; c++) {
          for (int r = 0; r < rows; r++) {
            final u0 = c / cols.toDouble();
            final u1 = (c + 1) / cols.toDouble();
            final v0 = r / rows.toDouble();
            final v1 = (r + 1) / rows.toDouble();

            final p00 = ParcelMeshUtils.bilinearInterp(tl, tr, br, bl, u0, v0);
            final p10 = ParcelMeshUtils.bilinearInterp(tl, tr, br, bl, u1, v0);
            final p11 = ParcelMeshUtils.bilinearInterp(tl, tr, br, bl, u1, v1);
            final p01 = ParcelMeshUtils.bilinearInterp(tl, tr, br, bl, u0, v1);

            if (_isPointInPolygon(point, [p00, p10, p11, p01])) {
              PixelModel? match;
              try {
                match = widget.pixels.firstWhere((px) => px.col == c && px.row == r);
              } catch (_) {
                match = null;
              }
              if (match != null) {
                widget.onPixelSelected?.call(match);
                return;
              }
            }
          }
        }
      } else {
        final minLat = activeBoundaryPoints.map((p) => p.latitude).reduce(math.min);
        final maxLat = activeBoundaryPoints.map((p) => p.latitude).reduce(math.max);
        final minLng = activeBoundaryPoints.map((p) => p.longitude).reduce(math.min);
        final maxLng = activeBoundaryPoints.map((p) => p.longitude).reduce(math.max);

        final cols = widget.pixels.map((p) => p.col).reduce(math.max) + 1;
        final rows = widget.pixels.map((p) => p.row).reduce(math.max) + 1;

        final stepLat = (maxLat - minLat) / rows;
        final stepLng = (maxLng - minLng) / cols;

        for (final p in widget.pixels) {
          final cellTop = maxLat - p.row * stepLat;
          final cellBottom = maxLat - (p.row + 1) * stepLat;
          final cellLeft = minLng + p.col * stepLng;
          final cellRight = minLng + (p.col + 1) * stepLng;

          if (point.latitude <= cellTop &&
              point.latitude >= cellBottom &&
              point.longitude >= cellLeft &&
              point.longitude <= cellRight) {
            widget.onPixelSelected?.call(p);
            return;
          }
        }
      }
    }

    // 2. Check if another plot in the 30-plot cluster was tapped
    if (widget.allFields != null && widget.onFieldSelected != null) {
      for (final f in widget.allFields!) {
        final pts = _getPointsForField(f);
        if (_isPointInPolygon(point, pts)) {
          widget.onFieldSelected!(f);
          return;
        }
      }
    }
  }

  void _zoomIn() {
    final nextZoom = (_mapController.camera.zoom + 0.8).clamp(13.0, 19.5);
    _mapController.move(_mapController.camera.center, nextZoom);
    setState(() => _currentZoom = nextZoom);
  }

  void _zoomOut() {
    final nextZoom = (_mapController.camera.zoom - 0.8).clamp(13.0, 19.5);
    _mapController.move(_mapController.camera.center, nextZoom);
    setState(() => _currentZoom = nextZoom);
  }

  void _focusSelectedPlot() {
    _mapController.move(LatLng(widget.field.lat, widget.field.lng), 18.0);
    setState(() => _currentZoom = 18.0);
  }

  void _viewAll30Plots() {
    // Farm cluster centroid covering all 30 plots (17.0673°N, 74.2764°E)
    _mapController.move(const LatLng(17.0673, 74.2764), 16.2);
    setState(() => _currentZoom = 16.2);
  }

  @override
  Widget build(BuildContext context) {
    final centerLatLng = LatLng(widget.field.lat, widget.field.lng);
    final activeBoundaryPoints = _getPointsForField(widget.field);

    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 1. Interactive Geospatial Basemap (OpenStreetMap or Esri World Imagery)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: centerLatLng,
                initialZoom: 17.8,
                maxZoom: 19.5,
                minZoom: 13.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                onTap: (tapPosition, point) => _handleMapTap(point, activeBoundaryPoints),
                onPositionChanged: (pos, hasGesture) {
                  if (pos.zoom != _currentZoom) {
                    setState(() => _currentZoom = pos.zoom);
                  }
                },
              ),
              children: [
                // Basemap Tiles
                TileLayer(
                  urlTemplate: _basemapType == 'satellite'
                      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bhoomiiq.app',
                  maxZoom: 19,
                ),

                // Surrounding Cadastral Plots (Subtle survey outlines from all 30 plots)
                PolygonLayer(
                  polygons: [
                    if (widget.allFields != null)
                      ...widget.allFields!
                          .where((f) => f.id != widget.field.id)
                          .map((f) => Polygon(
                                points: _getPointsForField(f),
                                color: Colors.white.withValues(alpha: 0.04),
                                borderColor: Colors.white.withValues(alpha: 0.38),
                                borderStrokeWidth: 1.2,
                              )),
                  ],
                ),

                // STRICT PARCEL-CLIPPED CONTINUOUS GRADIENT LAYER (MATCHES IMAGE 1 & 2 ZERO SPILLOVER!)
                if (_showAnalyticalOverlay)
                  _ParcelClippedRasterLayer(
                    boundaryPoints: activeBoundaryPoints,
                    pixels: widget.pixels,
                    activeTab: widget.activeTab,
                    selectedPixel: widget.selectedPixel,
                    isGradientMode: _isGradientMode,
                  ),

                // Active Plot Boundary Outlines (Crisp Glowing Borders on Top of Clipped Raster)
                PolygonLayer(
                  polygons: [
                    // Soft Glowing Emerald Halo
                    Polygon(
                      points: activeBoundaryPoints,
                      color: Colors.transparent,
                      borderColor: AppColors.emerald.withValues(alpha: 0.50),
                      borderStrokeWidth: 5.5,
                    ),

                    // Crisp White Boundary Outline Plotted Using Real GPS Coordinates
                    Polygon(
                      points: activeBoundaryPoints,
                      color: Colors.transparent,
                      borderColor: Colors.white,
                      borderStrokeWidth: 2.6,
                    ),
                  ],
                ),
              ],
            ),

            // 2. Top Left: Basemap Mode Switcher (Satellite vs OpenStreetMap)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _hudToggleButton(
                      label: '🛰️ Satellite',
                      isSelected: _basemapType == 'satellite',
                      onTap: () => setState(() => _basemapType = 'satellite'),
                    ),
                    const SizedBox(width: 4),
                    _hudToggleButton(
                      label: '🗺️ OpenStreet',
                      isSelected: _basemapType == 'osm',
                      onTap: () => setState(() => _basemapType = 'osm'),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Top Right: Smooth Gradient / Grid Toggle & Raster Visibility
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final next = !_isGradientMode;
                      setState(() => _isGradientMode = next);
                      widget.onToggleGradientMode?.call(next);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isGradientMode ? AppColors.emerald : AppColors.bgDark.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _isGradientMode ? AppColors.emerald : AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isGradientMode ? Icons.blur_on_rounded : Icons.grid_on_rounded,
                            size: 14,
                            color: _isGradientMode ? const Color(0xFF022C22) : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isGradientMode ? 'Gradient' : 'Grid',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: _isGradientMode ? const Color(0xFF022C22) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _showAnalyticalOverlay = !_showAnalyticalOverlay),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: _showAnalyticalOverlay ? AppColors.bgSurface : AppColors.bgDark.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showAnalyticalOverlay ? Icons.layers : Icons.layers_outlined,
                            size: 14,
                            color: _showAnalyticalOverlay ? AppColors.cyan : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showAnalyticalOverlay ? 'ON' : 'OFF',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: _showAnalyticalOverlay ? AppColors.cyan : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation, color: AppColors.emerald, size: 14),
                        Text(
                          'N',
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. Floating Plot Name HUD Badge
            Positioned(
              top: 54,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderGlow),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.crop_landscape, size: 14, color: AppColors.emerald),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.field.plotNumber} · ${widget.field.nameMr} (${widget.field.areaAcres} ac)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. PROMINENT FLOATING ZOOM CONTROLLER HUD (Right Side)
            Positioned(
              top: 54,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // A. ZOOM IN (+)
                    _mapFloatingActionBtn(
                      icon: Icons.add,
                      label: 'Zoom In (+)',
                      onTap: _zoomIn,
                    ),
                    Container(width: 26, height: 1, color: AppColors.divider),

                    // B. ZOOM OUT (-)
                    _mapFloatingActionBtn(
                      icon: Icons.remove,
                      label: 'Zoom Out (-)',
                      onTap: _zoomOut,
                    ),
                    Container(width: 26, height: 1, color: AppColors.divider),

                    // C. FOCUS SELECTED PLOT (⛶)
                    _mapFloatingActionBtn(
                      icon: Icons.filter_center_focus_rounded,
                      label: 'Focus Plot',
                      onTap: _focusSelectedPlot,
                    ),
                    Container(width: 26, height: 1, color: AppColors.divider),

                    // D. VIEW ALL 30 PLOTS (Cluster Overview)
                    _mapFloatingActionBtn(
                      icon: Icons.grid_view_rounded,
                      label: 'All 30 Plots',
                      onTap: _viewAll30Plots,
                    ),
                  ],
                ),
              ),
            ),

            // 6. Bottom Left: Live Coordinate HUD & Attribution
            Positioned(
              bottom: 10,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _basemapType == 'satellite'
                      ? 'Esri Aerial · GPS: ${widget.field.lat.toStringAsFixed(6)}°N, ${widget.field.lng.toStringAsFixed(6)}°E'
                      : 'OpenStreetMap · GPS: ${widget.field.lat.toStringAsFixed(6)}°N, ${widget.field.lng.toStringAsFixed(6)}°E',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // 7. Bottom Right: Active Sensor & Zoom Factor
            Positioned(
              bottom: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.activeTab == 'growth' ? 'Sentinel-2 NDVI (10m)' : 'Sentinel-2 NDMI (20m)',
                      style: const TextStyle(
                        color: AppColors.emerald,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_currentZoom.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hudToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.emerald : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? const Color(0xFF022C22) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _mapFloatingActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      preferBelow: false,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.emerald.withValues(alpha: 0.20),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Strict Parcel-Clipped Continuous Gradient / Raster Layer
class _ParcelClippedRasterLayer extends StatelessWidget {
  final List<LatLng> boundaryPoints;
  final List<PixelModel> pixels;
  final String activeTab;
  final PixelModel? selectedPixel;
  final bool isGradientMode;

  const _ParcelClippedRasterLayer({
    required this.boundaryPoints,
    required this.pixels,
    required this.activeTab,
    this.selectedPixel,
    this.isGradientMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    return CustomPaint(
      size: Size.infinite,
      painter: _ParcelClippedPainter(
        camera: camera,
        boundaryPoints: boundaryPoints,
        pixels: pixels,
        activeTab: activeTab,
        selectedPixel: selectedPixel,
        isGradientMode: isGradientMode,
      ),
    );
  }
}

class _MeshVertex {
  final Offset offset;
  final Color color;
  const _MeshVertex({required this.offset, required this.color});
}

class _ParcelClippedPainter extends CustomPainter {
  final MapCamera camera;
  final List<LatLng> boundaryPoints;
  final List<PixelModel> pixels;
  final String activeTab;
  final PixelModel? selectedPixel;
  final bool isGradientMode;

  _ParcelClippedPainter({
    required this.camera,
    required this.boundaryPoints,
    required this.pixels,
    required this.activeTab,
    this.selectedPixel,
    this.isGradientMode = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (boundaryPoints.isEmpty || pixels.isEmpty) return;

    // 1. Convert parcel boundary LatLngs to current screen offsets
    final screenPts = boundaryPoints.map((pt) => camera.latLngToScreenOffset(pt)).toList();

    // 2. Build precise boundary Path
    final polyPath = Path();
    for (int i = 0; i < screenPts.length; i++) {
      if (i == 0) {
        polyPath.moveTo(screenPts[i].dx, screenPts[i].dy);
      } else {
        polyPath.lineTo(screenPts[i].dx, screenPts[i].dy);
      }
    }
    polyPath.close();

    // 3. CLIP CANVAS STRICTLY INSIDE THE PARCEL POLYGON PATH (ZERO BLEEDING OUTSIDE PARCEL!)
    canvas.save();
    canvas.clipPath(polyPath);

    if (isGradientMode) {
      _paintContinuousGradient(canvas, boundaryPoints);
    } else {
      _paintDiscreteGrid(canvas, boundaryPoints);
    }

    // RESTORE CANVAS CLIP
    canvas.restore();
  }

  void _paintContinuousGradient(Canvas canvas, List<LatLng> boundaryPoints) {
    final param = AgronomicColorRampRegistry.get(activeTab);

    // Grid dimensions of source measurement data
    final colMax = pixels.map((p) => p.col).fold<int>(0, math.max);
    final rowMax = pixels.map((p) => p.row).fold<int>(0, math.max);
    final srcCols = math.max(colMax + 1, 3);
    final srcRows = math.max(rowMax + 1, 6);

    // Build 2D matrix of source parameters
    final srcValues = List.generate(
      srcRows,
      (r) => List.generate(srcCols, (c) {
        try {
          final p = pixels.firstWhere((px) => px.col == c && px.row == r);
          return _extractParamValue(p, activeTab);
        } catch (_) {
          return _defaultParamValue(activeTab, c, r, srcCols, srcRows);
        }
      }),
    );

    // High-density subdivision vertices for seamless hardware Gouraud interpolation
    const divU = 28; // along columns / width
    const divV = 42; // along rows / length

    final positions = <Offset>[];
    final colors = <Color>[];

    if (boundaryPoints.length == 4) {
      final orderedCorners = ParcelMeshUtils.orderQuadrilateral(boundaryPoints);
      final cLat = boundaryPoints.map((p) => p.latitude).reduce((a, b) => a + b) / 4.0;
      final cLng = boundaryPoints.map((p) => p.longitude).reduce((a, b) => a + b) / 4.0;
      final centroid = LatLng(cLat, cLng);

      // Inset corners slightly (0.8%) towards centroid for clean parcel boundary buffer
      final tl = ParcelMeshUtils.inset(orderedCorners[0], centroid, 0.008);
      final tr = ParcelMeshUtils.inset(orderedCorners[1], centroid, 0.008);
      final br = ParcelMeshUtils.inset(orderedCorners[2], centroid, 0.008);
      final bl = ParcelMeshUtils.inset(orderedCorners[3], centroid, 0.008);

      final vertexGrid = List.generate(divV + 1, (vIdx) {
        final v = vIdx / divV.toDouble();
        return List.generate(divU + 1, (uIdx) {
          final u = uIdx / divU.toDouble();
          final geoPt = ParcelMeshUtils.bilinearInterp(tl, tr, br, bl, u, v);
          final screenOffset = camera.latLngToScreenOffset(geoPt);

          final val = _sampleBilinear(srcValues, u, v, srcCols, srcRows);
          final color = param.evaluateColor(val, opacity: 0.70);

          return _MeshVertex(offset: screenOffset, color: color);
        });
      });

      for (int vIdx = 0; vIdx < divV; vIdx++) {
        for (int uIdx = 0; uIdx < divU; uIdx++) {
          final p00 = vertexGrid[vIdx][uIdx];
          final p10 = vertexGrid[vIdx][uIdx + 1];
          final p01 = vertexGrid[vIdx + 1][uIdx];
          final p11 = vertexGrid[vIdx + 1][uIdx + 1];

          // Triangle 1 (p00 -> p10 -> p01)
          positions.add(p00.offset);
          colors.add(p00.color);
          positions.add(p10.offset);
          colors.add(p10.color);
          positions.add(p01.offset);
          colors.add(p01.color);

          // Triangle 2 (p10 -> p11 -> p01)
          positions.add(p10.offset);
          colors.add(p10.color);
          positions.add(p11.offset);
          colors.add(p11.color);
          positions.add(p01.offset);
          colors.add(p01.color);
        }
      }
    } else {
      // General polygon: Bounding box triangulation with polygon clipping
      final minLat = boundaryPoints.map((p) => p.latitude).reduce(math.min);
      final maxLat = boundaryPoints.map((p) => p.latitude).reduce(math.max);
      final minLng = boundaryPoints.map((p) => p.longitude).reduce(math.min);
      final maxLng = boundaryPoints.map((p) => p.longitude).reduce(math.max);

      final vertexGrid = List.generate(divV + 1, (vIdx) {
        final v = vIdx / divV.toDouble();
        final lat = maxLat - v * (maxLat - minLat);
        return List.generate(divU + 1, (uIdx) {
          final u = uIdx / divU.toDouble();
          final lng = minLng + u * (maxLng - minLng);
          final screenOffset = camera.latLngToScreenOffset(LatLng(lat, lng));

          final val = _sampleBilinear(srcValues, u, v, srcCols, srcRows);
          final color = param.evaluateColor(val, opacity: 0.70);

          return _MeshVertex(offset: screenOffset, color: color);
        });
      });

      for (int vIdx = 0; vIdx < divV; vIdx++) {
        for (int uIdx = 0; uIdx < divU; uIdx++) {
          final p00 = vertexGrid[vIdx][uIdx];
          final p10 = vertexGrid[vIdx][uIdx + 1];
          final p01 = vertexGrid[vIdx + 1][uIdx];
          final p11 = vertexGrid[vIdx + 1][uIdx + 1];

          positions.add(p00.offset);
          colors.add(p00.color);
          positions.add(p10.offset);
          colors.add(p10.color);
          positions.add(p01.offset);
          colors.add(p01.color);

          positions.add(p10.offset);
          colors.add(p10.color);
          positions.add(p11.offset);
          colors.add(p11.color);
          positions.add(p01.offset);
          colors.add(p01.color);
        }
      }
    }

    if (positions.isNotEmpty) {
      final vertices = ui.Vertices(
        ui.VertexMode.triangles,
        positions,
        colors: colors,
      );
      canvas.drawVertices(vertices, BlendMode.srcOver, Paint());
    }
  }

  void _paintDiscreteGrid(Canvas canvas, List<LatLng> boundaryPoints) {
    final param = AgronomicColorRampRegistry.get(activeTab);
    final gridBorderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;

    const cols = 3;
    const rows = 6;

    if (boundaryPoints.length == 4) {
      final orderedCorners = ParcelMeshUtils.orderQuadrilateral(boundaryPoints);
      final cLat = boundaryPoints.map((p) => p.latitude).reduce((a, b) => a + b) / 4.0;
      final cLng = boundaryPoints.map((p) => p.longitude).reduce((a, b) => a + b) / 4.0;
      final centroid = LatLng(cLat, cLng);

      final tl = ParcelMeshUtils.inset(orderedCorners[0], centroid, 0.02);
      final tr = ParcelMeshUtils.inset(orderedCorners[1], centroid, 0.02);
      final br = ParcelMeshUtils.inset(orderedCorners[2], centroid, 0.02);
      final bl = ParcelMeshUtils.inset(orderedCorners[3], centroid, 0.02);

      for (int c = 0; c < cols; c++) {
        for (int r = 0; r < rows; r++) {
          final u0 = c / cols.toDouble();
          final u1 = (c + 1) / cols.toDouble();
          final v0 = r / rows.toDouble();
          final v1 = (r + 1) / rows.toDouble();

          final p00 = camera.latLngToScreenOffset(ParcelMeshUtils.bilinearInterp(tl, tr, br, bl, u0, v0));
          final p10 = camera.latLngToScreenOffset(ParcelMeshUtils.bilinearInterp(tl, tr, br, bl, u1, v0));
          final p11 = camera.latLngToScreenOffset(ParcelMeshUtils.bilinearInterp(tl, tr, br, bl, u1, v1));
          final p01 = camera.latLngToScreenOffset(ParcelMeshUtils.bilinearInterp(tl, tr, br, bl, u0, v1));

          final cellPath = Path()
            ..moveTo(p00.dx, p00.dy)
            ..lineTo(p10.dx, p10.dy)
            ..lineTo(p11.dx, p11.dy)
            ..lineTo(p01.dx, p01.dy)
            ..close();

          PixelModel? p;
          try {
            p = pixels.firstWhere((px) => px.col == c && px.row == r);
          } catch (_) {
            p = null;
          }

          final val = p != null
              ? _extractParamValue(p, activeTab)
              : _defaultParamValue(activeTab, c, r, cols, rows);
          final color = param.evaluateColor(val, opacity: 0.78);

          final cellPaint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;

          canvas.drawPath(cellPath, cellPaint);
          canvas.drawPath(cellPath, gridBorderPaint);

          if (selectedPixel != null && selectedPixel!.col == c && selectedPixel!.row == r) {
            final highlightPaint = Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5;
            canvas.drawPath(cellPath, highlightPaint);
          }
        }
      }
    }
  }

  static double _extractParamValue(PixelModel p, String activeTab) {
    final tab = activeTab.toLowerCase();
    if (tab == 'growth' || tab == 'ndvi') {
      return p.ndvi;
    } else if (tab == 'ndre') {
      return p.ndre;
    } else if (tab == 'msavi2') {
      return p.msavi2;
    } else if (tab == 'cari') {
      return p.cari;
    } else {
      return p.ndmi;
    }
  }

  static double _defaultParamValue(String activeTab, int c, int r, int maxC, int maxR) {
    final u = c / math.max(1, maxC - 1).toDouble();
    final tab = activeTab.toLowerCase();
    if (tab == 'growth' || tab == 'ndvi') {
      return 0.72 - (u * 0.44);
    } else if (tab == 'ndre') {
      return 0.42 - (u * 0.22);
    } else if (tab == 'msavi2') {
      return 0.65 - (u * 0.37);
    } else if (tab == 'cari') {
      return 0.48 - (u * 0.28);
    } else {
      return 0.22 - (u * 0.38);
    }
  }

  static double _sampleBilinear(List<List<double>> grid, double u, double v, int cols, int rows) {
    final cPos = (u * (cols - 1)).clamp(0.0, cols - 1.0);
    final rPos = (v * (rows - 1)).clamp(0.0, rows - 1.0);

    final c0 = cPos.floor();
    final c1 = math.min(cols - 1, c0 + 1);
    final r0 = rPos.floor();
    final r1 = math.min(rows - 1, r0 + 1);

    final fracC = cPos - c0;
    final fracR = rPos - r0;

    final v00 = grid[r0][c0];
    final v10 = grid[r0][c1];
    final v01 = grid[r1][c0];
    final v11 = grid[r1][c1];

    final top = (1.0 - fracC) * v00 + fracC * v10;
    final bottom = (1.0 - fracC) * v01 + fracC * v11;

    return (1.0 - fracR) * top + fracR * bottom;
  }

  @override
  bool shouldRepaint(covariant _ParcelClippedPainter oldDelegate) {
    return true;
  }
}

/// Geometric utilities for parcel-aligned sugarcane furrow mesh interpolation
class ParcelMeshUtils {
  /// Sorts 4 surveyed corner points into clockwise order: [Top-Left, Top-Right, Bottom-Right, Bottom-Left]
  static List<LatLng> orderQuadrilateral(List<LatLng> pts) {
    if (pts.length != 4) return pts;
    final minLat = pts.map((p) => p.latitude).reduce(math.min);
    final maxLat = pts.map((p) => p.latitude).reduce(math.max);
    final minLng = pts.map((p) => p.longitude).reduce(math.min);
    final maxLng = pts.map((p) => p.longitude).reduce(math.max);

    final dLat = maxLat - minLat;
    final dLng = maxLng - minLng;
    if (dLat == 0 || dLng == 0) return pts;

    // Corner targets: TL (NW), TR (NE), BR (SE), BL (SW)
    final targets = [
      const Offset(0.0, 1.0), // TL: minLng (0.0), maxLat (1.0)
      const Offset(1.0, 1.0), // TR: maxLng (1.0), maxLat (1.0)
      const Offset(1.0, 0.0), // BR: maxLng (1.0), minLat (0.0)
      const Offset(0.0, 0.0), // BL: minLng (0.0), minLat (0.0)
    ];

    final available = List<LatLng>.from(pts);
    final ordered = <LatLng>[];

    for (final target in targets) {
      LatLng best = available.first;
      double bestDistSq = double.infinity;
      for (final p in available) {
        final nLng = (p.longitude - minLng) / dLng;
        final nLat = (p.latitude - minLat) / dLat;
        final distSq = (nLng - target.dx) * (nLng - target.dx) + (nLat - target.dy) * (nLat - target.dy);
        if (distSq < bestDistSq) {
          bestDistSq = distSq;
          best = p;
        }
      }
      ordered.add(best);
      available.remove(best);
    }
    return ordered; // [TL, TR, BR, BL]
  }

  /// Bilinear interpolation across a quadrilateral surface
  /// u: 0.0 (left) to 1.0 (right)
  /// v: 0.0 (top) to 1.0 (bottom)
  static LatLng bilinearInterp(LatLng tl, LatLng tr, LatLng br, LatLng bl, double u, double v) {
    final lat = (1 - u) * (1 - v) * tl.latitude +
        u * (1 - v) * tr.latitude +
        u * v * br.latitude +
        (1 - u) * v * bl.latitude;
    final lng = (1 - u) * (1 - v) * tl.longitude +
        u * (1 - v) * tr.longitude +
        u * v * br.longitude +
        (1 - u) * v * bl.longitude;
    return LatLng(lat, lng);
  }

  /// Insets a point towards the centroid by factor [0.0..1.0]
  static LatLng inset(LatLng pt, LatLng centroid, double factor) {
    return LatLng(
      pt.latitude + (centroid.latitude - pt.latitude) * factor,
      pt.longitude + (centroid.longitude - pt.longitude) * factor,
    );
  }
}
