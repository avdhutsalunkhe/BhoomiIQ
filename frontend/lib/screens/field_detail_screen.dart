import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../services/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/satellite_map_canvas.dart';
import '../widgets/advisory_card.dart';
import '../widgets/resolution_badge.dart';
import '../widgets/pixel_info_sheet.dart';
import '../widgets/ai_triage_dialog.dart';
import '../widgets/weather_station_card.dart';

class FieldDetailScreen extends StatefulWidget {
  final FarmFieldModel? initialField;
  final Function(int tabIndex)? onNavigateTab;

  const FieldDetailScreen({
    super.key,
    this.initialField,
    this.onNavigateTab,
  });

  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  late FarmFieldModel _currentField;
  String _activeTab = 'growth'; // 'growth' | 'moisture'
  int _timelineIndex = 0; // 0=20 Oct, 1=15 Oct, 2=10 Oct, 3=05 Oct
  bool _isLoading = true;
  bool _showImageHistory = false;

  List<PixelModel> _pixels = [];
  SatelliteMetadataModel? _satellite;
  ResolutionAnalysisModel? _resolution;
  WeatherModel? _weather;
  DynamicAdvisoryModel? _advisory;
  PixelModel? _selectedPixel;

  final List<String> _revisitDates = ['20 Oct', '15 Oct', '10 Oct', '05 Oct'];

  @override
  void initState() {
    super.initState();
    _currentField = widget.initialField ?? MockData.fields[0];
    _fetchFieldData();
  }

  Future<void> _fetchFieldData() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getFieldAnalysis(_currentField.id, _timelineIndex);
    if (mounted) {
      setState(() {
        _pixels = (data['pixels'] as List<dynamic>).cast<PixelModel>();
        _satellite = data['satellite'] as SatelliteMetadataModel;
        _resolution = data['resolution'] as ResolutionAnalysisModel;
        _weather = data['weather'] as WeatherModel;
        _advisory = data['advisory'] as DynamicAdvisoryModel;
        _selectedPixel = null;
        _isLoading = false;
      });
    }
  }

  void _openAiTriage([String? prompt]) {
    showDialog(
      context: context,
      builder: (ctx) => AiTriageDialog(initialPrompt: prompt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Choose your field Dropdown Header
              _buildFieldSelector(),
              const SizedBox(height: 16),

              // Comprehensive Weather & Atmospheric Intelligence (Temp, Air/Wind, Pressure, Humidity, Dew Point, VPD, Soil, Sun)
              if (_weather != null) ...[
                WeatherStationCard(
                  weather: _weather!,
                  isMarathi: true,
                ),
                const SizedBox(height: 16),
              ],

              // Responsive Two Column Layout
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildLeftSatellitePanel()),
                    const SizedBox(width: 24),
                    Expanded(flex: 5, child: _buildRightAdvisoryPanel()),
                  ],
                )
              else ...[
                _buildLeftSatellitePanel(),
                const SizedBox(height: 24),
                _buildRightAdvisoryPanel(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<FarmFieldModel>(
                value: _currentField,
                isExpanded: true,
                items: MockData.fields.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(
                      '${f.nameMr} · ${f.areaAcres} acres',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _currentField = val;
                      _timelineIndex = 0;
                    });
                    _fetchFieldData();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSatellitePanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dual Tab Selector: "Crop growth" vs "Moisture signs"
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _tabButton(
                      label: 'Crop growth',
                      isActive: _activeTab == 'growth',
                      onTap: () => setState(() => _activeTab = 'growth'),
                    ),
                  ),
                  Expanded(
                    child: _tabButton(
                      label: 'Moisture signs',
                      isActive: _activeTab == 'moisture',
                      onTap: () => setState(() => _activeTab = 'moisture'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Satellite Canvas
            _isLoading
                ? Container(
                    height: 270,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const CircularProgressIndicator(),
                  )
                : SatelliteMapCanvas(
                    field: _currentField,
                    pixels: _pixels,
                    activeTab: _activeTab,
                    selectedPixel: _selectedPixel,
                    onPixelSelected: (p) => setState(() => _selectedPixel = p),
                  ),
            const SizedBox(height: 12),

            // Tapped Pixel Detail Sheet
            if (_selectedPixel != null)
              PixelInfoSheet(
                pixel: _selectedPixel!,
                onClose: () => setState(() => _selectedPixel = null),
              ),

            // Image Date Row & "Check for new image"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Image taken: ${_revisitDates[_timelineIndex]}',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () {
                    _fetchFieldData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checking latest Copernicus Sentinel-2 L2A tile...')),
                    );
                  },
                  child: const Text('Check for new image', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Cautious Advisory Notice
            const Text(
              'Limited satellite detail. Confirm conditions in the field.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),

            // "What do the colours mean?" Legend
            _buildLegend(),
            const SizedBox(height: 16),

            // Resolution & Pure Pixel Limitation Badge
            if (_resolution != null)
              ResolutionBadge(
                resolution: _resolution!,
                onDroneRequest: () => _openAiTriage('Request factory multispectral drone survey for ${_currentField.nameMr}'),
              ),
            const SizedBox(height: 16),

            // Expandable Image Details & History
            _buildExpandableHistory(),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final isGrowth = _activeTab == 'growth';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What do the colours mean?',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
        ),
        const SizedBox(height: 10),

        // Color bars
        Row(
          children: [
            Expanded(
              child: _legendSegment(
                color: isGrowth ? AppColors.statusRed : AppColors.moistureOrange,
                label: isGrowth ? 'Red / orange · less growth' : 'Red / orange · drier signal',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _legendSegment(
                color: isGrowth ? AppColors.statusYellow : AppColors.moistureYellow,
                label: isGrowth ? 'Yellow / light green · mixed growth' : 'Yellow · middle range',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _legendSegment(
                color: isGrowth ? AppColors.statusGreen : AppColors.moistureBlue,
                label: isGrowth ? 'Dark green · denser growth' : 'Teal / blue · wetter signal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Legend disclaimer note
        Text(
          isGrowth
              ? 'Check red or yellow areas in person. New planting or harvest can also cause these colours.'
              : 'Check the soil before watering. This is a satellite signal, not a water-level measurement.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
        ),
      ],
    );
  }

  Widget _legendSegment({required Color color, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildExpandableHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showImageHistory = !_showImageHistory),
          child: Row(
            children: [
              Icon(
                _showImageHistory ? Icons.arrow_drop_down : Icons.arrow_right,
                size: 20,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 4),
              const Text(
                'Image details & history',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
        if (_showImageHistory) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Scrubber Slider
                const Text('Satellite Revisit Timeline:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(_revisitDates.length, (idx) {
                    final isSel = _timelineIndex == idx;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _timelineIndex = idx);
                          _fetchFieldData();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primaryDark : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSel ? AppColors.primaryDark : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _revisitDates[idx],
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isSel ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),

                // Scientific Metadata
                if (_satellite != null) ...[
                  _metaRow('Platform', _satellite!.satellitePlatform),
                  _metaRow('Scene ID', _satellite!.sceneId),
                  _metaRow('Scene Cloud Cover', '${_satellite!.cloudCoverPct}% (Parcel: 0.0%)'),
                  _metaRow('Data Source', _satellite!.dataSource),
                ],
                if (_weather != null) ...[
                  _metaRow('Rainfall (7 Days)', '${_weather!.rainfallRecent7dMm} mm'),
                  _metaRow('Evapotranspiration (ET0)', '${_weather!.et0EvapotranspirationMm} mm/day'),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _metaRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightAdvisoryPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "YOUR NEXT STEP" Advisory Card
        if (_advisory != null)
          AdvisoryCard(
            advisory: _advisory!,
            onAskQuestion: () => _openAiTriage('Advisory question for ${_currentField.nameMr}'),
            onAddPhoto: () => _openAiTriage('Upload leaf photo for ${_currentField.nameMr}'),
          ),
        const SizedBox(height: 16),

        // "Help for this field" Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEFDF9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF6E8CE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help for this field',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 4),
              const Text(
                "Get advice using your field records and your factory's products.",
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF7E2BD)),
                ),
                child: const Text(
                  'Link a soil test from the past six months before personalised input advice. Ask below if you need help.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF92400E), height: 1.35),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () => _openAiTriage('How to submit soil sample to factory lab?'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Text('Update field details'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Shortcut Action 1: Request a drone service
        _serviceRow(
          icon: Icons.flight_takeoff,
          title: 'Request a drone service',
          subtitle: 'Survey or spraying · factory confirms the plan',
          onTap: () {
            if (widget.onNavigateTab != null) {
              widget.onNavigateTab!(3);
            }
          },
        ),
        const SizedBox(height: 10),

        // Shortcut Action 2: Browse factory supplies
        _serviceRow(
          icon: Icons.storefront_outlined,
          title: 'Browse factory supplies',
          subtitle: 'Choose a product and send an order request',
          onTap: () {
            if (widget.onNavigateTab != null) {
              widget.onNavigateTab!(3);
            }
          },
        ),
      ],
    );
  }

  Widget _serviceRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
