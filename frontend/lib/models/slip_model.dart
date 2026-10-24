class HarvestingSlipModel {
  final String slipId;
  final String regId;
  final String season;
  final String farmerName;
  final String farmerNameMr;
  final String plotName;
  final String village;
  final String caneType;
  final String variety;
  final double registeredAreaAcres;
  final String plantingDate;
  final String harvestingDate;
  final double estimatedTonnes;
  final String method;
  final String status;
  final String registeredAt;
  final String issuedAt;
  final String assignedOfficer;
  final String remarks;
  final String qrPayload;

  const HarvestingSlipModel({
    required this.slipId,
    required this.regId,
    required this.season,
    required this.farmerName,
    required this.farmerNameMr,
    required this.plotName,
    required this.village,
    required this.caneType,
    required this.variety,
    required this.registeredAreaAcres,
    required this.plantingDate,
    required this.harvestingDate,
    required this.estimatedTonnes,
    required this.method,
    required this.status,
    required this.registeredAt,
    required this.issuedAt,
    required this.assignedOfficer,
    required this.remarks,
    required this.qrPayload,
  });

  factory HarvestingSlipModel.fromJson(Map<String, dynamic> json) {
    return HarvestingSlipModel(
      slipId: json['slip_id'] as String? ?? '',
      regId: json['reg_id'] as String? ?? '',
      season: json['season'] as String? ?? '2026–27',
      farmerName: json['farmer_name'] as String? ?? '',
      farmerNameMr: json['farmer_name_mr'] as String? ?? '',
      plotName: json['plot_name'] as String? ?? '',
      village: json['village'] as String? ?? 'राजारामनगर',
      caneType: json['cane_type'] as String? ?? 'Plant cane',
      variety: json['variety'] as String? ?? 'Co 86032',
      registeredAreaAcres: (json['registered_area_acres'] as num?)?.toDouble() ?? 0.0,
      plantingDate: json['planting_date'] as String? ?? '',
      harvestingDate: json['harvesting_date'] as String? ?? '',
      estimatedTonnes: (json['estimated_tonnes'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? 'Manual',
      status: json['status'] as String? ?? 'Slip issued',
      registeredAt: json['registered_at'] as String? ?? '',
      issuedAt: json['issued_at'] as String? ?? '',
      assignedOfficer: json['assigned_officer'] as String? ?? '',
      remarks: json['remarks'] as String? ?? '',
      qrPayload: json['qr_payload'] as String? ?? '',
    );
  }
}

class QRVerificationResult {
  final bool valid;
  final String? slipId;
  final String? regId;
  final String? farmerName;
  final String? plotName;
  final double? estimatedTonnes;
  final String? harvestingDate;
  final String? status;
  final String issuer;
  final String verifiedAt;
  final String legalNotice;

  const QRVerificationResult({
    required this.valid,
    this.slipId,
    this.regId,
    this.farmerName,
    this.plotName,
    this.estimatedTonnes,
    this.harvestingDate,
    this.status,
    required this.issuer,
    required this.verifiedAt,
    required this.legalNotice,
  });

  factory QRVerificationResult.fromJson(Map<String, dynamic> json) {
    return QRVerificationResult(
      valid: json['valid'] as bool? ?? false,
      slipId: json['slip_id'] as String?,
      regId: json['reg_id'] as String?,
      farmerName: json['farmer_name'] as String?,
      plotName: json['plot_name'] as String?,
      estimatedTonnes: (json['estimated_tonnes'] as num?)?.toDouble(),
      harvestingDate: json['harvesting_date'] as String?,
      status: json['status'] as String?,
      issuer: json['issuer'] as String? ?? 'RBPSSK Ltd.',
      verifiedAt: json['verified_at'] as String? ?? '',
      legalNotice: json['legal_notice'] as String? ?? '',
    );
  }
}
