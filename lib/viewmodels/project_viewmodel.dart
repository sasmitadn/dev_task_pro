import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/priority.dart';
import '../models/project.dart';
import '../core/db/app_database.dart';
import 'package:uuid/uuid.dart';

class ProjectViewModel extends ChangeNotifier {
  final _db = AppDatabase.instance;
  final _uuid = const Uuid();

  List<Project> _projects = [];
  List<Category> _categories = [];
  List<Priority> _priorities = [];
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _isLoading = false;

  List<Project> get projects {
    var list = _projects;
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  List<Category> get categories => _categories;
  List<Priority> get priorities => _priorities;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _projects = await _db.getProjects();
    _categories = await _db.getCategories();
    _priorities = await _db.getPriorities();
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  Future<Project> addProject(Project p) async {
    // final p = Project(
    //   id: _uuid.v4(),
    //   name: name,
    //   order: _projects.length,
    // );
    await _db.insertProject(p);
    _projects.insert(0, p);
    notifyListeners();
    return p;
  }

  Future<void> updateProject(Project p) async {
    await _db.updateProject(p);
    final idx = _projects.indexWhere((x) => x.id == p.id);
    if (idx >= 0) _projects[idx] = p;
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    await _db.deleteProject(id);
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> reorderProjects(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final p = _projects.removeAt(oldIndex);
    _projects.insert(newIndex, p);
    for (int i = 0; i < _projects.length; i++) {
      _projects[i].order = i;
      await _db.updateProject(_projects[i]);
    }
    notifyListeners();
  }

  // Categories
  Future<void> addCategory(String name) async {
    final c = Category(id: _uuid.v4(), name: name, order: _categories.length);
    await _db.insertCategory(c);
    _categories.add(c);
    notifyListeners();
  }

  Future<void> updateCategory(Category c) async {
    await _db.updateCategory(c);
    final idx = _categories.indexWhere((x) => x.id == c.id);
    if (idx >= 0) _categories[idx] = c;
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _db.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // Priorities
  Future<void> addPriority(String name, int level) async {
    final p = Priority(id: _uuid.v4(), name: name, level: level, order: _priorities.length);
    await _db.insertPriority(p);
    _priorities.add(p);
    notifyListeners();
  }

  Future<void> updatePriority(Priority p) async {
    await _db.updatePriority(p);
    final idx = _priorities.indexWhere((x) => x.id == p.id);
    if (idx >= 0) _priorities[idx] = p;
    notifyListeners();
  }

  Future<void> deletePriority(String id) async {
    await _db.deletePriority(id);
    _priorities.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  int countByCategory(String? categoryId) {
    if (categoryId == null) return _projects.length;
    return _projects.where((p) => p.categoryId == categoryId).length;
  }
}
