import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../values/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farmer Details Form',
      theme: ThemeData(
        primarySwatch: Colors.green,
        secondaryHeaderColor: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.nunito().fontFamily,
        inputDecorationTheme: InputDecorationTheme(
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusColor: Colors.green[200],
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green)
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),

      ),
      home: FarmerRegister(),
    );
  }
}

class FarmerRegister extends StatefulWidget {
  const FarmerRegister({Key? key}) : super(key: key);
  @override
  _FarmerRegisterState createState() => _FarmerRegisterState();
}

class _FarmerRegisterState extends State<FarmerRegister> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  int _totalLandPatches = 0;

  bool _isLoading = false;

  // Controllers and variables
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? _selectedState;
  String? _selectedDistrict;
  String _aadhaarNumber = '';
  String _panNumber = '';
  String? _selectedBank;
  String _accountNumber = '';

  String _ifscCode = '';
  String _branchName = '';
  List<Map<String, dynamic>> _landDetails = [];
  List<String> _equipmentList = [
    "Tractor",
    "Plough",
    "Harrow",
    "Rotavator",
    "Cultivator",
    "Seed Drill",
    "Planter",
    "Broadcast Spreader",
    "Irrigation Pump",
    "Sprinkler System",
    "Drip Irrigation System",
    "Combine Harvester",
    "Sickle",
    "Reaper",
    "Threshing Machine",
    "Sprayer",
    "Fogger Machine",
    "Weed Remover",
    "Grain Silos",
    "Chaff Cutter",
    "Dryers",
    "Milking Machine",
    "Feeding Equipment",
    "Fencing Tools",
    "Loader/Backhoe",
    "Rice Transplanter",
    "Sugarcane Harvester",
    "Potato Digger",
    "Cotton Picker",
    "Drone"
  ];
  List<String> _selectedEquipment = [];

  final List<String> _allStates = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
    "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka",
    "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram",
    "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu",
    "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal"
  ];

  final Map<String, List<String>> _districts = {
    "Andhra Pradesh": ["Anantapur", "Chittoor", "East Godavari", "Guntur", "Krishna", "Kurnool", "Nellore", "Prakasam", "Srikakulam", "Visakhapatnam", "Vizianagaram", "West Godavari"],
    "Arunachal Pradesh": ["Tawang", "West Kameng", "East Kameng", "Papum Pare", "Kurung Kumey", "Kra Daadi", "Lower Subansiri", "Upper Subansiri", "West Siang", "East Siang", "Siang", "Upper Siang", "Lower Siang", "Longding", "Namsai", "Changlang", "Tirap", "Anjaw"],
    "Assam": ["Baksa", "Barpeta", "Bongaigaon", "Cachar", "Charaideo", "Chirang", "Darrang", "Dhemaji", "Dhubri", "Dibrugarh", "Dima Hasao", "Goalpara", "Golaghat", "Hailakandi", "Hojai", "Jorhat", "Kamrup", "Kamrup Metropolitan", "Karbi Anglong", "Karimganj", "Kokrajhar", "Lakhimpur", "Majuli", "Morigaon", "Nagaon", "Nalbari", "Sivasagar", "Sonitpur", "South Salmara-Mankachar", "Tinsukia", "Udalguri"],
    "Bihar": ["Araria", "Arwal", "Aurangabad", "Banka", "Begusarai", "Bhagalpur", "Bhojpur", "Buxar", "Darbhanga", "East Champaran", "Gaya", "Gopalganj", "Jamui", "Jehanabad", "Kaimur", "Katihar", "Khagaria", "Kishanganj", "Lakhisarai", "Madhepura", "Madhubani", "Munger", "Muzaffarpur", "Nalanda", "Nawada", "Patna", "Purnia", "Rohtas", "Saharsa", "Samastipur", "Saran", "Sheikhpura", "Sheohar", "Sitamarhi", "Siwan", "Supaul", "Vaishali", "West Champaran"],
    "Chhattisgarh": ["Balod", "Baloda Bazar", "Balrampur", "Bastar", "Bemetara", "Bijapur", "Bilaspur", "Dhamtari", "Durg", "Gariaband", "Gaurela-Pendra-Marwahi", "Janjgir-Champa", "Jashpur", "Kabirdham", "Kanker", "Kondagaon", "Korba", "Koriya", "Mahasamund", "Mungeli", "Narayanpur", "Raigarh", "Raipur", "Rajnandgaon", "Sukma", "Surajpur", "Surguja"],
    "Goa": ["North Goa", "South Goa"],
    "Gujarat": ["Ahmedabad", "Amreli", "Anand", "Aravalli", "Banaskantha", "Bharuch", "Bhavnagar", "Botad", "Chhota Udaipur", "Dahod", "Devbhumi Dwarka", "Gandhinagar", "Gir Somnath", "Jamnagar", "Junagadh", "Kheda", "Kutch", "Mahisagar", "Mehsana", "Morbi", "Narmada", "Navsari", "Panchmahal", "Patan", "Porbandar", "Rajkot", "Sabarkantha", "Surat", "Surendranagar", "Tapi", "Vadodara", "Valsad"],
    "Haryana": ["Ambala", "Bhiwani", "Charkhi Dadri", "Faridabad", "Fatehabad", "Gurugram", "Hisar", "Jhajjar", "Jind", "Kaithal", "Karnal", "Kurukshetra", "Mahendragarh", "Mewat", "Palwal", "Panchkula", "Panipat", "Rewari", "Rohtak", "Sirsa", "Sonipat", "Yamunanagar"],
    "Himachal Pradesh": ["Bilaspur", "Chamba", "Hamirpur", "Kangra", "Kinnaur", "Kullu", "Lahaul and Spiti", "Mandi", "Shimla", "Sirmaur", "Solan", "Una"],
    "Jharkhand": ["Bokaro", "Chatra", "Deoghar", "Dhanbad", "Dumka", "East Singhbhum", "Garhwa", "Giridih", "Godda", "Gumla", "Hazaribagh", "Jamtara", "Khunti", "Koderma", "Latehar", "Lohardaga", "Pakur", "Palamu", "Ramgarh", "Ranchi", "Sahebganj", "Seraikela Kharsawan", "Simdega", "West Singhbhum"],
    "Karnataka": ["Bagalkot", "Bangalore Rural", "Bangalore Urban", "Belagavi", "Bellary", "Bidar", "Chamarajanagar", "Chikballapur", "Chikkamagaluru", "Chitradurga", "Dakshina Kannada", "Davanagere", "Dharwad", "Gadag", "Hassan", "Haveri", "Kalaburagi", "Kodagu", "Kolar", "Koppal", "Mandya", "Mysore", "Raichur", "Ramanagara", "Shivamogga", "Tumakuru", "Udupi", "Uttara Kannada", "Vijayapura", "Yadgir"],
    "Kerala": ["Alappuzha", "Ernakulam", "Idukki", "Kannur", "Kasaragod", "Kollam", "Kottayam", "Kozhikode", "Malappuram", "Palakkad", "Pathanamthitta", "Thiruvananthapuram", "Thrissur", "Wayanad"],
    "Madhya Pradesh": ["Agar Malwa", "Alirajpur", "Anuppur", "Ashoknagar", "Balaghat", "Barwani", "Betul", "Bhind", "Bhopal", "Burhanpur", "Chhatarpur", "Chhindwara", "Damoh", "Datia", "Dewas", "Dhar", "Dindori", "Guna", "Gwalior", "Harda", "Hoshangabad", "Indore", "Jabalpur", "Jhabua", "Katni", "Khandwa", "Khargone", "Mandla", "Mandsaur", "Morena", "Narsinghpur", "Neemuch", "Panna", "Raisen", "Rajgarh", "Ratlam", "Rewa", "Sagar", "Satna", "Sehore", "Seoni", "Shahdol", "Shajapur", "Sheopur", "Shivpuri", "Sidhi", "Singrauli", "Tikamgarh", "Ujjain", "Umaria", "Vidisha"],
    "Maharashtra": ["Ahmednagar", "Akola", "Amravati", "Aurangabad", "Beed", "Bhandara", "Buldhana", "Chandrapur", "Dhule", "Gadchiroli", "Gondia", "Hingoli", "Jalgaon", "Jalna", "Kolhapur", "Latur", "Mumbai City", "Mumbai Suburban", "Nagpur", "Nanded", "Nandurbar", "Nashik", "Osmanabad", "Palghar", "Parbhani", "Pune", "Raigad", "Ratnagiri", "Sangli", "Satara", "Sindhudurg", "Solapur", "Thane", "Wardha", "Washim", "Yavatmal"],
    "Manipur": ["Bishnupur", "Chandel", "Churachandpur", "Imphal East", "Imphal West", "Jiribam", "Kakching", "Kamjong", "Kangpokpi", "Noney", "Pherzawl", "Senapati", "Tamenglong", "Tengnoupal", "Thoubal", "Ukhrul"],
    "Meghalaya": ["East Garo Hills", "East Jaintia Hills", "East Khasi Hills", "North Garo Hills", "Ri Bhoi", "South Garo Hills", "South West Garo Hills", "South West Khasi Hills", "West Garo Hills", "West Jaintia Hills", "West Khasi Hills"],
    "Mizoram": ["Aizawl", "Champhai", "Hnahthial", "Kolasib", "Lawngtlai", "Lunglei", "Mamit", "Saitual", "Serchhip", "Siaha"],
    "Nagaland": ["Dimapur", "Kiphire", "Kohima", "Longleng", "Mokokchung", "Mon", "Peren", "Phek", "Tuensang", "Wokha", "Zunheboto"],
    "Odisha": ["Angul", "Balangir", "Baleswar", "Bargarh", "Bhadrak", "Boudh", "Cuttack", "Deogarh", "Dhenkanal", "Gajapati", "Ganjam", "Jagatsinghpur", "Jajpur", "Jharsuguda", "Kalahandi", "Kandhamal", "Kendrapara", "Kendujhar", "Khordha", "Koraput", "Malkangiri", "Mayurbhanj", "Nabarangpur", "Nayagarh", "Nuapada", "Puri", "Rayagada", "Sambalpur", "Sonepur", "Sundargarh"],
    "Punjab": ["Amritsar", "Barnala", "Bathinda", "Faridkot", "Fatehgarh Sahib", "Fazilka", "Ferozepur", "Gurdaspur", "Hoshiarpur", "Jalandhar", "Kapurthala", "Ludhiana", "Mansa", "Moga", "Muktsar", "Nawanshahr", "Pathankot", "Patiala", "Rupnagar", "Sahibzada Ajit Singh Nagar", "Sangrur", "Tarn Taran"],
    "Rajasthan": ["Ajmer", "Alwar", "Banswara", "Baran", "Barmer", "Bharatpur", "Bhilwara", "Bikaner", "Bundi", "Chittorgarh", "Churu", "Dausa", "Dholpur", "Dungarpur", "Hanumangarh", "Jaipur", "Jaisalmer", "Jalore", "Jhalawar", "Jhunjhunu", "Jodhpur", "Karauli", "Kota", "Nagaur", "Pali", "Pratapgarh", "Rajsamand", "Sawai Madhopur", "Sikar", "Sirohi", "Sri Ganganagar", "Tonk", "Udaipur"],
    "Sikkim": ["East Sikkim", "North Sikkim", "South Sikkim", "West Sikkim"],
    "Tamil Nadu": ["Ariyalur", "Chengalpattu", "Chennai", "Coimbatore", "Cuddalore", "Dharmapuri", "Dindigul", "Erode", "Kallakurichi", "Kanchipuram", "Kanyakumari", "Karur", "Krishnagiri", "Madurai", "Mayiladuthurai", "Nagapattinam", "Namakkal", "Nilgiris", "Perambalur", "Pudukkottai", "Ramanathapuram", "Ranipet", "Salem", "Sivaganga", "Tenkasi", "Thanjavur", "Theni", "Thoothukudi", "Tiruchirappalli", "Tirunelveli", "Tirupathur", "Tiruppur", "Tiruvallur", "Tiruvannamalai", "Tiruvarur", "Vellore", "Viluppuram", "Virudhunagar"],
    "Telangana": ["Adilabad", "Bhadradri Kothagudem", "Hyderabad", "Jagtial", "Jangaon", "Jayashankar Bhupalapally", "Jogulamba Gadwal", "Kamareddy", "Karimnagar", "Khammam", "Kumuram Bheem Asifabad", "Mahabubabad", "Mahbubnagar", "Mancherial", "Medak", "Medchal-Malkajgiri", "Mulugu", "Nalgonda", "Narayanpet", "Nirmal", "Nizamabad", "Peddapalli", "Rajanna Sircilla", "Ranga Reddy", "Sangareddy", "Siddipet", "Suryapet", "Vikarabad", "Wanaparthy", "Warangal Rural", "Warangal Urban", "Yadadri Bhuvanagiri"],
    "Tripura": ["Dhalai", "Gomati", "Khowai", "North Tripura", "Sepahijala", "South Tripura", "Unakoti", "West Tripura"],
    "Uttar Pradesh": ["Agra", "Aligarh", "Ambedkar Nagar", "Amethi", "Amroha", "Auraiya", "Ayodhya", "Azamgarh", "Badaun", "Baghpat", "Bahraich", "Ballia", "Balrampur", "Banda", "Barabanki", "Bareilly", "Basti", "Bhadohi", "Bijnor", "Budaun", "Bulandshahr", "Chandauli", "Chitrakoot", "Deoria", "Etah", "Etawah", "Farrukhabad", "Fatehpur", "Firozabad", "Gautam Buddh Nagar", "Ghaziabad", "Ghazipur", "Gonda", "Gorakhpur", "Hapur", "Hardoi", "Hathras", "Jalaun", "Jaunpur", "Jhansi", "Kannauj", "Kanpur Dehat", "Kanpur Nagar", "Kasganj", "Kaushambi", "Kheri", "Kushinagar", "Lalitpur", "Lucknow", "Maharajganj", "Mahoba", "Mainpuri", "Mathura", "Mau", "Meerut", "Mirzapur", "Moradabad", "Muzaffarnagar", "Pilibhit", "Pratapgarh", "Prayagraj", "Raebareli", "Rampur", "Saharanpur", "Sambhal", "Sant Kabir Nagar", "Shahjahanpur", "Shamli", "Shravasti", "Siddharthnagar", "Sitapur", "Sonbhadra", "Sultanpur", "Unnao", "Varanasi"],
    "Uttarakhand": ["Almora", "Bageshwar", "Chamoli", "Champawat", "Dehradun", "Haridwar", "Nainital", "Pauri Garhwal", "Pithoragarh", "Rudraprayag", "Tehri Garhwal", "Udham Singh Nagar", "Uttarkashi"],
    "West Bengal": ["Alipurduar", "Bankura", "Birbhum", "Cooch Behar", "Dakshin Dinajpur", "Darjeeling", "Hooghly", "Howrah", "Jalpaiguri", "Jhargram", "Kalimpong", "Kolkata", "Malda", "Murshidabad", "Nadia", "North 24 Parganas", "Paschim Bardhaman", "Paschim Medinipur", "Purba Bardhaman", "Purba Medinipur", "Purulia", "South 24 Parganas", "Uttar Dinajpur"]
  };

  final List<Map<String, String>> _banks = [
    {"name": "State Bank of India", "icon": "assets/sbi_icon.png"},
    {"name": "HDFC Bank", "icon": "assets/HDFC_icon.png"},
    {"name": "ICICI Bank", "icon": "assets/icici_icon.png"},
    {"name": "Punjab National Bank", "icon": "assets/pnb_icon.png"},
    {"name": "Bank of Baroda", "icon": "assets/bob_icon.png"},
    {"name": "Kotak 811 Bank", "icon": "assets/kotak_icon.png"},
    // Add more banks with their icons here
  ];
  Map<String, dynamic> _formData = {};

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      _saveCurrentPageData();
      if (_currentPage < 3) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
      else if(_currentPage ==3){
        final args = ModalRoute.of(context)?.settings.arguments; // Get userType here
        final userType = args is String ? args : null;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FormReviewScreen(formData: _formData, userType: userType)),
        );
      }

    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _saveCurrentPageData() {
    switch(_currentPage){
      case 0:
        _formData.addAll({
          'firstName' : _firstNameController.text,
          'lastName' : _lastNameController.text,
          'dob': _dobController.text,
          'address':_addressController.text,
          'state':_selectedState,
          'district':_selectedDistrict,
          'phone': _phoneNumberController.text
        });
        break;
      case 1:
        _formData.addAll({
          'aadhaarNumber': _aadhaarNumber,
          'panNumber': _panNumber,
          'selectedBank': _selectedBank,
          'accountNumber': _accountNumber,
          'ifscCode': _ifscCode,
          'branchName': _branchName,
        });
        break;
      case 2:
        _formData.addAll({
          'landDetails':_landDetails
        });
        break;
      case 3:
        _formData.addAll({
          'selectedEquipment' : _selectedEquipment,
          'isRegistered' : true
        });
        break;

    }
  }

  void _initializeLandPatches(int i) {
    _landDetails = List.generate(_totalLandPatches, (index) => {
      "landSize": 0.0,
      "soilType": null,
      "crops": [],
      "irrigationSource": null,
      "location": null,
      "document": null,
      "coordinates": null,

    });
  }


  void _updateLandPatchDetails(int patches) {
    _landDetails = List.generate(patches, (index) => {
      "landSize": _landDetails.length > index ? _landDetails[index]['landSize'] : 0.0,
      "soilType": _landDetails.length > index ?  _landDetails[index]['soilType']: null,
      "crops": _landDetails.length > index ? _landDetails[index]['crops'] : [],
      "irrigationSource":  _landDetails.length > index ? _landDetails[index]['irrigationSource'] : null,
      "location": _landDetails.length > index ? _landDetails[index]['location'] : null,
      "document":  _landDetails.length > index ? _landDetails[index]['document'] : null,
      "coordinates":  _landDetails.length > index ? _landDetails[index]['coordinates'] : null,
    });
    setState(() {});
  }


  Future<void> _pickDocument(Map<String, dynamic> patch) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png']
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        patch['document'] = File(result.files.single.path!);
      });
    }
  }
  Future<void> _pickLocation(Map<String, dynamic> patch) async {
    LatLng? selectedCoordinates = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
    if (selectedCoordinates != null) {
      setState(() {
        patch['coordinates'] = selectedCoordinates;
      });
    }
  }

  void _removeLandPatch(int index) {
    setState(() {
      _landDetails.removeAt(index);
    });
  }


  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farmer Details Form'),
        backgroundColor: Colors.green[700],
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.nunito().fontFamily,
            fontSize: 20
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildFarmerDetailsPage(),
            _buildBankAndIDDetailsPage(),
            _buildLandDetailsPage(),
            _buildEquipmentDetailsPage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildFarmerDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Personal Information'),
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: 'First Name',
              hintText: 'Enter your first name',
              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
              prefixIcon: Icon(Icons.person, color: Colors.green),
            ),
            style: TextStyle(fontWeight: FontWeight.bold), // Make input bold
            validator: (value) => value!.isEmpty ? "Required" : null,
          ),

          SizedBox(
            height: 15,
          ),

          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: 'Last Name',
              hintText: 'Enter your last name',
              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green)),
              prefixIcon: Icon(Icons.person_outline, color: Colors.green),
            ),
            style: TextStyle(fontWeight: FontWeight.bold), // Make input bold
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Last Name is required';
              }

              final nameRegex = RegExp(r'^[a-zA-Z]+$');

              if (!nameRegex.hasMatch(value)) {
                return 'Only alphabetic characters are allowed';
              }

              if (value.length > 10) {
                return 'Last Name should not exceed 20 characters';
              }

              return null;
            },
          ),
          SizedBox(
            height: 15,
          ),
          TextFormField(
            controller: _dobController,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              hintText: 'Select your date of birth',
              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
              suffixIcon: Icon(Icons.calendar_today, color: Colors.green),
              prefixIcon: Icon(Icons.date_range, color: Colors.green),
            ),
            style: TextStyle(fontWeight: FontWeight.bold), // Make input bold
            onTap: () async {
              DateTime lastDate = DateTime.now().subtract(Duration(days: 365*18));
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: lastDate, // Set initialDate to lastDate
                  firstDate: DateTime(1900),
                  lastDate: lastDate,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.fromSwatch(
                          primarySwatch: Colors.green,
                        ).copyWith(secondary: Colors.green[700]),
                      ),
                      child: child!,
                    );
                  }

              );
              if (pickedDate != null) {
                setState(() {
                  _dobController.text =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                });
              }
            },
            readOnly: true,
            validator: (value) => value!.isEmpty ? "Required" : null,
          ),




          SizedBox(
            height: 15,
          ),


          TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile No.',
                hintText: 'Enter your Mobile No',
                labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
                prefixIcon: Icon(Icons.call, color: Colors.green),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(10)
              ],
              style: TextStyle(fontWeight: FontWeight.bold), // Make input bold
              validator: (value){
                if(value == null || value.isEmpty){
                  return "Mobile number cannot be empty";
                }
                final mobileNumberRegex = RegExp(r'^[0-9]{10}$');
                if(!mobileNumberRegex.hasMatch(value))
                  return "Enter 10 digit mobile number";


                return null;
              }
          ),

          SizedBox(
            height: 15,
          ),

          TextFormField(
            controller: _addressController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Address',
              hintText: 'Enter your full address',
              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green)),
              prefixIcon: Icon(Icons.home, color: Colors.green),
            ),
            style: TextStyle(fontWeight: FontWeight.bold), // Make input bold
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Address is required';
              }

              final addressRegex = RegExp(r'^[a-zA-Z0-9\s\/\-\.\,]+$'); // Added `\`

              if (!addressRegex.hasMatch(value)){
                return 'Please enter a valid address';
              }
              // Add further validation for length here
              return null;
            },
          ),

          SizedBox(
            height: 15,
          ),
          DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'State',
              labelStyle: TextStyle(fontWeight: FontWeight.bold,  color: Colors.green
              ),
              hintText: 'Select your state',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
              prefixIcon: Icon(Icons.location_on, color: Colors.green),
            ),
            value: _selectedState,
            items: _allStates
                .map((state) => DropdownMenuItem(
              value: state,
              child: Text(state),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedState = value as String?;
                _selectedDistrict = null;
              });
            },
            validator: (value) => value == null ? "Required" : null,
          ),

          SizedBox(
            height: 15,
          ),
          if (_selectedState != null)
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'District',
                hintText: 'Select your district',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.bold
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),

                prefixIcon: Icon(Icons.location_city, color: Colors.green),
              ),
              value: _selectedDistrict,
              items: _districts[_selectedState]!
                  .map((city) => DropdownMenuItem(
                value: city,
                child: Text(city),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = value as String?;
                });
              },
              validator: (value) => value == null ? "Required" : null,
            ),
        ],
      ),
    );
  }

  Widget _buildBankAndIDDetailsPage() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    _buildSectionTitle('Bank & ID Details'),
    TextFormField(
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
    labelText: 'Aadhaar Number',
    hintText: 'Enter your 12 digit Aadhaar number',
    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
    prefixIcon: Icon(Icons.credit_card, color: Colors.green),
    ),
    style: TextStyle(fontWeight: FontWeight.bold),
    onChanged: (value) {
    _aadhaarNumber = value;
    },
    inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(12),
    _AadhaarNumberFormatter()            ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Aadhaar number is required';
        }
        final aadhaarRegex = RegExp(r'^[0-9]{4}\s[0-9]{4}\s[0-9]{4}$');
        if(!aadhaarRegex.hasMatch(value))
          return "Enter valid 12 digit Aadhaar number";
        return null;
      },
    ),

      SizedBox(
        height: 15,
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'PAN Number',
          hintText: 'Enter your 10 digit PAN',
          labelStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
          prefixIcon: Icon(Icons.credit_card_outlined, color: Colors.green),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(10)
        ],
        style: TextStyle(fontWeight: FontWeight.bold),
        onChanged: (value) => _panNumber = value,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'PAN number is required';
          }
          final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
          if(!panRegex.hasMatch(value))
            return "Enter a valid 10 digit PAN";
          return null;
        },
      ),
      SizedBox(
        height: 15,
      ),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Bank Name',
          hintText: 'Select your bank',
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
          prefixIcon: Icon(Icons.account_balance, color: Colors.green),
        ),
        value: _selectedBank,
        items: _banks.map((bank) {
          return DropdownMenuItem<String>(
            value: bank['name'],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bank['icon'] != null)
                  Image.asset(
                    bank['icon']!,
                    width: 24,
                    height: 24,
                  ),
                SizedBox(width: 8),
                Text(bank['name']!),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedBank = value;
          });
        },
        validator: (value) => value == null ? "Required" : null,
      ),
      SizedBox(
        height: 15,
      ),
      TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Account Number',
          hintText: 'Enter your bank account number',
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
          prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.green),
        ),
        style: TextStyle(fontWeight: FontWeight.bold),
        onChanged: (value) {
          // Implement formatting here
          _accountNumber = value;
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(17),
          _AccountNumberFormatter()
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Account number is required';
          }
          final accountNumberRegex =  RegExp(r'^(?:\d{4}\s?){0,5}\d{0,3}$');
          if(!accountNumberRegex.hasMatch(value))
            return "Enter valid account number with spaces after 4 digits";

          return null;
        },
      ),
      SizedBox(
        height: 15,
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'IFSC Code',
          hintText: 'Enter your bank IFSC code',
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
          prefixIcon: Icon(Icons.code, color: Colors.green),
        ),
        style: TextStyle(fontWeight: FontWeight.bold),
        onChanged: (value) => _ifscCode = value,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'IFSC Code is required';
          }

          final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
          if(!ifscRegex.hasMatch(value))
            return "Enter a valid IFSC code";
          return null;
        },
      ),

      SizedBox(
        height: 15,
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Branch Name',
          hintText: 'Enter your bank branch name',
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green)
          ),
          prefixIcon: Icon(Icons.account_tree, color: Colors.green),
        ),
        style: TextStyle(fontWeight: FontWeight.bold),
        onChanged: (value) => _branchName = value,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Branch Name is required';
          }

          final branchRegex = RegExp(r'^[a-zA-Z\s]+$');
          if(!branchRegex.hasMatch(value))
            return "Enter valid branch name";

          return null;
        },
      ),
    ],
    ),
    );
  }
  Widget _buildLandDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Land Details'),

          SizedBox(height: 10),
          ..._landDetails.asMap().entries.map((entry) {
            int index = entry.key;
            var patch = entry.value;
            return  ExpansionTile(
              title: Text("Land Patch ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              subtitle: Text(
                  patch['landSize']!=null
                      ? "Land Size : ${patch['landSize']} Acres"
                      : "No details added"
              ),

              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildLandDetailInputs(index, patch),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _pickLocation(patch),
                              child: Text("Pick Location"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.green[700],
                                fixedSize: const Size(120, 10)
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _pickDocument(patch),
                              child: Text('Upload Document'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.green[700],
                              ),
                            ),
                          ]
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      if(patch['coordinates']!=null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Location Selected Lat: ${patch['coordinates'].latitude} Lng: ${patch['coordinates'].longitude}"),
                        ),
                      if (patch['coordinates'] == null)
                        Text("No location selected"),

                      if (patch['document'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Uploaded File: ${patch['document'].path.split('/').last}"),
                        ),
                      if (patch['document'] == null)
                        Text("No document uploaded"),


                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child:  ElevatedButton(
                    onPressed: () {
                      _removeLandPatch(index);
                    },
                    child: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red[700],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                )

              ],
            );
          }),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomRight,
            child:   ElevatedButton(
              onPressed: () {
                _updateLandPatchDetails(_landDetails.length+1);
              },
              child: Text('Add More'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green[700],
              ),
            ),
          ),
          if(_landDetails.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child:  Text(
                "${_landDetails.length} Patch Details Added",
                textAlign: TextAlign.end,
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildLandDetailInputs(int index, Map<String, dynamic> patch) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Land Size (acres)',
            hintText: 'Enter the land size for patch ${index+1} in acres',
            prefixIcon: Icon(Icons.zoom_out_map, color: Colors.green),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),

          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            patch["landSize"] = double.tryParse(value) ?? 0.0;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter land size';
            }
            double? patches = double.tryParse(value);
            if(patches == null || patches < 0){
              return "Enter a valid land size";
            }
            return null;
          },
        ),
        SizedBox(
          height: 25,
        ),
        DropdownButtonFormField(
          decoration: InputDecoration(
            labelText: 'Soil Type',
            hintText: 'Select soil type for patch ${index+1}',
            prefixIcon: Icon(Icons.filter_vintage, color: Colors.green),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
          ),
          items: ["Sandy", "Clay", "Loam", "Silt"].map((soil) {
            return DropdownMenuItem(
              value: soil,
              child: Text(soil),
            );
          }).toList(),
          onChanged: (value) {
            patch["soilType"] = value;
          },
          validator: (value) => value == null ? "Required" : null,
        ),
        SizedBox(
          height: 25,
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Preferred Crops',
            hintText: 'Enter the crops you plant on patch ${index+1}, separeated by comma',
            prefixIcon: Icon(Icons.eco, color: Colors.green),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
          ),
          onChanged: (value) {
            patch["crops"] = value.split(', ');
          },
          validator: (value){
            if (value == null || value.isEmpty) {
              return 'Please enter the crops';
            }

            final cropRegex = RegExp(r'^[a-zA-Z\s,]+$');
            if(!cropRegex.hasMatch(value))
              return "Enter valid crops (alphabets and comma)";
            return null;
          },
        ),
        SizedBox(
          height: 25,
        ),
        DropdownButtonFormField(
          decoration: InputDecoration(
            labelText: 'Irrigation Source',
            hintText: 'Select irrigation source',
            prefixIcon: Icon(Icons.water_drop, color: Colors.green),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green)),
          ),
          items: ["Borewell", "Well", "Motor", "Drip Irrigation"].map((irrigation) {
            return DropdownMenuItem(
              value: irrigation,
              child: Text(irrigation),
            );
          }).toList(),
          onChanged: (value) {
            patch["irrigationSource"] = value;
          },
          validator: (value) => value == null ? "Required" : null,
        ),
        SizedBox(
          height: 25,
        ),
      ],
    );
  }


  Widget _buildEquipmentDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Equipment Details'),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _equipmentList.map((equipment) {
              return FilterChip(
                label: Text(equipment),
                selected: _selectedEquipment.contains(equipment),
                onSelected: (isSelected) {
                  setState(() {
                    if (isSelected) {
                      _selectedEquipment.add(equipment);
                    } else {
                      _selectedEquipment.remove(equipment);
                    }
                  });
                },
                backgroundColor: Colors.green[100],
                selectedColor: Colors.green[400],
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            ElevatedButton(
                onPressed: _previousPage,
                child: Text("Previous"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.grey,
                )),
          if (_currentPage < 3)
            ElevatedButton(
                onPressed: _nextPage,
                child: Text("Continue"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green[700],
                )),
          if (_currentPage == 3)
            ElevatedButton(
                onPressed: _nextPage,
                child: Text("Review & Submit"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green[700],
                )),
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  Set<Marker> markers = {};


  void _onMapTap(LatLng latLng) {
    setState(() {
      selectedLocation = latLng;
      markers.clear();
      markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: latLng,
      ));
    });

  }
  void _onMapCreated(GoogleMapController controller){
    mapController = controller;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        backgroundColor: Colors.green[700],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onTap: _onMapTap,
        initialCameraPosition: CameraPosition(
          target: LatLng(20.5937, 78.9629),
          zoom: 4.0,
        ),
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if (selectedLocation != null) {
            Navigator.pop(context, selectedLocation);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a location')));
          }
        },
        child: Icon(Icons.check),
        backgroundColor: Colors.green[700],
      ),
    );
  }
}


class _AccountNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text;
    String newText = "";
    if (text.length > 0) {
      text = text.replaceAll(" ", "");// Remove previous space for formatting
      for(int i = 0; i<text.length; i++){
        newText += text[i];
        if((i+1) % 4 == 0 && (i+1) != text.length){
          newText += " ";
        }
      }
      return newValue.copyWith(text: newText,
          selection: TextSelection.collapsed(offset: newText.length));
    }
    return newValue;
  }
}

class _AadhaarNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text;
    String newText = "";
    if (text.length > 0) {
      text = text.replaceAll(" ", ""); // Remove previous space for formatting, also ensure the limit
      for(int i = 0; i<text.length; i++){
        newText += text[i];
        if((i+1) % 4 == 0 && (i+1) != text.length){
          newText += " ";
        }
      }
      return newValue.copyWith(text: newText,
          selection: TextSelection.collapsed(offset: newText.length));
    }
    return newValue;
  }
}










class FormReviewScreen extends StatelessWidget {
  final Map<String, dynamic> formData;
  final String? userType;
  FormReviewScreen({super.key, required this.formData, this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Form Review"),
          backgroundColor: Colors.green[700],
          titleTextStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Personal Information", Icons.person),
              _buildPersonalInfoContainer(),
              _buildSectionTitle("Bank & ID Details", Icons.account_balance),
              _buildAccountInfoContainer(),
              SizedBox(height: 20,),

              _buildSectionTitle("Land Details", Icons.landscape),
              _buildDataTile("Total Land Patches", (formData['landDetails'] as List?)?.length.toString() ?? "0", Icons.zoom_out_map),
              if (formData['landDetails'] != null)
                for(int i = 0; i < (formData['landDetails'] as List).length; i++)
                  _buildLandPatchDetailContainer(formData['landDetails'][i], i+1),
              _buildSectionTitle("Equipment Details", Icons.build),
              _buildEquipmentDetailsContainer(),

              SizedBox(height: 20,),
              ElevatedButton(
                  onPressed: () async {  // Make onPressed async
                    try {
                      final user = FirebaseAuth.instance.currentUser; // Get current user

                      if(user == null){print("User is not found");}
                      if(userType == null){print("UserType is not found");}

                      formData['totalLandPatches']= (formData['landDetails'] as List?)?.length ?? 0;

                      if (user != null && userType != null) {
                        await FirebaseFirestore.instance.collection(userType!)
                            .doc(user.uid) // Use user.uid as the document ID
                            .update(formData); // Set the formData

                        // Success! Navigate to profile screen & Remove All Previous Screens
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.farmer_profile,
                          (Route<dynamic> route) => false,
                          arguments: userType,
                        );

                      } else {
                        // Handle the case where user or userType is null
                        print("User not logged in or userType is missing.");
                        // Show an error message, etc.
                      }
                    } catch (e) {
                      // Handle Firestore errors
                      print("Error saving data to Firestore: $e");
                      // Show an error message, etc.
                    }
                  },
                  child: Text("Confirm & Proceed to Profile"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green[700],
                  )

              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 20),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
        ),
      ),
    );
  }
  Widget _buildDataTile(String label, String value, IconData icon, [String? imagePath]) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            if(imagePath != null)
              Image.asset(
                imagePath,
                width: 24,
                height: 24,
              ),
            if(imagePath == null)
              Icon(icon, color: Colors.grey[600]),
            SizedBox(width: 10,),
            Expanded(
              child:  RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(
                      text: "$label: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: value != null ? value.toString() : "Not Available",),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLandPatchDetailContainer(Map<String,dynamic> patch, int index){
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[400]!, width: 1)
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Land Patch $index",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Land Size",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child:  Text(patch['landSize'].toString(),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                ],
              ),
              SizedBox(height: 8),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Soil Type",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child:  Text(patch['soilType'].toString(),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]
              ),
              SizedBox(height: 8),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Crops",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(patch['crops'].join(', '),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Irrigation Source",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child:  Text(patch['irrigationSource'].toString(),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Location",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(patch['coordinates'] != null ? "Lat: ${patch['coordinates'].latitude} Lng: ${patch['coordinates'].longitude}" : "Not Selected",
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (patch['document'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                      children: [
                        Icon(Icons.file_present, color: Colors.grey[600],),
                        SizedBox(width: 10,),
                        Expanded(
                          child:  Text(
                            'Uploaded Document: ${patch['document'].path.split('/').last}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]
                  ),
                ),
            ],
          ),
        )
    );
  }
  Widget _buildAccountInfoContainer(){
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!, width: 1)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Bank Name", style: TextStyle(fontWeight: FontWeight.bold),),
                  Expanded(
                    child: Text(formData['selectedBank'] ?? 'Not Available',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                ]
            ),
            SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Account Number", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(formData['accountNumber'] ?? 'Not Available')
                ]
            ),
            SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("IFSC Code", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(formData['ifscCode'] ?? 'Not Available'),
                ]
            ),
            SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Branch Name", style: TextStyle(fontWeight: FontWeight.bold),),
                  Expanded(
                    child: Text(formData['branchName'] ?? 'Not Available',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEquipmentDetailsContainer() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!, width: 1)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (formData['selectedEquipment'] as List?)
              ?.map((equipment) => _buildEquipmentItem(equipment))
              .toList() ?? [],
        ),
      ),
    );
  }
  Widget _buildEquipmentItem(String equipment) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
            children: [
              Icon(Icons.build, color: Colors.grey[600]),
              SizedBox(width: 10,),
              Expanded(
                child: Text(equipment,
                  style: TextStyle(fontSize: 16),
                ),
              ),

            ]
        )

    );
  }
  Widget _buildCardContainer() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!, width: 1)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Card Number", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(".... .... .... 1234")
                ]
            ),
            SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Expiry Date", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text("12/2028")
                ]
            ),
            SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Card Holder", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(formData['firstName'] !=null && formData['lastName'] != null ? "${formData['firstName']} ${formData['lastName']}" : "Not Available"
                  )
                ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoContainer() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!, width: 1),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text("First Name", style: TextStyle(fontWeight: FontWeight.bold),),
    Expanded(
    child:  Text(formData['firstName'] != null ? formData['firstName'].toString() : "Not Available",
    textAlign: TextAlign.end,
    overflow: TextOverflow.ellipsis,
    ),
    ),
    ],
    ),
    SizedBox(height: 8),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text("Last Name", style: TextStyle(fontWeight: FontWeight.bold),),
    Expanded(
    child: Text(formData['lastName'] != null ? formData['lastName'].toString() : "Not Available",
    textAlign: TextAlign.end,
    overflow: TextOverflow.ellipsis,
    ),
    ),
    ],
    ),
    SizedBox(height: 8),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text("Date of Birth", style: TextStyle(fontWeight: FontWeight.bold),),
    Expanded(
    child: Text(formData['dob']!= null ? formData['dob'].toString() : "Not Available",
    textAlign: TextAlign.end,
    overflow: TextOverflow.ellipsis,
    ),
    ),

    ],
    ),
    SizedBox(height: 8),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text("Address", style: TextStyle(fontWeight: FontWeight.bold),),
    Expanded(
    child: Text(formData['address']!=null ? formData['address'].toString() : "Not Available",
    textAlign: TextAlign.end,
    overflow: TextOverflow.ellipsis,
    ),
    ),
    ],
    ),
    SizedBox(height: 8),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text("State", style: TextStyle(fontWeight: FontWeight.bold),),
    Expanded(
    child: Text(formData['state'] != null ? formData['state'].toString() : "Not Available",
    textAlign: TextAlign.end,
    overflow: TextOverflow.ellipsis,
    ),
    ),
    ],
    ),
    SizedBox(height: 8),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text("District", style: TextStyle(fontWeight: FontWeight.bold),),
    Expanded(
    child: Text(formData['district'] != null ? formData['district'].toString() : "Not Available",
    textAlign: TextAlign.end,
    overflow: TextOverflow.ellipsis,
    ),
    ),
    ],
    ),
    SizedBox(height: 8),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold),),
    Expanded(
    child: Text(formData['phone']!=null ? formData['phone'].toString() : "Not Available",
    textAlign: TextAlign.end,
    overflow: TextOverflow.ellipsis,                  ),
    ),
    ],
    ),
    ],
    ),
        ),
    );
  }
}
