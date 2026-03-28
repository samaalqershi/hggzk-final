import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// أداة مساعدة لحفظ ملفات PDF وفتحها ومشاركة مسارها من دون الاعتماد على حزمة الطباعة.
/// Utility for saving, opening, and sharing PDF files without depending on the printing package.
class PdfHelper {
  PdfHelper._();

  /// يحفظ بايتات PDF في ملف فعلي داخل مجلد مناسب للنظام.
  /// Saves PDF bytes into a real file inside a platform-appropriate directory.
  static Future<File> savePdfFile({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      // نختار مجلدًا مناسبًا بحسب المنصة حتى يبقى الملف قابلاً للوصول لاحقًا.
      Directory directory;

      if (Platform.isAndroid) {
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory.path}/$fileName.pdf';
      final file = File(filePath);

      await file.writeAsBytes(pdfBytes, flush: true);

      debugPrint('PDF saved to: $filePath');
      return file;
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      rethrow;
    }
  }

  /// يفتح ملف PDF عبر التطبيق الافتراضي في النظام.
  /// Opens a PDF file using the platform's default application.
  static Future<bool> openPdfFile(File file) async {
    try {
      final uri = Uri.file(file.path);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Cannot launch PDF file: ${file.path}');
        return false;
      }
    } catch (e) {
      debugPrint('Error opening PDF: $e');
      return false;
    }
  }

  /// يحفظ ملف PDF ثم يفتحه مباشرة إذا نجحت عملية الحفظ.
  /// Saves a PDF file and opens it immediately after a successful write.
  static Future<void> saveAndOpenPdf({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      final file = await savePdfFile(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      await openPdfFile(file);
    } catch (e) {
      debugPrint('Error in saveAndOpenPdf: $e');
      rethrow;
    }
  }

  /// يعيد مسار ملف PDF المحفوظ حتى يمكن تمريره لطبقة المشاركة أو الرفع.
  /// Returns the saved PDF path so another layer can share or upload it.
  static Future<String> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      final file = await savePdfFile(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      return file.path;
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      rethrow;
    }
  }

  /// ينشئ ملفًا مؤقتًا مناسبًا للمعاينة السريعة قبل الحفظ النهائي أو المشاركة.
  /// Creates a temporary file that can be used for preview flows.
  static Future<File> getTempPdfFile({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName.pdf';
      final file = File(filePath);

      await file.writeAsBytes(pdfBytes, flush: true);
      return file;
    } catch (e) {
      debugPrint('Error creating temp PDF: $e');
      rethrow;
    }
  }

  /// يحذف ملف PDF من القرص إذا كان موجودًا.
  /// Deletes a PDF file from disk when it exists.
  static Future<bool> deletePdfFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting PDF: $e');
      return false;
    }
  }

  /// يولّد اسم ملف فريدًا للفواتير لتجنب التعارض بين التنزيلات المتعددة.
  /// Generates a unique file name for invoices to avoid collisions.
  static String generateInvoiceFileName(String bookingId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanId = bookingId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return 'invoice_${cleanId}_$timestamp';
  }
}
