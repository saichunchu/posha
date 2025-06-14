import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posha/logic/bloc/pet_bloc.dart';
import 'package:posha/logic/bloc/pet_event.dart';
import 'package:posha/logic/bloc/pet_state.dart';
import '../../widgets/pet_card.dart';
import 'package:posha/routes/app_routes.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      context.read<PetBloc>().add(LoadPetsEvent());
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    const Icon(Icons.favorite, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16)),
                    const Text("Favorites",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetGrid(List pets) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return PetCard(pet: pets[index]);
      },
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: BlocBuilder<PetBloc, PetState>(
          builder: (context, state) {
            if (state is PetLoadingState) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.green));
            } else if (state is PetLoadedState) {
              final favorites =
                  state.pets.where((pet) => pet.isFavorited).toList();

              if (favorites.isEmpty) return _buildEmptyFavorites();
              return _buildPetGrid(favorites);
            } else if (state is PetErrorState) {
              return Center(
                  child: Text("Error: ${state.message}",
                      style: const TextStyle(color: Colors.red)));
            } else {
              return _buildEmptyFavorites();
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("No favorites yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Mark pets as favorites to see them here!",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEF5350), Color(0xFFFFA726)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fadeAnimation,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFEF5350),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
