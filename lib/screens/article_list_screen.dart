import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/article_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_chips.dart';
import '../widgets/article_card.dart';
import '../models/article_model.dart';
import 'article_detail_screen.dart';
import 'article_admin_screen.dart';

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({Key? key}) : super(key: key);

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize articles when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().initializeArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Artikel Kehamilan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArticleAdminScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          if (articleProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
              ),
            );
          }

          if (articleProvider.error != null) {
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
                      backgroundColor: const Color(0xFFE91E63),
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

          return Column(
            children: [
              // Search Bar
              SearchBarWidget(
                onSearch: articleProvider.searchArticles,
                onClear: articleProvider.clearSearch,
              ),

              // Category Chips
              CategoryChips(
                categories: articleProvider.categories,
                selectedCategory: articleProvider.selectedCategory,
                onCategorySelected: articleProvider.filterByCategory,
              ),

              const SizedBox(height: 16),

              // Article Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${articleProvider.filteredArticles.length} artikel ditemukan',
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
                child:
                    articleProvider.filteredArticles.isEmpty
                        ? Center(
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
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: articleProvider.filteredArticles.length,
                          itemBuilder: (context, index) {
                            final article =
                                articleProvider.filteredArticles[index];
                            return ArticleCard(
                              article: article,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ArticleDetailScreen(
                                          article: article,
                                        ),
                                  ),
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
    );
  }
}
