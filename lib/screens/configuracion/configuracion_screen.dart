import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'configuracion_controller.dart';
import '../../services/theme_service.dart';
import '../../models/erp_endpoint.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfiguracionController>(
      init: ConfiguracionController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor:
                Theme.of(context).appBarTheme.backgroundColor ??
                const Color(0xFF005285),
            centerTitle: false,
            elevation: 0,
            title: Row(
              children: [
                Image.asset('assets/logo.png', height: 50),
                const Text(
                  'Configuración del Sistema',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: controller.loading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF005285),
                    ),
                  ),
                )
              : controller.errorMessage != null
              ? _ErrorState(message: controller.errorMessage!)
              : _ConfigurationContent(controller: controller),
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
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
              width: 1,
            ),
          ),
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
                Text(
                  'Error de Configuración',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
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

class _ConfigurationContent extends StatelessWidget {
  final ConfiguracionController controller;
  const _ConfigurationContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final isTablet = constraints.maxWidth > 600;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuración de Facturación Electrónica',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure los parámetros necesarios para la emisión de facturas electrónicas',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _CompanyInfoSection(controller: controller),
                          const SizedBox(height: 20),
                          _FilesSection(controller: controller),
                          const SizedBox(height: 20),
                          _AppearanceSection(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _ConfigurationSection(controller: controller),
                          const SizedBox(height: 20),
                          _StorageSection(controller: controller),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _CompanyInfoSection(controller: controller),
                    const SizedBox(height: 20),
                    _ConfigurationSection(controller: controller),
                    const SizedBox(height: 20),
                    _FilesSection(controller: controller),
                    const SizedBox(height: 20),
                    _AppearanceSection(),
                    const SizedBox(height: 20),
                    _StorageSection(controller: controller),
                  ],
                ),

              const SizedBox(height: 24),
              // Nota informativa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los archivos (logo y certificado) se guardan automáticamente. Este botón guarda la configuración general.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SaveButton(controller: controller),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _CompanyInfoSection extends StatelessWidget {
  final ConfiguracionController controller;
  const _CompanyInfoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final companyData = controller.companyData ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información de la Empresa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información principal en grid compacto
            Row(
              children: [
                Expanded(
                  child: _CompactCompanyInfoItem(
                    icon: Icons.business,
                    label: 'Razón Social',
                    value: companyData['razonSocial'] ?? 'No especificado',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactCompanyInfoItem(
                    icon: Icons.numbers_outlined,
                    label: 'RNC',
                    value:
                        companyData['rnc'] ??
                        controller.companyRnc ??
                        'No especificado',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _CompactCompanyInfoItem(
                    icon: Icons.person_outlined,
                    label: 'Representante',
                    value:
                        companyData['representanteFiscal'] ?? 'No especificado',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactCompanyInfoItem(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: companyData['telefono'] ?? 'No especificado',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _CompactCompanyInfoItem(
              icon: Icons.location_on_outlined,
              label: 'Dirección',
              value: companyData['direccion'] ?? 'No especificada',
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _CompactCompanyInfoItem(
                    icon: Icons.email_outlined,
                    label: 'Correo',
                    value: companyData['correo'] ?? 'No especificado',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactCompanyInfoItem(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Email',
                    value: companyData['adminEmail'] ?? 'No especificado',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.brightness_6_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Apariencia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Modo oscuro',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Switch(
                  value: isDark,
                  onChanged: (v) {
                    final themeService = Get.isRegistered<ThemeService>()
                        ? Get.find<ThemeService>()
                        : Get.put(ThemeService());
                    themeService.toggleDarkMode(v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isDark
                  ? 'El modo oscuro reduce el brillo y usa fondos oscuros.'
                  : 'El modo claro usa fondos claros y alto contraste.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilesSection extends StatelessWidget {
  final ConfiguracionController controller;
  const _FilesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Archivos del Sistema',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Archivos en fila para aprovechar espacio
            Row(
              children: [
                Expanded(
                  child: _CompactFileCard(
                    title: 'Certificado Digital',
                    icon: Icons.verified_user_outlined,
                    hasFile:
                        controller.digitalSignatureUrl != null &&
                        controller.digitalSignatureUrl!.isNotEmpty &&
                        controller.digitalSignaturePassword != null &&
                        controller.digitalSignaturePassword!.isNotEmpty,
                    onTap: controller.pickDigitalSignature,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactFileCard(
                    title: 'Logo Empresa',
                    icon: Icons.image_outlined,
                    hasFile:
                        controller.companyLogoUrl != null &&
                        controller.companyLogoUrl!.isNotEmpty,
                    onTap: controller.pickCompanyLogo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageSection extends StatelessWidget {
  final ConfiguracionController controller;
  const _StorageSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Almacenamiento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tipo de almacenamiento en chips compactos
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StorageType.values.map((type) {
                return _CompactStorageOption(
                  storageType: type,
                  isSelected: controller.selectedStorageType == type,
                  onTap: () => controller.setStorageType(type),
                  controller: controller,
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Configuración específica del almacenamiento
            GetBuilder<ConfiguracionController>(
              builder: (c) {
                return _StorageConfigContent(controller: c);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? helperText;
  final bool readonly;

  const _ConfigTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.helperText,
    this.readonly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 1,
      readOnly: readonly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        helperText: helperText,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final ConfiguracionController controller;
  const _SaveButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfiguracionController>(
      builder: (c) {
        return GestureDetector(
          onTap: c.loading ? null : c.saveConfiguration,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: c.loading ? Colors.grey.shade400 : const Color(0xFF005285),
              borderRadius: BorderRadius.circular(12),
              boxShadow: c.loading
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFF005285).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (c.loading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.save_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 12),
                Text(
                  c.loading
                      ? 'Guardando Configuración...'
                      : 'Guardar Configuración General',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompactCompanyInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CompactCompanyInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF005285), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigurationSection extends StatelessWidget {
  final ConfiguracionController controller;
  const _ConfigurationSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Configuración API',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ambiente de facturación en chips compactos
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: InvoiceEnvironment.values.map((env) {
                return _CompactEnvironmentChip(
                  environment: env,
                  isSelected: controller.selectedEnvironment == env,
                  onTap: () => controller.setEnvironment(env),
                  controller: controller,
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // URL del servicio
            _ConfigTextField(
              controller: controller.baseEndpointCtrl,
              label: 'URL Base del API',
              icon: Icons.link_outlined,
              helperText: 'URL principal del servicio de facturación',
              readonly: false,
            ),

            const SizedBox(height: 12),

            // Endpoints ERP configurados
            GetBuilder<ConfiguracionController>(
              builder: (c) {
                return _ERPEndpointsSection(controller: c);
              },
            ),

            const SizedBox(height: 12),

            // Switch para datos fake
            GetBuilder<ConfiguracionController>(
              builder: (c) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.useFakeData
                        ? Colors.orange.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: c.useFakeData
                          ? Colors.orange.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        color: c.useFakeData
                            ? Colors.orange.shade700
                            : Colors.grey.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Datos de Prueba',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.useFakeData
                                    ? Colors.orange.shade700
                                    : Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              c.useFakeData
                                  ? 'Usando datos simulados para testing'
                                  : 'Usando datos reales del ERP',
                              style: TextStyle(
                                fontSize: 10,
                                color: c.useFakeData
                                    ? Colors.orange.shade600
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: c.useFakeData,
                        onChanged: c.toggleFakeData,
                        activeColor: Colors.orange,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Endpoint actual compacto
            GetBuilder<ConfiguracionController>(
              builder: (c) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green.shade700,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Endpoint: ${c.getCurrentEndpoint()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Colors.green.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactEnvironmentChip extends StatelessWidget {
  final InvoiceEnvironment environment;
  final bool isSelected;
  final VoidCallback onTap;
  final ConfiguracionController controller;

  const _CompactEnvironmentChip({
    required this.environment,
    required this.isSelected,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    Color getEnvironmentColor() {
      switch (environment) {
        case InvoiceEnvironment.certificacion:
          return Colors.orange;
        case InvoiceEnvironment.test:
          return Colors.blue;
        case InvoiceEnvironment.produccion:
          return Colors.green;
      }
    }

    final color = getEnvironmentColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              controller.getEnvironmentDisplayName(environment),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? color
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactFileCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool hasFile;
  final VoidCallback onTap;

  const _CompactFileCard({
    required this.title,
    required this.icon,
    required this.hasFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasFile
              ? Colors.green.shade50
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasFile
                ? Colors.green.shade300
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle : icon,
              color: hasFile
                  ? Colors.green.shade700
                  : Theme.of(context).iconTheme.color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: hasFile
                    ? Colors.green.shade700
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              hasFile ? 'Configurado' : 'Configurar URL',
              style: TextStyle(
                fontSize: 10,
                color: hasFile
                    ? Colors.green.shade600
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactStorageOption extends StatelessWidget {
  final StorageType storageType;
  final bool isSelected;
  final VoidCallback onTap;
  final ConfiguracionController controller;

  const _CompactStorageOption({
    required this.storageType,
    required this.isSelected,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    Color getStorageColor() {
      switch (storageType) {
        case StorageType.local:
          return Colors.grey.shade700;
        case StorageType.googleDrive:
          return Colors.blue;
        case StorageType.dropbox:
          return Colors.indigo;
        case StorageType.oneDrive:
          return Colors.blue.shade800;
      }
    }

    final color = getStorageColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              controller.getStorageIcon(storageType),
              color: isSelected ? color : Colors.grey.shade600,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              controller.getStorageDisplayName(storageType),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? color
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageConfigContent extends StatelessWidget {
  final ConfiguracionController controller;
  const _StorageConfigContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    switch (controller.selectedStorageType) {
      case StorageType.local:
        return _LocalStorageConfig(controller: controller);
      case StorageType.googleDrive:
        return _GoogleDriveCompactConfig(controller: controller);
      case StorageType.dropbox:
        return _DropboxCompactConfig(controller: controller);
      case StorageType.oneDrive:
        return _OneDriveCompactConfig(controller: controller);
    }
  }
}

class _LocalStorageConfig extends StatelessWidget {
  final ConfiguracionController controller;
  const _LocalStorageConfig({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConfigTextField(
          controller: controller.storagePathCtrl,
          label: 'Ruta Local',
          icon: Icons.folder_outlined,
          helperText: 'Carpeta donde se guardarán las facturas',
          readonly: false,
        ),
      ],
    );
  }
}

class _GoogleDriveCompactConfig extends StatelessWidget {
  final ConfiguracionController controller;
  const _GoogleDriveCompactConfig({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _ConfigTextField(
                controller: controller.storagePathCtrl,
                label: 'Carpeta Base',
                icon: Icons.folder_outlined,
                readonly: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ConfigTextField(
                controller: controller.googleDriveFolderCtrl,
                label: 'ID Carpeta Drive',
                icon: Icons.cloud_outlined,
                readonly: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ConfigTextField(
          controller: controller.googleDriveCredentialsCtrl,
          label: 'Credenciales API (JSON)',
          icon: Icons.key_outlined,
          helperText: 'Credenciales de Google Cloud Console',
          readonly: false,
        ),
      ],
    );
  }
}

class _DropboxCompactConfig extends StatelessWidget {
  final ConfiguracionController controller;
  const _DropboxCompactConfig({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _ConfigTextField(
                controller: controller.storagePathCtrl,
                label: 'Carpeta Base',
                icon: Icons.folder_outlined,
                readonly: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ConfigTextField(
                controller: controller.dropboxTokenCtrl,
                label: 'Token Dropbox',
                icon: Icons.key_outlined,
                readonly: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OneDriveCompactConfig extends StatelessWidget {
  final ConfiguracionController controller;
  const _OneDriveCompactConfig({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _ConfigTextField(
                controller: controller.storagePathCtrl,
                label: 'Carpeta Base',
                icon: Icons.folder_outlined,
                readonly: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ConfigTextField(
                controller: controller.oneDriveTokenCtrl,
                label: 'Token OneDrive',
                icon: Icons.key_outlined,
                readonly: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ERPEndpointsSection extends StatelessWidget {
  final ConfiguracionController controller;
  const _ERPEndpointsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.hasConfiguredEndpoints
            ? Colors.green[50]
            : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: controller.hasConfiguredEndpoints
              ? Colors.green[300]!
              : Colors.orange[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                controller.hasConfiguredEndpoints
                    ? Icons.check_circle
                    : Icons.warning,
                color: controller.hasConfiguredEndpoints
                    ? Colors.green[700]
                    : Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Endpoints ERP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: controller.hasConfiguredEndpoints
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: controller.goToEndpointConfiguration,
                icon: Icon(
                  controller.hasConfiguredEndpoints ? Icons.edit : Icons.add,
                  size: 16,
                ),
                label: Text(
                  controller.hasConfiguredEndpoints ? 'Editar' : 'Configurar',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: controller.hasConfiguredEndpoints
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (controller.hasConfiguredEndpoints) ...[
            Text(
              controller.getEndpointsStatus(),
              style: TextStyle(fontSize: 12, color: Colors.green[600]),
            ),
            const SizedBox(height: 12),

            // Lista de endpoints configurados
            ...controller.configuredEndpoints.take(3).map((endpoint) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getEndpointIcon(endpoint.type),
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            endpoint.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${endpoint.method} - ${endpoint.url}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        endpoint.type.displayName,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            if (controller.configuredEndpoints.length > 3)
              Text(
                'Y ${controller.configuredEndpoints.length - 3} endpoint(s) más...',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ] else ...[
            Text(
              'No hay endpoints configurados. Ve a la configuración inicial para agregar endpoints de tu ERP.',
              style: TextStyle(fontSize: 12, color: Colors.orange[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.orange[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Los endpoints se configuran una sola vez en el setup inicial y se sincronizan automáticamente aquí.',
                      style: TextStyle(fontSize: 10, color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getEndpointIcon(EndpointType type) {
    switch (type) {
      case EndpointType.invoices:
        return Icons.receipt_long;
      case EndpointType.clients:
        return Icons.people;
      case EndpointType.products:
        return Icons.inventory;
      case EndpointType.services:
        return Icons.room_service;
      case EndpointType.payments:
        return Icons.payment;
      case EndpointType.custom:
      default:
        return Icons.api;
    }
  }
}
