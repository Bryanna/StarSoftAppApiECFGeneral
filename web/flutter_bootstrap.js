// Flutter Bootstrap Configuration
// Este archivo será generado automáticamente por Flutter
// Configuración optimizada para GitHub Pages

{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: function(engineInitializer) {
    engineInitializer.initializeEngine().then(function(appRunner) {
      appRunner.runApp();
    });
  }
});
