import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:doctor_app/providers/language_provider.dart';
import 'package:doctor_app/core/theme/app_theme.dart';
import 'package:doctor_app/widgets/enhanced_card.dart';
import 'package:doctor_app/widgets/enhanced_buttons.dart';
import 'package:doctor_app/models/doctor.dart';

class ReviewsScreen extends StatefulWidget {
  final Doctor doctor;

  const ReviewsScreen({super.key, required this.doctor});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Review> _reviews = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadReviews();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadReviews() {
    setState(() {
      _isLoading = true;
    });

    // Mock reviews - replace with actual API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _reviews = [
            Review(
              id: '1',
              patientName: 'أحمد محمد',
              rating: 5,
              comment:
                  'طبيب ممتاز ومتفهم. شرح لي حالتي بوضوح وقدم العلاج المناسب.',
              date: DateTime.now().subtract(const Duration(days: 2)),
              isVerified: true,
            ),
            Review(
              id: '2',
              patientName: 'فاطمة علي',
              rating: 4,
              comment:
                  'خدمة جيدة وسريعة. الطبيب محترف ولكن كان يمكن أن يكون أكثر تفصيلاً في الشرح.',
              date: DateTime.now().subtract(const Duration(days: 5)),
              isVerified: true,
            ),
            Review(
              id: '3',
              patientName: 'محمد حسن',
              rating: 5,
              comment: 'أفضل طبيب تعاملت معه. دقيق في التشخيص ومتابعة ممتازة.',
              date: DateTime.now().subtract(const Duration(days: 8)),
              isVerified: false,
            ),
            Review(
              id: '4',
              patientName: 'سارة أحمد',
              rating: 3,
              comment: 'الطبيب جيد لكن وقت الانتظار كان طويلاً.',
              date: DateTime.now().subtract(const Duration(days: 12)),
              isVerified: true,
            ),
            Review(
              id: '5',
              patientName: 'عبدالله خالد',
              rating: 5,
              comment:
                  'ممتاز في التعامل مع الأطفال. ابني كان مرتاحاً جداً معه.',
              date: DateTime.now().subtract(const Duration(days: 15)),
              isVerified: true,
            ),
          ];
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    final filteredReviews = _getFilteredReviews();

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(isRTL ? 'التقييمات والمراجعات' : 'Reviews & Ratings'),
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'all',
                    child: Text(isRTL ? 'الكل' : 'All'),
                  ),
                  PopupMenuItem(
                    value: '5',
                    child: Text(isRTL ? '5 نجوم' : '5 Stars'),
                  ),
                  PopupMenuItem(
                    value: '4',
                    child: Text(isRTL ? '4 نجوم' : '4 Stars'),
                  ),
                  PopupMenuItem(
                    value: '3',
                    child: Text(isRTL ? '3 نجوم' : '3 Stars'),
                  ),
                  PopupMenuItem(
                    value: 'verified',
                    child: Text(isRTL ? 'المتحقق منها' : 'Verified Only'),
                  ),
                ],
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                _loadReviews();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Rating Summary
                    _buildRatingSummary(isRTL),
                    const SizedBox(height: 24),

                    // Rating Distribution
                    _buildRatingDistribution(isRTL),
                    const SizedBox(height: 24),

                    // Reviews List
                    _buildReviewsList(filteredReviews, isRTL),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReviewDialog(isRTL),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.rate_review, color: AppTheme.textLight),
        label: Text(
          isRTL ? 'إضافة تقييم' : 'Add Review',
          style: const TextStyle(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummary(bool isRTL) {
    final averageRating = _calculateAverageRating();
    final totalReviews = _reviews.length;

    return EnhancedCard(
      child: Column(
        children: [
          Row(
            children: [
              // Doctor Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryBlue,
                child:
                    widget.doctor.profilePicture != null
                        ? ClipOval(
                          child: Image.network(
                            widget.doctor.profilePicture!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: AppTheme.textLight,
                                size: 40,
                              );
                            },
                          ),
                        )
                        : const Icon(
                          Icons.person,
                          color: AppTheme.textLight,
                          size: 40,
                        ),
              ),
              const SizedBox(width: 20),

              // Rating Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doctor.user.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.doctor.specialization,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningYellow,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStarRating(averageRating),
                            const SizedBox(height: 4),
                            Text(
                              '$totalReviews ${isRTL ? 'تقييم' : 'reviews'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'توزيع التقييمات' : 'Rating Distribution',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(5, (index) {
            final rating = 5 - index;
            final count = _reviews.where((r) => r.rating == rating).length;
            final percentage = _reviews.isEmpty ? 0.0 : count / _reviews.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '$rating',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star,
                    color: AppTheme.warningYellow,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.warningYellow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$count',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsList(List<Review> reviews, bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isRTL ? 'المراجعات' : 'Reviews',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (_selectedFilter != 'all')
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'all';
                  });
                },
                child: Text(isRTL ? 'عرض الكل' : 'Show All'),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (reviews.isEmpty)
          _buildEmptyState(isRTL)
        else
          ...reviews.map((review) => _buildReviewCard(review, isRTL)),
      ],
    );
  }

  Widget _buildReviewCard(Review review, bool isRTL) {
    return EnhancedCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  review.patientName.substring(0, 1),
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.patientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (review.isVerified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified,
                                  color: AppTheme.primaryGreen,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isRTL ? 'متحقق' : 'Verified',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStarRating(review.rating.toDouble()),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd, yyyy').format(review.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : index < rating
              ? Icons.star_half
              : Icons.star_border,
          color: AppTheme.warningYellow,
          size: 16,
        );
      }),
    );
  }

  Widget _buildEmptyState(bool isRTL) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'لا توجد مراجعات' : 'No reviews yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRTL
                ? 'كن أول من يقيم هذا الطبيب'
                : 'Be the first to review this doctor',
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  List<Review> _getFilteredReviews() {
    switch (_selectedFilter) {
      case 'verified':
        return _reviews.where((r) => r.isVerified).toList();
      case '5':
      case '4':
      case '3':
        final rating = int.parse(_selectedFilter);
        return _reviews.where((r) => r.rating == rating).toList();
      default:
        return _reviews;
    }
  }

  double _calculateAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return total / _reviews.length;
  }

  void _showAddReviewDialog(bool isRTL) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                isRTL ? 'إضافة تقييم' : 'Add Review',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? 'تقييمك للطبيب' : 'Your rating',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedRating = index + 1;
                          });
                        },
                        child: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: AppTheme.warningYellow,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isRTL ? 'تعليقك (اختياري)' : 'Your comment (optional)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          isRTL
                              ? 'شاركنا تجربتك مع الطبيب...'
                              : 'Share your experience with the doctor...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    isRTL ? 'إلغاء' : 'Cancel',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _submitReview(selectedRating, commentController.text);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isRTL ? 'إرسال' : 'Submit',
                    style: const TextStyle(color: AppTheme.textLight),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitReview(int rating, String comment) {
    final newReview = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: 'أنت', // Replace with actual patient name
      rating: rating,
      comment: comment.isEmpty ? 'تقييم بدون تعليق' : comment,
      date: DateTime.now(),
      isVerified: true,
    );

    setState(() {
      _reviews.insert(0, newReview);
    });

    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL ? 'تم إرسال التقييم بنجاح' : 'Review submitted successfully',
        ),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}

// Review Model
class Review {
  final String id;
  final String patientName;
  final int rating;
  final String comment;
  final DateTime date;
  final bool isVerified;

  Review({
    required this.id,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.isVerified,
  });
}
