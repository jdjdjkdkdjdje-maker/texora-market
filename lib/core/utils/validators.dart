class AppValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ism kiriting';
    }
    if (value.trim().length < 2) {
      return 'Ism juda qisqa';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon raqam kiriting';
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 9) {
      return 'Telefon raqam noto\'g\'ri';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Manzil kiriting';
    }
    if (value.trim().length < 5) {
      return 'Manzil juda qisqa';
    }
    return null;
  }
}
