import 'package:flutter/material.dart';

class PersonalDataProvider extends InheritedWidget {
  final int selectedYear;
  final String selectedGender;
  final String storedWeight;
  final String selectedWeightUnit;
  final String storedHeight;
  final String selectedHeightUnit;
  final String storedMedicalHistory;

  const PersonalDataProvider({super.key, 
    required this.selectedYear,
    required this.selectedGender,
    required this.storedWeight,
    required this.selectedWeightUnit,
    required this.storedHeight,
    required this.selectedHeightUnit,
    required this.storedMedicalHistory,
    required Widget child,
  }) : super(child: child);

  static PersonalDataProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PersonalDataProvider>();
  }

  @override
  bool updateShouldNotify(PersonalDataProvider oldWidget) {
    return true;
  }
}
