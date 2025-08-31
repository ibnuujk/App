import 'package:flutter/material.dart';
import '../utilities/safe_navigation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../providers/article_provider.dart';

import '../models/article_model.dart';
import '../services/article_service.dart';

class PanelEdukasi extends StatefulWidget {
  final UserModel user;

  const PanelEdukasi({Key? key, required this.user}) : super(key: key);

  @override
  State<PanelEdukasi> createState() => _PanelEdukasiState();
}

class _PanelEdukasiState extends State<PanelEdukasi>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // CRUD Article variables
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  String _selectedCategoryForForm = 'Trimester 1';
  bool _isActive = true;
  Article? _editingArticle;

  final List<String> _categoryOptions = [
    'Trimester 1',
    'Trimester 2',
    'Trimester 3',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize articles when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().initializeArticles();
      context.read<ArticleProvider>().refreshViewCounts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _websiteUrlController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationHelper.safeNavigateBack(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Statistik & Kelola'),
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
              // Tab 1: Statistik & Kelola Artikel
              _buildStatisticsAndCrudTab(articleProvider),

              // Tab 2: Daftar Artikel
              _buildArticlesListTab(articleProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsAndCrudTab(ArticleProvider articleProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Statistics Section
          _buildStatisticsSection(articleProvider),

          // CRUD Article Section
          _buildCrudSection(articleProvider),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(ArticleProvider articleProvider) {
    final articles = articleProvider.articles;
    final activeArticles = articles.where((a) => a.isActive).length;
    final totalViews = articles.fold<int>(0, (sum, a) => sum + a.views);
    final avgViews = articles.isNotEmpty ? totalViews / articles.length : 0;

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
                  Icons.analytics,
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
                      'Statistik Artikel',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEC407A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ringkasan performa artikel edukasi',
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
          const SizedBox(height: 20),

          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Artikel',
                  '${articles.length}',
                  Icons.article,
                  const Color(0xFFEC407A),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Artikel Aktif',
                  '$activeArticles',
                  Icons.check_circle,
                  const Color(0xFFF48FB1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Rata-rata Baca',
                  '${avgViews.toStringAsFixed(1)}',
                  Icons.visibility,
                  const Color(0xFFE91E63),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCrudSection(ArticleProvider articleProvider) {
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
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFEC407A).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.add_circle,
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
                      _editingArticle != null
                          ? 'Edit Artikel'
                          : 'Tambah Artikel Baru',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEC407A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _editingArticle != null
                          ? 'Edit artikel yang sudah ada'
                          : 'Buat artikel edukasi baru',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (_editingArticle != null)
                IconButton(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Batal Edit',
                ),
            ],
          ),
          const SizedBox(height: 20),

          // CRUD Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul Artikel',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Informasi Singkat',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informasi singkat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Website URL Field
                TextFormField(
                  controller: _websiteUrlController,
                  decoration: InputDecoration(
                    labelText: 'Link Website (Opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.link),
                    hintText: 'https://example.com',
                  ),
                ),
                const SizedBox(height: 16),

                // Category Field
                DropdownButtonFormField<String>(
                  value: _selectedCategoryForForm,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items:
                      _categoryOptions
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryForForm = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Active Status
                CheckboxListTile(
                  title: Text(
                    'Artikel Aktif',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value!;
                    });
                  },
                  activeColor: const Color(0xFFEC407A),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveArticle,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          _editingArticle != null
                              ? 'Update Artikel'
                              : 'Simpan Artikel',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC407A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (_editingArticle != null) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _deleteArticle(articleProvider),
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: Text(
                            'Hapus',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesListTab(ArticleProvider articleProvider) {
    return Column(
      children: [
        // Header
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
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFEC407A).withValues(alpha: 0.3),
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
                          'Kelola semua artikel yang tersedia',
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
        const SizedBox(height: 16),

        // Articles List
        Expanded(child: _buildArticlesListSection(articleProvider)),
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
              'Buat artikel pertama menggunakan form di atas',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article.description,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCE4EC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    article.category,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFFC2185B),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        article.isActive
                                            ? const Color(0xFFE8F5E8)
                                            : const Color(0xFFFCE4EC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    article.isActive ? 'Aktif' : 'Tidak Aktif',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color:
                                          article.isActive
                                              ? const Color(0xFF2E7D32)
                                              : const Color(0xFFC2185B),
                                    ),
                                  ),
                                ),
                                if (article.websiteUrl.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E5F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.link,
                                          size: 12,
                                          color: const Color(0xFF7B1FA2),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Website',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: const Color(0xFF7B1FA2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => _editArticle(article),
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFFEC407A),
                            ),
                            tooltip: 'Edit Artikel',
                          ),
                          IconButton(
                            onPressed:
                                () => _deleteArticleDirectly(
                                  articleProvider,
                                  article,
                                ),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Hapus Artikel',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // CRUD Methods
  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final article = Article(
        id:
            _editingArticle?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        websiteUrl: _websiteUrlController.text.trim(),
        category: _selectedCategoryForForm,
        readTime: 5,
        views: _editingArticle?.views ?? 0,
        isActive: _isActive,
        createdAt: _editingArticle?.createdAt ?? DateTime.now(),
      );

      if (_editingArticle != null) {
        // Update existing article
        await ArticleService().updateArticle(article);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artikel berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Add new article
        await ArticleService().addArticle(article);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artikel berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _resetForm();
      context.read<ArticleProvider>().refreshArticles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _websiteUrlController.clear();
    _selectedCategoryForForm = 'Trimester 1';
    _isActive = true;
    _editingArticle = null;
    setState(() {});
  }

  void _editArticle(Article article) {
    _editingArticle = article;
    _titleController.text = article.title;
    _descriptionController.text = article.description;
    _websiteUrlController.text = article.websiteUrl;
    _selectedCategoryForForm = article.category;
    _isActive = article.isActive;
    setState(() {});

    // Switch to CRUD tab
    _tabController.animateTo(0);
  }

  Future<void> _deleteArticle(ArticleProvider articleProvider) async {
    if (_editingArticle == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Konfirmasi Hapus'),
            content: Text(
              'Apakah Anda yakin ingin menghapus artikel "${_editingArticle!.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context, false);
                  }
                },
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await ArticleService().deleteArticle(_editingArticle!.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artikel berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
        articleProvider.refreshArticles();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteArticleDirectly(
    ArticleProvider articleProvider,
    Article article,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Konfirmasi Hapus'),
            content: Text(
              'Apakah Anda yakin ingin menghapus artikel "${article.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context, false);
                  }
                },
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await ArticleService().deleteArticle(article.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Artikel berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        articleProvider.refreshArticles();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
