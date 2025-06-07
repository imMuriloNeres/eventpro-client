import 'package:intl/intl.dart';

class Validators {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName é obrigatório' : 'Campo obrigatório';
    }
    return null;
  }

  static String? validateName(String? value, {String fieldName = 'Nome'}) {
    final requiredError = validateRequired(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;
    
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value!)) {
      return '$fieldName deve conter apenas letras';
    }
    
    if (value.length < 3) {
      return '$fieldName deve ter pelo menos 3 caracteres';
    }
    
    return null;
  }

  static String? validateEmail(String? value) {
    final requiredError = validateRequired(value, fieldName: 'E-mail');
    if (requiredError != null) return requiredError;
    
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    
    if (!emailRegex.hasMatch(value!)) {
      return 'Informe um e-mail válido';
    }
    
    return null;
  }

  static String? validateCPF(String? value) {
    final requiredError = validateRequired(value, fieldName: 'CPF');
    if (requiredError != null) return requiredError;
    
    final numericValue = value!.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numericValue.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    final requiredError = validateRequired(value, fieldName: 'Telefone');
    if (requiredError != null) return requiredError;
    
    final numericValue = value!.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numericValue.length < 10 || numericValue.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    
    return null;
  }

  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Data de nascimento é obrigatória';
    }
    
    final age = DateTime.now().difference(value).inDays ~/ 365;
    
    if (age < 18) {
      return 'Você deve ter pelo menos 18 anos';
    }
    
    return null;
  }

  static String formatCPF(String input) {
    final numericValue = input.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numericValue.length <= 3) {
      return numericValue;
    } else if (numericValue.length <= 6) {
      return '${numericValue.substring(0, 3)}.${numericValue.substring(3)}';
    } else if (numericValue.length <= 9) {
      return '${numericValue.substring(0, 3)}.${numericValue.substring(3, 6)}.${numericValue.substring(6)}';
    } else {
      return '${numericValue.substring(0, 3)}.${numericValue.substring(3, 6)}.${numericValue.substring(6, 9)}-${numericValue.substring(9, 11)}';
    }
  }

  static String formatPhone(String input) {
    final numericValue = input.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numericValue.length <= 2) {
      return numericValue;
    } else if (numericValue.length <= 6) {
      return '(${numericValue.substring(0, 2)}) ${numericValue.substring(2)}';
    } else if (numericValue.length <= 10) {
      return '(${numericValue.substring(0, 2)}) ${numericValue.substring(2, 6)}-${numericValue.substring(6)}';
    } else {
      return '(${numericValue.substring(0, 2)}) ${numericValue.substring(2, 7)}-${numericValue.substring(7)}';
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String limitNumeric(String value, int maxLength) {
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    return numericValue.length > maxLength ? numericValue.substring(0, maxLength) : numericValue;
  }
}