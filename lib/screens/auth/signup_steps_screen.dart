import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';

class SignUpStepScreen extends StatefulWidget {
  final int initialStep;
  
  const SignUpStepScreen({super.key, this.initialStep = 0});
  
  @override
  State<SignUpStepScreen> createState() => _SignUpStepScreenState();
}

class _SignUpStepScreenState extends State<SignUpStepScreen> {
  int _currentStep = 0;
  String _selectedCountry = 'United States';
  String _selectedCountryCode = 'US';
  String _homeName = '';
  final List<String> _selectedRooms = [];
  bool _locationEnabled = false;
  String _address = '';

  final List<Map<String, dynamic>> _availableRooms = [
    {'name': 'Living Room', 'icon': Icons.weekend_outlined},
    {'name': 'Bedroom', 'icon': Icons.bed_outlined},
    {'name': 'Bathroom', 'icon': Icons.bathtub_outlined},
    {'name': 'Kitchen', 'icon': Icons.restaurant_outlined},
    {'name': 'Study Room', 'icon': Icons.school_outlined},
    {'name': 'Dining Room', 'icon': Icons.restaurant_menu_outlined},
    {'name': 'Backyard', 'icon': Icons.yard_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCountryStep();
      case 1:
        return _buildHomeNameStep();
      case 2:
        return _buildRoomsStep();
      case 3:
        return _buildLocationStep();
      default:
        return Container();
    }
  }

  Widget _buildCountryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              height: 1.2,
            ),
            children: [
              TextSpan(
                text: 'Select ',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Country',
                style: TextStyle(color: Color(0xFF5B7CFF)),
              ),
              TextSpan(
                text: ' of Origin',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Let's start by selecting the country where your smart haven resides.",
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        
        // Search Country Input
        TextField(
          readOnly: true,
          onTap: () {
            showCountryPicker(
              context: context,
              countryListTheme: CountryListThemeData(
                flagSize: 25,
                backgroundColor: const Color(0xFF1B1A20),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
                bottomSheetHeight: 500,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                inputDecoration: InputDecoration(
                  hintText: 'Search Country...',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: const Color(0xFF2A2930),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              onSelect: (country) {
                setState(() {
                  _selectedCountry = country.name;
                  _selectedCountryCode = country.countryCode;
                });
              },
            );
          },
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: 'Search Country...',
            hintStyle: const TextStyle(color: Color(0xFF6B7280)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
            filled: true,
            fillColor: const Color(0xFF2A2930),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
        const SizedBox(height: 24),
        
        // Selected Country Display
        if (_selectedCountry.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2930),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF5B7CFF),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Text(
                  CountryParser.parseCountryCode(_selectedCountryCode).flagEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedCountry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const Icon(Icons.check_circle, color: Color(0xFF5B7CFF)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHomeNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              height: 1.2,
            ),
            children: [
              TextSpan(
                text: 'Add ',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Home',
                style: TextStyle(color: Color(0xFF5B7CFF)),
              ),
              TextSpan(
                text: ' Name',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Every smart home needs a name. What would you like to call yours?',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        
        TextField(
          onChanged: (value) => setState(() => _homeName = value),
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: 'My Home',
            hintStyle: const TextStyle(color: Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFF2A2930),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              height: 1.2,
            ),
            children: [
              TextSpan(
                text: 'Add ',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Rooms',
                style: TextStyle(color: Color(0xFF5B7CFF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Select the rooms in your house. Don't worry, you can always add more later.",
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        
        // Rooms Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: _availableRooms.length + 1,
          itemBuilder: (context, index) {
            if (index == _availableRooms.length) {
              // Add Room Button
              return GestureDetector(
                onTap: () {
                  _showAddRoomDialog();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2930),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3D4556),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: Color(0xFF5B7CFF), size: 48),
                        SizedBox(height: 12),
                        Text(
                          'Add Room',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            
            final room = _availableRooms[index];
            final isSelected = _selectedRooms.contains(room['name']);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedRooms.remove(room['name']);
                  } else {
                    _selectedRooms.add(room['name']);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2930),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF3D4556),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            room['icon'],
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            room['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5B7CFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
              height: 1.2,
            ),
            children: [
              TextSpan(
                text: 'Set Home ',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Location',
                style: TextStyle(color: Color(0xFF5B7CFF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pin your home\'s location to enhance location-based features. Privacy is our priority.',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        
        // Map placeholder
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2930),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Map mockup
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: const Color(0xFF35353D),
                  child: CustomPaint(
                    painter: _MapPainter(),
                    size: const Size(double.infinity, 300),
                  ),
                ),
              ),
              // Location pin
              const Icon(
                Icons.location_on,
                color: Color(0xFF5B7CFF),
                size: 64,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Address Details
        const Text(
          'Address Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2930),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _locationEnabled 
                    ? '701 7th Ave, New York, 10036, USA'
                    : 'Enable location to see address',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddRoomDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2930),
        title: const Text(
          'Add Custom Room',
          style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Room name',
            hintStyle: const TextStyle(color: Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFF1B1A20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _availableRooms.add({
                    'name': controller.text,
                    'icon': Icons.room_outlined,
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B7CFF),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2930),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF5B7CFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Enable Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please activate the location feature, so we can find your home address.',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _locationEnabled = true;
                      _address = '701 7th Ave, New York, 10036, USA';
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7CFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Enable Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF35353D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Not Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessScreen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF1B1A20),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B7CFF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5B7CFF).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Well Done!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Congratulations! Your home is now a Smartify haven. Start exploring and managing your smart space with ease.',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7CFF),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  
  String _getRoomIcon(String roomName) {
    switch (roomName.toLowerCase()) {
      case 'living room': return 'living';
      case 'bedroom': return 'bed';
      case 'kitchen': return 'kitchen';
      case 'bathroom': return 'bathroom';
      default: return 'room';
    }
  }

  Future<void> _handleContinue() async {
    if (_currentStep < 3) {
      if (_currentStep == 2 && !_locationEnabled) {
        _showLocationDialog();
      }
      setState(() => _currentStep++);
    } else {
      // Final step - save data
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final userId = authProvider.user?.userId;
      if (userId == null) return;

      // Format rooms
      final List<Map<String, String>> roomsData = [];
      for (var roomName in _selectedRooms) {
        roomsData.add({
          'name': roomName,
          'icon': _getRoomIcon(roomName),
        });
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF5B7CFF)),
        ),
      );

      // Save to backend
      final success = await homeProvider.saveHomeSetup(
        userId: userId,
        homeName: _homeName.isEmpty ? 'My Home' : _homeName,
        country: _selectedCountry,
        rooms: roomsData,
      );

      if (context.mounted) Navigator.pop(context); // Hide loading

      if (success) {
        await homeProvider.loadHomeData(userId.toString());
        if (context.mounted) {
          _showSuccessScreen();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save home setup'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Progress Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  
                  // Progress bar
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF35353D),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_currentStep + 1) / 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B7CFF),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Step counter
                  Text(
                    '${_currentStep + 1} / 4',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildStepContent(),
              ),
            ),
            
            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {  // ← Thêm async
                        if (_currentStep < 3) {
                          setState(() => _currentStep++);
                        } else {
                          // Skip ở bước cuối vẫn cần lưu data
                          await _handleContinue();  // ← Gọi _handleContinue thay vì _showSuccessScreen
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: const Color(0xFF35353D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _handleContinue,  // ← THAY ĐỔI QUAN TRỌNG: Gọi _handleContinue thay vì logic cũ
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7CFF),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
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
}

// Custom painter for map mockup
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF444450)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw random map-like lines
    for (int i = 0; i < 8; i++) {
      final path = Path();
      path.moveTo(0, size.height * i / 8);
      path.quadraticBezierTo(
        size.width * 0.3,
        size.height * (i / 8 + 0.1),
        size.width,
        size.height * i / 8,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}