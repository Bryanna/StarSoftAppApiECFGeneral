enum TipoComprobante {
  facturaConsumo, // 31
  facturaCreditoFiscal, // 32
  facturaGubernamental, // 33
  facturaRegimenEspecial, // 34
  notaDebito, // 41
  notaCredito, // 43
  comprobanteCompra, // 44
  gastosMenores, // 45
  pagosExterior, // 46
  regimenEspecial, // 47
  exportacion, // 48
  pagoElectronico, // 49
  donacion, // 50
  bonoIncentivo, // 51
  ventaTerceros, // 52
  gastoGubernamental, // 53
  compraGubernamental, // 54
}

extension TipoComprobanteExtension on TipoComprobante {
  String get codigo {
    switch (this) {
      case TipoComprobante.facturaConsumo:
        return '31';
      case TipoComprobante.facturaCreditoFiscal:
        return '32';
      case TipoComprobante.facturaGubernamental:
        return '33';
      case TipoComprobante.facturaRegimenEspecial:
        return '34';
      case TipoComprobante.notaDebito:
        return '41';
      case TipoComprobante.notaCredito:
        return '43';
      case TipoComprobante.comprobanteCompra:
        return '44';
      case TipoComprobante.gastosMenores:
        return '45';
      case TipoComprobante.pagosExterior:
        return '46';
      case TipoComprobante.regimenEspecial:
        return '47';
      case TipoComprobante.exportacion:
        return '48';
      case TipoComprobante.pagoElectronico:
        return '49';
      case TipoComprobante.donacion:
        return '50';
      case TipoComprobante.bonoIncentivo:
        return '51';
      case TipoComprobante.ventaTerceros:
        return '52';
      case TipoComprobante.gastoGubernamental:
        return '53';
      case TipoComprobante.compraGubernamental:
        return '54';
    }
  }

  String get descripcion {
    switch (this) {
      case TipoComprobante.facturaConsumo:
        return 'Factura de Consumo Electrónica';
      case TipoComprobante.facturaCreditoFiscal:
        return 'Factura de Crédito Fiscal Electrónica';
      case TipoComprobante.facturaGubernamental:
        return 'Factura Gubernamental Electrónica';
      case TipoComprobante.facturaRegimenEspecial:
        return 'Factura Regímenes Especiales Electrónica';
      case TipoComprobante.notaDebito:
        return 'Nota de Débito Electrónica';
      case TipoComprobante.notaCredito:
        return 'Nota de Crédito Electrónica';
      case TipoComprobante.comprobanteCompra:
        return 'Comprobante de Compras Electrónico';
      case TipoComprobante.gastosMenores:
        return 'Comprobante de Gastos Menores Electrónico';
      case TipoComprobante.pagosExterior:
        return 'Comprobante para Pagos al Exterior Electrónico';
      case TipoComprobante.regimenEspecial:
        return 'Comprobante para Regímenes Especiales Electrónico';
      case TipoComprobante.exportacion:
        return 'Comprobante de Exportación Electrónico';
      case TipoComprobante.pagoElectronico:
        return 'Comprobante para Pagos Electrónicos';
      case TipoComprobante.donacion:
        return 'Comprobante de Donaciones Electrónico';
      case TipoComprobante.bonoIncentivo:
        return 'Comprobante de Bonos o Incentivos Electrónico';
      case TipoComprobante.ventaTerceros:
        return 'Comprobante de Venta por Terceros Electrónico';
      case TipoComprobante.gastoGubernamental:
        return 'Comprobante Gubernamental de Gastos Electrónico';
      case TipoComprobante.compraGubernamental:
        return 'Comprobante de Compras Gubernamentales Electrónico';
    }
  }

  String get aliasCorto {
    switch (this) {
      case TipoComprobante.facturaConsumo:
        return 'Consumo';
      case TipoComprobante.facturaCreditoFiscal:
        return 'Crédito Fiscal';
      case TipoComprobante.facturaGubernamental:
        return 'Gubernamental';
      case TipoComprobante.facturaRegimenEspecial:
        return 'Régimen Especial';
      case TipoComprobante.notaDebito:
        return 'Nota Débito';
      case TipoComprobante.notaCredito:
        return 'Nota Crédito';
      case TipoComprobante.comprobanteCompra:
        return 'Compras';
      case TipoComprobante.gastosMenores:
        return 'Gastos Menores';
      case TipoComprobante.pagosExterior:
        return 'Pagos Exterior';
      case TipoComprobante.regimenEspecial:
        return 'Régimen Especial';
      case TipoComprobante.exportacion:
        return 'Exportación';
      case TipoComprobante.pagoElectronico:
        return 'Pago Electrónico';
      case TipoComprobante.donacion:
        return 'Donaciones';
      case TipoComprobante.bonoIncentivo:
        return 'Bonos/Incentivos';
      case TipoComprobante.ventaTerceros:
        return 'Venta Terceros';
      case TipoComprobante.gastoGubernamental:
        return 'Gasto Gubernamental';
      case TipoComprobante.compraGubernamental:
        return 'Compras Gubernamentales';
    }
  }
}

TipoComprobante? tipoComprobanteDesdeCodigo(String? codigo) {
  switch (codigo) {
    case '31':
      return TipoComprobante.facturaConsumo;
    case '32':
      return TipoComprobante.facturaCreditoFiscal;
    case '33':
      return TipoComprobante.facturaGubernamental;
    case '34':
      return TipoComprobante.facturaRegimenEspecial;
    case '41':
      return TipoComprobante.notaDebito;
    case '43':
      return TipoComprobante.notaCredito;
    case '44':
      return TipoComprobante.comprobanteCompra;
    case '45':
      return TipoComprobante.gastosMenores;
    case '46':
      return TipoComprobante.pagosExterior;
    case '47':
      return TipoComprobante.regimenEspecial;
    case '48':
      return TipoComprobante.exportacion;
    case '49':
      return TipoComprobante.pagoElectronico;
    case '50':
      return TipoComprobante.donacion;
    case '51':
      return TipoComprobante.bonoIncentivo;
    case '52':
      return TipoComprobante.ventaTerceros;
    case '53':
      return TipoComprobante.gastoGubernamental;
    case '54':
      return TipoComprobante.compraGubernamental;
    default:
      return null;
  }
}

String? _extraerCodigoDesdeDocumento(String? documento) {
  if (documento == null || documento.isEmpty) return null;
  // Busca 'E' seguido de dos dígitos (ej. E31...)
  final m = RegExp(r'[Ee]\s*(\d{2})').firstMatch(documento);
  if (m != null) return m.group(1);
  // Si no contiene 'E', intenta primeros dos dígitos en la cadena
  final m2 = RegExp(r'^(\d{2})').firstMatch(documento);
  return m2?.group(1);
}

String? descripcionDesdeDocumento(String? documento) {
  final codigo = _extraerCodigoDesdeDocumento(documento);
  final tipo = tipoComprobanteDesdeCodigo(codigo);
  return tipo?.descripcion;
}

String? aliasDesdeDocumento(String? documento) {
  final codigo = _extraerCodigoDesdeDocumento(documento);
  final tipo = tipoComprobanteDesdeCodigo(codigo);
  return tipo?.aliasCorto;
}