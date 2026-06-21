import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../providers/user_provider.dart';

class WallScreen extends StatefulWidget {
  const WallScreen({super.key});

  @override
  State<WallScreen> createState() => _WallScreenState();
}

class _WallScreenState extends State<WallScreen> {
  List<dynamic> publications = [];
  List<dynamic> filteredPublications = [];
  bool isLoading = true;
  String searchQuery = "";
  String filterBy = "date";
  late TextEditingController searchController;
  late UserProvider _userProvider;
  late String _previousAlias;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _userProvider = context.read<UserProvider>();
    _previousAlias = _userProvider.userSession['alias'] ?? '';
    
    // Registrar listener antes de cargar publicaciones
    _userProvider.addListener(_onUserProviderChange);
    
    // Cargar publicaciones iniciales
    _loadPublications();
  }

  void _onUserProviderChange() {
    if (!mounted) return;
    
    // Recarga publicaciones cada vez que el Provider cambia
    // Aumentar delay para asegurar que MongoDB ya actualizó
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
        _loadPublications();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _userProvider.removeListener(_onUserProviderChange);
    super.dispose();
  }

  Future<void> _loadPublications() async {
    try {
      final response = await ApiService.getPublications(
        search: searchQuery,
        filterBy: filterBy,
      );

      setState(() {
        publications = response['publications'] ?? [];
        filteredPublications = publications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar publicaciones: $e')),
        );
      }
    }
  }

  void _filterPublications(String query, String newFilterBy) {
    setState(() {
      searchQuery = query;
      filterBy = newFilterBy;
      isLoading = true;
    });
    _loadPublications();
  }

  void _createPublication(String content) async {
    final userSession = context.read<UserProvider>().userSession;
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La publicación no puede estar vacía')),
      );
      return;
    }

    try {
      await ApiService.createPublication(
        userSession['_id'] ?? '',
        userSession['alias'] ?? 'Usuario',
        userSession['nombre_completo'] ?? 'Usuario',
        content,
      );
      _loadPublications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación creada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear publicación: $e')),
        );
      }
    }
  }

  void _editPublication(String publicationId, String currentContent) async {
    final userSession = context.read<UserProvider>().userSession;
    final TextEditingController editController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar publicación', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: editController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Edita tu publicación...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              try {
                await ApiService.updatePublication(
                  publicationId,
                  userSession['_id'] ?? '',
                  editController.text,
                );
                _loadPublications();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publicación actualizada exitosamente')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al editar: $e')),
                  );
                }
              }
            },
            child: Text('Guardar', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deletePublication(String publicationId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar publicación?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text('Esta acción no se puede deshacer.', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ApiService.deletePublication(publicationId);
                _loadPublications();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publicación eliminada exitosamente')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
            child: Text('Eliminar', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleLike(String publicationId) async {
    final userSession = context.read<UserProvider>().userSession;
    
    try {
      await ApiService.toggleLike(
        publicationId,
        userSession['_id'] ?? '',
      );
      _loadPublications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _toggleDislike(String publicationId) async {
    final userSession = context.read<UserProvider>().userSession;
    
    try {
      await ApiService.toggleDislike(
        publicationId,
        userSession['_id'] ?? '',
      );
      _loadPublications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatDateTime(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final mexicoTime = dateTime.add(const Duration(hours: -6));
      return DateFormat('dd/MM/yyyy HH:mm').format(mexicoTime);
    } catch (e) {
      return "Fecha desconocida";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "Muro de Expresión Lince",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          _showCreatePublicationDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  "Muro de",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "Expresión Lince",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Comparte ideas con la comunidad.",
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),
                _buildSearchAndFilters(),
                const SizedBox(height: 30),
                if (filteredPublications.isEmpty)
                  Center(
                    child: Text(
                      "No hay publicaciones",
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...List.generate(
                    filteredPublications.length,
                    (index) {
                      final userSession = context.read<UserProvider>().userSession;
                      final isOwner = filteredPublications[index]['user_id'] == userSession['_id'];
                      
                      return Column(
                        children: [
                          _postCard(
                            publication: filteredPublications[index],
                            isOwner: isOwner,
                            onLikeTap: () => _toggleLike(filteredPublications[index]['_id']),
                            onDislikeTap: () => _toggleDislike(filteredPublications[index]['_id']),
                            onEditTap: () => _editPublication(
                              filteredPublications[index]['_id'],
                              filteredPublications[index]['content'],
                            ),
                            onDeleteTap: () => _deletePublication(filteredPublications[index]['_id']),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
              ],
            ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          onSubmitted: (value) {
            _filterPublications(value, filterBy);
          },
          decoration: InputDecoration(
            hintText: "Buscar publicaciones (presiona Enter)",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: searchQuery.isNotEmpty ? AppColors.primary.withOpacity(0.1) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: searchQuery.isNotEmpty
                  ? BorderSide(color: AppColors.primary, width: 2)
                  : BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterButton(
                label: "Más recientes",
                isActive: filterBy == "date",
                onTap: () => _filterPublications(searchQuery, "date"),
              ),
              const SizedBox(width: 10),
              _filterButton(
                label: "Por usuario",
                isActive: filterBy == "user",
                onTap: () => _filterPublications(searchQuery, "user"),
              ),
              const SizedBox(width: 10),
              _filterButton(
                label: "Más antiguas",
                isActive: filterBy == "age",
                onTap: () => _filterPublications(searchQuery, "age"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _postCard({
    required Map<String, dynamic> publication,
    required bool isOwner,
    required VoidCallback onLikeTap,
    required VoidCallback onDislikeTap,
    required VoidCallback onEditTap,
    required VoidCallback onDeleteTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.04)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.08),
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        publication['user_alias'] ?? '@usuario',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _formatDateTime(publication['created_at'] ?? ''),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isOwner)
                Row(
                  children: [
                    IconButton(
                      iconSize: 20,
                      onPressed: onEditTap,
                      icon: const Icon(Icons.edit),
                      color: AppColors.primary,
                    ),
                    IconButton(
                      iconSize: 20,
                      onPressed: onDeleteTap,
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            publication['content'] ?? '',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              GestureDetector(
                onTap: onLikeTap,
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up_alt_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (publication['likes'] ?? 0).toString(),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: onDislikeTap,
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_down_alt_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (publication['dislikes'] ?? 0).toString(),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreatePublicationDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Nueva publicación',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Escribe tu publicación...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              _createPublication(controller.text);
              Navigator.pop(context);
            },
            child: Text('Publicar', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
