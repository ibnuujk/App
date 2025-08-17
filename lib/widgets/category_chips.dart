import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryChips({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                onCategorySelected(category);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: _getCategoryColor(category),
              checkmarkColor: Colors.white,
              elevation: isSelected ? 4 : 1,
              pressElevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              labelStyle: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'All':
        return const Color(0xFF607D8B); // Blue Grey
      case 'Trimester 1':
        return const Color(0xFFE91E63); // Pink
      case 'Trimester 2':
        return const Color(0xFF9C27B0); // Purple
      case 'Trimester 3':
        return const Color(0xFF3F51B5); // Indigo
      default:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }
}
