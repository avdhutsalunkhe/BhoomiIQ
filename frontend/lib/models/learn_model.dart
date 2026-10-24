class AgronomicGuideModel {
  final String id;
  final String stage;
  final String stageMr;
  final String title;
  final String titleMr;
  final String summary;
  final String summaryMr;
  final String category;
  final List<String> dosages;
  final String? safetyNotes;

  const AgronomicGuideModel({
    required this.id,
    required this.stage,
    required this.stageMr,
    required this.title,
    required this.titleMr,
    required this.summary,
    required this.summaryMr,
    required this.category,
    required this.dosages,
    this.safetyNotes,
  });

  factory AgronomicGuideModel.fromJson(Map<String, dynamic> json) {
    return AgronomicGuideModel(
      id: json['id'] as String? ?? '',
      stage: json['stage'] as String? ?? '',
      stageMr: json['stage_mr'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleMr: json['title_mr'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      summaryMr: json['summary_mr'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      dosages: (json['dosages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      safetyNotes: json['safety_notes'] as String?,
    );
  }
}

class FactorySchemeModel {
  final String id;
  final String title;
  final String titleMr;
  final String benefit;
  final String benefitMr;
  final String eligibility;
  final String eligibilityMr;
  final String contactName;
  final String contactPhone;

  const FactorySchemeModel({
    required this.id,
    required this.title,
    required this.titleMr,
    required this.benefit,
    required this.benefitMr,
    required this.eligibility,
    required this.eligibilityMr,
    required this.contactName,
    required this.contactPhone,
  });

  factory FactorySchemeModel.fromJson(Map<String, dynamic> json) {
    return FactorySchemeModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleMr: json['title_mr'] as String? ?? '',
      benefit: json['benefit'] as String? ?? '',
      benefitMr: json['benefit_mr'] as String? ?? '',
      eligibility: json['eligibility'] as String? ?? '',
      eligibilityMr: json['eligibility_mr'] as String? ?? '',
      contactName: json['contact_name'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
    );
  }
}

class FactoryFacilityModel {
  final String id;
  final String title;
  final String titleMr;
  final String department;
  final String departmentMr;
  final String description;
  final String descriptionMr;
  final String leadTime;
  final String contactPhone;

  const FactoryFacilityModel({
    required this.id,
    required this.title,
    required this.titleMr,
    required this.department,
    required this.departmentMr,
    required this.description,
    required this.descriptionMr,
    required this.leadTime,
    required this.contactPhone,
  });

  factory FactoryFacilityModel.fromJson(Map<String, dynamic> json) {
    return FactoryFacilityModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleMr: json['title_mr'] as String? ?? '',
      department: json['department'] as String? ?? '',
      departmentMr: json['department_mr'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionMr: json['description_mr'] as String? ?? '',
      leadTime: json['lead_time'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
    );
  }
}
