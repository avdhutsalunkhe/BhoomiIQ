import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../services/mock_data.dart';
import '../theme/app_theme.dart';
import 'home_dashboard_screen.dart';
import 'field_detail_screen.dart';
import 'slips_screen.dart';
import 'learn_screen.dart';
import '../widgets/ai_triage_dialog.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  FarmFieldModel? _selectedFieldForDetail;
  bool _isMarathi = true;

  void _navigateToField(FarmFieldModel field) {
    setState(() {
      _selectedFieldForDetail = field;
      _currentIndex = 1; // Fields Tab
    });
  }

  void _openAiTriage([String? prompt]) {
    showDialog(
      context: context,
      builder: (ctx) => AiTriageDialog(initialPrompt: prompt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeDashboardScreen(
        onNavigateToField: _navigateToField,
        onNavigateTab: (idx) => setState(() => _currentIndex = idx),
        isMarathi: _isMarathi,
      ),
      FieldDetailScreen(
        key: ValueKey(_selectedFieldForDetail?.id ?? 'default'),
        initialField: _selectedFieldForDetail ?? MockData.fields[0],
        onNavigateTab: (idx) => setState(() => _currentIndex = idx),
      ),
      const SlipsScreen(),
      const LearnScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x14000000),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.eco_rounded, color: AppColors.orange, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      _isMarathi ? 'भूमीआयक्यू (BhoomiIQ)' : 'BHOOMIIQ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.orangeLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _isMarathi ? 'शेतकरी मित्र' : 'PRECISION AGRO',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _isMarathi ? 'राजारामबापू साखर कारखाना कार्यक्षेत्र, सांगली' : 'RBPSSK Command Core · Sangli',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Weather badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.orangeLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 14, color: AppColors.orange),
                const SizedBox(width: 6),
                Text(
                  _isMarathi ? '३१°C · सांगली' : '31°C · Sangli Core',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Bilingual Language Toggle
          TextButton(
            onPressed: () => setState(() => _isMarathi = !_isMarathi),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: AppColors.bgSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.orangeLight),
              ),
            ),
            child: Text(
              _isMarathi ? 'English' : 'मराठी',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.orange,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Notification Bell
          IconButton(
            icon: const Badge(
              label: Text('1', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.orange,
              child: Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isMarathi
                      ? 'शेताची सूचना: गट क्र. ३० मधील उसाची पाहणी करा.'
                      : 'Field Alert: Plot 30 growth reading requires physical inspection.'),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAiTriage(),
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat_bubble_outline, size: 19),
        label: Text(
          _isMarathi ? 'सल्ला विचारा 🌾' : 'Ask BhoomiIQ',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) {
            setState(() {
              _currentIndex = idx;
              if (idx == 1 && _selectedFieldForDetail == null) {
                _selectedFieldForDetail = MockData.fields[0];
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.orange,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: _isMarathi ? 'माझं शेत' : 'Command',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: _isMarathi ? 'शेताचे नकाशे' : 'Parcels',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: _isMarathi ? 'तोडणी पावती' : 'Harvest Slips',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.school_outlined),
              activeIcon: const Icon(Icons.school),
              label: _isMarathi ? 'शेती शाळा' : 'Agro Academy',
            ),
          ],
        ),
      ),
    );
  }
}
