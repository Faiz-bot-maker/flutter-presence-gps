import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftingKerjaPage extends StatefulWidget {
  const ShiftingKerjaPage({super.key});

  @override
  State<ShiftingKerjaPage> createState() => _ShiftingKerjaPageState();
}

class _ShiftingKerjaPageState extends State<ShiftingKerjaPage> {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(8 * 60.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Jadwal Shift'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _selectedDate = DateTime.now()),
            icon: const Icon(Icons.today_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          _buildDateStrip(scheme),
          Expanded(child: _buildTimeline(scheme)),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(_selectedDate),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate =
                        _selectedDate.subtract(const Duration(days: 7));
                  });
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate =
                        _selectedDate.add(const Duration(days: 7));
                  });
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= DATE STRIP =================

  Widget _buildDateStrip(ColorScheme scheme) {
    final startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

    return Container(
      height: 100,
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary
                    : (isToday
                        ? scheme.primaryContainer
                        : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? scheme.primary
                      : Colors.grey.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isSelected ? Colors.white : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.white : scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= TIMELINE =================

  Widget _buildTimeline(ColorScheme scheme) {
    final isWeekend =
        _selectedDate.weekday == 6 || _selectedDate.weekday == 7;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Stack(
        children: [
          Column(
            children: List.generate(24, (index) {
              return SizedBox(
                height: 60,
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${index.toString().padLeft(2, '0')}:00',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: Colors.grey[200]),
                    ),
                  ],
                ),
              );
            }),
          ),

          // SHIFT
          if (!isWeekend)
            Positioned(
              top: 8 * 60.0,
              left: 70,
              right: 20,
              height: 9 * 60.0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(
                      color: scheme.primary,
                      width: 4,
                    ),
                  ),
                ),
                child: const Text(
                  'Shift Pagi\n08:00 - 17:00',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // WEEKEND
          if (isWeekend)
            Positioned(
              top: 20,
              left: 70,
              right: 20,
              height: 120,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(30, 255, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  border: Border(
                    left: BorderSide(color: Colors.red, width: 4),
                  ),
                ),
                child: const Text(
                  'Libur Akhir Pekan',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
