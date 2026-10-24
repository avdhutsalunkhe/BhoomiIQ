import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AiTriageDialog extends StatefulWidget {
  final String? initialPrompt;

  const AiTriageDialog({super.key, this.initialPrompt});

  @override
  State<AiTriageDialog> createState() => _AiTriageDialogState();
}

class _AiTriageDialogState extends State<AiTriageDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _triageResult;

  final List<String> _quickSymptoms = [
    'Yellowing on top whorl leaves (पाने पिवळी पडणे)',
    'Dead-heart with bore holes at base (खोडरोग / कांडी कीड)',
    'Reddish lesions & sour odor inside stem (तांबेरा / लाल कुजव्या)',
    'Lower leaf drying & general yellowing (खालची पाने सुकणे)',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      _controller.text = widget.initialPrompt!;
      _analyzeSymptom(widget.initialPrompt!);
    }
  }

  Future<void> _analyzeSymptom(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _triageResult = null;
    });

    final res = await ApiService.triageSymptom(text, 'Grand Growth');
    if (mounted) {
      setState(() {
        _isLoading = false;
        _triageResult = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.smart_toy_outlined, color: AppColors.orange, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ask BhoomiIQ (विचार करा)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        'AI Sugarcane Symptom & Advisory Assistant',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.divider),

            // Quick Symptom Chips
            const Text(
              'Select common symptom or describe below:',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickSymptoms.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: AppColors.bgSurface,
                      side: const BorderSide(color: AppColors.orangeLight, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      onPressed: () {
                        _controller.text = s;
                        _analyzeSymptom(s);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Input field with Analyze button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.bgSurfaceMuted,
                      hintText: 'Describe leaf symptom or ask a question...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.orange, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.orange),
                    ),
                    onSubmitted: _analyzeSymptom,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _analyzeSymptom(_controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Analyze', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Triage Result View
            Expanded(
              child: _triageResult == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.biotech_outlined, size: 48, color: AppColors.orange.withValues(alpha: 0.4)),
                          const SizedBox(height: 10),
                          const Text(
                            'Enter cane symptoms to receive an instant\nagronomic differential triage.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.orangeLight, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Result Header
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _triageResult!['detected_condition'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _triageResult!['condition_marathi'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _triageResult!['severity'] == 'Critical'
                                        ? AppColors.rose.withValues(alpha: 0.15)
                                        : _triageResult!['severity'] == 'High'
                                            ? AppColors.orange.withValues(alpha: 0.15)
                                            : Colors.blue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _triageResult!['severity'] == 'Critical'
                                          ? AppColors.rose
                                          : _triageResult!['severity'] == 'High'
                                              ? AppColors.orange
                                              : Colors.blue,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${_triageResult!['severity']} Severity',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: _triageResult!['severity'] == 'Critical'
                                          ? AppColors.rose
                                          : _triageResult!['severity'] == 'High'
                                              ? AppColors.orangeDark
                                              : Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, color: AppColors.border),

                            // Next Steps
                            const Text(
                              'Immediate Next Actions:',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            ...?(_triageResult!['immediate_next_steps'] as List<dynamic>?)?.map(
                              (step) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.arrow_right, size: 18, color: AppColors.orange),
                                    Expanded(
                                      child: Text(
                                        step.toString(),
                                        style: const TextStyle(fontSize: 12.5, height: 1.35, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Factory Liaison
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: AppColors.orangeLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone_in_talk, size: 16, color: AppColors.orangeDark),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _triageResult!['expert_consultation'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.orangeDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
