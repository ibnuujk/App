import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../routes/route_helper.dart';
import '../../providers/article_provider.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/article_card.dart';

class EdukasiScreen extends StatefulWidget {
  final UserModel user;

  const EdukasiScreen({super.key, required this.user});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _searchQuery = '';
  String _selectedCategory = 'Semua Jenis';
  List<String> _categories = [
    'Semua Jenis',
    'Trimester 1',
    'Trimester 2',
    'Trimester 3',
    'Nutrisi',
    'Perkembangan Janin',
    'Tips Kehamilan',
    'Kesehatan',
    'Persiapan Persalinan',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Initialize articles when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().initializeArticles();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _handleClearSearch() {
    setState(() {
      _searchQuery = '';
    });
  }

  void _handleCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  List<dynamic> _getFilteredArticles(ArticleProvider articleProvider) {
    List<dynamic> articles = articleProvider.activeArticles;

    // Filter by category
    if (_selectedCategory != 'Semua Jenis') {
      articles =
          articles
              .where((article) => article.category == _selectedCategory)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      articles =
          articles
              .where(
                (article) =>
                    article.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    article.content.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    article.keywords.any(
                      (keyword) => keyword.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList();
    }

    return articles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Edukasi Kehamilan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Admin panel button for admin users
          if (widget.user.role == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RouteHelper.panelEdukasi,
                  arguments: widget.user,
                );
              },
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                // Header Section with Search and Filter
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEC407A),
                        const Color(0xFFEC407A).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEC407A).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Description
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edukasi Kehamilan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pelajari semua hal tentang kehamilan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Dapatkan informasi lengkap dan akurat tentang kehamilan dari trimester pertama hingga ketiga.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search and Filter Section
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search Bar
                      SearchBarWidget(
                        onSearch: _handleSearch,
                        onClear: _handleClearSearch,
                      ),
                      const SizedBox(height: 16),
                      // Category Chips
                      CategoryChips(
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        onCategorySelected: _handleCategorySelected,
                      ),
                    ],
                  ),
                ),

                // Articles Section
                Expanded(
                  child: Consumer<ArticleProvider>(
                    builder: (context, articleProvider, child) {
                      if (articleProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFEC407A),
                            ),
                          ),
                        );
                      }

                      if (articleProvider.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Terjadi kesalahan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                articleProvider.error!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  articleProvider.clearError();
                                  articleProvider.initializeArticles();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEC407A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  'Coba Lagi',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final filteredArticles = _getFilteredArticles(
                        articleProvider,
                      );

                      if (filteredArticles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada artikel ditemukan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Coba ubah filter atau kata kunci pencarian',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Article Count
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  '${filteredArticles.length} artikel ditemukan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Articles List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: filteredArticles.length,
                              itemBuilder: (context, index) {
                                final article = filteredArticles[index];
                                return ArticleCard(
                                  article: article,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      RouteHelper.articleDetail,
                                      arguments: {'article': article},
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
