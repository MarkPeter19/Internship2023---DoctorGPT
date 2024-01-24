import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../custom/custom_appbar.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  int? _selectedYear;
  String? _selectedGender;

  final TextEditingController _weightController = TextEditingController();
  String _storedWeight = '';

  String _selectedWeightUnit = 'kg'; // default weight unit is kg
  List<String> weightUnits = ['kg', 'lbs'];

  final TextEditingController _heightController = TextEditingController();
  String _storedHeight = '';

  String _selectedHeightUnit = 'cm'; // default height unit is cm
  List<String> heightUnits = ['cm', 'ft'];

  final TextEditingController _medicalHistoryController =
      TextEditingController();
  String _storedMedicalHistory = '';

  @override
  void initState() {
    super.initState();
    _retrieveStoredData();
  }

  // Function to retrieve previously stored data from flutter_secure_storage
  Future<void> _retrieveStoredData() async {
    _selectedYear =
        int.tryParse(await _secureStorage.read(key: 'selectedYear') ?? '');
    _selectedGender = await _secureStorage.read(key: 'selectedGender') ?? '';
    _storedWeight = await _secureStorage.read(key: 'weight') ?? '';
    _weightController.text = _storedWeight;
    _selectedWeightUnit =
        await _secureStorage.read(key: 'selectedWeightUnit') ?? 'kg';
    _storedHeight = await _secureStorage.read(key: 'height') ?? '';
    _heightController.text = _storedHeight;
    _selectedHeightUnit =
        await _secureStorage.read(key: 'selectedHeightUnit') ?? 'cm';
    _storedMedicalHistory =
        await _secureStorage.read(key: 'medicalHistory') ?? '';
    _medicalHistoryController.text = _storedMedicalHistory;

    setState(() {});
  }

  // Function to store the input data and medical history
  Future<void> _storeData() async {
    await _secureStorage.write(
        key: 'selectedYear', value: _selectedYear?.toString() ?? '');
    await _secureStorage.write(key: 'selectedGender', value: _selectedGender);
    await _secureStorage.write(key: 'weight', value: _weightController.text);
    await _secureStorage.write(
        key: 'selectedWeightUnit', value: _selectedWeightUnit);
    await _secureStorage.write(key: 'height', value: _heightController.text);
    await _secureStorage.write(
        key: 'selectedHeightUnit', value: _selectedHeightUnit);
    await _secureStorage.write(
        key: 'medicalHistory', value: _medicalHistoryController.text);
  }

  // Function to generate a list of years from a starting year (current year - 120) until the current year
  List<int> generateYearsList() {
    int currentYear = DateTime.now().year;
    int startingYear = currentYear - 120;
    return List.generate(
        currentYear - startingYear + 1, (index) => startingYear + index);
  }

  // Function to handle gender selection
  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
      _storeData();
    });
  }

  // Function to handle weight unit selection
  void _toggleWeightUnit() {
    setState(() {
      _selectedWeightUnit = _selectedWeightUnit == 'kg' ? 'lbs' : 'kg';
      _storeData();
    });
  }

  // Function to handle height unit selection
  void _toggleHeightUnit() {
    setState(() {
      _selectedHeightUnit = _selectedHeightUnit == 'cm' ? 'ft' : 'cm';
      _storeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: widget.title),
      body: Container(
        color: const Color.fromARGB(210, 16, 0, 35),
        child: ListView(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //! GENDER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gender',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => {
                                _selectGender('Male'),
                                _storeData(),
                              },
                              child: _buildGenderCell('Male'),
                            ),
                            SizedBox(width: 15), // Távolság hozzáadása
                            GestureDetector(
                              onTap: () => {
                                _selectGender('Female'),
                                _storeData(),
                              },
                              child: _buildGenderCell('Female'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // //! YEAR OF BIRTH
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Year of birth',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        border: UnderlineInputBorder(),
                      ),
                      value: _selectedYear,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      dropdownColor: Color.fromARGB(210, 16, 0, 35),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedYear = newValue;
                          _storeData();
                        });
                      },
                      items: generateYearsList()
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              color: _selectedYear == value
                                  ? Colors.white
                                  : Color.fromARGB(255, 194, 61, 189),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  //! WEIGHT
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.ideographic,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Weight',
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            onChanged: (value) {
                              _storedWeight = value;
                              _storeData();
                            },
                            // show the stored weight value
                            controller: _weightController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        //! Weight unit switcher
                        GestureDetector(
                          onTap: _toggleWeightUnit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'kg',
                                  style: TextStyle(
                                    color: _selectedWeightUnit == 'kg'
                                        ? Color.fromARGB(255, 181, 74, 193)  //255, 181, 74, 193
                                        : Colors.grey,
                                    fontWeight: _selectedWeightUnit == 'kg'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  '|',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'lbs',
                                  style: TextStyle(
                                    color: _selectedWeightUnit == 'lbs'
                                        ? Color.fromARGB(255, 181, 74, 193)
                                        : Colors.grey,
                                    fontWeight: _selectedWeightUnit == 'lbs'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //! HEIGHT
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.ideographic,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Height',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                onChanged: (value) {
                                  _storedHeight = value;
                                  _storeData();
                                },
                                // show the stored weight value
                                controller: _heightController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            //! Height unit switcher
                            GestureDetector(
                                onTap: _toggleHeightUnit,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'cm',
                                          style: TextStyle(
                                            color: _selectedHeightUnit == 'cm'
                                                ? Color.fromARGB(255, 181, 74, 193)
                                                : Colors.grey,
                                            fontWeight:
                                                _selectedHeightUnit == 'cm'
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          '|',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'ft',
                                          style: TextStyle(
                                            color: _selectedHeightUnit == 'ft'
                                                ? Color.fromARGB(255, 181, 74, 193)
                                                : Colors.grey,
                                            fontWeight:
                                                _selectedHeightUnit == 'ft'
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    )))
                          ])),
                  //! MEDICAL HISTORY
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Medical history',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            border: UnderlineInputBorder(),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          maxLines: null,
                          onChanged: (value) {
                            _storedMedicalHistory = value;
                            _storeData();
                          },
                          // show the stored medical history
                          controller: _medicalHistoryController,
                        ),
                        const SizedBox(height: 15),
                        //! Medical history info
                        const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Color.fromARGB(217, 210, 11, 11), size: 20),
                            SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: Text(
                                  'Please provide information about any existing medical conditions or health issues the patient currently has.',
                                  style: TextStyle(
                                    color: Color.fromARGB(217, 210, 11, 11),
                                    fontSize: 12,
                                  )),
                            )
                          ],
                        ),
                        //! Medical history details
                        const Text(
                          'Include details such as:\n  ‣  The symptoms or health concerns that prompted them to get the lab tests done\n  ‣  Any medical conditions or chronic illnesses, such as diabetes, hypertension, thyroid disorders, heart disease etc.\n  ‣  Any medications the patient is currently taking, including prescription drugs, over-the-counter medications, supplements, or herbal remedies\n  ‣  If anyone in their immediate family has a history of medical conditions like diabetes, heart disease, cancer, or other hereditary disorders\n  ‣  Anything else you think might be relevant to interpret the lab results accurately',
                          style: TextStyle(
                            color: Color.fromARGB(217, 210, 11, 11),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build gender cells with white outline
  Widget _buildGenderCell(String gender) {
    bool isSelected = _selectedGender == gender;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.white : Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Text(
        gender,
        style: TextStyle(
          color: isSelected ? Color.fromARGB(255, 136, 7, 134) : Colors.white,
        ),
      ),
    );
  }
}
