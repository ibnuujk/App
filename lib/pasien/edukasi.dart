import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../routes/route_helper.dart';
import '../../providers/article_provider.dart';
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
  String _selectedSubCategory = '';

  // Enhanced category structure with subcategories
  final Map<String, List<String>> _categoryStructure = {
    'Semua Jenis': [],
    'Nutrisi & Gizi': [
      'Makanan Sehat',
      'Vitamin & Suplemen',
      'Diet Kehamilan',
      'Hidrasi',
    ],
    'Perkembangan Janin': [
      'Pertumbuhan',
      'Gerakan Janin',
      'Organ Development',
      'Ukuran Janin',
    ],
    'Tips Kesehatan': [
      'Kesehatan Ibu',
      'Olahraga',
      'Istirahat',
      'Pakaian Hamil',
    ],
    'Pemeriksaan Medis': [
      'Pemeriksaan Rutin',
      'Gejala Normal',
      'Tanda Bahaya',
      'Imunisasi',
    ],
    'Persiapan Persalinan': [
      'Persiapan Fisik',
      'Persiapan Mental',
      'Persiapan Barang',
      'Rencana Persalinan',
    ],
    'Kesehatan Mental': [
      'Stres Kehamilan',
      'Depresi Pasca Melahirkan',
      'Teknik Relaksasi',
      'Dukungan Keluarga',
    ],
    'Olahraga & Aktivitas': [
      'Senam Hamil',
      'Yoga Kehamilan',
      'Berjalan Kaki',
      'Berenang',
    ],
  };

  final List<String> _quickAccessCategories = [
    'Nutrisi & Gizi',
    'Perkembangan Janin',
    'Tips Kesehatan',
    'Pemeriksaan Medis',
    'Persiapan Persalinan',
    'Kesehatan Mental',
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
      _selectedSubCategory = '';
    });
  }

  void _handleSubCategorySelected(String subCategory) {
    setState(() {
      _selectedSubCategory = subCategory;
    });
  }

  List<dynamic> _getFilteredArticles(ArticleProvider articleProvider) {
    List<dynamic> articles = articleProvider.activeArticles;

    // Filter by main category
    if (_selectedCategory != 'Semua Jenis') {
      if (_selectedSubCategory.isNotEmpty) {
        // Filter by subcategory
        articles =
            articles
                .where((article) => article.category == _selectedSubCategory)
                .toList();
      } else {
        // Filter by main category (check if article category matches any subcategory)
        List<String> subCategories =
            _categoryStructure[_selectedCategory] ?? [];
        if (subCategories.isNotEmpty) {
          articles =
              articles
                  .where((article) => subCategories.contains(article.category))
                  .toList();
        } else {
          articles =
              articles
                  .where((article) => article.category == _selectedCategory)
                  .toList();
        }
      }
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
                    (article.keywords != null &&
                        article.keywords.any(
                          (keyword) => keyword.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        )) ||
                    article.category.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return articles;
  }

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: const Color(0xFFEC407A),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Filter Kategori',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Kategori Utama:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _categoryStructure.keys.map((category) {
                          final isSelected = _selectedCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                                _selectedSubCategory = '';
                              });
                              Navigator.pop(context);
                            },
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
                              child: Text(
                                category,
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
                          );
                        }).toList(),
                  ),
                  if (_selectedCategory != 'Semua Jenis' &&
                      _categoryStructure[_selectedCategory]?.isNotEmpty ==
                          true) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Pilih Sub-Kategori:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // "Semua" option
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSubCategory = '';
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _selectedSubCategory.isEmpty
                                      ? const Color(0xFFEC407A)
                                      : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    _selectedSubCategory.isEmpty
                                        ? const Color(0xFFEC407A)
                                        : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Semua',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    _selectedSubCategory.isEmpty
                                        ? Colors.white
                                        : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        // Sub-categories
                        ...(_categoryStructure[_selectedCategory] ?? []).map((
                          subCategory,
                        ) {
                          final isSelected =
                              _selectedSubCategory == subCategory;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSubCategory = subCategory;
                              });
                              Navigator.pop(context);
                            },
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
                              child: Text(
                                subCategory,
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
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSubCategoriesRow() {
    final subCategories = _categoryStructure[_selectedCategory] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Sub Kategori:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _handleSubCategorySelected(''),
              child: Text(
                'Semua',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color:
                      _selectedSubCategory.isEmpty
                          ? const Color(0xFFEC407A)
                          : Colors.grey[500],
                  fontWeight:
                      _selectedSubCategory.isEmpty
                          ? FontWeight.w600
                          : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final subCategory = subCategories[index];
              final isSelected = _selectedSubCategory == subCategory;

              return Container(
                margin: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => _handleSubCategorySelected(subCategory),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFEC407A).withOpacity(0.2)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFFEC407A)
                                : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      subCategory,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? const Color(0xFFEC407A)
                                : Colors.grey[600],
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

        if (filteredArticles.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Article Count and Sort Options
            _buildArticleHeader(filteredArticles.length),

            // Articles List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = filteredArticles[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: ArticleCard(
                      article: article,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteHelper.articleDetail,
                          arguments: {'article': article, 'user': widget.user},
                        );
                      },
                    ),
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
          const Spacer(),
          if (_selectedCategory != 'Semua Jenis' ||
              _selectedSubCategory.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEC407A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEC407A).withOpacity(0.3),
                ),
              ),
              child: Text(
                _selectedSubCategory.isNotEmpty
                    ? _selectedSubCategory
                    : _selectedCategory,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEC407A),
                ),
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
            'Coba ubah filter atau kata kunci pencarian',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'Semua Jenis';
                _selectedSubCategory = '';
                _searchQuery = '';
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

  Widget _buildSearchAndFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Custom Search Bar with Filter Icon
          _buildCustomSearchBar(),
          const SizedBox(height: 16),

          // Sub Categories - Only show when main category is selected
          if (_selectedCategory != 'Semua Jenis' &&
              _categoryStructure[_selectedCategory]?.isNotEmpty == true)
            _buildSubCategoriesRow(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCustomSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          // Search Icon
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Icon(Icons.search, color: Colors.grey[600], size: 24),
          ),
          // Search Text Field
          Expanded(
            child: TextField(
              onChanged: _handleSearch,
              style: GoogleFonts.poppins(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Cari artikel kehamilan...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Filter Icon Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEC407A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFEC407A).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: const Color(0xFFEC407A),
                size: 20,
              ),
              onPressed: _showCategoryFilterDialog,
              tooltip: 'Filter Kategori',
            ),
          ),
        ],
      ),
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
                // Search and Filter Section
                _buildSearchAndFilterSection(),

                const SizedBox(
                  height: 24,
                ), // Add spacing between search and articles
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
