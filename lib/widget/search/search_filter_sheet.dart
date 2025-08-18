import 'package:Athlify/constant/Constants.dart';
import 'package:flutter/material.dart';

class SearchFilterSheet extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final List<String> allCategories;
  final List<String> selectedCategories;
  final Function(double, double) onPriceChanged;
  final Function(String, bool) onCategoryToggled;

  const SearchFilterSheet({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.allCategories,
    required this.selectedCategories,
    required this.onPriceChanged,
    required this.onCategoryToggled,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late double _min;
  late double _max;
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _min = widget.minPrice;
    _max = widget.maxPrice;
    _selected = List.from(widget.selectedCategories);
  }

  void _onPriceChanged(RangeValues values) {
    setState(() {
      _min = values.start;
      _max = values.end;
    });
    widget.onPriceChanged(_min, _max);
  }

  void _onCategoryToggled(String cat, bool selected) {
    setState(() {
      selected ? _selected.add(cat) : _selected.remove(cat);
    });
    widget.onCategoryToggled(cat, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Filter",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: PrimaryColor)),
          const SizedBox(height: 10),
          const Text(
            "Price Range",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: PrimaryColor, fontSize: 19),
          ),
          RangeSlider(
            activeColor: PrimaryColor,
            inactiveColor: SecondaryContainerText,
            values: RangeValues(_min, _max),
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels('${_min.round()}', '${_max.round()}'),
            onChanged: _onPriceChanged,
          ),
          const SizedBox(height: 10),
          const Text(
            "Categories",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: PrimaryColor, fontSize: 19),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: widget.allCategories.map((cat) {
              return FilterChip(
                backgroundColor: PrimaryColor,
                selectedColor: SecondaryContainerText,
                showCheckmark: false,
                label: Text(
                  cat,
                  style: TextStyle(color: Colors.white),
                ),
                selected: _selected.contains(cat),
                onSelected: (selected) => _onCategoryToggled(cat, selected),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
