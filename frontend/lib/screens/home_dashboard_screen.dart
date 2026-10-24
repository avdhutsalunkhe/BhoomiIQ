import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../services/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/satellite_map_canvas.dart';
import '../widgets/telemetry_gauges.dart';
import '../widgets/ai_triage_dialog.dart';
import '../widgets/data_providers_hud.dart';
import '../widgets/sugarcane_ml_cockpit.dart';
import '../widgets/continuous_gradient_legend.dart';
import '../widgets/weather_station_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Function(FarmFieldModel field) onNavigateToField;
  final Function(int tabIndex) onNavigateTab;
  final bool isMarathi;

  const HomeDashboardScreen({
    super.key,
    required this.onNavigateToField,
    required this.onNavigateTab,
    this.isMarathi = true,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  FarmFieldModel _selectedField =
      MockData.fields.firstWhere((f) => f.id == 'plot-30', orElse: () => MockData.fields[0]);
  List<PixelModel> _pixels = [];
  SatelliteMetadataModel? _satellite;
  ResolutionAnalysisModel? _resolution;
  WeatherModel? _weather;
  DynamicAdvisoryModel? _advisory;
  PlanetSceneModel? _planetScene;
  SugarcaneYieldModel? _yieldModel;
  SucroseMaturityModel? _sucroseModel;
  IrrigationPrescriptionModel? _irrigationModel;
  AnomalyDiagnosticMLModel? _anomalyModel;
  String _activeTab = 'growth'; // 'growth' | 'moisture' | 'ndre' | 'msavi2' | 'cari'
  bool _isGradientMode = true;
  bool _isLoading = true;
  bool _isTechnicalExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadFieldTelemetry();
  }

  Future<void> _loadFieldTelemetry() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getFieldAnalysis(_selectedField.id, 0);
    final planetScenes = await ApiService.getPlanetScenes(_selectedField.id);
    if (mounted) {
      setState(() {
        _pixels = (data['pixels'] as List<dynamic>).cast<PixelModel>();
        _satellite = data['satellite'] as SatelliteMetadataModel;
        _resolution = data['resolution'] as ResolutionAnalysisModel;
        _weather = data['weather'] as WeatherModel;
        _advisory = data['advisory'] as DynamicAdvisoryModel;
        _planetScene = planetScenes.isNotEmpty ? planetScenes.first : null;
        _yieldModel = data['yield_prediction'] as SugarcaneYieldModel?;
        _sucroseModel = data['sucrose_maturity'] as SucroseMaturityModel?;
        _irrigationModel = data['irrigation_prescription'] as IrrigationPrescriptionModel?;
        _anomalyModel = data['anomaly_ml'] as AnomalyDiagnosticMLModel?;
        _isLoading = false;
      });
    }
  }

  void _openAiTriage([String? initialPrompt]) {
    showDialog(
      context: context,
      builder: (ctx) => AiTriageDialog(initialPrompt: initialPrompt),
    );
  }

  void _showAllPlotsDialog(BuildContext context, bool isMr) {
    showDialog(
      context: context,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredFields = MockData.fields.where((f) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return f.name.toLowerCase().contains(q) ||
                  f.nameMr.toLowerCase().contains(q) ||
                  f.plotNumber.toLowerCase().contains(q) ||
                  f.variety.toLowerCase().contains(q) ||
                  f.areaAcres.toString().contains(q);
            }).toList();

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: 720,
                constraints: const BoxConstraints(maxHeight: 650),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.orangeLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.grid_view_rounded, color: AppColors.orange, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMr ? 'सर्व ३० नोंदणीकृत शेते' : 'All 30 Registered Plots',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                                Text(
                                  isMr ? 'पाहणी करण्यासाठी कोणतेही शेत निवडा' : 'Select any plot to inspect live telemetry',
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Search Input
                    TextField(
                      decoration: InputDecoration(
                        hintText: isMr
                            ? 'प्लॉट नंबर, नाव किंवा जात शोधा (उदा. 15, Phule)...'
                            : 'Search by plot #, name, or variety (e.g. 15, Phule)...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.orange),
                        filled: true,
                        fillColor: AppColors.bgSurface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() => searchQuery = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Plots Grid
                    Expanded(
                      child: filteredFields.isEmpty
                          ? Center(
                              child: Text(
                                isMr ? 'कोणतेही शेत सापडले नाही' : 'No plots matching your search',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          : GridView.builder(
                              itemCount: filteredFields.length,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 2.1,
                              ),
                              itemBuilder: (context, idx) {
                                final f = filteredFields[idx];
                                final isSelected = f.id == _selectedField.id;
                                return InkWell(
                                  onTap: () {
                                    setState(() => _selectedField = f);
                                    Navigator.pop(ctx);
                                    _loadFieldTelemetry();
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.orangeLight : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? AppColors.orange : AppColors.border,
                                        width: isSelected ? 1.8 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.orange : AppColors.bgSurface,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            f.plotNumber.replaceAll('Plot ', ''),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: isSelected ? Colors.white : AppColors.orangeDark,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                isMr ? f.nameMr : f.name,
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: isSelected ? AppColors.orangeDark : AppColors.textPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${f.areaAcres} ${isMr ? "एकर" : "ac"} · ${f.variety}',
                                                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(Icons.check_circle_rounded, color: AppColors.orange, size: 16),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final validPixels = _pixels.where((p) => !p.isBoundary).toList();
    final meanNdvi = validPixels.isNotEmpty
        ? validPixels.map((p) => p.ndvi).reduce((a, b) => a + b) / validPixels.length
        : 0.38;
    final meanNdmi = validPixels.isNotEmpty
        ? validPixels.map((p) => p.ndmi).reduce((a, b) => a + b) / validPixels.length
        : -0.06;

    final isMr = widget.isMarathi;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A. Welcome Header & Plot Selector (नमस्कार! 👋 आज तुमच्या शेताची स्थिती)
              _buildFarmerWelcomeHeader(isMr),
              const SizedBox(height: 16),

              // B. Main Crop Status (माझं पीक कसं आहे?)
              _buildCropHealthStatusCard(meanNdvi, isMr),
              const SizedBox(height: 16),

              // C. Water & Weather Section (शेताला पाण्याची गरज आहे का?)
              _buildWaterRequirementCard(meanNdmi, isMr),
              const SizedBox(height: 16),

              // D. Today's Farming Advice (आज काय करावे?)
              _buildTodayFarmingAdviceCard(isMr),
              const SizedBox(height: 16),

              // E. Spatial Parcel Map: Which part needs attention? (शेताचा नकाशा — कुठे लक्ष द्यावे?)
              _buildFarmerMapSection(isMr),
              const SizedBox(height: 16),

              // F. Yield & Harvest Maturity Card (अंदाजे उत्पादन आणि साखर उतारा)
              _buildYieldAndHarvestCard(isMr),
              const SizedBox(height: 20),

              // G. Farmer Quick Service Shortcuts
              _buildFarmerServiceShortcuts(isMr),
              const SizedBox(height: 24),

              // H. Optional Collapsible Technical Details (तांत्रिक माहिती)
              _buildCollapsibleTechnicalSection(meanNdvi, meanNdmi, isMr),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // A. Welcome Header & Plot Selector
  // =========================================================================
  Widget _buildFarmerWelcomeHeader(bool isMr) {
    final updateTimeStr = _satellite != null
        ? '${_satellite!.satellitePlatform} (${_satellite!.acquisitionTimestamp})'
        : (isMr ? '२० ऑक्टोबर २०२६ (सेंटिनेल-२ उपग्रह)' : '20 Oct 2026 (Sentinel-2)');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orangeLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isMr ? 'नमस्कार! 👋' : 'Welcome! 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.emerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isMr ? 'थेट उपग्रह जोडणी' : 'Live Satellite',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMr ? 'आज तुमच्या शेताची स्थिती' : 'Today\'s Crop & Field Status',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isMr
                          ? 'राजारामबापू पाटील सहकारी साखर कारखाना कार्यक्षेत्र · राजारामनगर / वाळवा'
                          : 'RBPSSK Sugarcane Command Area · Rajaramnagar / Walwa',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Plot Selector Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMr ? 'तुमचे नोंदणीकृत शेत निवडा (एकूण ३० शेते):' : 'Select Your Registered Plot (30 Plots):',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              InkWell(
                onTap: () => _showAllPlotsDialog(context, isMr),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.grid_on_rounded, size: 14, color: AppColors.orangeDark),
                      const SizedBox(width: 5),
                      Text(
                        isMr ? 'सर्व ३० शेते पहा / निवडा ▾' : 'View All 30 Plots ▾',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.orangeDark),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Active Plot Card with Direct Modal / Dropdown Trigger
          InkWell(
            onTap: () => _showAllPlotsDialog(context, isMr),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.orange, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedField.plotNumber,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMr ? _selectedField.nameMr : _selectedField.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedField.areaAcres} ${isMr ? "एकर" : "ac"} · ऊस जात: ${_selectedField.variety} · अवस्था: ${_selectedField.cropStage}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isMr ? 'बदला' : 'Change',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.orangeDark),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.orangeDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Quick Jump Number Carousel (1 to 30)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MockData.fields.map((field) {
                final isSel = field.id == _selectedField.id;
                final plotNum = field.plotNumber.replaceAll('Plot ', '');

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedField = field);
                    _loadFieldTelemetry();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSel ? AppColors.orange : AppColors.border,
                        width: isSel ? 1.5 : 1,
                      ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: AppColors.orange.withValues(alpha: 0.28),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      'P$plotNum',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSel ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Data update status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.satellite_alt_rounded, size: 15, color: AppColors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isMr ? 'ताजी उपग्रह नोंद: $updateTimeStr' : 'Satellite Telemetry: $updateTimeStr',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isMr ? 'ऊस जात: ${_selectedField.variety}' : 'Variety: ${_selectedField.variety}',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.orangeDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // B. Main Crop Status: माझं पीक कसं आहे?
  // =========================================================================
  Widget _buildCropHealthStatusCard(double meanNdvi, bool isMr) {
    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusDetail;
    String statusAdvice;

    if (meanNdvi >= 0.50) {
      statusColor = AppColors.emerald;
      statusIcon = Icons.eco_rounded;
      statusTitle = isMr ? 'पीक उत्तम आणि जोमदार वाढत आहे! 🌱' : 'Crop is Healthy and Growing Well! 🌱';
      statusDetail = isMr
          ? 'तुमच्या शेतातील उसाची वाढ समाधानकारक असून पानांचा हिरवेपणा उत्तम आहे. पिकाची घनता चांगली आहे.'
          : 'Canopy density and photosynthetic vigor are strong across the field.';
      statusAdvice = isMr
          ? 'सध्या पिकाला नियमित पाणी व पोषणाची गरज आहे. कोणताही गंभीर ताण नाही.'
          : 'Maintain routine irrigation and nutrient scheduling.';
    } else if (meanNdvi >= 0.35) {
      statusColor = AppColors.amber;
      statusIcon = Icons.info_outline_rounded;
      statusTitle = isMr ? 'पीक मध्यम स्थितीत आहे — काही भागात लक्ष द्या 🌾' : 'Crop Growth is Moderate — Attention Needed in Sections 🌾';
      statusDetail = isMr
          ? 'काही पट्ट्यांमध्ये पिकांची वाढ थोडी मंदावलेली दिसत आहे. पिवळेपणा किंवा जमिनीतील पाण्याची कमतरता असू शकते.'
          : 'Variations in canopy vigor observed. Possible localized moisture or nutrient stress.';
      statusAdvice = isMr
          ? 'खालील नकाशावर लाल किंवा पिवळा रंग असलेल्या भागात प्रत्यक्ष जाऊन पाहणी करा.'
          : 'Inspect the field rows indicated in red/yellow on the parcel map.';
    } else {
      statusColor = AppColors.rose;
      statusIcon = Icons.warning_amber_rounded;
      statusTitle = isMr ? 'काही भागात तात्काळ लक्ष देण्याची गरज आहे ⚠️' : 'Urgent Attention Required in Crop Sections ⚠️';
      statusDetail = isMr
          ? 'पिकात पाण्याचा ताण किंवा पानांचा पिवळेपणा तीव्र स्वरूपात जाणवत आहे.'
          : 'Significant moisture deficit or chlorosis identified by multispectral sensors.';
      statusAdvice = isMr
          ? 'तातडीने ठिबक सिंचन सुरू करा किंवा जवळच्या कृषी सहाय्यकांचा सल्ला घ्या.'
          : 'Initiate irrigation immediately and consider nutrient booster spray.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMr ? 'माझं पीक कसं आहे?' : 'How is My Crop Doing?',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusDetail,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.orange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        statusAdvice,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orangeDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // C. Does My Field Need Water? & Weather Forecast: शेताला पाण्याची गरज आहे का?
  // =========================================================================
  Widget _buildWaterRequirementCard(double meanNdmi, bool isMr) {
    final rain7d = _weather?.rainfallRecent7dMm ?? 0.0;
    final temp = _weather?.temperature2mC ?? 31.0;
    final humidity = _weather?.relativeHumidityPct ?? 65.0;
    final et0 = _weather?.et0EvapotranspirationMm ?? 4.8;
    final dripHours = _irrigationModel?.recommendedDripRuntimeHours ?? 2.5;

    bool needsWater = false;
    String waterTitle;
    String waterDetail;
    Color waterColor;
    IconData waterIcon;

    if (rain7d >= 15.0) {
      needsWater = false;
      waterColor = AppColors.cyan;
      waterIcon = Icons.cloud_done_rounded;
      waterTitle = isMr ? 'आज पाणी देण्याची घाई करू नका 🌧️' : 'No Immediate Irrigation Needed 🌧️';
      waterDetail = isMr
          ? 'हवामानाच्या अंदाजानुसार आगामी काही दिवसांत पाऊस पडण्याची शक्यता आहे. अतिरिक्त पाणी दिल्यास मुळांभोवती पाणी साचू शकते.'
          : 'Forecast predicts incoming rainfall. Excess watering may saturate rootzone.';
    } else if (meanNdmi < -0.02 || (_irrigationModel?.soilMoistureStatus.contains('Deficit') ?? true)) {
      needsWater = true;
      waterColor = AppColors.orange;
      waterIcon = Icons.water_drop_rounded;
      waterTitle = isMr ? 'होय, शेताला पाण्याची आवश्यकता आहे! 💧' : 'Yes, Irrigation is Needed Today! 💧';
      waterDetail = isMr
          ? 'उन्हामुळे जमिनीतून पाण्याचे बाष्पीभवन (${et0.toStringAsFixed(1)} मिमी/दिवस) वेगाने होत आहे. पिकाला पाण्याचा ताण पडू नये म्हणून पाणी द्यावे.'
          : 'High evapotranspiration (${et0.toStringAsFixed(1)} mm/day) has depleted rootzone moisture.';
    } else {
      needsWater = false;
      waterColor = AppColors.emerald;
      waterIcon = Icons.check_circle_outline_rounded;
      waterTitle = isMr ? 'शेतात पुरेसा ओलावा आहे 👍' : 'Adequate Soil Moisture 👍';
      waterDetail = isMr
          ? 'उपग्रहाच्या नोंदीनुसार पिकात सध्या पाण्याचा पुरेसा ओलावा उपलब्ध आहे. पाणी देण्यापूर्वी उद्या पुन्हा तपासा.'
          : 'Leaf water content is within the optimal zone. Recheck tomorrow before irrigating.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: waterColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(waterIcon, color: waterColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMr ? 'शेताला पाण्याची गरज आहे का?' : 'Does My Field Need Water?',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      waterTitle,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: waterColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            waterDetail,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.35),
          ),
          const SizedBox(height: 14),

          // Irrigation Prescription Box (if water is needed)
          if (needsWater)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.orangeDark, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMr ? 'शिफारस: ठिबक सिंचन चालवा' : 'Recommended Drip Run Time',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.orangeDark),
                        ),
                        Text(
                          isMr
                              ? '$dripHours तास (सकाळी ८ च्या आत किंवा संध्याकाळी ५ नंतर)'
                              : '$dripHours Hours (Early morning before 8 AM or after 5 PM)',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // 4-Card Weather Strip (हवामानाचा अंदाज)
          Text(
            isMr ? 'हवामानाचा अंदाज (सांगली / वाळवा)' : 'Weather Forecast (Sangli / Walwa)',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _weatherPill(
                  icon: Icons.thermostat_rounded,
                  iconColor: const Color(0xFFE11D48),
                  label: isMr ? 'तापमान' : 'Temp',
                  value: '${temp.toStringAsFixed(0)}°C',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _weatherPill(
                  icon: Icons.water_drop_outlined,
                  iconColor: AppColors.cyan,
                  label: isMr ? 'पाऊस' : 'Rain',
                  value: '${rain7d.toStringAsFixed(1)} mm',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _weatherPill(
                  icon: Icons.cloud_outlined,
                  iconColor: const Color(0xFF0284C7),
                  label: isMr ? 'हवेतील आर्द्रता' : 'Humidity',
                  value: '${humidity.toStringAsFixed(0)}%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _weatherPill(
                  icon: Icons.wb_sunny_outlined,
                  iconColor: AppColors.orange,
                  label: isMr ? 'बाष्पीभवन' : 'ET₀',
                  value: '${et0.toStringAsFixed(1)} mm/d',
                ),
              ),
            ],
          ),
          if (_weather != null) ...[
            const SizedBox(height: 14),
            WeatherStationCard(
              weather: _weather!,
              isMarathi: isMr,
            ),
          ],
        ],
      ),
    );
  }

  Widget _weatherPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // D. Today's Farming Advice: आज काय करावे?
  // =========================================================================
  Widget _buildTodayFarmingAdviceCard(bool isMr) {
    final conditionMr = _anomalyModel?.topConditionMr ?? 'पाण्याचा ताण आणि पानांचे पोषण';
    final rxPrescription = _anomalyModel?.chemicalPrescriptionRx ?? '१९:१९:१९ विद्राव्य खत ५ ग्रॅम प्रति लिटर पाण्यातून फवारावे.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.orangeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.assignment_turned_in_outlined, color: AppColors.orange, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isMr ? 'आज काय करावे? (शेती सल्ला)' : 'What to Do Today? (Agro Advice)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isMr ? '३ महत्त्वाच्या गोष्टी' : '3 Key Actions',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.orangeDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Advice 1: Irrigation & Soil moisture
          _adviceItem(
            action: isMr ? 'पाणी देण्यापूर्वी जमिनीतील ओलावा तपासा' : 'Check soil moisture before irrigating',
            reason: isMr
                ? 'उपग्रह नोंदीनुसार बाष्पीभवन वेगाने होत आहे, परंतु शेतात प्रत्यक्ष फेरफटका मारून वाफसा तपासा.'
                : 'Satellite shows active evapotranspiration. Verify rootzone before starting pumps.',
            when: isMr ? 'आज सकाळी किंवा संध्याकाळी' : 'Morning or evening today',
            isUrgent: false,
            basis: isMr ? 'उपग्रह ओलावा डेटा व स्थानिक हवामान' : 'NDMI sensor & Open-Meteo',
            isMr: isMr,
          ),
          const SizedBox(height: 10),

          // Advice 2: Crop Protection & Nutrient
          _adviceItem(
            action: isMr ? 'पिकातील संभाव्य समस्या: $conditionMr' : 'Inspect for: $conditionMr',
            reason: isMr
                ? 'काही भागात पानांचा रंग फिकट दिसत आहे. उपाय: $rxPrescription'
                : 'Mild chlorosis in northern rows. Remedy: $rxPrescription',
            when: isMr ? 'पुढील २४ ते ४८ तासांत' : 'Next 24 to 48 hours',
            isUrgent: true,
            basis: isMr ? 'सेंटिनेल-२ रेड-एज व क्लोरोफिल स्पेक्ट्रम' : 'Sentinel-2 RedEdge & CARI',
            isMr: isMr,
          ),
          const SizedBox(height: 10),

          // Advice 3: Weather-based field activity
          _adviceItem(
            action: isMr ? 'फवारणी करताना हवेची स्थिती तपासा' : 'Monitor weather before spraying',
            reason: isMr
                ? 'दुपारी ऊन वाढल्याने औषध फवारणी सकाळी १० च्या आधी किंवा संध्याकाळी ४ नंतर पूर्ण करा.'
                : 'Temperature increases by midday; complete any spray runs before 10 AM.',
            when: isMr ? 'सकाळी ८ ते १० दरम्यान' : 'Between 8 AM and 10 AM',
            isUrgent: false,
            basis: isMr ? 'स्थानिक हवामान केंद्र अंदाज' : 'Local meteorological station',
            isMr: isMr,
          ),
          const SizedBox(height: 14),

          // Action button: Ask AI Triage
          ElevatedButton.icon(
            onPressed: () => _openAiTriage(isMr
                ? 'माझ्या शेतातील उसाची वाढ आणि पाण्याची स्थिती याबद्दल मार्गदर्शन करा.'
                : 'Please advise on sugarcane growth and irrigation for Plot 30.'),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(
              isMr ? 'कृषी तज्ज्ञांना किंवा AI ला प्रश्न विचारा 💬' : 'Ask Agro AI Expert a Question 💬',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
              elevation: 1,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adviceItem({
    required String action,
    required String reason,
    required String when,
    required bool isUrgent,
    required String basis,
    required bool isMr,
  }) {
    final badgeColor = isUrgent ? AppColors.rose : AppColors.emerald;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  action,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isUrgent ? (isMr ? 'तातडीचे 🚨' : 'Urgent 🚨') : (isMr ? 'नियमित सल्ला 🌿' : 'Routine 🌿'),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reason,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    when,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Text(
                isMr ? 'आधार: $basis' : 'Source: $basis',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // E. Spatial Parcel Map: Which part of my field needs attention?
  // =========================================================================
  Widget _buildFarmerMapSection(bool isMr) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.orangeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.map_outlined, color: AppColors.orange, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMr ? 'शेताचा नकाशा (कुठे लक्ष द्यावे?)' : 'Field Map (Which Part Needs Attention?)',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      Text(
                        isMr ? 'उपग्रहाने घेतलेले शेताचे रंगीत चित्र' : 'Satellite multispectral field scan',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Multi-Spectral Indicator Matrix Toggle (5 Precision Agronomic Layers - Screenshot 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _spectralTogglePill(
                    label: isMr ? 'पिकांची वाढ · NDVI' : 'NDVI (Biomass)',
                    icon: Icons.eco_rounded,
                    isActive: _activeTab == 'growth' || _activeTab == 'ndvi',
                    activeColor: AppColors.emerald,
                    onTap: () => setState(() => _activeTab = 'growth'),
                  ),
                  const SizedBox(width: 4),
                  _spectralTogglePill(
                    label: isMr ? 'नत्र / पोषण · NDRE' : 'NDRE (Nitrogen)',
                    icon: Icons.grain_rounded,
                    isActive: _activeTab == 'ndre',
                    activeColor: const Color(0xFF8B5CF6),
                    onTap: () => setState(() => _activeTab = 'ndre'),
                  ),
                  const SizedBox(width: 4),
                  _spectralTogglePill(
                    label: isMr ? 'पिकांतील ओलावा · NDMI' : 'NDMI (Moisture)',
                    icon: Icons.water_drop_rounded,
                    isActive: _activeTab == 'moisture' || _activeTab == 'ndmi',
                    activeColor: AppColors.cyan,
                    onTap: () => setState(() => _activeTab = 'moisture'),
                  ),
                  const SizedBox(width: 4),
                  _spectralTogglePill(
                    label: isMr ? 'माती-सुधारित · MSAVI2' : 'MSAVI2 (Soil-Free)',
                    icon: Icons.filter_hdr_outlined,
                    isActive: _activeTab == 'msavi2',
                    activeColor: const Color(0xFFD97706),
                    onTap: () => setState(() => _activeTab = 'msavi2'),
                  ),
                  const SizedBox(width: 4),
                  _spectralTogglePill(
                    label: isMr ? 'हरितद्रव्य · CARI' : 'CARI (Chlorophyll)',
                    icon: Icons.biotech_outlined,
                    isActive: _activeTab == 'cari',
                    activeColor: const Color(0xFF0D9488),
                    onTap: () => setState(() => _activeTab = 'cari'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Coordinate-Clipped Satellite Map Canvas
          _isLoading
              ? Container(
                  height: 340,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const CircularProgressIndicator(color: AppColors.orange),
                )
              : SatelliteMapCanvas(
                  field: _selectedField,
                  allFields: MockData.fields,
                  pixels: _pixels,
                  activeTab: _activeTab,
                  isGradientMode: _isGradientMode,
                  onToggleGradientMode: (val) => setState(() => _isGradientMode = val),
                  onFieldSelected: (field) {
                    setState(() => _selectedField = field);
                    _loadFieldTelemetry();
                  },
                ),
          const SizedBox(height: 14),

          // Marathi Continuous Gradient Legend
          ContinuousGradientLegend(
            activeTab: _activeTab,
            isGradientMode: _isGradientMode,
            isMarathi: isMr,
            onToggleGradientMode: (val) => setState(() => _isGradientMode = val),
            onFullAnalysis: () => widget.onNavigateToField(_selectedField),
          ),
        ],
      ),
    );
  }

  Widget _spectralTogglePill({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // F. Estimated Yield & Harvest Maturity: अंदाजे उत्पादन आणि साखर उतारा
  // =========================================================================
  Widget _buildYieldAndHarvestCard(bool isMr) {
    final yieldTonPerAcre = _yieldModel?.predictedYieldMtPerAcre ?? 58.4;
    final totalFieldTonnes = _yieldModel?.totalFieldTonnes ?? 17.5;
    final brix = _sucroseModel?.brixDegrees ?? 21.8;
    final harvestWindow = isMr
        ? '${_sucroseModel?.optimalHarvestWindowStart ?? "३५ दिवसांत"} ते ${_sucroseModel?.optimalHarvestWindowEnd ?? "५५ दिवसांत"}'
        : '${_sucroseModel?.optimalHarvestWindowStart ?? "In 35 Days"} to ${_sucroseModel?.optimalHarvestWindowEnd ?? "In 55 Days"}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.agriculture_rounded, color: AppColors.orange, size: 22),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMr ? 'अंदाजे उत्पादन आणि तोडणी माहिती' : 'Predicted Yield & Harvest Maturity',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  Text(
                    isMr ? 'राजारामबापू पाटील साखर कारखाना नोंदणी' : 'RBPSSK Factory Harvest Scheduling',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Yield Metrics Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMr ? 'अंदाजे उत्पादन' : 'Expected Yield',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${yieldTonPerAcre.toStringAsFixed(1)} ${isMr ? "टन / एकर" : "MT / Acre"}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.emerald),
                      ),
                      Text(
                        isMr ? 'एकूण शेतात: ~${totalFieldTonnes.toStringAsFixed(1)} टन' : 'Total Field: ~${totalFieldTonnes.toStringAsFixed(1)} Tonnes',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMr ? 'साखर प्रमाण (ब्रिक्स)' : 'Sucrose (Brix)',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${brix.toStringAsFixed(1)}° Brix',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.orangeDark),
                      ),
                      Text(
                        isMr ? 'साखर उतारा चांगला' : 'Optimal Sugar Recovery',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Harvest Window Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.orangeDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isMr ? 'अपेक्षित तोडणी कालावधी: $harvestWindow' : 'Optimal Harvest Window: $harvestWindow',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onNavigateTab(2),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    isMr ? 'तोडणी पावती ->' : 'Harvest Slip ->',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.orangeDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // G. Farmer Quick Service Shortcuts
  // =========================================================================
  Widget _buildFarmerServiceShortcuts(bool isMr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMr ? 'शेतकऱ्यांसाठी इतर सेवा' : 'Farmer Support Services',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        _shortcutRow(
          icon: Icons.receipt_long_rounded,
          title: isMr ? 'तोडणी पावती आणि नोंदणी' : 'Harvesting Slips & Quotas',
          subtitle: isMr ? 'कारखान्याची अधिकृत तोडणी पावती आणि थेट QR पडताळणी' : 'Active season authorizations and live QR verification',
          badge: 'CR-00000002',
          onTap: () => widget.onNavigateTab(2),
        ),
        const SizedBox(height: 8),
        _shortcutRow(
          icon: Icons.flight_takeoff_rounded,
          title: isMr ? 'ड्रोन फवारणी बुकिंग' : 'Precision Drone Spraying',
          subtitle: isMr ? 'शेतात औषध किंवा खत फवारणीसाठी ड्रोन बुक करा' : 'Book sub-decimeter multispectral imaging or canopy spray',
          badge: isMr ? '४८ तासांत' : '48h Slot',
          onTap: () => widget.onNavigateTab(3),
        ),
        const SizedBox(height: 8),
        _shortcutRow(
          icon: Icons.biotech_outlined,
          title: isMr ? 'माती व पाणी परीक्षण प्रयोगशाळा' : 'Soil & Water Testing Lab',
          subtitle: isMr ? 'जमिनीतील एन.पी.के. आणि क्षारतेची खात्रीशीर तपासणी' : 'NPK, electrical conductivity, and micronutrient testing',
          badge: 'ISO-Calibrated',
          onTap: () => widget.onNavigateTab(3),
        ),
        const SizedBox(height: 8),
        _shortcutRow(
          icon: Icons.storefront_outlined,
          title: isMr ? 'कारखाना खत व औषध केंद्र' : 'Factory Farm Store',
          subtitle: isMr ? 'सवलतीच्या दरात कंपोस्ट खत, जिवाणू खते आणि जैविक औषधे' : 'Subsidized press mud, compost & biological controls',
          badge: isMr ? 'सभासद दर' : 'Member Rates',
          onTap: () => widget.onNavigateTab(3),
        ),
      ],
    );
  }

  Widget _shortcutRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.orangeDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // H. Optional Collapsible Technical Details (तांत्रिक माहिती)
  // =========================================================================
  Widget _buildCollapsibleTechnicalSection(double meanNdvi, double meanNdmi, bool isMr) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isTechnicalExpanded,
          onExpansionChanged: (val) => setState(() => _isTechnicalExpanded = val),
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.science_outlined, color: AppColors.orange, size: 20),
          ),
          title: Text(
            isMr ? 'तांत्रिक माहिती (Technical Details)' : 'Technical Details & Scientific Telemetry',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            isMr
                ? 'कृषी शास्त्रज्ञ व सखोल डेटा विश्लेषणासाठी (NDVI, NDMI, ET₀, उपग्रह रिझोल्यूशन)'
                : 'For agricultural scientists & agronomic specialists (NDVI, NDMI, ET₀, Sentinel-2)',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 18, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 12),

                  // 1. Live Telemetry Gauges Grid
                  if (_weather != null && _resolution != null)
                    TelemetryGaugesGrid(
                      meanNdvi: meanNdvi,
                      meanNdmi: meanNdmi,
                      weather: _weather!,
                      resolution: _resolution!,
                      statusLevel: _advisory?.statusLevel ?? 'check',
                    ),
                  const SizedBox(height: 16),

                  // 2. AI ML Predictive Agro-Cockpit
                  SugarcaneMLCockpit(
                    yieldModel: _yieldModel,
                    sucroseModel: _sucroseModel,
                    irrigationModel: _irrigationModel,
                    anomalyModel: _anomalyModel,
                    field: _selectedField,
                  ),
                  const SizedBox(height: 16),

                  // 3. Data Providers HUD
                  DataProvidersHud(
                    satellite: _satellite,
                    weather: _weather,
                    planetScene: _planetScene,
                  ),
                  const SizedBox(height: 16),

                  // 4. ML Anomaly Classifier Diagnostic
                  _buildDifferentialDiagnosticCard(isMr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Differential Diagnostic Anomaly Card inside Technical Section
  Widget _buildDifferentialDiagnosticCard(bool isMr) {
    final topCond = _anomalyModel?.topCondition ?? _advisory?.headline ?? 'Moisture Deficit (Drought Stress)';
    final confPct = _anomalyModel?.mlConfidencePct ?? _advisory?.confidencePct ?? 78;
    final probs = _anomalyModel?.probabilityDistribution ?? {
      'Moisture Deficit (Drought Stress)': 0.78,
      'Nitrogen Chlorosis (Nutrient Deficiency)': 0.12,
      'Early Shoot Borer / White Grub Risk': 0.06,
      'Red Rot / Smut Fungal Threat': 0.03,
      'Optimal Vigorous Canopy': 0.01,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology_rounded, size: 18, color: AppColors.orange),
                  const SizedBox(width: 8),
                  Text(
                    isMr ? 'मल्टी-स्पेक्ट्रल ML वर्गीकरण' : 'MULTI-SPECTRAL ML ANOMALY CLASSIFIER',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$confPct% ML Confidence',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.emerald),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            topCond,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            _advisory?.detail ?? 'Canopy shows clear moisture stress in sector 2 with accelerated transpiration.',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Softmax Probabilities
          ...probs.entries.take(4).map((entry) {
            final pct = (entry.value * 100).clamp(0, 100).toInt();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                      Text('$pct%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.orangeDark)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: entry.value.clamp(0.0, 1.0),
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Precision Agronomic Rx Box (Screenshot 3)
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medical_services_outlined, size: 20, color: AppColors.emerald),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMr ? 'पिकासाठी अचूक शिफारस (Precision Agronomic Rx):' : 'Precision Agronomic Rx:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.emerald),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _advisory?.suggestedActions.isNotEmpty == true
                            ? _advisory!.suggestedActions.first
                            : 'Chlorantraniliprole 18.5% SC @ 150 ml/acre drenching for root grub protection / targeted irrigation.',
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
