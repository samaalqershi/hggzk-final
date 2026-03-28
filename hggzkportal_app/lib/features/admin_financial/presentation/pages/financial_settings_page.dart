import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hggzkportal/core/network/api_client.dart';
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import 'package:hggzkportal/core/theme/app_theme.dart';

class FinancialSettingsPage extends StatefulWidget {
  const FinancialSettingsPage({super.key});
  @override
  State<FinancialSettingsPage> createState() => _FinancialSettingsPageState();
}

class _FinancialSettingsPageState extends State<FinancialSettingsPage> {
  final ApiClient _apiClient = GetIt.instance<ApiClient>();
  final TextEditingController _commissionRateController =
      TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  double _loadedRate = 5.0;
  @override
  void initState() {
    super.initState();
    _loadCommissionSettings();
  }

  @override
  void dispose() {
    _commissionRateController.dispose();
    super.dispose();
  }

  Future<void> _loadCommissionSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response =
          await _apiClient.get('/api/admin/system-settings/commission');
      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        final payload = data['data'];
        final rate = payload is Map<String, dynamic>
            ? (payload['defaultRate'] as num?)?.toDouble() ?? 5.0
            : 5.0;

        setState(() {
          _loadedRate = rate;
          _commissionRateController.text = _formatRate(rate);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'تعذر تحميل إعدادات العمولة';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل الإعدادات';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCommissionSettings() async {
    final rawValue = _commissionRateController.text.trim();
    final parsedRate = double.tryParse(rawValue);

    if (parsedRate == null || parsedRate < 0 || parsedRate > 100) {
      _showSnackBar('نسبة العمولة يجب أن تكون بين 0 و 100', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await _apiClient.put(
        '/api/admin/system-settings/commission',
        data: {'defaultRate': parsedRate},
      );

      final data = response.data;
      final success =
          data is Map<String, dynamic> ? data['success'] == true : false;

      if (success) {
        setState(() {
          _loadedRate = parsedRate;
          _commissionRateController.text = _formatRate(parsedRate);
        });

        _showSnackBar('تم حفظ نسبة العمولة بنجاح');
      } else {
        _showSnackBar('فشل حفظ إعدادات العمولة', isError: true);
      }
    } catch (_) {
      _showSnackBar('حدث خطأ أثناء حفظ الإعدادات', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatRate(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkCard,
        title: Text(
          'إعدادات العمولة',
          style: AppTextStyles.heading3.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCommissionSettings,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.darkBorder.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'العمولة العامة للحجوزات',
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'هذه النسبة تُطبق تلقائيًا على كل حجز ما لم يتم تعيين عمولة مخصصة لعقار محدد.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _commissionRateController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'نسبة العمولة (%)',
                            labelStyle: AppTextStyles.bodySmall
                                .copyWith(color: AppTheme.textMuted),
                            hintText: 'مثال: 5',
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                                color:
                                    AppTheme.textMuted.withValues(alpha: 0.7)),
                            suffixText: '%',
                            filled: true,
                            fillColor:
                                AppTheme.darkSurface.withValues(alpha: 0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'القيمة الحالية المحفوظة: ${_formatRate(_loadedRate)}%',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => setState(() {
                                          _commissionRateController.text = '5';
                                        }),
                                child: const Text('إعادة الافتراضي 5%'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    _isSaving ? null : _saveCommissionSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('حفظ'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
