class UserDocumentsDTO {
  final String? idCardUrl;
  final String? profileImageUrl;
  final String? medicalCertificateUrl;
  final String? federalLicenseUrl;
  final String? licenseUrl;

  const UserDocumentsDTO({
    this.idCardUrl,
    this.profileImageUrl,
    this.medicalCertificateUrl,
    this.federalLicenseUrl,
    this.licenseUrl,
  });

  factory UserDocumentsDTO.fromJson(Map<String, dynamic> json) =>
      UserDocumentsDTO(
        idCardUrl: json['idCardUrl'],
        profileImageUrl: json['profileImageUrl'],
        medicalCertificateUrl: json['medicalCertificateUrl'],
        federalLicenseUrl: json['federalLicenseUrl'],
        licenseUrl: json['licenseUrl'],
      );

  Map<String, dynamic> toJson() => {
        'idCardUrl': idCardUrl,
        'profileImageUrl': profileImageUrl,
        'medicalCertificateUrl': medicalCertificateUrl,
        'federalLicenseUrl': federalLicenseUrl,
        'licenseUrl': licenseUrl,
      };

  bool get hasAnyDocument =>
      idCardUrl != null ||
      profileImageUrl != null ||
      medicalCertificateUrl != null ||
      federalLicenseUrl != null ||
      licenseUrl != null;
}
