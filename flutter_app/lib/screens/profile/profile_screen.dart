import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../providers/user_provider.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController aliasController;
  late String selectedCampus;
  bool isEditing = false;
  late UserProvider _userProvider;

  final List<String> campuses = [
    'Lomas Verdes',
    'Campus San Rafael',
    'Campus Polanco',
    'Campus Pedregal',
    'Campus Norte',
  ];

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    final userSession = _userProvider.userSession;
    aliasController = TextEditingController(text: userSession['alias'] ?? 'Usuario');
    final userCampus = userSession['campus'];
    selectedCampus = (userCampus != null && campuses.contains(userCampus)) ? userCampus : campuses[0];
    
    // Escuchar cambios en el Provider
    _userProvider.addListener(_onUserProviderChange);
  }

  void _onUserProviderChange() {
    if (!mounted) return;
    
    final userSession = _userProvider.userSession;
    final newAlias = userSession['alias'] ?? 'Usuario';
    final newCampus = userSession['campus'];
    
    // Actualizar controller y campus si cambiaron
    if (aliasController.text != newAlias) {
      aliasController.text = newAlias;
    }
    if (newCampus != null && newCampus != selectedCampus) {
      setState(() {
        selectedCampus = newCampus;
      });
    }
  }

  @override
  void dispose() {
    aliasController.dispose();
    _userProvider.removeListener(_onUserProviderChange);
    super.dispose();
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¿Cerrar sesión?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Se cerrará tu sesión en la aplicación.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ApiService.logout();
                
                // Limpiar sesión del Provider
                context.read<UserProvider>().logout();
                
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
              }
            },
            child: Text('Cerrar sesión', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    final userProvider = context.read<UserProvider>();
    final userSession = userProvider.userSession;
    
    try {
      final response = await ApiService.updateProfile(
        userSession['_id'] ?? '',
        aliasController.text,
        selectedCampus,
      );

      if (response['success'] == true) {
        // Actualizar el Provider con los nuevos datos
        userProvider.updateUserData({
          'alias': aliasController.text,
          'campus': selectedCampus,
        });
        
        // Forzar una notificación adicional para asegurar que WallScreen recargue
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            userProvider.notifyChange();
          }
        });
        
        setState(() {
          isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSession = context.watch<UserProvider>().userSession;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(Icons.person, size: 60, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userSession['alias'] ?? 'Usuario',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    userSession['carrera'] ?? 'Ingeniería',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Información Editable',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableField('ALIAS', isEditing, aliasController),
            const SizedBox(height: 16),
            Text(
              'CAMPUS',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            if (isEditing)
              DropdownButtonFormField<String>(
                value: selectedCampus,
                items: campuses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => selectedCampus = v ?? campuses[0]),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF0F5FF),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Text(selectedCampus, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
              ),
            const SizedBox(height: 16),
            _buildReadOnlyField('CARRERA', userSession['carrera'] ?? 'Ingeniería'),
            const SizedBox(height: 32),
            Text(
              'Datos Institucionales',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField('NOMBRE COMPLETO', userSession['nombre_completo'] ?? 'Usuario'),
            const SizedBox(height: 16),
            _buildReadOnlyField('MATRÍCULA', userSession['matricula'] ?? '0101456666'),
            const SizedBox(height: 16),
            _buildReadOnlyField('CORREO INSTITUCIONAL', userSession['correo'] ?? 'usuario@uvm.edu.mx'),
            const SizedBox(height: 16),
            _buildReadOnlyField('EDAD', userSession['edad']?.toString() ?? '20'),
            const SizedBox(height: 16),
            _buildReadOnlyField('FECHA DE NACIMIENTO', userSession['fecha_nacimiento'] ?? '01/01/2004'),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing ? Colors.grey : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => setState(() => isEditing = !isEditing),
                    child: Text(
                      isEditing ? 'Cancelar' : 'Editar Perfil',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _saveProfile,
                      child: Text('Guardar', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _logout,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Cerrar Sesión', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, bool editing, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        if (editing)
          TextField(
            controller: ctrl,
            minLines: 3,
            maxLines: 3,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF0F5FF),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Text(ctrl.text, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
          ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(          width: double.infinity,          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Text(value, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
