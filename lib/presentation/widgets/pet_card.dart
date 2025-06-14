import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/pet_model.dart';
import '../../../routes/app_routes.dart';

class PetCard extends StatefulWidget {
  final Pet pet;
  final VoidCallback? onFavoriteToggle;

  const PetCard({
    super.key,
    required this.pet,
    this.onFavoriteToggle,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> with TickerProviderStateMixin {
  late final AnimationController _tapController;
  late final AnimationController _favoriteController;
  late final Animation<double> _tapScale;
  late final Animation<double> _favoriteScale;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.pet.isFavorited;

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _tapScale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );

    _favoriteScale = Tween(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _favoriteController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _tapController.forward().then((_) => _tapController.reverse());
    Navigator.pushNamed(context, AppRoutes.petDetails, arguments: widget.pet);
  }

  void _toggleFavorite() {
    HapticFeedback.selectionClick();
    setState(() => _isFavorite = !_isFavorite);
    _favoriteController.forward().then((_) => _favoriteController.reverse());
    widget.onFavoriteToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tapScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _tapScale.value,
          child: GestureDetector(
            onTap: _onTap,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Hero(
                              tag: 'pet-image-${widget.pet.id}',
                              child: Image.network(
                                widget.pet.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.pets,
                                      size: 36, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: AnimatedBuilder(
                              animation: _favoriteScale,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _favoriteScale.value,
                                  child: GestureDetector(
                                    onTap: _toggleFavorite,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _isFavorite
                                            ? Colors.red
                                            : Colors.grey[600],
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        widget.pet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
