//Package
import 'dart:async';

import 'package:flickd_app/models/search_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../models/search_category.dart';

//Models
//import '../models/main_page_data.dart';
import '../models/movie.dart';

//Services
import '../services/movie_service.dart';

abstract class MainPageData {
  const MainPageData();
}

class MainPageDataInitial extends MainPageData {
  final List<Movie>? movies;
  final int? page;
  final String? searchCategory;
  final String? searchText;

  const MainPageDataInitial({this.movies, this.page = 1, this.searchCategory = SearchCategory.popular, this.searchText = ''});
}

class MainPageDataLoading extends MainPageData {
  const MainPageDataLoading();
}

class MainPageDataLoaded extends MainPageData {
  final List<Movie>? movies;
  final int? page;
  final String? searchCategory;
  final String? searchText;

  const MainPageDataLoaded({this.movies, this.page, this.searchCategory, this.searchText});
}

class MainPageDataController extends StateNotifier<MainPageData> {
  MainPageDataController([MainPageData? state])
      : super(MainPageDataInitial());

  final MovieService _movieService = GetIt.instance.get<MovieService>();

  Future<void> getMovies() async {
    try {
      List<Movie>? _movies = [];

      if (MainPageDataLoaded().searchText!.isEmpty) {
        if (MainPageDataLoaded().searchCategory == SearchCategory.popular) {
          _movies = await (_movieService.getPopularMovies(page: MainPageDataLoaded().page));
        } else if (MainPageDataLoaded().searchCategory == SearchCategory.upcoming) {
          _movies = await (_movieService.getUpcomingMovies(page: MainPageDataLoaded().page));
        } else if (MainPageDataLoaded().searchCategory == SearchCategory.none) {
          _movies = [];
        }
      } else {
        _movies = await (_movieService.searchMovies(MainPageDataLoaded().searchText));
      }
      state = MainPageDataLoaded(movies: [...MainPageDataLoaded().movies!, ..._movies!], page: MainPageDataLoaded().page! + 1);
    } catch (e) {
      print(e);
    }
  }

  void updateSearchCategory(String? _category) {
    try {
      state = MainPageDataLoaded(movies: [], page: 1, searchCategory: _category, searchText: '');
      getMovies();
    } catch (e) {
      print(e);
    }
  }

  void updateTextSearch(String _searchText) {
    try {
      state = MainPageDataLoaded(movies: [],
          page: 1,
          searchCategory: SearchCategory.none,
          searchText: _searchText);
      getMovies();
    } catch (e) {
      print(e);
    }
  }
}
