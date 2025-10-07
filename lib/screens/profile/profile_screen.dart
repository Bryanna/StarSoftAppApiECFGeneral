import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (c) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,

          appBar: AppBar(
            backgroundColor: const Color(0xFF005285),
            centerTitle: false,
            elevation: 0,
            title: const Text(
              'Mi Perfil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: c.loading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF005285),
                    ),
                  ),
                )
              : c.errorMessage != null
              ? _ErrorState(message: c.errorMessage!)
              : _ProfileContent(controller: c),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileController controller;
  const _ProfileContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.userData ?? {};
    final email = (data['email'] ?? '') as String;
    final role = (data['role'] ?? '') as String;
    final company = (data['companyName'] ?? '') as String;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final isTablet = constraints.maxWidth > 600;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del Usuario',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _ProfileHeader(
                            email: email,
                            role: role,
                            company: company,
                          ),
                          const SizedBox(height: 20),
                          _UserInfoCard(
                            email: email,
                            role: role,
                            company: company,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    if (controller.isAdmin)
                      Expanded(
                        flex: 3,
                        child: _AdminPanel(controller: controller),
                      ),
                  ],
                )
              else
                Column(
                  children: [
                    _ProfileHeader(email: email, role: role, company: company),
                    const SizedBox(height: 20),
                    _UserInfoCard(email: email, role: role, company: company),
                    if (controller.isAdmin) ...[
                      const SizedBox(height: 20),
                      _AdminPanel(controller: controller),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String email;
  final String role;
  final String company;

  const _ProfileHeader({
    required this.email,
    required this.role,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(email);

    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF005285),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              email,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoleChip(role: role),
                if (company.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.business,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          company,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            _QuickActions(controller: Get.find<ProfileController>()),
          ],
        ),
      ),
    );
  }

  String _getInitials(String email) {
    if (email.isEmpty) return '?';
    final parts = email.split('@')[0].split('.');
    if (parts.length >= 2) {
      return '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
    }
    return email[0].toUpperCase();
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    final color = isAdmin ? Colors.orange : const Color(0xFF005285);
    final icon = isAdmin ? Icons.admin_panel_settings : Icons.person;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            isAdmin ? 'Administrador' : 'Usuario',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final ProfileController controller;
  const _QuickActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.settings_outlined,
            label: 'Configuración',
            onPressed: () {
              _showUserConfigDialog(context, Get.find<ProfileController>());
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.info_outline,
            label: 'Acerca de',
            onPressed: () {
              _showAboutDialog(context);
            },
          ),
        ),
        if (controller.isAdmin) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.group_add_outlined,
              label: 'Nuevo Usuario',
              onPressed: () => _showCreateUserDialog(context, controller),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF005285)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF005285),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  final String email;
  final String role;
  final String company;

  const _UserInfoCard({
    required this.email,
    required this.role,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Color(0xFF005285),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Información Personal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _InfoItem(
              icon: Icons.email_outlined,
              label: 'Correo Electrónico',
              value: email,
            ),
            const SizedBox(height: 16),
            _InfoItem(
              icon: Icons.badge_outlined,
              label: 'Rol',
              value: role == 'admin' ? 'Administrador' : 'Usuario',
            ),
            const SizedBox(height: 16),
            _InfoItem(
              icon: Icons.business_outlined,
              label: 'Empresa',
              value: company.isEmpty ? 'No especificada' : company,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF005285).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF005285)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminPanel extends StatelessWidget {
  final ProfileController controller;
  const _AdminPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Color(0xFF005285),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Panel de Administración',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _AdminStats(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.group_outlined,
                          color: Color(0xFF005285),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Usuarios de la Empresa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showCreateUserDialog(context, controller),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF005285),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF005285).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person_add,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Agregar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _UsersList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: controller.usersStream,
      builder: (context, snapshot) {
        int totalUsers = 0;
        int adminUsers = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          totalUsers = docs.length;
          adminUsers = docs.where((doc) {
            final data = doc.data();
            return (data['role'] ?? '') == 'admin';
          }).length;
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people_outline,
                label: 'Total Usuarios',
                value: '$totalUsers',
                color: const Color(0xFF005285),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Administradores',
                value: '$adminUsers',
                color: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final stream = controller.usersStream;

    print(
      '_UsersList build - isAdmin: ${controller.isAdmin}, companyRnc: ${controller.companyRnc}, stream: ${stream != null}',
    );

    if (stream == null) {
      return _EmptyState(
        icon: Icons.group_outlined,
        message: controller.isAdmin
            ? 'Configurando lista de usuarios...'
            : 'No hay usuarios para mostrar',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005285)),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          print('StreamBuilder error: ${snapshot.error}');
          // Fallback a FutureBuilder si el stream falla
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: controller.getUsersList(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF005285),
                      ),
                    ),
                  ),
                );
              }

              if (futureSnapshot.hasError) {
                print('FutureBuilder error: ${futureSnapshot.error}');
                return _EmptyState(
                  icon: Icons.error_outline,
                  message: 'Error cargando usuarios: ${futureSnapshot.error}',
                  isError: true,
                );
              }

              final users = futureSnapshot.data ?? [];

              if (users.isEmpty) {
                return _EmptyState(
                  icon: Icons.group_outlined,
                  message: 'Sin usuarios registrados',
                );
              }

              return Column(
                children: users.map((userData) {
                  final email = (userData['email'] ?? '') as String;
                  final role = (userData['role'] ?? '') as String;

                  return _UserListItem(email: email, role: role);
                }).toList(),
              );
            },
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return _EmptyState(
            icon: Icons.group_outlined,
            message: 'Sin usuarios registrados',
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final email = (data['email'] ?? '') as String;
            final role = (data['role'] ?? '') as String;

            return _UserListItem(email: email, role: role);
          }).toList(),
        );
      },
    );
  }
}

class _UserListItem extends StatelessWidget {
  final String email;
  final String role;

  const _UserListItem({required this.email, required this.role});

  @override
  Widget build(BuildContext context) {
    final initials = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final isAdmin = role == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAdmin ? Colors.orange : const Color(0xFF005285),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      size: 12,
                      color: isAdmin ? Colors.orange : const Color(0xFF005285),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAdmin ? 'Administrador' : 'Usuario',
                      style: TextStyle(
                        color: isAdmin
                            ? Colors.orange
                            : const Color(0xFF005285),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.grey, size: 16),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.redAccent, size: 16),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              final controller = Get.find<ProfileController>();
              switch (value) {
                case 'edit':
                  Get.snackbar(
                    'Información',
                    'Funcionalidad de edición próximamente',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  break;
                case 'delete':
                  _showDeleteUserDialog(context, email, controller);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isError;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: isError ? Colors.redAccent : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: isError ? Colors.redAccent : Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

void _showCreateUserDialog(BuildContext context, ProfileController controller) {
  controller.newRole = 'user';

  showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_add_outlined,
                      color: Color(0xFF005285),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Crear Nuevo Usuario',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.newEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.newPasswordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                GetBuilder<ProfileController>(
                  builder: (c) {
                    return DropdownButtonFormField<String>(
                      value: c.newRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol del Usuario',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('Usuario')),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Administrador'),
                        ),
                      ],
                      onChanged: (value) {
                        c.newRole = value ?? 'user';
                        c.update();
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GetBuilder<ProfileController>(
                      builder: (c) {
                        return GestureDetector(
                          onTap: c.loading
                              ? null
                              : () async {
                                  final email = controller.newEmailCtrl.text
                                      .trim();
                                  final password =
                                      controller.newPasswordCtrl.text;
                                  final role = controller.newRole;

                                  // Validación básica
                                  if (email.isEmpty) {
                                    Get.snackbar(
                                      'Error',
                                      'El correo electrónico es requerido',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red.shade600,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  if (password.isEmpty || password.length < 6) {
                                    Get.snackbar(
                                      'Error',
                                      'La contraseña debe tener al menos 6 caracteres',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red.shade600,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(email)) {
                                    Get.snackbar(
                                      'Error',
                                      'Ingresa un correo electrónico válido',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red.shade600,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  Navigator.of(context).pop();
                                  await controller.createUser(
                                    email: email,
                                    password: password,
                                    role: role,
                                  );
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: c.loading
                                  ? Colors.grey.shade400
                                  : const Color(0xFF005285),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: c.loading
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF005285,
                                        ).withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                c.loading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                const SizedBox(width: 8),
                                Text(
                                  c.loading ? 'Creando...' : 'Crear Usuario',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

void _showDeleteUserDialog(
  BuildContext context,
  String email,
  ProfileController controller,
) {
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar al usuario "$email"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
              await controller.deleteUser(email);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

void _showAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/logo2.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 24),

                // Título
                const Text(
                  'Starsoft Dominicana',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005285),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtítulo
                const Text(
                  'Sistema de Facturación Electrónica',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Descripción
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Text(
                    'Nuestro sistema de facturación electrónica está diseñado para simplificar y automatizar el proceso de emisión de facturas, cumpliendo con todas las normativas fiscales vigentes. Ofrecemos una solución integral que permite a las empresas gestionar sus documentos fiscales de manera eficiente y segura.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 24),

                // Información de contacto
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005285).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF005285).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de Contacto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF005285),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ContactItem(
                        icon: Icons.phone,
                        label: 'Teléfono',
                        value: '+1 (809) 916-2053',
                      ),
                      const SizedBox(height: 8),
                      _ContactItem(
                        icon: Icons.email,
                        label: 'Correo',
                        value: 'ing.abelmedrano@gmail.com',
                      ),
                      const SizedBox(height: 8),
                      _ContactItem(
                        icon: Icons.web,
                        label: 'Web',
                        value: 'www.starsoftdominicana.com',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005285),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF005285)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

void _showUserConfigDialog(BuildContext context, ProfileController controller) {
  final userData = controller.userData ?? {};
  final email = (userData['email'] ?? '') as String;
  final role = (userData['role'] ?? '') as String;
  final company = (userData['companyName'] ?? '') as String;
  final companyRnc = (userData['companyRnc'] ?? '') as String;
  final createdAt = userData['createdAt'] as Timestamp?;

  showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFF005285),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Configuración de Usuario',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Información del usuario
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de la Cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF005285),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ConfigItem(
                        label: 'Correo Electrónico',
                        value: email,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 8),
                      _ConfigItem(
                        label: 'Rol',
                        value: role == 'admin' ? 'Administrador' : 'Usuario',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 8),
                      _ConfigItem(
                        label: 'Empresa',
                        value: company.isEmpty ? 'No especificada' : company,
                        icon: Icons.business_outlined,
                      ),
                      if (companyRnc.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _ConfigItem(
                          label: 'RNC Empresa',
                          value: companyRnc,
                          icon: Icons.numbers_outlined,
                        ),
                      ],
                      if (createdAt != null) ...[
                        const SizedBox(height: 8),
                        _ConfigItem(
                          label: 'Cuenta creada',
                          value: _formatDate(createdAt.toDate()),
                          icon: Icons.calendar_today_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Opciones de configuración
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005285).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF005285).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Opciones Disponibles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF005285),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ConfigOption(
                        icon: Icons.lock_outline,
                        title: 'Cambiar Contraseña',
                        subtitle: 'Actualiza tu contraseña de acceso',
                        onTap: () {
                          Navigator.of(context).pop();
                          _showChangePasswordDialog(context, controller);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005285),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ConfigItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ConfigItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF005285)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _ConfigOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ConfigOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF005285).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF005285)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  return '${date.day} de ${months[date.month - 1]} de ${date.year}';
}

void _showChangePasswordDialog(
  BuildContext context,
  ProfileController controller,
) {
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF005285),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cambiar Contraseña',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Por seguridad, necesitas confirmar tu contraseña actual',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Contraseña actual
                    TextField(
                      controller: currentPasswordCtrl,
                      obscureText: obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña Actual',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrentPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureCurrentPassword = !obscureCurrentPassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nueva contraseña
                    TextField(
                      controller: newPasswordCtrl,
                      obscureText: obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureNewPassword = !obscureNewPassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                        helperText: 'Mínimo 6 caracteres',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirmar nueva contraseña
                    TextField(
                      controller: confirmPasswordCtrl,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Nueva Contraseña',
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Consejos de seguridad
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Consejos de seguridad:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Usa al menos 8 caracteres\n• Combina letras, números y símbolos\n• No uses información personal',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            currentPasswordCtrl.dispose();
                            newPasswordCtrl.dispose();
                            confirmPasswordCtrl.dispose();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 16),
                        GetBuilder<ProfileController>(
                          builder: (c) {
                            return ElevatedButton.icon(
                              onPressed: c.loading
                                  ? null
                                  : () async {
                                      final currentPassword =
                                          currentPasswordCtrl.text;
                                      final newPassword = newPasswordCtrl.text;
                                      final confirmPassword =
                                          confirmPasswordCtrl.text;

                                      // Validaciones
                                      if (currentPassword.isEmpty) {
                                        Get.snackbar(
                                          'Error',
                                          'Ingresa tu contraseña actual',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red.shade600,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }

                                      if (newPassword.isEmpty ||
                                          newPassword.length < 6) {
                                        Get.snackbar(
                                          'Error',
                                          'La nueva contraseña debe tener al menos 6 caracteres',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red.shade600,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }

                                      if (newPassword != confirmPassword) {
                                        Get.snackbar(
                                          'Error',
                                          'Las contraseñas no coinciden',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red.shade600,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }

                                      if (currentPassword == newPassword) {
                                        Get.snackbar(
                                          'Error',
                                          'La nueva contraseña debe ser diferente a la actual',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red.shade600,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }

                                      // Cambiar contraseña
                                      await controller.changePassword(
                                        currentPassword: currentPassword,
                                        newPassword: newPassword,
                                      );

                                      // Si fue exitoso, cerrar el diálogo
                                      if (!controller.loading) {
                                        currentPasswordCtrl.dispose();
                                        newPasswordCtrl.dispose();
                                        confirmPasswordCtrl.dispose();
                                        Navigator.of(context).pop();
                                      }
                                    },
                              icon: c.loading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(
                                c.loading
                                    ? 'Cambiando...'
                                    : 'Cambiar Contraseña',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005285),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
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
    },
  );
}
