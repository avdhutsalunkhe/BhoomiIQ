import 'package:flutter/material.dart';
import '../models/learn_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<AgronomicGuideModel> _guides = [];
  List<FactorySchemeModel> _schemes = [];
  List<FactoryFacilityModel> _facilities = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final g = await ApiService.getGuides();
    final s = await ApiService.getSchemes();
    final f = await ApiService.getFacilities();
    if (mounted) {
      setState(() {
        _guides = g;
        _schemes = s;
        _facilities = f;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Learn — Practical guides for your farm',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Stage-by-stage agronomy advice, sugar factory subsidies, and agricultural facilities.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'What would you like to learn?',
                  hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
              const SizedBox(height: 18),

              // Tabs: Guides, Schemes, Facilities
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  tabs: const [
                    Tab(text: 'Guides'),
                    Tab(text: 'Schemes'),
                    Tab(text: 'Facilities'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Content based on selected tab
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        switch (_tabController.index) {
                          case 0:
                            return _buildGuidesTab();
                          case 1:
                            return _buildSchemesTab();
                          case 2:
                            return _buildFacilitiesTab();
                          default:
                            return _buildGuidesTab();
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidesTab() {
    final filtered = _guides.where((g) {
      if (_searchQuery.isEmpty) return true;
      return g.title.toLowerCase().contains(_searchQuery) ||
          g.titleMr.toLowerCase().contains(_searchQuery) ||
          g.summary.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final isTwoCol = constraints.maxWidth >= 600;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: filtered.map((g) {
              return SizedBox(
                width: isTwoCol ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                child: _buildGuideCard(g),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildGuideCard(AgronomicGuideModel guide) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                guide.stage,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              guide.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
            ),
            Text(
              guide.titleMr,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              guide.summary,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            if (guide.dosages.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: guide.dosages
                      .map((d) => Text('• $d', style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155))))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemesTab() {
    return Column(
      children: _schemes.map((scheme) {
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheme.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                ),
                Text(
                  scheme.titleMr,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Color(0xFFD97706), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          scheme.benefit,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Eligibility: ${scheme.eligibility}',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Contact: ${scheme.contactName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${scheme.contactPhone}...')),
                        );
                      },
                      icon: const Icon(Icons.call, size: 16),
                      label: const Text('Call contact'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFacilitiesTab() {
    return Column(
      children: [
        ..._facilities.map((fac) {
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fac.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                            ),
                            Text(
                              fac.titleMr,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          fac.department,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fac.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Turnaround: ${fac.leadTime}',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Connecting to ${fac.title} (${fac.contactPhone})...')),
                          );
                        },
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Call contact'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),

        // Factory Farm Supplies Banner (matching Screen 8 bottom banner)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse farm supplies',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Order factory-subsidized press mud, bio-fertilizers & chemicals',
                    style: TextStyle(fontSize: 12, color: AppColors.accentMint),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Factory Store catalog...')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
