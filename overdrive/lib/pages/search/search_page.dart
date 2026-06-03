/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## search_page.dart - Search screen scaffold with bottom search bar.
 ##
 */

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/menu_overlay.dart';
import '../../widgets/search_bar.dart' as od;

const SearchPageContent _searchPageContent = SearchPageContent(
  title: 'Search',
  placeholder: 'Rechercher',
);

/// Copy rendered by the search page shell.
class SearchPageContent {
  const SearchPageContent({required this.title, required this.placeholder});

  final String title;
  final String placeholder;
}

/// Search screen shell with an externalized search bar state.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

/// State holder for the search input controller lifecycle.
class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: ColoredBox(
        color: AppColors.black,
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 96, 20, 20),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          _searchPageContent.title,
                          style: AppTextStyles.display(),
                        ),
                      ),
                    ),
                    od.SearchBar(
                      props: od.SearchBarProps(
                        controller: _searchController,
                        placeholder: _searchPageContent.placeholder,
                        onSearch: (_) {},
                        onClear: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //const MenuOverlay(),
          ],
        ),
      ),
    );
  }
}
