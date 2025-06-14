import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/pet_bloc.dart';
import 'package:posha/logic/bloc/pet_state.dart';
import 'package:posha/logic/bloc/pet_event.dart';
import '../../widgets/pet_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _searchScaleAnimation;
  late Animation<double> _listFadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Dogs',
    'Cats',
    'Birds',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupSearchFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimationSequence();
      context.read<PetBloc>().add(LoadPetsEvent());
    });
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    ));

    _searchScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.bounceOut,
    ));

    _listFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupSearchFocus() {
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  void _startAnimationSequence() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _searchAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _searchAnimationController.dispose();
    _listAnimationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<PetBloc>().add(SearchPetEvent(query));
  }

  void _handleFilterChange(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF667eea),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAnimatedHeader(),
              _buildAnimatedSearchSection(),
              _buildFilterChips(),
              _buildAnimatedPetList(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAnimatedFAB(),
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _headerSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Your',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Text(
                        'Perfect Companion',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSearchSection() {
    return AnimatedBuilder(
      animation: _searchScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _searchScaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: _isSearchFocused ? 16 : 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isSearchFocused
                      ? const Color(0xFF667eea)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.search,
                      color: _isSearchFocused
                          ? const Color(0xFF667eea)
                          : Colors.grey[400],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search for your perfect pet...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: _handleSearch,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _handleSearch('');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _selectedFilter == option;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF667eea),
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _handleFilterChange(option),
              selectedColor: const Color(0xFF667eea),
              backgroundColor: Colors.white,
              elevation: isSelected ? 8 : 2,
              shadowColor: const Color(0xFF667eea).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color:
                      isSelected ? Colors.transparent : const Color(0xFF667eea),
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedPetList() {
    return Expanded(
      child: AnimatedBuilder(
        animation: _listFadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _listFadeAnimation.value,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<PetBloc>().add(LoadPetsEvent());
                },
                color: const Color(0xFF667eea),
                child: BlocBuilder<PetBloc, PetState>(
                  builder: (context, state) {
                    if (state is PetLoadingState) {
                      return _buildLoadingState();
                    } else if (state is PetLoadedState) {
                      if (state.pets.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildPetGrid(state.pets);
                    } else if (state is PetErrorState) {
                      return _buildErrorState(state.message);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Finding amazing pets for you...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets,
              size: 64,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No pets found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<PetBloc>().add(LoadPetsEvent()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetGrid(List pets) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: PetCard(
                  pet: pets[index],
                  onFavoriteToggle: () {
                    context
                        .read<PetBloc>()
                        .add(ToggleFavoriteEvent(pets[index].id));
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedFAB() {
    return FloatingActionButton.extended(
      onPressed: () => context.read<PetBloc>().add(LoadPetsEvent()),
      backgroundColor: const Color(0xFF667eea),
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.refresh),
      label: const Text(
        'Refresh',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
