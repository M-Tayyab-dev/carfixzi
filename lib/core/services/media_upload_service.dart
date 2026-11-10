import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Result from Cloudinary upload
class UploadResult {
  final String publicId;
  final String secureUrl;
  final String format;
  final int bytes;

  const UploadResult({
    required this.publicId,
    required this.secureUrl,
    required this.format,
    required this.bytes,
  });
}

/// Service managing document and image uploads to Cloudinary
class MediaUploadService {
  // Verified Cloudinary Credentials
  static const String cloudName = 'mbecykon';
  static const String apiKey = '913588559286195';
  static const String apiSecret = '6_8G2S1kTbpM98DOLwoLo6gxoAY';

  final ImagePicker _imagePicker = ImagePicker();

  /// Picks an image via Camera or Gallery and uploads to Cloudinary
  Future<UploadResult?> pickAndUploadImage({
    required ImageSource source,
    String folder = 'carfixzi/onboarding',
  }) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (file == null) return null;

      final bytes = await file.readAsBytes();
      final filename = file.name.isNotEmpty ? file.name : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      return await uploadBytes(
        bytes: bytes,
        filename: filename,
        folder: folder,
        isPdf: false,
      );
    } catch (e) {
      debugPrint('[MediaUploadService] pickAndUploadImage error: $e');
      rethrow;
    }
  }

  /// Picks a PDF document or image file and uploads to Cloudinary
  Future<UploadResult?> pickAndUploadDocument({
    String folder = 'carfixzi/onboarding/tax_returns',
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final pickedFile = result.files.first;
      final bytes = pickedFile.bytes;
      if (bytes == null) return null;

      final filename = pickedFile.name;
      final isPdf = filename.toLowerCase().endsWith('.pdf');

      return await uploadBytes(
        bytes: bytes,
        filename: filename,
        folder: folder,
        isPdf: isPdf,
      );
    } catch (e) {
      debugPrint('[MediaUploadService] pickAndUploadDocument error: $e');
      rethrow;
    }
  }

  /// Direct signed upload to Cloudinary API
  Future<UploadResult> uploadBytes({
    required Uint8List bytes,
    required String filename,
    required String folder,
    required bool isPdf,
  }) async {
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    // Calculate SHA-1 signature
    final toSign = 'folder=$folder&timestamp=$timestamp$apiSecret';
    final signature = sha1.convert(utf8.encode(toSign)).toString();

    final resourceType = isPdf ? 'raw' : 'image';
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');

    // Encode file to base64 data URI for universal cross-platform (Web + Android) compatibility
    final ext = filename.split('.').last.toLowerCase();
    final mime = isPdf ? 'application/pdf' : 'image/$ext';
    final b64 = base64Encode(bytes);
    final dataUri = 'data:$mime;base64,$b64';

    final response = await http.post(
      uri,
      body: {
        'file': dataUri,
        'folder': folder,
        'timestamp': timestamp,
        'api_key': apiKey,
        'signature': signature,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UploadResult(
        publicId: json['public_id'] as String? ?? 'uploaded_${DateTime.now().millisecondsSinceEpoch}',
        secureUrl: json['secure_url'] as String? ?? '',
        format: json['format'] as String? ?? ext,
        bytes: json['bytes'] as int? ?? bytes.length,
      );
    } else {
      throw Exception('Cloudinary upload failed (HTTP ${response.statusCode}): ${response.body}');
    }
  }
}
