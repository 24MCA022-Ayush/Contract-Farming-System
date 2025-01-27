import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class FarmerProfilePage extends StatefulWidget {
  const FarmerProfilePage({Key? key}) : super(key: key);
  @override
  State<FarmerProfilePage> createState() => _FarmerProfilePageState();
}

class _FarmerProfilePageState extends State<FarmerProfilePage> {
  Map<String, dynamic>? formData;
  File? _profileImage;
  String? userType;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final args = ModalRoute.of(context)?.settings.arguments;

      userType = args is String ? args : null;

      if (user != null && userType != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection(userType!)
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            formData = snapshot.data() as Map<String, dynamic>;
          });
        } else {
          // Handle the case where the document doesn't exist
          print('User document not found.');
          // You might want to navigate back or show an error message.
        }
      } else {
        print("User not logged in or userType argument is missing.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      // Handle errors (e.g., show a SnackBar)
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (formData != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile Setting'),
          backgroundColor: Colors.green[700],
          titleTextStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20),
            _buildSectionTitle("General"),
            _buildOptionTile(
                "Edit Profile",
                Icons.edit,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(
                                  profileImage: _profileImage,
                                  formData: formData!,
                                  onImageChanged: (File? image) {
                                    setState(() {
                                      _profileImage = image;
                                    });
                                  })));
                }
            ),
            _buildOptionTile(
                "Bank Details",
                Icons.account_balance,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              BankDetailsScreen(
                                  formData: formData!
                              )));
                }
            ),
            _buildOptionTile(
                "Terms of Use",
                Icons.description,
                onTap: () {
                  // TODO: Open Terms of Use
                  print('Terms of Use Pressed');
                }
            ),
            _buildOptionTile(
                "Land Patch Details",
                Icons.landscape,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LandPatchDetailsScreen(
                              formData: formData!,
                            )),
                  );
                }
            ),
            _buildOptionTile(
                "Equipment Details",
                Icons.build,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EquipmentDetailsScreen(
                              formData: formData!,
                            )),
                  );
                }
            ),
            SizedBox(height: 20),
            _buildSectionTitle("Preferences"),
            _buildOptionTile("Notification", Icons.notifications,
                trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // TODO : Implement Notification Toggle
                      print('Notification switch toggled');
                    }
                )
            ),
            _buildOptionTile("FAQ", Icons.question_answer, onTap: () {
              // TODO: Open FAQ
              print('FAQ Pressed');
            }),
            _buildOptionTile("Log Out", Icons.logout,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
              // TODO : Log out from profile
              print('User Log out');
            }),

          ],
        ),
      );
    }
    else {
      return const Scaffold( // Or display a loading indicator
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
          backgroundColor: Colors.grey[300],
          child: _profileImage == null ?  Icon(Icons.person, size: 60, color: Colors.grey[600],) : null,
        ),
        SizedBox(height: 10),
        Text(
          formData!['firstName']!=null && formData!['lastName']!=null
              ? "${formData!['firstName']} ${formData!['lastName']}"
              : "Not Available",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
            formData!['email'] ?? "Not Available"
        ),

      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, {Widget? trailing, void Function()? onTap} ) {
    return  Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(title, style: TextStyle(color: Colors.black),),
        trailing: trailing != null ? trailing : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600],),
        onTap: onTap,
      ),
    );
  }
}



class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final File? profileImage;
  final Function(File?) onImageChanged;

  EditProfileScreen({super.key, required this.formData, required this.onImageChanged, this.profileImage});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _nickNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _profileImage = widget.profileImage;
    _nameController.text = widget.formData['firstName'] ?? '';
    _nickNameController.text = widget.formData['lastName'] ?? '';
    _emailController.text = widget.formData['email'] ?? '';
    _phoneNumberController.text =  widget.formData['phone'] ?? '';
    _dateOfBirthController.text = widget.formData['dob'] ?? '';

  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
        widget.onImageChanged(_profileImage);
      });
    }
  }

  void _saveProfileDetails(BuildContext context) {
    // Simulate saving data (replace with actual save logic)
    widget.formData['firstName'] = _nameController.text;
    widget.formData['lastName'] = _nickNameController.text;
    widget.formData['email'] = _emailController.text;
    widget.formData['phone'] = _phoneNumberController.text;
    widget.formData['dob'] = _dateOfBirthController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated Successfully'),
        backgroundColor: Colors.green,
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.green[700],
        titleTextStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      backgroundColor: Colors.grey[300],
                      child: _profileImage == null
                          ? Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.grey[600],
                      )
                          : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.white,),
                      onPressed: (){
                        showModalBottomSheet(context: context, builder: (context){
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.camera_alt),
                                  title: Text('Camera'),
                                  onTap: () {
                                    _pickImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Gallery'),
                                  onTap: () {
                                    _pickImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    ),
                  ]
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _nickNameController,
              decoration: InputDecoration(labelText: 'Nick Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: ElevatedButton(
                    onPressed: (){
                      // TODO: Add email verification functionality.
                      print('Verify pressed');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green[700]!),
                    ),
                    child: Text("Verify",
                        style: TextStyle(color: Colors.white)
                    )),

              ),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _dateOfBirthController,
              decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.green),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
              ),
              style: TextStyle(fontWeight: FontWeight.bold),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateOfBirthController.text =
                        DateFormat('dd/MM/yyyy').format(pickedDate);
                  });
                }
              },
              readOnly: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveProfileDetails(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green[700],
              ),
              child: Text('Save'),
            ),

          ],
        ),
      ),
    );
  }
}



class BankDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> formData;

  BankDetailsScreen({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Bank Details'),
          backgroundColor: Colors.green[700],
          titleTextStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle("Account Information"),
            _buildAccountInfoContainer(),

            SizedBox(height: 20,),
            _buildSectionTitle("Card Details"),
            _buildCardContainer(),
            SizedBox(height: 20,),
            _buildSectionTitle("ID Details"),
            _buildDataTile("Aadhaar Number", formData['aadhaarNumber'], Icons.credit_card),
            _buildDataTile("PAN Number", formData['panNumber'], Icons.credit_card_outlined),
          ],
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 20),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: GoogleFonts.nunito().fontFamily),
                    ),
                    TextSpan(text: value.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String? _getBankIcon(String? bankName) {
    final List<Map<String, String>> _banks = [
      {"name": "State Bank of India", "icon": "assets/sbi_icon.png"},
      {"name": "HDFC Bank", "icon": "assets/HDFC_icon.png"},
      {"name": "ICICI Bank", "icon": "assets/icici_icon.png"},
      {"name": "Punjab National Bank", "icon": "assets/pnb_icon.png"},
      {"name": "Bank of Baroda", "icon": "assets/bob_icon.png"},
      // Add more banks with their icons here
    ];
    final bank = _banks.firstWhere((element) => element['name'] == bankName, orElse: () => {});
    return bank['icon'];
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
                  Text("Card Holder", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: GoogleFonts.nunito().fontFamily),),
                  Text(formData['firstName'] !=null && formData['lastName'] != null ? "${formData['firstName']} ${formData['lastName']}" : "Not Available"
                  )
                ]
            ),
          ],
        ),
      ),
    );
  }
}







class LandPatchDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> formData;

  LandPatchDetailsScreen({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Land Details'),
          backgroundColor: Colors.green[700],
          titleTextStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle("Land Details"),
            if (formData['totalLandPatches'] != null)
              _buildDataTile("Total Land Patches", formData['totalLandPatches'].toString(), Icons.zoom_out_map),

            if (formData['landDetails'] != null)
              for(int i = 0; i < (formData['landDetails'] as List).length; i++)
                _buildLandPatchDetailContainer(formData['landDetails'][i], i+1),

          ],
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 20),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
      ),
    );
  }

  Widget _buildDataTile(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            SizedBox(width: 10,),
            Expanded(
              child:  RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(
                      text: "$label: ",
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: GoogleFonts.nunito().fontFamily),
                    ),
                    TextSpan(text: value.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandPatchDetailContainer(Map<String, dynamic> patch, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[400]!, width: 1)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Land Patch $index",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black
              ),
            ),
            SizedBox(height: 10),
            _buildDataRow("Land Size", patch['landSize'].toString(), Icons.zoom_out_map),
            _buildDataRow("Soil Type", patch['soilType'].toString(), Icons.filter_vintage),
            _buildDataRow("Crops", patch['crops'].join(', '), Icons.eco),
            _buildDataRow("Irrigation Source", patch['irrigationSource'].toString(), Icons.water_drop),
            _buildDataRow("Location", patch['coordinates'] != null ? "Lat: ${patch['coordinates'].latitude} Lng: ${patch['coordinates'].longitude}" : "Not Selected", Icons.location_on),
            if (patch['document'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                    children: [
                      Icon(Icons.file_present, color: Colors.grey[600],),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Text(
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
      ),
    );
  }
  Widget _buildDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[600], size: 18,),
                SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

              ],
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]
      ),
    );
  }
}








class EquipmentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> formData;

  EquipmentDetailsScreen({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Equipment Details'),
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
              _buildSectionTitle("Equipment Details"),
              _buildEquipmentDetailsContainer(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 20),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]),
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
        child: Column(
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
              Icon(Icons.format_list_bulleted, size: 15  , color: Colors.green[600]),
              SizedBox(width: 10,),
              Expanded(
                child:Text(equipment,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

            ]
        )

    );
  }
}