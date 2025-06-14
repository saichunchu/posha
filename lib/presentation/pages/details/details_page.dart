import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:confetti/confetti.dart';
import 'package:hive/hive.dart';
import '../../../data/models/pet_model.dart';
import '../../../logic/bloc/pet_bloc.dart';
import '../../../logic/bloc/pet_event.dart';

class DetailsPage extends StatefulWidget {
  final Pet pet;
  const DetailsPage({super.key, required this.pet});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _heartAnimationController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _heartScaleAnimation;

  late Pet _currentPet;
  late bool _isFavorite;
  bool _showFullDescription = false;
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  // Hive boxes
  Box<Pet>? _petBox;
  Box<dynamic>? _preferencesBox;

  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeControllers();
    _init();
  }

  Future<void> _init() async {
    await _initializeHiveBoxes();
    _initializePetData();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
    _startAnimations();
  }

  Future<void> _initializeHiveBoxes() async {
    try {
      if (!Hive.isBoxOpen('pets')) {
        await Hive.openBox<Pet>('pets');
      }
      if (!Hive.isBoxOpen('preferences')) {
        await Hive.openBox('preferences');
      }

      _petBox = Hive.box<Pet>('pets');
      _preferencesBox = Hive.box('preferences');
    } catch (e) {
      debugPrint('Error opening Hive boxes: $e');
    }
  }

  void _initializePetData() {
    _currentPet = widget.pet;

    // Get saved preferences from Hive
    final petId = _currentPet.id;
    final savedFavorite = _preferencesBox?.get('favorite_$petId',
        defaultValue: _currentPet.isFavorited);
    final savedAdopted = _preferencesBox?.get('adopted_$petId',
        defaultValue: _currentPet.isAdopted);

    // Update current pet with saved data
    _currentPet = _currentPet.copyWith(
      isFavorited:
          savedFavorite is bool ? savedFavorite : _currentPet.isFavorited,
      isAdopted: savedAdopted is bool ? savedAdopted : _currentPet.isAdopted,
    );

    _isFavorite = _currentPet.isFavorited;
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.bounceOut,
    ));

    _heartScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeControllers() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  void _startAnimations() {
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _buttonAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _buttonAnimationController.dispose();
    _heartAnimationController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    if (!mounted) return;

    final petId = _currentPet.id;
    final newFavoriteStatus = !_isFavorite;

    try {
      // Update local state immediately for better UX
      setState(() {
        _isFavorite = newFavoriteStatus;
        _currentPet = _currentPet.copyWith(isFavorited: newFavoriteStatus);
      });

      // Save to Hive
      await _preferencesBox?.put('favorite_$petId', newFavoriteStatus);

      // Update pet in pet box if it exists
      if (_petBox?.containsKey(petId) ?? false) {
        final updatedPet = _currentPet.copyWith(isFavorited: newFavoriteStatus);
        await _petBox?.put(petId, updatedPet);
      }

      // Trigger heart animation
      _heartAnimationController.forward().then((_) {
        if (mounted) _heartAnimationController.reverse();
      });

      if (mounted) {
        context.read<PetBloc>().add(ToggleFavoriteEvent(petId));
        context.read<PetBloc>().add(LoadPetsEvent());
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');

      if (mounted) {
        setState(() {
          _isFavorite = !newFavoriteStatus;
          _currentPet = _currentPet.copyWith(isFavorited: !newFavoriteStatus);
        });
      }
    }
  }

  void _handleAdoption(BuildContext context) async {
    if (_currentPet.isAdopted || !mounted) return;

    final petId = _currentPet.id;

    try {
      setState(() {
        _currentPet = _currentPet.copyWith(isAdopted: true);
      });

      await _preferencesBox?.put('adopted_$petId', true);

      if (_petBox?.containsKey(petId) ?? false) {
        final updatedPet = _currentPet.copyWith(isAdopted: true);
        await _petBox?.put(petId, updatedPet);
      }

      _confettiController.play();
      _showAdoptionSuccessDialog(context);

      if (mounted) {
        context.read<PetBloc>().add(AdoptPetEvent(petId));
        context.read<PetBloc>().add(LoadPetsEvent());
      }
    } catch (e) {
      debugPrint('Error adopting pet: $e');

      if (mounted) {
        setState(() {
          _currentPet = _currentPet.copyWith(isAdopted: false);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to adopt pet. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAdoptionSuccessDialog(BuildContext context) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TweenAnimationBuilder(
        duration: const Duration(milliseconds: 500),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "🎉 Congratulations!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You've successfully adopted ${_currentPet.name}!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Awesome!",
                      style: TextStyle(fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: _buildPetDetails(),
              ),
            ],
          ),
          _buildFloatingAdoptButton(),
          _buildConfettiWidget(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedBuilder(
            animation: _heartScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _heartScaleAnimation.value,
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'pet_${_currentPet.id}',
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: _buildImageCarousel(),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = [
      _currentPet.imageUrl,
      _currentPet.imageUrl,
      _currentPet.imageUrl
    ];

    return Stack(
      children: [
        PageView.builder(
          controller: _imagePageController,
          onPageChanged: (index) {
            if (mounted) {
              setState(() {
                _currentImageIndex = index;
              });
            }
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return PhotoView(
              imageProvider: NetworkImage(images[index]),
              loadingBuilder: (context, event) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  ),
                ),
              ),
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPetDetails() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPetHeader(),
              const SizedBox(height: 24),
              _buildPetStats(),
              const SizedBox(height: 24),
              _buildDescription(),
              const SizedBox(height: 24),
              _buildOwnerInfo(),
              const SizedBox(height: 24),
              _buildAdditionalInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentPet.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _currentPet.isAdopted
                            ? Colors.green.withOpacity(0.1)
                            : const Color(0xFF667eea).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _currentPet.isAdopted
                              ? Colors.green.withOpacity(0.3)
                              : const Color(0xFF667eea).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _currentPet.isAdopted ? 'Adopted' : 'Available',
                        style: TextStyle(
                          color: _currentPet.isAdopted
                              ? Colors.green
                              : const Color(0xFF667eea),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'Vaccinated',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!_currentPet.isAdopted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                "₹${_currentPet.price.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPetStats() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFF764ba2).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF667eea).withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              Icons.cake,
              "${_currentPet.age} year${_currentPet.age > 1 ? 's' : ''}",
              "Age",
            ),
            _buildStatDivider(),
            _buildStatItem(
              Icons.monitor_weight,
              "12 kg",
              "Weight",
            ),
            _buildStatDivider(),
            _buildStatItem(
              Icons.male,
              "Male",
              "Gender",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667eea),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildDescription() {
    final description =
        "Meet ${_currentPet.name}, a lovable and energetic companion who's looking for their forever home! This adorable pet is well-trained, friendly with children, and loves to play. They're up to date on all vaccinations and ready to bring joy to your family.";

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
              maxLines: _showFullDescription ? null : 3,
              overflow: _showFullDescription ? null : TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _showFullDescription = !_showFullDescription;
              });
            },
            child: Text(
              _showFullDescription ? "Show less" : "Read more",
              style: const TextStyle(
                color: Color(0xFF667eea),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF667eea),
              child: const Text(
                "JD",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "John Doe",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Pet Owner",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.message,
                  color: Color(0xFF667eea),
                ),
                onPressed: () {
                  // Handle message action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message feature coming soon!'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Additional Information",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.home, "House Trained", "Yes"),
          _buildInfoRow(Icons.child_care, "Good with Kids", "Yes"),
          _buildInfoRow(Icons.pets, "Good with Pets", "Yes"),
          _buildInfoRow(Icons.medical_services, "Health Status", "Excellent"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF667eea),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAdoptButton() {
    return Positioned(
      bottom: 30,
      left: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _buttonScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _currentPet.isAdopted
                        ? Colors.grey.withOpacity(0.3)
                        : const Color(0xFF667eea).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _currentPet.isAdopted
                    ? null
                    : () => _handleAdoption(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentPet.isAdopted
                      ? Colors.grey[400]
                      : const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentPet.isAdopted
                          ? Icons.check_circle
                          : Icons.volunteer_activism,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _currentPet.isAdopted
                          ? "Already Adopted"
                          : "Adopt ${_currentPet.name}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfettiWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        gravity: 0.3,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        colors: const [
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Colors.pink,
          Colors.amber,
          Colors.green,
        ],
      ),
    );
  }
}
