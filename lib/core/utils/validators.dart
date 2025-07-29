// lib/core/utils/validators.dart
import 'package:dm_assistant/core/constants/strings.dart';

/// Utility class per validatori di form riutilizzabili
class AppValidators {
  /// VALIDATORI BASE

  /// Validatore per campi obbligatori
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validatore per lunghezza minima
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.trim().length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }

  /// Validatore per lunghezza massima
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.trim().length > maxLength) {
      return '${fieldName ?? 'This field'} must be no more than $maxLength characters';
    }
    return null;
  }

  /// Validatore per range di lunghezza
  static String? lengthRange(
    String? value,
    int minLength,
    int maxLength, [
    String? fieldName,
  ]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final length = value.trim().length;
    if (length < minLength || length > maxLength) {
      return '${fieldName ?? 'This field'} must be between $minLength and $maxLength characters';
    }
    return null;
  }

  /// VALIDATORI EMAIL E CONTATTI

  /// Validatore per email
  static String? email(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Email'} is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validatore per email opzionale
  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email opzionale
    }
    return email(value);
  }

  /// Validatore per numero di telefono
  static String? phoneNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Phone number'} is required';
    }

    // Rimuove spazi, trattini e parentesi
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');

    if (!phoneRegex.hasMatch(cleanNumber)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// VALIDATORI NUMERICI

  /// Validatore per numeri interi
  static String? integer(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (int.tryParse(value.trim()) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }
    return null;
  }

  /// Validatore per numeri interi opzionali
  static String? optionalInteger(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return integer(value, fieldName);
  }

  /// Validatore per numeri decimali
  static String? decimal(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (double.tryParse(value.trim()) == null) {
      return '${fieldName ?? 'This field'} must be a valid decimal number';
    }
    return null;
  }

  /// Validatore per range numerico
  static String? numberRange(
    String? value,
    num min,
    num max, [
    String? fieldName,
  ]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final number = num.tryParse(value.trim());
    if (number == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    if (number < min || number > max) {
      return '${fieldName ?? 'This field'} must be between $min and $max';
    }
    return null;
  }

  /// Validatore per numeri positivi
  static String? positiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final number = num.tryParse(value.trim());
    if (number == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    if (number <= 0) {
      return '${fieldName ?? 'This field'} must be greater than 0';
    }
    return null;
  }

  /// VALIDATORI PASSWORD

  /// Validatore per password base
  static String? password(String? value, [int minLength = 6]) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validatore per password forte
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validatore per conferma password
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// VALIDATORI GAMING SPECIFICI

  /// Validatore per nome campagna
  static String? campaignName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }

    if (value.trim().length < 3) {
      return 'Campaign name must be at least 3 characters';
    }

    if (value.trim().length > 50) {
      return 'Campaign name must be no more than 50 characters';
    }

    // Non deve contenere caratteri speciali pericolosi
    if (RegExp(r'[<>{}\\|`]').hasMatch(value)) {
      return 'Campaign name contains invalid characters';
    }

    return null;
  }

  /// Validatore per nome personaggio
  static String? characterName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Character name is required';
    }

    if (value.trim().length < 2) {
      return 'Character name must be at least 2 characters';
    }

    if (value.trim().length > 30) {
      return 'Character name must be no more than 30 characters';
    }

    // Solo lettere, spazi, apostrofi e trattini
    if (!RegExp(r"^[a-zA-Z\s\'\-]+$").hasMatch(value.trim())) {
      return 'Character name can only contain letters, spaces, apostrophes, and hyphens';
    }

    return null;
  }

  /// Validatore per livello personaggio (1-20)
  static String? characterLevel(String? value) {
    return numberRange(value, 1, 20, 'Character level');
  }

  /// Validatore per punteggi abilità (3-18 o 8-15 per point buy)
  static String? abilityScore(String? value, {bool isPointBuy = false}) {
    final min = isPointBuy ? 8 : 3;
    final max = isPointBuy ? 15 : 18;
    return numberRange(value, min, max, 'Ability score');
  }

  /// Validatore per punti vita (1+)
  static String? hitPoints(String? value) {
    return numberRange(value, 1, 999, 'Hit points');
  }

  /// Validatore per classe armatura (1-30)
  static String? armorClass(String? value) {
    return numberRange(value, 1, 30, 'Armor class');
  }

  /// VALIDATORI COMPOSTI

  /// Combina più validatori
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  /// Validatore condizionale
  static String? Function(String?) conditional(
    bool condition,
    String? Function(String?) validator,
  ) {
    return (String? value) {
      if (condition) {
        return validator(value);
      }
      return null;
    };
  }

  /// VALIDATORI URL E FILE

  /// Validatore per URL
  static String? url(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'URL'} is required';
    }

    try {
      final uri = Uri.parse(value.trim());
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL starting with http:// or https://';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validatore per URL opzionale
  static String? optionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return url(value);
  }

  /// VALIDATORI DATA

  /// Validatore per data nel futuro
  static String? futureDate(DateTime? value, [String? fieldName]) {
    if (value == null) {
      return '${fieldName ?? 'Date'} is required';
    }

    if (value.isBefore(DateTime.now())) {
      return '${fieldName ?? 'Date'} must be in the future';
    }
    return null;
  }

  /// Validatore per data nel passato
  static String? pastDate(DateTime? value, [String? fieldName]) {
    if (value == null) {
      return '${fieldName ?? 'Date'} is required';
    }

    if (value.isAfter(DateTime.now())) {
      return '${fieldName ?? 'Date'} must be in the past';
    }
    return null;
  }

  /// Validatore per range di date
  static String? dateRange(
    DateTime? value,
    DateTime? minDate,
    DateTime? maxDate, [
    String? fieldName,
  ]) {
    if (value == null) {
      return '${fieldName ?? 'Date'} is required';
    }

    if (minDate != null && value.isBefore(minDate)) {
      return '${fieldName ?? 'Date'} must be after ${minDate.toString().split(' ')[0]}';
    }

    if (maxDate != null && value.isAfter(maxDate)) {
      return '${fieldName ?? 'Date'} must be before ${maxDate.toString().split(' ')[0]}';
    }

    return null;
  }
}

/// Extension per semplificare l'uso dei validatori nei form
extension FormFieldValidatorExtension on String {
  /// Valida come campo obbligatorio
  String? get requiredValidator => AppValidators.required(this);

  /// Valida come email
  String? get emailValidator => AppValidators.email(this);

  /// Valida come numero intero
  String? get integerValidator => AppValidators.integer(this);

  /// Valida come numero decimale
  String? get decimalValidator => AppValidators.decimal(this);

  /// Valida come nome campagna
  String? get campaignNameValidator => AppValidators.campaignName(this);

  /// Valida come nome personaggio
  String? get characterNameValidator => AppValidators.characterName(this);
}

/// Validatori pre-configurati comuni
class CommonValidators {
  /// Validatore per nome campagna (combina required + campaignName)
  static final campaignName = AppValidators.combine([
    AppValidators.required,
    AppValidators.campaignName,
  ]);

  /// Validatore per nome personaggio (combina required + characterName)
  static final characterName = AppValidators.combine([
    AppValidators.required,
    AppValidators.characterName,
  ]);

  /// Validatore per email obbligatoria
  static final requiredEmail = AppValidators.combine([
    AppValidators.required,
    AppValidators.email,
  ]);

  /// Validatore per password forte
  static final strongPassword = AppValidators.combine([
    AppValidators.required,
    AppValidators.strongPassword,
  ]);

  /// Validatore per livello personaggio
  static final characterLevel = AppValidators.combine([
    AppValidators.required,
    AppValidators.characterLevel,
  ]);

  /// Validatore per descrizione (opzionale, max 500 caratteri)
  static String? description(String? value) {
    return AppValidators.maxLength(value, 500, 'Description');
  }

  /// Validatore per note (opzionale, max 1000 caratteri)
  static String? notes(String? value) {
    return AppValidators.maxLength(value, 1000, 'Notes');
  }
}
