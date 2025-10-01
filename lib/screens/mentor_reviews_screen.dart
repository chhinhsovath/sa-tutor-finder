import 'package:flutter/material.dart';

class MentorReviewsScreen extends StatelessWidget {
  final String mentorId;
  final String mentorName;

  const MentorReviewsScreen({
    super.key,
    required this.mentorId,
    required this.mentorName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Reviews'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Rating summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall rating
                  Column(
                    children: [
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < 4 ? Icons.star : Icons.star_border,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '124 reviews',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),

                  // Rating distribution
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar(5, 0.75, '75%', theme),
                        _buildRatingBar(4, 0.15, '15%', theme),
                        _buildRatingBar(3, 0.05, '5%', theme),
                        _buildRatingBar(2, 0.03, '3%', theme),
                        _buildRatingBar(1, 0.02, '2%', theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reviews list
            ..._buildReviews(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage, String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            stars.toString(),
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6,
                backgroundColor: theme.brightness == Brightness.light
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF374151),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReviews(ThemeData theme) {
    final reviews = [
      Review(
        authorName: 'Ethan Carter',
        authorAvatar: 'EC',
        timeAgo: '2 weeks ago',
        rating: 5,
        content: 'Absolutely fantastic mentor! Alex helped me understand complex concepts in physics with ease. Their teaching style is engaging and tailored to my learning pace. Highly recommend!',
        likes: 12,
        dislikes: 2,
      ),
      Review(
        authorName: 'Sophia Bennett',
        authorAvatar: 'SB',
        timeAgo: '1 month ago',
        rating: 4,
        content: 'Alex is a great mentor, very knowledgeable and patient. They helped me improve my math skills significantly. However, sometimes the sessions felt a bit rushed.',
        likes: 8,
        dislikes: 1,
      ),
      Review(
        authorName: 'Liam Harper',
        authorAvatar: 'LH',
        timeAgo: '2 months ago',
        rating: 5,
        content: 'Alex is an exceptional mentor! Their expertise in chemistry is evident, and they explain concepts clearly. I appreciate their dedication and support. Highly recommend!',
        likes: 15,
        dislikes: 3,
      ),
    ];

    return reviews.map((review) => _buildReviewCard(review, theme)).toList();
  }

  Widget _buildReviewCard(Review review, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  review.authorAvatar,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      review.timeAgo,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating stars
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Review content
          Text(
            review.content,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          // Like/dislike buttons
          Row(
            children: [
              InkWell(
                onTap: () {
                  // TODO: Handle like
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        size: 18,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        review.likes.toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  // TODO: Handle dislike
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_down_outlined,
                        size: 18,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        review.dislikes.toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Review {
  final String authorName;
  final String authorAvatar;
  final String timeAgo;
  final int rating;
  final String content;
  final int likes;
  final int dislikes;

  Review({
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
    required this.rating,
    required this.content,
    required this.likes,
    required this.dislikes,
  });
}
