import 'package:flutter/material.dart';

/// يعرّف الكلاس `EmojiProvider`.
/// Describes the `EmojiProvider` class.
class EmojiProvider extends ChangeNotifier {
  /// Indicates whether `isEmojiVisible` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isEmojiVisible` مفعلة.
  bool _isEmojiVisible = false;

  /// يعيد قيمة `isEmojiVisible`.
  /// Exposes the `isEmojiVisible` value.
  bool get isEmojiVisible => _isEmojiVisible;

  /// ينفذ العملية `toggleEmojiKeyboard`.
  /// Runs the `toggleEmojiKeyboard` operation.
  void toggleEmojiKeyboard() {
    _isEmojiVisible = !_isEmojiVisible;
    notifyListeners();
  }

  /// ينفذ العملية `hideEmojiKeyboard`.
  /// Runs the `hideEmojiKeyboard` operation.
  void hideEmojiKeyboard() {
    if (_isEmojiVisible) {
      _isEmojiVisible = false;
      notifyListeners();
    }
  }

  /// ينفذ العملية `showEmojiKeyboard`.
  /// Runs the `showEmojiKeyboard` operation.
  void showEmojiKeyboard() {
    if (!_isEmojiVisible) {
      _isEmojiVisible = true;
      notifyListeners();
    }
  }
}
