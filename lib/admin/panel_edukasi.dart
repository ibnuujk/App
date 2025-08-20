import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../providers/article_provider.dart';
import '../widgets/article_card.dart';

class PanelEdukasi extends StatefulWidget {
  final UserModel user;

  const PanelEdukasi({Key? key, required this.user}) : super(key: key);

  @override
  State<PanelEdukasi> createState() => _PanelEdukasiState();
}

class _PanelEdukasiState extends State<PanelEdukasi>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _articleCount = 25;
  String _selectedContentType = 'Semua Jenis';
  bool _highQualityOnly = true;
  bool _clearExisting = false;
  bool _isGenerating = false;
  String _selectedCategory = 'Semua Jenis';
  int _selectedFocus = 0; // 0: General, 1: Nutrition, 2: Development, etc.

  final List<String> _contentTypes = [
    'Semua Jenis',
    'Nutrisi & Gizi',
    'Perkembangan Janin',
    'Tips Kesehatan',
    'Pemeriksaan Medis',
    'Persiapan Persalinan',
    'Kesehatan Mental',
    'Olahraga & Aktivitas',
  ];

  final List<String> _focusTypes = [
    'General',
    'Nutrition',
    'Development',
    'Tips',
    'Medical',
    'Preparation',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize articles when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().initializeArticles();
      // Also refresh view counts to ensure accuracy
      context.read<ArticleProvider>().refreshViewCounts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is admin
    if (widget.user.role != 'admin') {
      return Scaffold(
        appBar: AppBar(
          title: Text('Akses Ditolak', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFEC407A),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 80, color: Colors.red[400]),
              const SizedBox(height: 20),
              Text(
                'Akses Ditolak',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hanya admin yang dapat mengakses panel ini',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Panel Edukasi Admin', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'Generator Artikel'),
            Tab(icon: Icon(Icons.list), text: 'Daftar Artikel'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<ArticleProvider>().refreshArticles();
            },
            tooltip: 'Refresh Artikel',
          ),
        ],
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          if (articleProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEC407A)),
              ),
            );
          }

          if (articleProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Terjadi Kesalahan',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[400],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    articleProvider.error!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
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
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Generator Artikel
              _buildGeneratorTab(articleProvider),

              // Tab 2: Daftar Artikel
              _buildArticlesListTab(articleProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGeneratorTab(ArticleProvider articleProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Statistics Section
          _buildStatisticsSection(articleProvider),

          // Enhanced Sample Data Generator Section
          _buildEnhancedGeneratorSection(articleProvider),
        ],
      ),
    );
  }

  Widget _buildArticlesListTab(ArticleProvider articleProvider) {
    return Column(
      children: [
        // Header for Articles List Tab
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFEC407A).withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.list_alt,
                      color: Color(0xFFEC407A),
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Artikel',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEC407A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola dan lihat semua artikel edukasi',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Articles List Section
        Expanded(child: _buildArticlesListSection(articleProvider)),
      ],
    );
  }

  Widget _buildEnhancedGeneratorSection(ArticleProvider articleProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFEC407A).withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFEC407A),
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enhanced Sample Data Generator',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEC407A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Buat artikel edukasi berkualitas tinggi secara otomatis',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Quick navigation to articles list
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEC407A).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.list_alt,
                    color: Color(0xFFEC407A),
                    size: 20,
                  ),
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  tooltip: 'Lihat Daftar Artikel',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Article Count Slider
          Row(
            children: [
              Icon(Icons.format_list_numbered, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'Jumlah Artikel: $_articleCount',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _articleCount.toDouble(),
            min: 5,
            max: 50,
            divisions: 9,
            activeColor: const Color(0xFFEC407A),
            inactiveColor: Colors.grey[300],
            label: _articleCount.toString(),
            onChanged: (value) {
              setState(() {
                _articleCount = value.round();
              });
            },
          ),

          const SizedBox(height: 16),

          // Content Type Dropdown
          Row(
            children: [
              Icon(Icons.category, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'Jenis Konten:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedContentType,
            decoration: InputDecoration(
              labelText: 'Pilih Jenis Konten',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEC407A)),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items:
                _contentTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                _selectedContentType = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Focus Type Selection
          Row(
            children: [
              Icon(Icons.center_focus_strong, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'Fokus Konten:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedFocus,
            decoration: InputDecoration(
              labelText: 'Pilih Fokus Konten',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEC407A)),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: List.generate(_focusTypes.length, (index) {
              return DropdownMenuItem(
                value: index,
                child: Text(_focusTypes[index]),
              );
            }),
            onChanged: (value) {
              setState(() {
                _selectedFocus = value ?? 0;
              });
            },
          ),

          const SizedBox(height: 16),

          // Quality Control Checkboxes
          Row(
            children: [
              Checkbox(
                value: _highQualityOnly,
                onChanged: (value) {
                  setState(() {
                    _highQualityOnly = value!;
                  });
                },
                activeColor: const Color(0xFFEC407A),
              ),
              Expanded(
                child: Text(
                  'Hanya konten berkualitas tinggi',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ],
          ),

          Row(
            children: [
              Checkbox(
                value: _clearExisting,
                onChanged: (value) {
                  setState(() {
                    _clearExisting = value!;
                  });
                },
                activeColor: const Color(0xFFEC407A),
              ),
              Expanded(
                child: Text(
                  'Hapus artikel lama sebelum generate baru',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _isGenerating
                          ? null
                          : () => _loadFreshSampleData(articleProvider),
                  icon:
                      _isGenerating
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Icon(Icons.auto_awesome, color: Colors.white),
                  label: Text(
                    _isGenerating ? 'Generating...' : 'Generate Artikel Baru',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC407A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isGenerating
                          ? null
                          : () =>
                              _loadFocusedArticles(articleProvider, 'nutrisi'),
                  icon: const Icon(Icons.restaurant, color: Color(0xFFEC407A)),
                  label: Text(
                    'Generate Nutrisi',
                    style: GoogleFonts.poppins(color: Color(0xFFEC407A)),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: const BorderSide(color: Color(0xFFEC407A)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isGenerating
                          ? null
                          : () => _loadFocusedArticles(articleProvider, 'tips'),
                  icon: const Icon(Icons.lightbulb, color: Color(0xFFEC407A)),
                  label: Text(
                    'Generate Tips',
                    style: GoogleFonts.poppins(color: Color(0xFFEC407A)),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: const BorderSide(color: Color(0xFFEC407A)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(ArticleProvider articleProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEC407A),
            const Color(0xFFEC407A).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC407A).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Artikel',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ringkasan performa konten edukasi',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Refresh button for view counts
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Consumer<ArticleProvider>(
                  builder: (context, articleProvider, child) {
                    return IconButton(
                      icon:
                          articleProvider.isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20,
                              ),
                      onPressed:
                          articleProvider.isLoading
                              ? null
                              : () {
                                context
                                    .read<ArticleProvider>()
                                    .refreshViewCounts();
                              },
                      tooltip: 'Refresh View Counts',
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<Map<String, dynamic>>(
            future: articleProvider.getArticleStatistics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading statistics',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                );
              }

              final stats = snapshot.data ?? {};

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total Artikel',
                          stats['totalArticles']?.toString() ?? '0',
                          Icons.article_rounded,
                          Colors.white,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Artikel Aktif',
                          stats['activeArticles']?.toString() ?? '0',
                          Icons.check_circle_rounded,
                          Colors.white,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Rata-rata Baca',
                          '${stats['averageReadTime'] ?? 0} menit',
                          Icons.timer_rounded,
                          Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildArticlesListSection(ArticleProvider articleProvider) {
    final articles = articleProvider.articles;

    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Artikel',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Gunakan generator di atas untuk membuat artikel baru',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.list, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'Daftar Artikel (${articles.length})',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // Show category filter
                  _showCategoryFilter();
                },
                icon: const Icon(Icons.filter_list),
                label: Text('Filter'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEC407A),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ArticleCard(
                  article: article,
                  onTap: () {
                    // Navigate to article detail
                    _showArticleDetail(article);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Load fresh sample data
  Future<void> _loadFreshSampleData(ArticleProvider articleProvider) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      await articleProvider.loadFreshSampleData(
        count: _articleCount,
        category:
            _selectedContentType == 'Semua Jenis' ? null : _selectedContentType,
        clearExisting: _clearExisting,
        highQualityOnly: _highQualityOnly,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(
                  child: Text(
                    '$_articleCount artikel baru berhasil dibuat!',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Switch to articles list tab
                    _tabController.animateTo(1);
                  },
                  child: Text(
                    'Lihat Artikel',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  // Load focused articles
  Future<void> _loadFocusedArticles(
    ArticleProvider articleProvider,
    String focus,
  ) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      await articleProvider.loadFocusedArticles(
        focus: focus,
        count: _articleCount,
        category:
            _selectedContentType == 'Semua Jenis'
                ? 'Semua Jenis'
                : _selectedContentType,
        clearExisting: _clearExisting,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(
                  child: Text(
                    '$_articleCount artikel $focus berhasil dibuat!',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Switch to articles list tab
                    _tabController.animateTo(1);
                  },
                  child: Text(
                    'Lihat Artikel',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  // Show category filter
  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Filter Kategori', style: GoogleFonts.poppins()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Semua', style: GoogleFonts.poppins()),
                  leading: Radio<String>(
                    value: 'Semua Jenis',
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: Text('Trimester 1', style: GoogleFonts.poppins()),
                  leading: Radio<String>(
                    value: 'Trimester 1',
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: Text('Trimester 2', style: GoogleFonts.poppins()),
                  leading: Radio<String>(
                    value: 'Trimester 2',
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: Text('Trimester 3', style: GoogleFonts.poppins()),
                  leading: Radio<String>(
                    value: 'Trimester 3',
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Show article detail
  void _showArticleDetail(article) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(article.title, style: GoogleFonts.poppins()),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kategori: ${article.category}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEC407A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waktu Baca: ${article.readTime} menit',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  Text(
                    'Views: ${article.views}',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  Text(
                    'Status: ${article.isActive ? "Aktif" : "Tidak Aktif"}',
                    style: GoogleFonts.poppins(
                      color: article.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Konten:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.content,
                    style: GoogleFonts.poppins(fontSize: 14),
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }
}
