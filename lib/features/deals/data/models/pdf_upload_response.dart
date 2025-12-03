class PdfUploadResponse {
  final String fileId;
  final String cdnUrl;

  PdfUploadResponse({
    required this.fileId,
    required this.cdnUrl,
  });

  factory PdfUploadResponse.fromJson(Map<String, dynamic> json) => PdfUploadResponse(
        fileId: json['fileId'] as String,
        cdnUrl: json['cdnUrl'] as String,
      );

  Map<String, dynamic> toJson() => {
        'fileId': fileId,
        'cdnUrl': cdnUrl,
      };
}

