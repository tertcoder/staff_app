import 'dart:io';

import 'package:staff_app/models/staff.dart';
import 'package:staff_app/screens/add_staff_screen.dart';
import 'package:staff_app/services/api_service.dart';
import 'package:staff_app/widgets/staff_card.dart';
import 'package:staff_app/widgets/stats_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController();
  List<StaffMember> _staff = [];
  Map<String, dynamic> _stats = {};
  String _searchTerm = "";
  final String _filter = "all";
  bool _isLoading = false;
  final bool _isDeletingAll = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final [staff, stats] = await Future.wait([
        ApiService.getStaff(search: _searchTerm, filter: _filter),
        ApiService.getStats(),
      ]);

      setState(() {
        _staff = staff as List<StaffMember>;
        _stats = stats as Map<String, dynamic>;
      });
    } catch (e) {
      _showErrorSnackBar('Erreur de chargement : ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
      _refreshController.refreshCompleted();
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _showDeleteDialog(StaffMember staff) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Supprimer un membre',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ${staff.name} ? Cette action est irréversible.',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteStaff(staff);
    }
  }

  Future<void> _deleteStaff(StaffMember staff) async {
    try {
      // Afficher l'indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          );
        },
      );

      await ApiService.deleteStaff(staff.id);

      if (context.mounted) {
        // Masquer l'indicateur de chargement
        Navigator.of(context).pop();

        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${staff.name} supprimé avec succès'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Actualiser les données
        _loadData();
      }
    } catch (e) {
      if (context.mounted) {
        // Masquer l'indicateur de chargement
        Navigator.of(context).pop();

        // Afficher le message d'erreur
        _showErrorSnackBar('Échec de la suppression : ${e.toString()}');
      }
    }
  }

  Future<void> _confirmDeleteAll() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Supprimer tout le personnel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer TOUS les membres? Cette action est irréversible.',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Supprimer tout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    try {
      await ApiService.deleteAllStaff();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tous les membres supprimés avec succès'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Échec de la suppression: ${e.toString()}');
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      setState(() => _isLoading = true);
      final path = await ApiService.exportStaffToExcel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export Excel réussi!'),
            backgroundColor: Colors.green,
          ),
        );

        await OpenFilex.open(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec export: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importFromExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isLoading = true);
      final count = await ApiService.importStaffFromExcel(
        File(result.files.single.path!),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count membres importés avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec import: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddOptionsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Ajouter du personnel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.upload_file,
                    color: Color(0xFF6366F1),
                  ),
                  title: const Text('Importer depuis Excel'),
                  onTap: () {
                    Navigator.pop(context);
                    _importFromExcel();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.person_add,
                    color: Color(0xFF6366F1),
                  ),
                  title: const Text('Ajouter manuellement'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                const AddStaffScreen(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: child,
                          );
                        },
                      ),
                    ).then((_) => _loadData());
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'export_btn',
            onPressed: _exportToExcel,
            backgroundColor: const Color(0xFF10B981),
            mini: true,
            child: const Icon(Icons.download, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_btn',
            onPressed: _showAddOptionsDialog,
            backgroundColor: const Color(0xFF6366F1),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true, // Enable pull up functionality
        onRefresh: _handleRefresh,
        onLoading: () async {
          // Show delete confirmation when pulling up
          if (_staff.isNotEmpty) {
            await _confirmDeleteAll();
          }
          _refreshController.loadComplete();
        },
        header: const ClassicHeader(
          idleText: 'Tirer pour actualiser',
          releaseText: 'Relâcher pour actualiser',
          completeText: 'Actualisation terminée',
          failedText: 'Échec de l\'actualisation',
          refreshingText: 'Actualisation en cours...',
        ),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (_staff.isEmpty) {
              body = const Text("");
            } else if (mode == LoadStatus.idle) {
              body = const Text(
                "Tirer vers le haut pour supprimer tout le personnel",
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                textAlign: TextAlign.center,
              );
            } else if (mode == LoadStatus.loading) {
              body = const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
              );
            } else if (mode == LoadStatus.canLoading) {
              body = const Text(
                "Relâcher pour supprimer tout",
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              );
            } else if (mode == LoadStatus.failed) {
              body = const Text(
                "Échec! Réessayez",
                style: TextStyle(color: Color(0xFFEF4444)),
              );
            } else {
              body = const Text("");
            }
            return SizedBox(height: 55, child: Center(child: body));
          },
        ),
        child: CustomScrollView(
          slivers: [
            // Barre d'application moderne
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Color(0XFFF8FAFC),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: const Text(
                        'Gestion du personnel',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    );
                  },
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: FloatingActionButton.small(
                    onPressed: _showAddOptionsDialog,

                    // onPressed: () {
                    //   Navigator.push(
                    //     context,
                    //     PageRouteBuilder(
                    //       pageBuilder:
                    //           (context, animation, secondaryAnimation) =>
                    //               const AddStaffScreen(),
                    //       transitionsBuilder: (
                    //         context,
                    //         animation,
                    //         secondaryAnimation,
                    //         child,
                    //       ) {
                    //         return SlideTransition(
                    //           position: Tween<Offset>(
                    //             begin: const Offset(1.0, 0.0),
                    //             end: Offset.zero,
                    //           ).animate(
                    //             CurvedAnimation(
                    //               parent: animation,
                    //               curve: Curves.easeInOut,
                    //             ),
                    //           ),
                    //           child: child,
                    //         );
                    //       },
                    //     ),
                    //   ).then((_) => _loadData());
                    // },
                    backgroundColor: const Color(0xFF6366F1),
                    elevation: 4,
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),

            // Section Recherche et Statistiques
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Barre de recherche améliorée
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Rechercher des membres...",
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF6B7280),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                          ),
                          onChanged: (value) {
                            setState(() => _searchTerm = value);
                            _loadData();
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Cartes de statistiques améliorées
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            EnhancedStatsCard(
                              value: _stats['totalStaff'] ?? 0,
                              label: "Total",
                              icon: Icons.people_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                            ),
                            EnhancedStatsCard(
                              value: _stats['activeStaff'] ?? 0,
                              label: "Actifs",
                              icon: Icons.check_circle_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                            ),
                            EnhancedStatsCard(
                              value: _stats['onLeaveStaff'] ?? 0,
                              label: "En congé",
                              icon: Icons.beach_access_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Liste du personnel
            _isLoading && _staff.isEmpty
                ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    ),
                  ),
                )
                : _staff.isEmpty
                ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.people_outline_rounded,
                            size: 64,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Aucun membre trouvé',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tirez pour actualiser ou ajoutez du personnel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: EnhancedStaffCard(
                                staff: _staff[index],
                                onDelete:
                                    () => _showDeleteDialog(_staff[index]),
                                onEdit:
                                    () => Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => AddStaffScreen(
                                              staff: _staff[index],
                                            ),
                                        transitionsBuilder: (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeInOut,
                                              ),
                                            ),
                                            child: child,
                                          );
                                        },
                                      ),
                                    ).then((_) => _loadData()),
                                onDataChanged: _loadData,
                              ),
                            ),
                          );
                        },
                      );
                    }, childCount: _staff.length),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
