import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/cubits/field_trainer_cubit/getField_cubit.dart';
import 'package:Athlify/cubits/field_trainer_cubit/getField_state.dart';
import 'package:Athlify/widget/Filterchip.dart';
import 'package:Athlify/widget/trainercard.dart';

class TrainersTab extends StatefulWidget {
  @override
  State<TrainersTab> createState() => _TrainersTabState();
}

class _TrainersTabState extends State<TrainersTab> {
  String selectedType = 'All';

  @override
  void initState() {
    super.initState();
    // Fetch trainers based on the initial 'All' type
    BlocProvider.of<getFieldsCubit>(context).getTrainers(type: selectedType);
  }

  void onFilterChanged(String type) {
    setState(() {
      selectedType = type;
    });
    // Fetch trainers based on the selected type
    BlocProvider.of<getFieldsCubit>(context).getTrainers(type: selectedType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Clubsfilterchip(
                      isSelected: selectedType == 'All',
                      label: "All",
                      onSelected: () => onFilterChanged('All'),
                    ),
                    Clubsfilterchip(
                      isSelected: selectedType == 'Football',
                      label: "Football",
                      onSelected: () => onFilterChanged('Football'),
                    ),
                    Clubsfilterchip(
                      isSelected: selectedType == 'Tennis',
                      label: "Tennis",
                      onSelected: () => onFilterChanged('Tennis'),
                    ),
                    Clubsfilterchip(
                      isSelected: selectedType == 'Basketball',
                      label: "Basketball",
                      onSelected: () => onFilterChanged('Basketball'),
                    ),
                    Clubsfilterchip(
                      isSelected: selectedType == 'Paddle',
                      label: "Paddle",
                      onSelected: () => onFilterChanged('Paddle'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Recently added",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SecondaryColor,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<getFieldsCubit, getFieldState>(
                  builder: (context, state) {
                    if (state is getFieldsFailure) {
                      return Center(child: Text("Failed to load trainers"));
                    } else if (state is getFieldsSuccess) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await BlocProvider.of<getFieldsCubit>(context)
                              .getTrainers(type: selectedType);
                        },
                        color: PrimaryColor,
                        backgroundColor: Colors.white,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.trainers.length,
                          itemBuilder: (context, index) {
                            return TrainerCardWidget(
                              trainer: state.trainers[index],
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
