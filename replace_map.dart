import 'dart:io';

void main() {
  var file = File('lib/main.dart');
  var content = file.readAsStringSync();

  var pattern = RegExp(
      r'class _MapScreenState extends State<MapScreen> \{.*?bool shouldRepaint\(covariant CustomPainter oldDelegate\) => false;\n\}',
      multiLine: true,
      dotAll: true);

  var newContent = '''class _MapScreenState extends State<MapScreen> {
  int? _selectedSeatId;

  Widget _buildSeat(int id, {Color? highlightColor}) {
    bool isSelected = id == _selectedSeatId;
    bool isOccupied = [2, 14, 25].contains(id);

    Color seatColor;
    if (isOccupied) {
      seatColor = const Color(0xFF8B0000); // Dark red
    } else if (isSelected) {
      seatColor = const Color(0xFF00E5FF); // Bright blue
    } else {
      seatColor = const Color(0xFF333338); // Dark gray
    }

    return GestureDetector(
      onTap: () {
        if (isOccupied) return;
        setState(() {
          _selectedSeatId = isSelected ? null : id;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(8),
          border: highlightColor != null ? Border.all(color: highlightColor, width: 2) : null,
          boxShadow: highlightColor != null ? [
            BoxShadow(color: highlightColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)
          ] : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.desktop_windows, size: 24, color: Colors.white24),
            Text(
              '\$id',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<int> ids, {int? highlightId, Color? highlightColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: ids.map((id) => _buildSeat(id, highlightColor: id == highlightId ? highlightColor : null)).toList(),
    );
  }

  Widget _buildVerticalWall({required double height}) {
    return SizedBox(
      width: 2,
      height: height,
      child: CustomPaint(painter: DashedLinePainter(isHorizontal: false)),
    );
  }

  Widget _buildHorizontalWall({required double width}) {
    return SizedBox(
      width: width,
      height: 2,
      child: CustomPaint(painter: DashedLinePainter(isHorizontal: true)),
    );
  }

  Widget _buildMap() {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 80, left: 40, right: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Left Zone
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildColumn([28, 27, 26, 25, 24]),
                  const SizedBox(width: 8),
                  _buildColumn([29, 30, 31, 32, 33], highlightId: 33, highlightColor: Colors.yellow),
                ],
              ),
              
              const SizedBox(width: 24),
              _buildVerticalWall(height: 380),
              const SizedBox(width: 24),

              // Central Zone
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColumn([1, 2, 3, 4]),
                  const SizedBox(width: 8),
                  _buildColumn([9, 8, 7, 6, 5], highlightId: 5, highlightColor: Colors.green),
                  const SizedBox(width: 8),
                  _buildColumn([10, 11, 12, 13, 14, 15]),
                ],
              ),

              const SizedBox(width: 24),
              _buildVerticalWall(height: 380),
              const SizedBox(width: 24),

              // Right Zone
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildSeat(16), _buildSeat(17), _buildSeat(18)],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildSeat(20), _buildSeat(19)],
                  ),
                  
                  const SizedBox(height: 16),
                  _buildHorizontalWall(width: 160),
                  const SizedBox(height: 16),

                  // Bottom
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildSeat(21), _buildSeat(22)],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildSeat(23)],
                  ),
                ],
              ),
            ],
          ),
          
          // Reception
          Positioned(
            left: 110,
            bottom: -30,
            child: Column(
              children: [
                const Icon(Icons.support_agent, color: Colors.white70, size: 36),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text('RECEPTION', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ),
          )
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
      body: Stack(
        children: [
          // Map Canvas
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 3.0,
            constrained: false,
            child: Container(
              width: 1000,
              height: 800,
              alignment: Alignment.center,
              child: _buildMap(),
            ),
          ),

          // Bottom Sheet
          if (_selectedSeatId != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2B30),
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
                              color: const Color(0xFF333338),
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
                            color: const Color(0xFF4A4A50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text('\$_selectedSeatId',
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
            )
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final bool isHorizontal;
  DashedLinePainter({this.isHorizontal = true});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 8, dashSpace = 8;
    double distance = isHorizontal ? size.width : size.height;
    double startX = 0, startY = 0;

    while (isHorizontal ? startX < distance : startY < distance) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(isHorizontal ? startX + dashWidth : startX, isHorizontal ? startY : startY + dashWidth),
        paint,
      );
      if (isHorizontal) {
        startX += dashWidth + dashSpace;
      } else {
        startY += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}''';

  content = content.replaceFirst(pattern, newContent);
  file.writeAsStringSync(content);
  print('done!');
}
