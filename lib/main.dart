import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:telegram_web_app/telegram_web_app.dart';

const String backendBaseUrl = 'https://sixty-papayas-exist.loca.lt/api';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F111A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6A4DFF),
          surface: Color(0xFF2C2C30),
        ),
        fontFamily: 'Roboto',
      ),
      home: const BookingScreen(),
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _isTimeSelection = false;
  int _selectedDay = 1;
  int _selectedHour = 18;
  int _selectedMinute = 37;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    try {
      final user = TelegramWebApp.instance.initDataUnsafe?.user;
      if (user != null) {
        final response = await http.get(Uri.parse('$backendBaseUrl/api/is_admin/${user.id}'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _isAdmin = data['is_admin'] ?? false;
          });
        }
      }
    } catch (e) {
      debugPrint('Admin check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isTimeSelection) {
              setState(() {
                _isTimeSelection = false;
              });
            }
          },
        ),
        title: const Text('Бронирование', style: TextStyle(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ClubInfoCard(),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E202C),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      _isTimeSelection ? 'Выберите время' : 'Выбери дату',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_isTimeSelection) ...[
                    _buildCalendarHeader(),
                    const SizedBox(height: 16),
                    _buildDaysOfWeek(),
                    const SizedBox(height: 8),
                    _buildCalendarGrid(),
                  ] else ...[
                    _buildHorizontalDateList(),
                    const SizedBox(height: 20),
                    CustomTimePicker(
                      initialHour: _selectedHour,
                      initialMinute: _selectedMinute,
                      onTimeChanged: (hour, minute) {
                        _selectedHour = hour;
                        _selectedMinute = minute;
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A4DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (!_isTimeSelection) {
                          setState(() {
                            _isTimeSelection = true;
                          });
                        } else {
                          final dateStr = '$_selectedDay мая';
                          final timeStr = '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                selectedDate: dateStr,
                                selectedTime: timeStr,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Далее',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  if (_isAdmin) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
                        label: const Text('Управление', style: TextStyle(color: Colors.amber)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.amber),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminManagementScreen()));
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Май',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: const [
            Icon(Icons.chevron_left, color: Colors.grey, size: 20),
            SizedBox(width: 16),
            Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        )
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((day) => Text(
                day,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 31 + 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < 4) return const SizedBox();
        final day = index - 3;
        final isSelected = day == _selectedDay;
        final isWeekend = (index % 7 == 5) || (index % 7 == 6);
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = day;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6A4DFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? Colors.white
                        : (isWeekend ? Colors.redAccent : Colors.white),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalDateList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildDateCard(icon: Icons.calendar_today),
          const SizedBox(width: 8),
          _buildDateCard(day: 1, weekday: 'Пт', isSelected: _selectedDay == 1),
          const SizedBox(width: 8),
          _buildDateCard(day: 2, weekday: 'Сб', isWeekend: true, isSelected: _selectedDay == 2),
          const SizedBox(width: 8),
          _buildDateCard(day: 3, weekday: 'Вс', isWeekend: true, isSelected: _selectedDay == 3),
          const SizedBox(width: 8),
          _buildDateCard(day: 4, weekday: 'Пн', isSelected: _selectedDay == 4),
          const SizedBox(width: 8),
          _buildDateCard(day: 5, weekday: 'Вт', isSelected: _selectedDay == 5),
          const SizedBox(width: 8),
          _buildDateCard(day: 6, weekday: 'Ср', isSelected: _selectedDay == 6),
        ],
      ),
    );
  }

  Widget _buildDateCard(
      {int? day,
      String? weekday,
      IconData? icon,
      bool isSelected = false,
      bool isWeekend = false}) {
    return Container(
      width: 45,
      height: 50,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6A4DFF) : const Color(0xFF1E202C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, color: Colors.white, size: 20)
          else ...[
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text('$day',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                if (isSelected)
                  Positioned(
                    right: -6,
                    top: 0,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
              ],
            ),
            Text(weekday!,
                style: TextStyle(
                    color: isSelected
                        ? Colors.white70
                        : (isWeekend ? Colors.redAccent : Colors.grey),
                    fontSize: 12)),
          ]
        ],
      ),
    );
  }
}

class ClubInfoCard extends StatelessWidget {
  const ClubInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E202C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF140D26),
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=2070&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.sports_esports, size: 80, color: Colors.white24)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Continental cyber club',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Костанай, 8 микрорайон, 8а',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CustomTimePicker extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final void Function(int hour, int minute) onTimeChanged;

  const CustomTimePicker({
    super.key,
    required this.initialHour,
    required this.initialMinute,
    required this.onTimeChanged,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour;
    _selectedMinute = widget.initialMinute;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A50),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 36,
                  perspective: 0.005,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedHour = index;
                    });
                    widget.onTimeChanged(_selectedHour, _selectedMinute);
                  },
                  controller: FixedExtentScrollController(initialItem: _selectedHour),
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > 23) return null;
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _selectedHour == index
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      );
                    },
                    childCount: 24,
                  ),
                ),
              ),
              const Text(':',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(
                width: 80,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 36,
                  perspective: 0.005,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedMinute = index;
                    });
                    widget.onTimeChanged(_selectedHour, _selectedMinute);
                  },
                  controller: FixedExtentScrollController(initialItem: _selectedMinute),
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index > 59) return null;
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _selectedMinute == index
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      );
                    },
                    childCount: 60,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WallsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFF282B3A) // Цвет сплошных стен
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void line(double x1, double y1, double x2, double y2) {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Left Block Walls
    line(24, 24, 208, 24); // Top
    line(24, 24, 24, 386); // Left
    line(24, 386, 208, 386); // Bottom
    line(208, 24, 208, 320); // Right (верхняя часть)
    line(208, 370, 208, 386); // Right (нижняя часть, проход на уровне 320..370)

    // Center Block Walls
    line(292, 24, 548, 24); // Top
    
    // Left (проход на уровне 320..370)
    line(292, 24, 292, 320); 
    line(292, 370, 292, 452); // Идет ровно до нижнего левого угла (452)
    
    // Right (полностью сплошная стена)
    line(548, 24, 548, 452); 
    
    // Bottom (с проходом прямо под ПК 15)
    line(548, 452, 530, 452); // Правый нижний уголок
    line(460, 452, 292, 452); // Основная часть нижней стены до левого угла

    // Right Block Top Walls
    line(612, 24, 812, 24); // Top
    line(612, 24, 612, 188); // Left
    line(812, 24, 812, 188); // Right
    line(612, 188, 628, 188); // Bottom (левая часть)
    line(684, 188, 812, 188); // Bottom (правая часть, проход под ПК 16: 628..684)

    // Right Block Bottom Walls
    line(612, 222, 756, 222); // Top
    line(756, 222, 756, 386); // Right
    line(612, 386, 756, 386); // Bottom
    line(612, 222, 612, 250); // Left (верхняя часть)
    line(612, 290, 612, 320); // Left (средняя часть)
    line(612, 370, 612, 386); // Left (нижняя часть)

    // Внутренняя стена между ПК 21, 22 и 23
    line(612, 304, 756, 304);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MapScreen extends StatefulWidget {
  final String selectedDate;
  final String selectedTime;

  const MapScreen({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int? _selectedSeatId;
  List<int> _occupiedSeats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOccupiedSeats();
  }

  Future<void> _fetchOccupiedSeats() async {
    setState(() { _isLoading = true; });
    try {
      final url = Uri.parse('$backendBaseUrl/api/bookings?date=${widget.selectedDate}&time_slot=${widget.selectedTime}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _occupiedSeats = data.map((b) => b['pc_number'] as int).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      setState(() { _isLoading = false; });
    }
  }

  Widget _buildSeat(int id) {
    bool isSelected = id == _selectedSeatId;
    bool isOccupied = _occupiedSeats.contains(id);
    
    return GestureDetector(
      onTap: isOccupied ? null : () {
        setState(() { _selectedSeatId = isSelected ? null : id; });
      },
      child: SizedBox(
        width: 44,
        height: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Monitor Body
            Container(
              width: 44,
              height: 32,
              decoration: BoxDecoration(
                color: isOccupied ? Colors.red.withOpacity(0.2) : const Color(0xFF1E202C),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isOccupied 
                    ? Colors.redAccent.withOpacity(0.5) 
                    : (isSelected ? const Color(0xFF00E5FF) : const Color(0xFF333747)),
                  width: 1.5,
                ),
                boxShadow: isSelected ? [
                  const BoxShadow(
                    color: Color(0xFF00E5FF),
                    blurRadius: 8,
                    offset: Offset(0, 0),
                  )
                ] : null,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        '$id',
                        style: TextStyle(
                          color: isOccupied 
                            ? Colors.redAccent 
                            : (isSelected ? Colors.white : Colors.white60),
                          fontSize: 16,
                          fontWeight: isOccupied ? FontWeight.bold : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  // Неоновая вставка внутри монитора внизу
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: isOccupied 
                        ? Colors.redAccent 
                        : (isSelected ? const Color(0xFF00E5FF) : const Color(0xFF14151C)),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 2),
            // Stand (ножка)
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: isOccupied 
                  ? Colors.redAccent 
                  : (isSelected ? const Color(0xFF00E5FF) : const Color(0xFF333747)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatAt(int id, double x, double y) {
    return Positioned(
      left: x + 6,
      top: y + 8,
      child: _buildSeat(id),
    );
  }

  Widget _buildMap() {
    return SizedBox(
      width: 830,
      height: 500,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Сплошные стены (с проходами)
          Positioned.fill(
            child: CustomPaint(
              painter: WallsPainter(),
            ),
          ),

          // SEATS 
          // Left Block
          _buildSeatAt(28, 40, 40), _buildSeatAt(27, 40, 106), _buildSeatAt(26, 40, 172), _buildSeatAt(25, 40, 238), _buildSeatAt(24, 40, 304),
          _buildSeatAt(29, 136, 40), _buildSeatAt(30, 136, 106), _buildSeatAt(31, 136, 172), _buildSeatAt(32, 136, 238), _buildSeatAt(33, 136, 304),
          
          // Center Block
          _buildSeatAt(1, 308, 40), _buildSeatAt(2, 308, 106), _buildSeatAt(3, 308, 172), _buildSeatAt(4, 308, 238),
          _buildSeatAt(9, 372, 40), _buildSeatAt(8, 372, 106), _buildSeatAt(7, 372, 172), _buildSeatAt(6, 372, 238), _buildSeatAt(5, 372, 304),
          _buildSeatAt(10, 476, 40), _buildSeatAt(11, 476, 106), _buildSeatAt(12, 476, 172), _buildSeatAt(13, 476, 238), _buildSeatAt(14, 476, 304), _buildSeatAt(15, 476, 370),

          // Right Block Top
          _buildSeatAt(16, 628, 40), _buildSeatAt(17, 684, 40), _buildSeatAt(18, 740, 40),
          _buildSeatAt(20, 684, 106), _buildSeatAt(19, 740, 106),

          // Right Block Bottom
          Positioned(left: 630, top: 238, child: _buildSeat(21)),
          Positioned(left: 694, top: 238, child: _buildSeat(22)),
          Positioned(left: 694, top: 320, child: _buildSeat(23)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Карта клуба', style: TextStyle(fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: _buildMap(),
                  ),
                ),
              ),
            ),
          ),

          if (_selectedSeatId != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E202C),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Выбор игровых мест',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Количество: 1',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSeatId = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF282B3A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.redAccent, size: 20),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF282B3A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text('$_selectedSeatId',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const Text('pc',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A4DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingConfirmationScreen(
                              selectedDate: widget.selectedDate,
                              selectedTime: widget.selectedTime,
                              selectedSeatId: _selectedSeatId!,
                            ),
                          ),
                        );
                      },
                      child: const Text('Далее',
                          style:
                              TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class BookingConfirmationScreen extends StatefulWidget {
  final String selectedDate;
  final String selectedTime;
  final int selectedSeatId;

  const BookingConfirmationScreen({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedSeatId,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isLoading = false;
  String? telegramId;
  String? telegramName;

  @override
  void initState() {
    super.initState();
    try {
      final webApp = TelegramWebApp.instance;
      if (webApp.isSupported) {
        final initData = webApp.initDataUnsafe;
        if (initData != null && initData.user != null) {
          telegramId = initData.user!.id.toString();
          telegramName = initData.user!.firstName;
          if (telegramName == null || telegramName!.isEmpty) {
            telegramName = initData.user!.username ?? 'Пользователь';
          }
        }
      }
      
      // Fallback if not in Telegram or data is missing
      if (telegramId == null) {
        telegramId = '0';
        telegramName = 'Тестовый пользователь';
      }
    } catch (e) {
      telegramId = '0';
      telegramName = 'Ошибка SDK';
    }
  }

  Future<void> bookSeat() async {
    final url = Uri.parse('$backendBaseUrl/api/book');
    try {
      final user = TelegramWebApp.instance.initDataUnsafe?.user;
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': user?.id ?? 0,
          'username': user?.username ?? 'guest',
          'first_name': user?.firstName ?? telegramName,
          'date': widget.selectedDate,
          'time_slot': widget.selectedTime,
          'pc_number': widget.selectedSeatId,
        }),
      );
      if (response.statusCode != 200) {
        debugPrint('Failed to send request: ${response.body}');
        throw Exception(jsonDecode(response.body)['detail'] ?? 'Ошибка бронирования');
      }
    } catch (e) {
      debugPrint('Error sending request: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Подтверждение', style: TextStyle(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ClubInfoCard(),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E202C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Детали бронирования', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDetailRow('Дата:', widget.selectedDate),
                  const SizedBox(height: 8),
                  _buildDetailRow('Время:', widget.selectedTime),
                  const SizedBox(height: 8),
                  _buildDetailRow('Номер ПК:', '${widget.selectedSeatId} pc'),
                  const SizedBox(height: 24),
                  const Text('Бронирует:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282B3A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.telegram, color: Color(0xFF0088cc)),
                        const SizedBox(width: 12),
                        Text(
                          telegramName ?? 'Пользователь',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A4DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        await bookSeat();

                        if (!mounted) return;

                        setState(() {
                          _isLoading = false;
                        });
                        
                        // Show success message and go back to root
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Бронь успешно создана!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Забронировать', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() { _isLoading = true; });
    try {
      final response = await http.get(Uri.parse('$backendBaseUrl/api/admin/bookings'));
      if (response.statusCode == 200) {
        setState(() {
          _bookings = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching admin bookings: $e');
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _deleteBooking(int id) async {
    try {
      final response = await http.delete(Uri.parse('$backendBaseUrl/api/admin/bookings/$id'));
      if (response.statusCode == 200) {
        _fetchBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Бронь удалена')));
        }
      }
    } catch (e) {
      debugPrint('Error deleting booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Управление бронями')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _bookings.isEmpty 
          ? const Center(child: Text('Нет активных броней'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final b = _bookings[index];
                return Card(
                  color: const Color(0xFF1E202C),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('${b['user_name']} - ПК ${b['pc_number']}'),
                    subtitle: Text('${b['date']} в ${b['time_slot']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteBooking(b['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

