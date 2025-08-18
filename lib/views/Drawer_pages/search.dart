import 'dart:async';
import 'package:Athlify/widget/search/search_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/functions/update_delete_club.dart';
import 'package:Athlify/functions/update_delete_trainerCard.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/services/searchService.dart';
import 'package:Athlify/widget/clubcard.dart';
import 'package:Athlify/widget/trainercard.dart';

class SearchPage extends StatefulWidget {
  final String type;

  const SearchPage({super.key, required this.type});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

  List<Trainer> _trainers = [];
  List<ClubModel> _clubs = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _debounce;

  double _minPrice = 0;
  double _maxPrice = 1000;
  List<String> _allCategories = ["Football", "Basketball", "Paddle", "Tennis"];
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _search();
      } else {
        setState(() {
          _trainers.clear();
          _clubs.clear();
        });
      }
    });
  }

  void _search() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Trainer> trainers = [];
      List<ClubModel> clubs = [];

      if (widget.type == 'trainer' || widget.type == 'home') {
        trainers = await _searchService.fetchTrainers(
          query: _searchController.text,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          categories: _selectedCategories,
        );
      }

      if (widget.type == 'club' || widget.type == 'home') {
        clubs = await _searchService.fetchClubs(
          query: _searchController.text,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          categories: _selectedCategories,
        );
      }

      setState(() {
        _trainers = trainers;
        _clubs = clubs;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load results';
      });
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SearchFilterSheet(
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          allCategories: _allCategories,
          selectedCategories: _selectedCategories,
          onPriceChanged: (min, max) {
            setState(() {
              _minPrice = min;
              _maxPrice = max;
            });
            _search(); // ✅ مباشرة
          },
          onCategoryToggled: (category, selected) {
            setState(() {
              selected
                  ? _selectedCategories.add(category)
                  : _selectedCategories.remove(category);
            });
            _search(); // ✅ مباشرة
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(
          child:
              Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    } else if (_clubs.isEmpty &&
        _trainers.isEmpty &&
        _searchController.text.isNotEmpty) {
      return const Center(child: Text('No results found'));
    } else {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((widget.type == 'club' || widget.type == 'home') &&
                _clubs.isNotEmpty) ...[
              const Text('Clubs:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PrimaryColor)),
              const SizedBox(height: 8),
              ..._clubs.map((club) => ClubCardWidget(
                    club: club,
                    onTapDelete: () {
                      showDeleteConfirmationDialog(
                          context: context, club: club);
                    },
                    onTapUpdate: () {
                      showEditClubDialog(context: context, club: club);
                    },
                  )),
              const SizedBox(height: 16),
            ],
            if ((widget.type == 'trainer' || widget.type == 'home') &&
                _trainers.isNotEmpty) ...[
              const Text('Trainers:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PrimaryColor)),
              const SizedBox(height: 8),
              ..._trainers.map((trainer) => TrainerCardWidget(
                    trainer: trainer,
                    onTapDelete: () => showDeleteConfirmationDialogTrainer(
                        context: context, trainer: trainer),
                    onTapUpdate: () => showEditTrainerDialog(
                        context: context, trainer: trainer),
                  )),
            ],
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.primaryDelta! > 10) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            hintText: "Search...",
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _trainers.clear();
                                        _clubs.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _showFilterBottomSheet,
                    icon: const Icon(Icons.filter_alt, color: PrimaryColor),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),
        body: _buildResults(),
      ),
    );
  }
}
