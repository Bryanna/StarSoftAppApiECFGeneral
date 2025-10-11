/// Convierte datos del ERP al formato indexado de la DGII
/// Solo incluye campos que existen en los XSD oficiales (e-CF 31 y e-CF 32)
List<Map<String, String>> mapEcfToIndexedFormat(
  Map<String, dynamic> src, {
  int defaultItbisPercent = 18,
}) {
  String s0(Object? v) => (v ?? "").toString().trim();

  /// Clean values - remove null/empty values
  String? cleanValue(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'undefined') return null;
    return str;
  }

  /// dd/mm/yyyy -> dd-mm-yyyy
  String normalizeDate(String input) {
    final t = input.trim();
    if (t.contains('/')) {
      final parts = t.split('/');
      if (parts.length == 3) {
        final d = parts[0].padLeft(2, '0');
        final m = parts[1].padLeft(2, '0');
        final y = parts[2];
        return "$d-$m-$y";
      }
    }
    return t;
  }

  // Clean scenario - remove fields not in XSD and null values
  final cleanedScenario = Map<String, dynamic>.from(src);
  cleanedScenario.remove('EmpresaID');
  cleanedScenario.remove('estatus');
  cleanedScenario.remove('detalle_factura'); // Processed separately in items

  // Remove custom fields not in XSD
  cleanedScenario.remove('rnc_paciente');
  cleanedScenario.remove('aseguradora');
  cleanedScenario.remove('no_autorizacion');
  cleanedScenario.remove('nss');
  cleanedScenario.remove('medico');
  cleanedScenario.remove('cedula_medico');
  cleanedScenario.remove('tipo_factura_titulo');
  cleanedScenario.remove('monto_cobertura');

  // Apply cleaning
  final scenario = <String, dynamic>{};
  cleanedScenario.forEach((key, value) {
    final cleaned = cleanValue(value);
    if (cleaned != null) {
      scenario[key] = cleaned;
    }
  });

  final out = <String, String>{};

  // === ENCABEZADO ===

  // Version (required)
  final version = s0(scenario['Version']);
  if (version.isNotEmpty) out["Version"] = version;

  // === IdDoc ===
  final tipoEcf = s0(scenario['TipoeCF']);
  if (tipoEcf.isNotEmpty) out["TipoeCF"] = tipoEcf;

  final encf = s0(scenario['eNCF'] ?? scenario['ENCF']);
  if (encf.isNotEmpty) out["eNCF"] = encf;

  // FechaVencimientoSecuencia (required for e-CF 31)
  final fechaVencimientoSecuencia = s0(scenario['FechaVencimientoSecuencia']);
  if (fechaVencimientoSecuencia.isNotEmpty) {
    out["FechaVencimientoSecuencia"] = fechaVencimientoSecuencia;
  }

  final indicadorEnvioDiferido = s0(scenario['IndicadorEnvioDiferido']);
  if (indicadorEnvioDiferido.isNotEmpty) {
    out["IndicadorEnvioDiferido"] = indicadorEnvioDiferido;
  }

  final indicadorMontoGravado = s0(scenario['IndicadorMontoGravado']);
  if (indicadorMontoGravado.isNotEmpty) {
    out["IndicadorMontoGravado"] = indicadorMontoGravado;
  }

  final indicadorServicioTodoIncluido = s0(
    scenario['IndicadorServicioTodoIncluido'],
  );
  if (indicadorServicioTodoIncluido.isNotEmpty) {
    out["IndicadorServicioTodoIncluido"] = indicadorServicioTodoIncluido;
  }

  final tipoIngresos = s0(scenario['TipoIngresos']);
  if (tipoIngresos.isNotEmpty) out["TipoIngresos"] = tipoIngresos;

  final tipoPago = s0(scenario['TipoPago']);
  if (tipoPago.isNotEmpty) out["TipoPago"] = tipoPago;

  final fechaLimitePago = s0(scenario['FechaLimitePago']);
  if (fechaLimitePago.isNotEmpty) out["FechaLimitePago"] = fechaLimitePago;

  final terminoPago = s0(scenario['TerminoPago']);
  if (terminoPago.isNotEmpty) out["TerminoPago"] = terminoPago;

  // TablaFormasPago (up to 7 forms)
  for (int i = 1; i <= 7; i++) {
    final formaPago = s0(scenario['FormaPago[$i]']);
    if (formaPago.isNotEmpty) out["FormaPago[$i]"] = formaPago;

    final montoPago = s0(scenario['MontoPago[$i]']);
    if (montoPago.isNotEmpty) out["MontoPago[$i]"] = montoPago;
  }

  final tipoCuentaPago = s0(scenario['TipoCuentaPago']);
  if (tipoCuentaPago.isNotEmpty) out["TipoCuentaPago"] = tipoCuentaPago;

  final numeroCuentaPago = s0(scenario['NumeroCuentaPago']);
  if (numeroCuentaPago.isNotEmpty) out["NumeroCuentaPago"] = numeroCuentaPago;

  final bancoPago = s0(scenario['BancoPago']);
  if (bancoPago.isNotEmpty) out["BancoPago"] = bancoPago;

  final fechaDesde = s0(scenario['FechaDesde']);
  if (fechaDesde.isNotEmpty) out["FechaDesde"] = fechaDesde;

  final fechaHasta = s0(scenario['FechaHasta']);
  if (fechaHasta.isNotEmpty) out["FechaHasta"] = fechaHasta;

  final totalPaginas = s0(scenario['TotalPaginas']);
  if (totalPaginas.isNotEmpty) out["TotalPaginas"] = totalPaginas;

  // === Emisor ===
  final rncEmisor = s0(scenario['RNCEmisor']);
  if (rncEmisor.isNotEmpty) out["RNCEmisor"] = rncEmisor;

  final razonSocialEmisor = s0(scenario['RazonSocialEmisor']);
  if (razonSocialEmisor.isNotEmpty)
    out["RazonSocialEmisor"] = razonSocialEmisor;

  final nombreComercial = s0(scenario['NombreComercial']);
  if (nombreComercial.isNotEmpty) out["NombreComercial"] = nombreComercial;

  final sucursal = s0(scenario['Sucursal']);
  if (sucursal.isNotEmpty) out["Sucursal"] = sucursal;

  final direccionEmisor = s0(scenario['DireccionEmisor']);
  if (direccionEmisor.isNotEmpty) out["DireccionEmisor"] = direccionEmisor;

  final municipio = s0(scenario['Municipio']);
  if (municipio.isNotEmpty) out["Municipio"] = municipio;

  final provincia = s0(scenario['Provincia']);
  if (provincia.isNotEmpty) out["Provincia"] = provincia;

  // TablaTelefonoEmisor (up to 3 phones)
  for (int i = 1; i <= 3; i++) {
    final telefono = s0(scenario['TelefonoEmisor[$i]']);
    if (telefono.isNotEmpty) out["TelefonoEmisor[$i]"] = telefono;
  }

  final correoEmisor = s0(scenario['CorreoEmisor']);
  if (correoEmisor.isNotEmpty) out["CorreoEmisor"] = correoEmisor;

  final webSite = s0(scenario['WebSite']);
  if (webSite.isNotEmpty) out["WebSite"] = webSite;

  final actividadEconomica = s0(scenario['ActividadEconomica']);
  if (actividadEconomica.isNotEmpty)
    out["ActividadEconomica"] = actividadEconomica;

  final codigoVendedor = s0(scenario['CodigoVendedor']);
  if (codigoVendedor.isNotEmpty) out["CodigoVendedor"] = codigoVendedor;

  final numeroFacturaInterna = s0(scenario['NumeroFacturaInterna']);
  if (numeroFacturaInterna.isNotEmpty)
    out["NumeroFacturaInterna"] = numeroFacturaInterna;

  final numeroPedidoInterno = s0(scenario['NumeroPedidoInterno']);
  if (numeroPedidoInterno.isNotEmpty)
    out["NumeroPedidoInterno"] = numeroPedidoInterno;

  final zonaVenta = s0(scenario['ZonaVenta']);
  if (zonaVenta.isNotEmpty) out["ZonaVenta"] = zonaVenta;

  final rutaVenta = s0(scenario['RutaVenta']);
  if (rutaVenta.isNotEmpty) out["RutaVenta"] = rutaVenta;

  final informacionAdicionalEmisor = s0(scenario['InformacionAdicionalEmisor']);
  if (informacionAdicionalEmisor.isNotEmpty)
    out["InformacionAdicionalEmisor"] = informacionAdicionalEmisor;

  final fechaEmision = s0(scenario['FechaEmision']);
  if (fechaEmision.isNotEmpty)
    out["FechaEmision"] = normalizeDate(fechaEmision);

  // === Comprador ===
  final rncComprador = s0(scenario['RNCComprador']);
  if (rncComprador.isNotEmpty) out["RNCComprador"] = rncComprador;

  final identificadorExtranjero = s0(scenario['IdentificadorExtranjero']);
  if (identificadorExtranjero.isNotEmpty)
    out["IdentificadorExtranjero"] = identificadorExtranjero;

  final razonSocialComprador = s0(scenario['RazonSocialComprador']);
  if (razonSocialComprador.isNotEmpty)
    out["RazonSocialComprador"] = razonSocialComprador;

  final contactoComprador = s0(scenario['ContactoComprador']);
  if (contactoComprador.isNotEmpty)
    out["ContactoComprador"] = contactoComprador;

  final correoComprador = s0(scenario['CorreoComprador']);
  if (correoComprador.isNotEmpty) out["CorreoComprador"] = correoComprador;

  final direccionComprador = s0(scenario['DireccionComprador']);
  if (direccionComprador.isNotEmpty)
    out["DireccionComprador"] = direccionComprador;

  final municipioComprador = s0(scenario['MunicipioComprador']);
  if (municipioComprador.isNotEmpty)
    out["MunicipioComprador"] = municipioComprador;

  final provinciaComprador = s0(scenario['ProvinciaComprador']);
  if (provinciaComprador.isNotEmpty)
    out["ProvinciaComprador"] = provinciaComprador;

  final fechaEntrega = s0(scenario['FechaEntrega']);
  if (fechaEntrega.isNotEmpty) out["FechaEntrega"] = fechaEntrega;

  final contactoEntrega = s0(scenario['ContactoEntrega']);
  if (contactoEntrega.isNotEmpty) out["ContactoEntrega"] = contactoEntrega;

  final direccionEntrega = s0(scenario['DireccionEntrega']);
  if (direccionEntrega.isNotEmpty) out["DireccionEntrega"] = direccionEntrega;

  final telefonoAdicional = s0(scenario['TelefonoAdicional']);
  if (telefonoAdicional.isNotEmpty)
    out["TelefonoAdicional"] = telefonoAdicional;

  final fechaOrdenCompra = s0(scenario['FechaOrdenCompra']);
  if (fechaOrdenCompra.isNotEmpty) out["FechaOrdenCompra"] = fechaOrdenCompra;

  final numeroOrdenCompra = s0(scenario['NumeroOrdenCompra']);
  if (numeroOrdenCompra.isNotEmpty)
    out["NumeroOrdenCompra"] = numeroOrdenCompra;

  final codigoInternoComprador = s0(scenario['CodigoInternoComprador']);
  if (codigoInternoComprador.isNotEmpty)
    out["CodigoInternoComprador"] = codigoInternoComprador;

  final responsablePago = s0(scenario['ResponsablePago']);
  if (responsablePago.isNotEmpty) out["ResponsablePago"] = responsablePago;

  final informacionAdicionalComprador = s0(
    scenario['InformacionAdicionalComprador'],
  );
  if (informacionAdicionalComprador.isNotEmpty)
    out["InformacionAdicionalComprador"] = informacionAdicionalComprador;

  // === Totales ===
  final montoGravadoTotal = s0(scenario['MontoGravadoTotal']);
  if (montoGravadoTotal.isNotEmpty)
    out["MontoGravadoTotal"] = montoGravadoTotal;

  final montoGravadoI1 = s0(scenario['MontoGravadoI1']);
  if (montoGravadoI1.isNotEmpty) out["MontoGravadoI1"] = montoGravadoI1;

  final montoGravadoI2 = s0(scenario['MontoGravadoI2']);
  if (montoGravadoI2.isNotEmpty) out["MontoGravadoI2"] = montoGravadoI2;

  final montoGravadoI3 = s0(scenario['MontoGravadoI3']);
  if (montoGravadoI3.isNotEmpty) out["MontoGravadoI3"] = montoGravadoI3;

  final montoExento = s0(scenario['MontoExento']);
  if (montoExento.isNotEmpty) out["MontoExento"] = montoExento;

  final itbis1 = s0(scenario['ITBIS1']);
  if (itbis1.isNotEmpty) out["ITBIS1"] = itbis1;

  final itbis2 = s0(scenario['ITBIS2']);
  if (itbis2.isNotEmpty) out["ITBIS2"] = itbis2;

  final itbis3 = s0(scenario['ITBIS3']);
  if (itbis3.isNotEmpty) out["ITBIS3"] = itbis3;

  final totalItbis = s0(scenario['TotalITBIS']);
  if (totalItbis.isNotEmpty) out["TotalITBIS"] = totalItbis;

  final totalItbis1 = s0(scenario['TotalITBIS1']);
  if (totalItbis1.isNotEmpty) out["TotalITBIS1"] = totalItbis1;

  final totalItbis2 = s0(scenario['TotalITBIS2']);
  if (totalItbis2.isNotEmpty) out["TotalITBIS2"] = totalItbis2;

  final totalItbis3 = s0(scenario['TotalITBIS3']);
  if (totalItbis3.isNotEmpty) out["TotalITBIS3"] = totalItbis3;

  final montoImpuestoAdicional = s0(scenario['MontoImpuestoAdicional']);
  if (montoImpuestoAdicional.isNotEmpty)
    out["MontoImpuestoAdicional"] = montoImpuestoAdicional;

  // ImpuestosAdicionales (up to 20)
  for (int i = 1; i <= 20; i++) {
    final tipoImpuesto = s0(scenario['TipoImpuesto[$i]']);
    if (tipoImpuesto.isNotEmpty) out["TipoImpuesto[$i]"] = tipoImpuesto;

    final tasaImpuestoAdicional = s0(scenario['TasaImpuestoAdicional[$i]']);
    if (tasaImpuestoAdicional.isNotEmpty)
      out["TasaImpuestoAdicional[$i]"] = tasaImpuestoAdicional;

    final montoImpuestoSelectivoConsumoEspecifico = s0(
      scenario['MontoImpuestoSelectivoConsumoEspecifico[$i]'],
    );
    if (montoImpuestoSelectivoConsumoEspecifico.isNotEmpty) {
      out["MontoImpuestoSelectivoConsumoEspecifico[$i]"] =
          montoImpuestoSelectivoConsumoEspecifico;
    }

    final montoImpuestoSelectivoConsumoAdvalorem = s0(
      scenario['MontoImpuestoSelectivoConsumoAdvalorem[$i]'],
    );
    if (montoImpuestoSelectivoConsumoAdvalorem.isNotEmpty) {
      out["MontoImpuestoSelectivoConsumoAdvalorem[$i]"] =
          montoImpuestoSelectivoConsumoAdvalorem;
    }

    final otrosImpuestosAdicionales = s0(
      scenario['OtrosImpuestosAdicionales[$i]'],
    );
    if (otrosImpuestosAdicionales.isNotEmpty)
      out["OtrosImpuestosAdicionales[$i]"] = otrosImpuestosAdicionales;
  }

  final montoTotal = s0(scenario['MontoTotal']);
  if (montoTotal.isNotEmpty) out["MontoTotal"] = montoTotal;

  final montoNoFacturable = s0(scenario['MontoNoFacturable']);
  if (montoNoFacturable.isNotEmpty)
    out["MontoNoFacturable"] = montoNoFacturable;

  final montoPeriodo = s0(scenario['MontoPeriodo']);
  if (montoPeriodo.isNotEmpty) out["MontoPeriodo"] = montoPeriodo;

  final saldoAnterior = s0(scenario['SaldoAnterior']);
  if (saldoAnterior.isNotEmpty) out["SaldoAnterior"] = saldoAnterior;

  final montoAvancePago = s0(scenario['MontoAvancePago']);
  if (montoAvancePago.isNotEmpty) out["MontoAvancePago"] = montoAvancePago;

  final valorPagar = s0(scenario['ValorPagar']);
  if (valorPagar.isNotEmpty) out["ValorPagar"] = valorPagar;

  // Only for e-CF 31 (not in e-CF 32)
  final totalItbisRetenido = s0(scenario['TotalITBISRetenido']);
  if (totalItbisRetenido.isNotEmpty)
    out["TotalITBISRetenido"] = totalItbisRetenido;

  final totalIsrRetencion = s0(scenario['TotalISRRetencion']);
  if (totalIsrRetencion.isNotEmpty)
    out["TotalISRRetencion"] = totalIsrRetencion;

  final totalItbisPercepcion = s0(scenario['TotalITBISPercepcion']);
  if (totalItbisPercepcion.isNotEmpty)
    out["TotalITBISPercepcion"] = totalItbisPercepcion;

  final totalIsrPercepcion = s0(scenario['TotalISRPercepcion']);
  if (totalIsrPercepcion.isNotEmpty)
    out["TotalISRPercepcion"] = totalIsrPercepcion;

  // === DetallesItems ===
  // Find maximum number of items
  int maxItems = 0;
  for (var key in scenario.keys) {
    final match = RegExp(r'NumeroLinea\[(\d+)\]').firstMatch(key);
    if (match != null) {
      final itemNum = int.tryParse(match.group(1) ?? '0') ?? 0;
      if (itemNum > maxItems) maxItems = itemNum;
    }
  }

  // Generate items (up to 1000)
  for (int i = 1; i <= maxItems && i <= 1000; i++) {
    final numeroLinea = s0(scenario['NumeroLinea[$i]']);
    if (numeroLinea.isNotEmpty) out["NumeroLinea[$i]"] = numeroLinea;

    // TablaCodigosItem (up to 5)
    for (int j = 1; j <= 5; j++) {
      final tipoCodigo = s0(scenario['TipoCodigo[$i][$j]']);
      if (tipoCodigo.isNotEmpty) out["TipoCodigo[$i][$j]"] = tipoCodigo;

      final codigoItem = s0(scenario['CodigoItem[$i][$j]']);
      if (codigoItem.isNotEmpty) out["CodigoItem[$i][$j]"] = codigoItem;
    }

    final indicadorFacturacion = s0(scenario['IndicadorFacturacion[$i]']);
    if (indicadorFacturacion.isNotEmpty)
      out["IndicadorFacturacion[$i]"] = indicadorFacturacion;

    // Retencion (only for e-CF 31)
    final indicadorAgenteRetencionoPercepcion = s0(
      scenario['IndicadorAgenteRetencionoPercepcion[$i]'],
    );
    if (indicadorAgenteRetencionoPercepcion.isNotEmpty) {
      out["IndicadorAgenteRetencionoPercepcion[$i]"] =
          indicadorAgenteRetencionoPercepcion;
    }

    final montoItbisRetenido = s0(scenario['MontoITBISRetenido[$i]']);
    if (montoItbisRetenido.isNotEmpty)
      out["MontoITBISRetenido[$i]"] = montoItbisRetenido;

    final montoIsrRetenido = s0(scenario['MontoISRRetenido[$i]']);
    if (montoIsrRetenido.isNotEmpty)
      out["MontoISRRetenido[$i]"] = montoIsrRetenido;

    final nombreItem = s0(scenario['NombreItem[$i]']);
    if (nombreItem.isNotEmpty) out["NombreItem[$i]"] = nombreItem;

    final indicadorBienoServicio = s0(scenario['IndicadorBienoServicio[$i]']);
    if (indicadorBienoServicio.isNotEmpty)
      out["IndicadorBienoServicio[$i]"] = indicadorBienoServicio;

    final descripcionItem = s0(scenario['DescripcionItem[$i]']);
    if (descripcionItem.isNotEmpty)
      out["DescripcionItem[$i]"] = descripcionItem;

    final cantidadItem = s0(scenario['CantidadItem[$i]']);
    if (cantidadItem.isNotEmpty) out["CantidadItem[$i]"] = cantidadItem;

    final unidadMedida = s0(scenario['UnidadMedida[$i]']);
    if (unidadMedida.isNotEmpty) out["UnidadMedida[$i]"] = unidadMedida;

    final cantidadReferencia = s0(scenario['CantidadReferencia[$i]']);
    if (cantidadReferencia.isNotEmpty)
      out["CantidadReferencia[$i]"] = cantidadReferencia;

    final unidadReferencia = s0(scenario['UnidadReferencia[$i]']);
    if (unidadReferencia.isNotEmpty)
      out["UnidadReferencia[$i]"] = unidadReferencia;

    // TablaSubcantidad (up to 5)
    for (int j = 1; j <= 5; j++) {
      final subcantidad = s0(scenario['Subcantidad[$i][$j]']);
      if (subcantidad.isNotEmpty) out["Subcantidad[$i][$j]"] = subcantidad;

      final codigoSubcantidad = s0(scenario['CodigoSubcantidad[$i][$j]']);
      if (codigoSubcantidad.isNotEmpty)
        out["CodigoSubcantidad[$i][$j]"] = codigoSubcantidad;
    }

    final gradosAlcohol = s0(scenario['GradosAlcohol[$i]']);
    if (gradosAlcohol.isNotEmpty) out["GradosAlcohol[$i]"] = gradosAlcohol;

    final precioUnitarioReferencia = s0(
      scenario['PrecioUnitarioReferencia[$i]'],
    );
    if (precioUnitarioReferencia.isNotEmpty)
      out["PrecioUnitarioReferencia[$i]"] = precioUnitarioReferencia;

    final fechaElaboracion = s0(scenario['FechaElaboracion[$i]']);
    if (fechaElaboracion.isNotEmpty)
      out["FechaElaboracion[$i]"] = fechaElaboracion;

    final fechaVencimientoItem = s0(scenario['FechaVencimientoItem[$i]']);
    if (fechaVencimientoItem.isNotEmpty)
      out["FechaVencimientoItem[$i]"] = fechaVencimientoItem;

    // Mineria (only for e-CF 32)
    final pesoNetoKilogramo = s0(scenario['PesoNetoKilogramo[$i]']);
    if (pesoNetoKilogramo.isNotEmpty)
      out["PesoNetoKilogramo[$i]"] = pesoNetoKilogramo;

    final pesoNetoMineria = s0(scenario['PesoNetoMineria[$i]']);
    if (pesoNetoMineria.isNotEmpty)
      out["PesoNetoMineria[$i]"] = pesoNetoMineria;

    final tipoAfiliacion = s0(scenario['TipoAfiliacion[$i]']);
    if (tipoAfiliacion.isNotEmpty) out["TipoAfiliacion[$i]"] = tipoAfiliacion;

    final liquidacion = s0(scenario['Liquidacion[$i]']);
    if (liquidacion.isNotEmpty) out["Liquidacion[$i]"] = liquidacion;

    final precioUnitarioItem = s0(scenario['PrecioUnitarioItem[$i]']);
    if (precioUnitarioItem.isNotEmpty)
      out["PrecioUnitarioItem[$i]"] = precioUnitarioItem;

    final descuentoMonto = s0(scenario['DescuentoMonto[$i]']);
    if (descuentoMonto.isNotEmpty) out["DescuentoMonto[$i]"] = descuentoMonto;

    // TablaSubDescuento (up to 12)
    for (int j = 1; j <= 12; j++) {
      final tipoSubDescuento = s0(scenario['TipoSubDescuento[$i][$j]']);
      if (tipoSubDescuento.isNotEmpty)
        out["TipoSubDescuento[$i][$j]"] = tipoSubDescuento;

      final subDescuentoPorcentaje = s0(
        scenario['SubDescuentoPorcentaje[$i][$j]'],
      );
      if (subDescuentoPorcentaje.isNotEmpty)
        out["SubDescuentoPorcentaje[$i][$j]"] = subDescuentoPorcentaje;

      final montoSubDescuento = s0(scenario['MontoSubDescuento[$i][$j]']);
      if (montoSubDescuento.isNotEmpty)
        out["MontoSubDescuento[$i][$j]"] = montoSubDescuento;
    }

    final recargoMonto = s0(scenario['RecargoMonto[$i]']);
    if (recargoMonto.isNotEmpty) out["RecargoMonto[$i]"] = recargoMonto;

    // TablaSubRecargo (up to 12)
    for (int j = 1; j <= 12; j++) {
      final tipoSubRecargo = s0(scenario['TipoSubRecargo[$i][$j]']);
      if (tipoSubRecargo.isNotEmpty)
        out["TipoSubRecargo[$i][$j]"] = tipoSubRecargo;

      final subRecargoPorcentaje = s0(scenario['SubRecargoPorcentaje[$i][$j]']);
      if (subRecargoPorcentaje.isNotEmpty)
        out["SubRecargoPorcentaje[$i][$j]"] = subRecargoPorcentaje;

      final montoSubRecargo = s0(scenario['MontoSubRecargo[$i][$j]']);
      if (montoSubRecargo.isNotEmpty)
        out["MontoSubRecargo[$i][$j]"] = montoSubRecargo;
    }

    // TablaImpuestoAdicional (up to 2)
    for (int j = 1; j <= 2; j++) {
      final tipoImpuestoItem = s0(scenario['TipoImpuesto[$i][$j]']);
      if (tipoImpuestoItem.isNotEmpty)
        out["TipoImpuesto[$i][$j]"] = tipoImpuestoItem;
    }

    // OtraMonedaDetalle
    final precioOtraMoneda = s0(scenario['PrecioOtraMoneda[$i]']);
    if (precioOtraMoneda.isNotEmpty)
      out["PrecioOtraMoneda[$i]"] = precioOtraMoneda;

    final descuentoOtraMoneda = s0(scenario['DescuentoOtraMoneda[$i]']);
    if (descuentoOtraMoneda.isNotEmpty)
      out["DescuentoOtraMoneda[$i]"] = descuentoOtraMoneda;

    final recargoOtraMoneda = s0(scenario['RecargoOtraMoneda[$i]']);
    if (recargoOtraMoneda.isNotEmpty)
      out["RecargoOtraMoneda[$i]"] = recargoOtraMoneda;

    final montoItemOtraMoneda = s0(scenario['MontoItemOtraMoneda[$i]']);
    if (montoItemOtraMoneda.isNotEmpty)
      out["MontoItemOtraMoneda[$i]"] = montoItemOtraMoneda;

    final montoItem = s0(scenario['MontoItem[$i]']);
    if (montoItem.isNotEmpty) out["MontoItem[$i]"] = montoItem;
  }

  // === InformacionReferencia ===
  final ncfModificado = s0(scenario['NCFModificado']);
  if (ncfModificado.isNotEmpty) out["NCFModificado"] = ncfModificado;

  final rncOtroContribuyente = s0(scenario['RNCOtroContribuyente']);
  if (rncOtroContribuyente.isNotEmpty)
    out["RNCOtroContribuyente"] = rncOtroContribuyente;

  final fechaNcfModificado = s0(scenario['FechaNCFModificado']);
  if (fechaNcfModificado.isNotEmpty)
    out["FechaNCFModificado"] = fechaNcfModificado;

  final codigoModificacion = s0(scenario['CodigoModificacion']);
  if (codigoModificacion.isNotEmpty)
    out["CodigoModificacion"] = codigoModificacion;

  final fechaHoraFirma = s0(scenario['FechaHoraFirma']);
  if (fechaHoraFirma.isNotEmpty) out["FechaHoraFirma"] = fechaHoraFirma;

  // Preserve ID if present
  if (src['id'] != null) {
    out["id"] = s0(src['id']);
  }

  return [out];
}
