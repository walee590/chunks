import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DrawingScreen extends StatefulWidget {
  final File? initialFile;

  const DrawingScreen({super.key, this.initialFile});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final DrawingController _drawingController = DrawingController();
  
  // State for UI
  Color _currentColor = Colors.white;
  double _strokeWidth = 4.0;
  int _selectedToolIndex = 0; // 0: Pen, 1: Marker, 2: Eraser

  @override
  void initState() {
    super.initState();
    // Initialize defaults
    _drawingController.setStyle(color: _currentColor, strokeWidth: _strokeWidth);
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  Future<void> _saveDrawing() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saving drawings is not supported on Web. Please run on Windows/Mobile.')),
        );
      }
      return;
    }

    final imageData = await _drawingController.getImageData();
    if (imageData == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Canvas is empty')));
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'drawing_${const Uuid().v4()}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageData.buffer.asUint8List());

      if (mounted) {
        Navigator.pop(context, file.path);
      }
    } catch (e) {
      debugPrint('Error saving drawing: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  void _selectTool(int index) {
    setState(() {
      _selectedToolIndex = index;
    });

    switch (index) {
      case 0: // Pen
        _drawingController.setPaintContent(SimpleLine());
        _drawingController.setStyle(
          color: _currentColor, 
          strokeWidth: 4,
          isAntiAlias: true,
        );
        break;
      case 1: // Marker (Thicker, maybe transparent-ish if supported, or just thick)
        _drawingController.setPaintContent(SimpleLine());
        _drawingController.setStyle(
          color: _currentColor.withValues(alpha: 0.8), 
          strokeWidth: 12,
          isAntiAlias: true,
        );
        break;
      case 2: // Eraser
        _drawingController.setPaintContent(Eraser());
        _drawingController.setStyle(strokeWidth: 20); 
        break;
    }
  }

  void _selectColor(Color color) {
    setState(() {
      _currentColor = color;
      if (_selectedToolIndex == 2) _selectedToolIndex = 0; // Switch back to pen if erasing
    });
    // Apply new color to controller if not eraser
    _drawingController.setPaintContent(SimpleLine());
    _drawingController.setStyle(color: color, strokeWidth: _selectedToolIndex == 1 ? 12 : 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202124),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white),
            onPressed: () => _drawingController.undo(),
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Colors.white),
            onPressed: () => _drawingController.redo(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _drawingController.clear(),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.amber),
            onPressed: _saveDrawing,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return DrawingBoard(
                  controller: _drawingController,
                  background: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    color: const Color(0xFF202124),
                  ),
                  // showDefaultTools: false, // Removed as it is invalid
                );
              },
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final colors = [
      Colors.white,
      Colors.redAccent,
      Colors.amber,
      Colors.lightGreenAccent,
      Colors.lightBlueAccent,
      Colors.purpleAccent,
    ];

    return Container(
      color: const Color(0xFF2D2E31),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          // Basic Colors
          if (_selectedToolIndex != 2)
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: colors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final color = colors[index];
                  final isSelected = _currentColor == color;
                  return GestureDetector(
                    onTap: () => _selectColor(color),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_selectedToolIndex != 2) const SizedBox(height: 12),
          
          // Tools
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToolIcon(Icons.edit, 0, 'Pen'),
              _buildToolIcon(Icons.brush, 1, 'Marker'),
              _buildToolIcon(Icons.cleaning_services_outlined, 2, 'Eraser'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, int index, String label) {
    final isSelected = _selectedToolIndex == index;
    return GestureDetector(
      onTap: () => _selectTool(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              color: isSelected ? Colors.blueAccent : Colors.grey,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
