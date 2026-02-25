import 'package:flutter/material.dart';


// TODO: In the future, connect this page to real feedback data (e.g., via Provider, Bloc, or direct API call)
class FeedbackDetailPage extends StatelessWidget {
  final String courseName;
  const FeedbackDetailPage({Key? key, required this.courseName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Feedback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use courseName passed from CourseDetailsPage
              // Use the courseName passed from CourseDetailPage
              Text(
                courseName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            _RatingSummary(),
            const SizedBox(height: 24),
            const Text(
              'Common themes',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _CommonThemes(),
            const SizedBox(height: 24),
            const Text(
              'Reviews',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _ReviewList(),
          ],
        ),
      ),
    );
  }
}

// TODO: Replace with a widget that takes rating summary data from backend or state
class _RatingSummary extends StatelessWidget {
  const _RatingSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '4.5',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.star, color: Colors.amber, size: 32),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Based on 47 reviews',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 5; i >= 1; i--)
                Row(
                  children: [
                    Text('$i', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(
                        // TODO: Replace hardcoded rating distribution with real data
                        value: [0.6, 0.2, 0.1, 0.05, 0.05][5 - i],
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// TODO: Replace with a widget that takes common themes from backend or state
class _CommonThemes extends StatelessWidget {
  const _CommonThemes();

  @override
  Widget build(BuildContext context) {
    // TODO: Replace hardcoded themes with data from backend or state
    final themes = [
      'Exam heavy (22)',
      'Project based (31)',
      'Great lecturer (28)',
      'Lots of coding (19)',
      'Challenging (15)',
      'Practical (25)',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: themes
          .map((theme) => Chip(
                label: Text(theme, style: const TextStyle(fontSize: 13)),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ))
          .toList(),
    );
  }
}

class _ReviewList extends StatelessWidget {
  // TODO: Replace hardcoded reviews with data fetched from backend or state
  final List<_Review> reviews = const [
    _Review(
      name: 'Sarah M.',
      date: 'Oct 2024',
      rating: 5,
      comment:
          'Excellent course! The projects were challenging but very rewarding. The professor explains concepts clearly and provides great feedback.',
    ),
    _Review(
      name: 'James K.',
      date: 'Sep 2024',
      rating: 4,
      comment:
          'Very practical course with real-world applications. The workload is heavy but manageable if you stay on top of assignments.',
    ),
    _Review(
      name: 'Emma L.',
      date: 'Sep 2024',
      rating: 5,
      comment:
          'One of the best courses I’ve taken! Great balance between theory and practice. The final project was especially helpful.',
    ),
  ];

  _ReviewList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reviews
          .map((review) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ReviewCard(review: review),
              ))
          .toList(),
    );
  }
}

class _Review {
  final String name;
  final String date;
  final int rating;
  final String comment;

  const _Review({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
  });
}

class _ReviewCard extends StatelessWidget {
  final _Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                child: Text(
                  review.name[0],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      review.date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
