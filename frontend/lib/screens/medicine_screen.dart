import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import 'add_medicine_screen.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({Key? key}) : super(key: key);

  @override
  _MedicinesScreenState createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final List<Medicine> _medicines = [
    Medicine(name: 'Omeprazole', dose: '20 mg', time: '09:00'),
    Medicine(name: 'Dipyrone', dose: '10 mg', time: '09:00'),
    Medicine(name: 'Losartan', dose: '20 mg', time: '09:00'),
    Medicine(name: 'Simvastatin', dose: '40 mg', time: '09:00'),
    Medicine(name: 'Paracetamol', dose: '750 mg', time: '14:00'),
  ];

  void _markAsTaken(int index, bool? newState) {
    setState(() {
      _medicines[index].taken = newState ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: const Text('Medicines', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF89D2F3),
                Color(0xFFC0E6FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _medicines.length,
        itemBuilder: (context, index) {
          final medicine = _medicines[index];
          return _buildMedicineItem(medicine, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newMedicine = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
          );
          if (newMedicine != null && newMedicine is Medicine) {
            setState(() {
              _medicines.add(newMedicine);
            });
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 30),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: 'Settings',
          ),
        ],
      ),
      extendBody: true,
    );
  }

  Widget _buildMedicineItem(Medicine medicine, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.8,
            child: Checkbox(
              value: medicine.taken,
              onChanged: (bool? newState) {
                _markAsTaken(index, newState);
              },
              activeColor: Colors.black,
              checkColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade400, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${medicine.name} ${medicine.dose}',
              style: TextStyle(
                color: medicine.taken ? Colors.grey.shade500 : Colors.black87,
                decoration: medicine.taken ? TextDecoration.lineThrough : null,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            medicine.time,
            style: TextStyle(
              color: medicine.taken ? Colors.grey.shade400 : Colors.black54,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
