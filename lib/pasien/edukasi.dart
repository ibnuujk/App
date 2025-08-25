import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';
import '../../routes/route_helper.dart';
import '../../providers/article_provider.dart';
import '../../widgets/article_card.dart';
import '../../services/firebase_service.dart';
import '../../models/article_model.dart';

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
  String _selectedCategory = 'Semua Jenis';
  String _selectedContentType = 'Semua Konten';
  bool _isFilterExpanded = false;
  bool _isHeaderVisible = true; // New variable for header visibility
  late ScrollController _scrollController; // New scroll controller
  late ScrollController
  _contentTypeScrollController; // New scroll controller for content type

  // Firebase service for article interactions
  final FirebaseService _firebaseService = FirebaseService();

  // Streams for liked and bookmarked articles
  Stream<List<String>>? _likedArticleIdsStream;
  Stream<List<String>>? _bookmarkedArticleIdsStream;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController(); // Initialize scroll controller
    _scrollController.addListener(_onScroll); // Add scroll listener
    _contentTypeScrollController =
        ScrollController(); // Initialize content type scroll controller

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

    // Initialize liked and bookmarked article streams
    _likedArticleIdsStream = _firebaseService.getLikedArticleIds(
      widget.user.id,
    );
    _bookmarkedArticleIdsStream = _firebaseService.getBookmarkedArticleIds(
      widget.user.id,
    );

    // Initialize articles when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final articleProvider = context.read<ArticleProvider>();
      print('EdukasiScreen: Starting article initialization...');

      // Initialize articles from Firebase
      articleProvider
          .initializeArticles()
          .then((_) {
            print('EdukasiScreen: Articles initialized from Firebase');
            print(
              'EdukasiScreen: Total articles: ${articleProvider.activeArticles.length}',
            );

            if (mounted) {
              print(
                'EdukasiScreen: Final article count: ${articleProvider.activeArticles.length}',
              );
              setState(() {}); // Trigger rebuild to show articles
            }
          })
          .catchError((error) {
            print('Error initializing articles: $error');
            if (mounted) {
              setState(() {});
            }
          });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // Remove scroll listener
    _scrollController.dispose(); // Dispose scroll controller
    _contentTypeScrollController
        .dispose(); // Dispose content type scroll controller
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show header when scrolling up, hide when scrolling down
    if (_scrollController.position.pixels > 100) {
      if (_isHeaderVisible) {
        setState(() {
          _isHeaderVisible = false;
        });
      }
    } else {
      if (!_isHeaderVisible) {
        setState(() {
          _isHeaderVisible = true;
        });
      }
    }
  }

  void _handleCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _handleContentTypeSelected(String contentType) {
    setState(() {
      _selectedContentType = contentType;
    });
  }

  void _toggleFilterExpansion() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
    });
  }

  void _scrollContentTypeLeft() {
    // Scroll content type filter to the left
    if (_contentTypeScrollController.hasClients) {
      _contentTypeScrollController.animateTo(
        _contentTypeScrollController.offset - 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollContentTypeRight() {
    // Scroll content type filter to the right
    if (_contentTypeScrollController.hasClients) {
      _contentTypeScrollController.animateTo(
        _contentTypeScrollController.offset + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Handle article like action
  Future<void> _handleArticleLike(Article article) async {
    try {
      await _firebaseService.toggleArticleLike(article.id, widget.user.id);
      // The UI will automatically update through the stream
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Handle article bookmark action
  Future<void> _handleArticleBookmark(Article article) async {
    try {
      await _firebaseService.toggleArticleBookmark(article.id, widget.user.id);
      // The UI will automatically update through the stream
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Get filtered articles with like and bookmark status
  List<dynamic> _getFilteredArticles(ArticleProvider articleProvider) {
    try {
      List<dynamic> articles = articleProvider.activeArticles;

      print(
        '_getFilteredArticles: Total articles available: ${articles.length}',
      );
      print('_getFilteredArticles: Selected category: "$_selectedCategory"');
      print(
        '_getFilteredArticles: Selected content type: "$_selectedContentType"',
      );

      // Filter by category
      if (_selectedCategory != 'Semua Jenis') {
        articles =
            articles
                .where((article) => article.category == _selectedCategory)
                .toList();
        print(
          '_getFilteredArticles: After category filter: ${articles.length} articles',
        );
      }

      // Filter by content type (based on article title/content patterns)
      if (_selectedContentType != 'Semua Konten') {
        articles =
            articles.where((article) {
              final title = article.title?.toLowerCase() ?? '';
              final content = article.description?.toLowerCase() ?? '';

              switch (_selectedContentType) {
                case 'Nutrisi & Gizi':
                  return title.contains('nutrisi') ||
                      title.contains('gizi') ||
                      content.contains('nutrisi') ||
                      content.contains('gizi');
                case 'Perkembangan Janin':
                  return title.contains('perkembangan') ||
                      title.contains('janin') ||
                      content.contains('perkembangan') ||
                      content.contains('janin');
                case 'Tips Kesehatan':
                  return title.contains('tips') ||
                      title.contains('kesehatan') ||
                      content.contains('tips') ||
                      content.contains('kesehatan');
                case 'Pemeriksaan Medis':
                  return title.contains('pemeriksaan') ||
                      title.contains('medis') ||
                      content.contains('pemeriksaan') ||
                      content.contains('medis');
                case 'Persiapan Persalinan':
                  return title.contains('persiapan') ||
                      title.contains('persalinan') ||
                      content.contains('persiapan') ||
                      content.contains('persalinan');
                case 'Kesehatan Mental':
                  return title.contains('mental') ||
                      title.contains('emosi') ||
                      content.contains('mental') ||
                      content.contains('emosi');
                case 'Olahraga & Aktivitas':
                  return title.contains('olahraga') ||
                      title.contains('aktivitas') ||
                      content.contains('olahraga') ||
                      content.contains('aktivitas');
                default:
                  return true;
              }
            }).toList();
        print(
          '_getFilteredArticles: After content type filter: ${articles.length} articles',
        );
      }

      print('_getFilteredArticles: Final result: ${articles.length} articles');
      return articles;
    } catch (e) {
      print('Error in _getFilteredArticles: $e');
      return [];
    }
  }

  Widget _buildArticlesSection() {
    return Consumer<ArticleProvider>(
      builder: (context, articleProvider, child) {
        if (articleProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEC407A)),
            ),
          );
        }

        if (articleProvider.error != null) {
          return _buildErrorState(articleProvider);
        }

        final filteredArticles = _getFilteredArticles(articleProvider);

        print(
          '_buildArticlesSection: Provider has ${articleProvider.activeArticles.length} articles',
        );
        print(
          '_buildArticlesSection: Filtered articles: ${filteredArticles.length}',
        );
        print('_buildArticlesSection: Selected category: "$_selectedCategory"');
        print(
          '_buildArticlesSection: Selected content type: "$_selectedContentType"',
        );

        if (filteredArticles.isEmpty) {
          // Check if there are no articles at all
          if (articleProvider.activeArticles.length == 0) {
            print(
              '_buildArticlesSection: No articles in provider, showing no articles state',
            );
            return _buildNoArticlesState();
          }
          // Check if it's due to filters
          if (_selectedCategory != 'Semua Jenis' ||
              _selectedContentType != 'Semua Konten') {
            print(
              '_buildArticlesSection: No articles found for current filters, showing empty state',
            );
            return _buildEmptyState();
          }
          // If no articles and no filters, show no articles state
          print(
            '_buildArticlesSection: No articles and no filters, showing no articles state',
          );
          return _buildNoArticlesState();
        }

        return Column(
          children: [
            // Article Count
            _buildArticleHeader(filteredArticles.length),

            // Articles List
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // Add scroll controller here
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = filteredArticles[index];
                  return StreamBuilder<List<String>>(
                    stream: _likedArticleIdsStream,
                    builder: (context, likedSnapshot) {
                      return StreamBuilder<List<String>>(
                        stream: _bookmarkedArticleIdsStream,
                        builder: (context, bookmarkedSnapshot) {
                          // Create article with current like and bookmark status
                          final currentArticle = article.copyWith(
                            isLiked:
                                likedSnapshot.data?.contains(article.id) ??
                                false,
                            isBookmarked:
                                bookmarkedSnapshot.data?.contains(article.id) ??
                                false,
                          );

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ArticleCard(
                              article: currentArticle,
                              onTap: () async {
                                // Check if article has website URL
                                if (currentArticle.websiteUrl.isNotEmpty) {
                                  // Open website URL directly
                                  try {
                                    final url = Uri.parse(
                                      currentArticle.websiteUrl,
                                    );
                                    // Use url_launcher to open website
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Tidak dapat membuka website: ${currentArticle.websiteUrl}',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'URL tidak valid: ${currentArticle.websiteUrl}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } else {
                                  // Navigate to article detail if no website URL
                                  final result = await Navigator.pushNamed(
                                    context,
                                    RouteHelper.articleDetail,
                                    arguments: {
                                      'article': currentArticle,
                                      'user': widget.user,
                                    },
                                  );

                                  // Refresh article status when returning from detail
                                  if (result == true) {
                                    setState(() {
                                      // This will trigger a rebuild and refresh the streams
                                    });
                                  }
                                }
                              },
                              onLike: () => _handleArticleLike(currentArticle),
                              onBookmark:
                                  () => _handleArticleBookmark(currentArticle),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArticleHeader(int articleCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.article, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Text(
            '$articleCount artikel ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ArticleProvider articleProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
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
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
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

  Widget _buildNoArticlesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada artikel tersedia',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Artikel akan tersedia setelah admin membuat konten edukasi',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final articleProvider = context.read<ArticleProvider>();
              articleProvider.initializeArticles();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC407A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Refresh',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
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
            'Coba ubah filter yang dipilih',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'Semua Jenis';
                _selectedContentType = 'Semua Konten';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC407A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Reset Filter',
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

  Widget _buildFilterSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isHeaderVisible ? null : 0,
      child:
          _isHeaderVisible
              ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Header Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC407A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.school, color: Colors.white, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'Edukasi Kehamilan',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Temukan informasi lengkap tentang kehamilan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Filter Toggle Button
                    _buildFilterToggleButton(),

                    // Filter Options - Expandable
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isFilterExpanded ? null : 0,
                      child:
                          _isFilterExpanded
                              ? _buildFilterOptions()
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterToggleButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _toggleFilterExpansion,
        icon: Icon(
          _isFilterExpanded
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down,
          color: Colors.white,
        ),
        label: Text(
          _isFilterExpanded ? 'Sembunyikan Filter' : 'Tampilkan Filter',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[600],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filter - Horizontal scrollable chips
          _buildHorizontalFilterChips(
            title: 'Kategori',
            options: [
              'Semua Jenis',
              'Trimester 1',
              'Trimester 2',
              'Trimester 3',
            ],
            selectedValue: _selectedCategory,
            onSelected: _handleCategorySelected,
          ),
          const SizedBox(height: 16),

          // Content Type Filter - With navigation buttons
          _buildContentTypeFilterWithNavigation(),

          // Active Filters Summary
          if (_selectedCategory != 'Semua Jenis' ||
              _selectedContentType != 'Semua Konten')
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC), // Soft pink background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF8BBD9),
                ), // Light pink border
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: const Color(0xFFE91E63),
                    size: 16,
                  ), // Pink icon
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filter Aktif: ${_getActiveFiltersText()}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFC2185B), // Dark pink text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'Semua Jenis';
                        _selectedContentType = 'Semua Konten';
                      });
                    },
                    child: Text(
                      'Reset',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFE91E63), // Pink button text
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentTypeFilterWithNavigation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Konten',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Left Navigation Button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: IconButton(
                onPressed: _scrollContentTypeLeft,
                icon: Icon(
                  Icons.chevron_left,
                  color: Colors.grey[600],
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 8),

            // Content Type Chips Container
            Expanded(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _contentTypeScrollController,
                  itemCount: _getContentTypeOptions().length,
                  itemBuilder: (context, index) {
                    final option = _getContentTypeOptions()[index];
                    final isSelected = _selectedContentType == option;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _handleContentTypeSelected(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xFFEC407A)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFFEC407A)
                                      : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Right Navigation Button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: IconButton(
                onPressed: _scrollContentTypeRight,
                icon: Icon(
                  Icons.chevron_right,
                  color: Colors.grey[600],
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<String> _getContentTypeOptions() {
    return [
      'Semua Konten',
      'Nutrisi & Gizi',
      'Perkembangan Janin',
      'Tips Kesehatan',
      'Pemeriksaan Medis',
      'Persiapan Persalinan',
      'Kesehatan Mental',
      'Olahraga & Aktivitas',
    ];
  }

  String _getActiveFiltersText() {
    List<String> activeFilters = [];
    if (_selectedCategory != 'Semua Jenis') {
      activeFilters.add(_selectedCategory);
    }
    if (_selectedContentType != 'Semua Konten') {
      activeFilters.add(_selectedContentType);
    }
    return activeFilters.join(', ');
  }

  Widget _buildHorizontalFilterChips({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selectedValue == option;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelected(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFEC407A)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFFEC407A)
                                : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
                // Filter Section
                _buildFilterSection(),
                const SizedBox(height: 16), // Reduced spacing
                // Articles Section
                Expanded(child: _buildArticlesSection()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
