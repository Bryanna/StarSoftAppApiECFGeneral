// Modelo simple para facturas del ERP - acepta datos tal como vienen del API
class ERPInvoice {
  // TODOS los campos del API - exactamente como vienen
  final int? fFacturaSecuencia;
  final String? version;
  final String? tipoecf;
  final String? encf;
  final String? fechavencimientosecuencia;
  final String? indicadorenviodiferido;
  final String? indicadormontogravado;
  final String? indicadornotacredito;
  final String? tipoingresos;
  final String? tipopago;
  final String? formapago1;
  final String? montopago1;
  final String? formapago2;
  final String? montopago2;
  final String? formapago3;
  final String? montopago3;
  final String? formapago4;
  final String? montopago4;
  final String? formapago5;
  final String? montopago5;
  final String? formapago6;
  final String? montopago6;
  final String? formapago7;
  final String? montopago7;
  final String? tipocuentapago;
  final String? numerocuentapago;
  final String? bancopago;
  final String? fechadesde;
  final String? fechahasta;
  final String? fechalimitepago;
  final String? terminopago;
  final String? totalpaginas;
  final String? rncemisor;
  final String? razonsocialemisor;
  final String? nombrecomercial;
  final String? sucursal;
  final String? direccionemisor;
  final String? municipio;
  final String? provincia;
  final String? telefonoemisor1;
  final String? telefonoemisor2;
  final String? telefonoemisor3;
  final String? correoemisor;
  final String? website;
  final String? actividadeconomica;
  final String? codigovendedor;
  final String? numerofacturainterna;
  final String? numeropedidointerno;
  final String? zonaventa;
  final String? rutaventa;
  final String? informacionadicionalemisor;
  final String? fechaemision;
  final String? rnccomprador;
  final String? identificadorextranjero;
  final String? razonsocialcomprador;
  final String? contactocomprador;
  final String? correocomprador;
  final String? direccioncomprador;
  final String? municipiocomprador;
  final String? provinciacomprador;
  final String? paiscomprador;
  final String? fechaentrega;
  final String? contactoentrega;
  final String? direccionentrega;
  final String? telefonoadicional;
  final String? fechaordencompra;
  final String? numeroordencompra;
  final String? codigointernocomprador;
  final String? responsablepago;
  final String? informacionadicionalcomprador;
  final String? fechaembarque;
  final String? numeroembarque;
  final String? numerocontenedor;
  final String? numeroreferencia;
  final String? nombrepuertoembarque;
  final String? condicionesentrega;
  final String? totalfob;
  final String? seguro;
  final String? flete;
  final String? otrosgastos;
  final String? totalcif;
  final String? regimenaduanero;
  final String? nombrepuertosalida;
  final String? nombrepuertodesembarque;
  final String? pesobruto;
  final String? pesoneto;
  final String? unidadpesobruto;
  final String? unidadpesoneto;
  final String? cantidadbulto;
  final String? unidadbulto;
  final String? volumenbulto;
  final String? unidadvolumen;
  final String? viatransporte;
  final String? paisorigen;
  final String? direcciondestino;
  final String? paisdestino;
  final String? rncidentificacioncompaniatransportista;
  final String? nombrecompaniatransportista;
  final String? numeroviaje;
  final String? conductor;
  final String? documentotransporte;
  final String? ficha;
  final String? placa;
  final String? rutatransporte;
  final String? zonatransporte;
  final String? numeroalbaran;
  final String? montogravadototal;
  final String? montogravadoi1;
  final String? montogravadoi2;
  final String? montogravadoi3;
  final String? montoexento;
  final String? itbis1;
  final String? itbis2;
  final String? itbis3;
  final String? totalitbis;
  final String? totalitbis1;
  final String? totalitbis2;
  final String? totalitbis3;
  final String? montoimpuestoadicional;
  final String? tipoimpuesto1;
  final String? tasaimpuestoadicional1;
  final String? montoimpuestoselectivoconsumoespecifico1;
  final String? montoimpuestoselectivoconsumoadvalorem1;
  final String? otrosimpuestoadicionales1;
  final String? tipoimpuesto2;
  final String? tasaimpuestoadicional2;
  final String? montoimpuestoselectivoconsumoespecifico2;
  final String? montoimpuestoselectivoconsumoadvalorem2;
  final String? otrosimpuestoadicionales2;
  final String? tipoimpuesto3;
  final String? tasaimpuestoadicional3;
  final String? montoimpuestoselectivoconsumoespecifico3;
  final String? montoimpuestoselectivoconsumoadvalorem3;
  final String? otrosimpuestoadicionales3;
  final String? tipoimpuesto4;
  final String? tasaimpuestoadicional4;
  final String? montoimpuestoselectivoconsumoespecifico4;
  final String? montoimpuestoselectivoconsumoadvalorem4;
  final String? otrosimpuestoadicionales4;
  final String? montototal;
  final String? montonofacturable;
  final String? montoperiodo;
  final String? saldoanterior;
  final String? montoavancepago;
  final String? valorpagar;
  final String? totalitbisretenido;
  final String? totalisrretencion;
  final String? totalitbispercepcion;
  final String? totalisrpercepcion;
  final String? tipomoneda;
  final String? tipocambio;
  final String? montogravadototalotramoneda;
  final String? montogravado1otramoneda;
  final String? montogravado2otramoneda;
  final String? montogravado3otramoneda;
  final String? montoexentootramoneda;
  final String? totalitbisotramoneda;
  final String? totalitbis1otramoneda;
  final String? totalitbis2otramoneda;
  final String? totalitbis3otramoneda;
  final String? montoimpuestoadicionalotramoneda;
  final String? tipoimpuestootramoneda1;
  final String? tasaimpuestoadicionalotramoneda1;
  final String? montoimpuestoselectivoconsumoespecificootramoneda1;
  final String? montoimpuestoselectivoconsumoadvaloremotramoneda1;
  final String? otrosimpuestoadicionalesotramoneda1;
  final String? tipoimpuestootramoneda2;
  final String? tasaimpuestoadicionalotramoneda2;
  final String? montoimpuestoselectivoconsumoespecificootramoneda2;
  final String? montoimpuestoselectivoconsumoadvaloremotramoneda2;
  final String? otrosimpuestoadicionalesotramoneda2;
  final String? tipoimpuestootramoneda3;
  final String? tasaimpuestoadicionalotramoneda3;
  final String? montoimpuestoselectivoconsumoespecificootramoneda3;
  final String? montoimpuestoselectivoconsumoadvaloremotramoneda3;
  final String? otrosimpuestoadicionalesotramoneda3;
  final String? tipoimpuestootramoneda4;
  final String? tasaimpuestoadicionalotramoneda4;
  final String? montoimpuestoselectivoconsumoespecificootramoneda4;
  final String? montoimpuestoselectivoconsumoadvaloremotramoneda4;
  final String? otrosimpuestoadicionalesotramoneda4;
  final String? montototalotramoneda;
  final String? fechahorafirma;
  final String? codigoseguridad;
  final String? linkOriginal;
  final String? tipoComprobante;
  final String? tablatelefonoemisor;
  final String? tablaformaspago;
  final String? detalleFactura;
  final String? tipoTabEnvioFactura;

  // Nuevos campos del ERP actualizado
  final String? rncPaciente;
  final String? aseguradora;
  final String? noAutorizacion;
  final String? nss;
  final String? medico;
  final String? cedulaMedico;
  final String? tipoFacturaTitulo;
  final String? montoCobertura;

  ERPInvoice({
    this.fFacturaSecuencia,
    this.version,
    this.tipoecf,
    this.encf,
    this.fechavencimientosecuencia,
    this.indicadorenviodiferido,
    this.indicadormontogravado,
    this.indicadornotacredito,
    this.tipoingresos,
    this.tipopago,
    this.formapago1,
    this.montopago1,
    this.formapago2,
    this.montopago2,
    this.formapago3,
    this.montopago3,
    this.formapago4,
    this.montopago4,
    this.formapago5,
    this.montopago5,
    this.formapago6,
    this.montopago6,
    this.formapago7,
    this.montopago7,
    this.tipocuentapago,
    this.numerocuentapago,
    this.bancopago,
    this.fechadesde,
    this.fechahasta,
    this.fechalimitepago,
    this.terminopago,
    this.totalpaginas,
    this.rncemisor,
    this.razonsocialemisor,
    this.nombrecomercial,
    this.sucursal,
    this.direccionemisor,
    this.municipio,
    this.provincia,
    this.telefonoemisor1,
    this.telefonoemisor2,
    this.telefonoemisor3,
    this.correoemisor,
    this.website,
    this.actividadeconomica,
    this.codigovendedor,
    this.numerofacturainterna,
    this.numeropedidointerno,
    this.zonaventa,
    this.rutaventa,
    this.informacionadicionalemisor,
    this.fechaemision,
    this.rnccomprador,
    this.identificadorextranjero,
    this.razonsocialcomprador,
    this.contactocomprador,
    this.correocomprador,
    this.direccioncomprador,
    this.municipiocomprador,
    this.provinciacomprador,
    this.paiscomprador,
    this.fechaentrega,
    this.contactoentrega,
    this.direccionentrega,
    this.telefonoadicional,
    this.fechaordencompra,
    this.numeroordencompra,
    this.codigointernocomprador,
    this.responsablepago,
    this.informacionadicionalcomprador,
    this.fechaembarque,
    this.numeroembarque,
    this.numerocontenedor,
    this.numeroreferencia,
    this.nombrepuertoembarque,
    this.condicionesentrega,
    this.totalfob,
    this.seguro,
    this.flete,
    this.otrosgastos,
    this.totalcif,
    this.regimenaduanero,
    this.nombrepuertosalida,
    this.nombrepuertodesembarque,
    this.pesobruto,
    this.pesoneto,
    this.unidadpesobruto,
    this.unidadpesoneto,
    this.cantidadbulto,
    this.unidadbulto,
    this.volumenbulto,
    this.unidadvolumen,
    this.viatransporte,
    this.paisorigen,
    this.direcciondestino,
    this.paisdestino,
    this.rncidentificacioncompaniatransportista,
    this.nombrecompaniatransportista,
    this.numeroviaje,
    this.conductor,
    this.documentotransporte,
    this.ficha,
    this.placa,
    this.rutatransporte,
    this.zonatransporte,
    this.numeroalbaran,
    this.montogravadototal,
    this.montogravadoi1,
    this.montogravadoi2,
    this.montogravadoi3,
    this.montoexento,
    this.itbis1,
    this.itbis2,
    this.itbis3,
    this.totalitbis,
    this.totalitbis1,
    this.totalitbis2,
    this.totalitbis3,
    this.montoimpuestoadicional,
    this.tipoimpuesto1,
    this.tasaimpuestoadicional1,
    this.montoimpuestoselectivoconsumoespecifico1,
    this.montoimpuestoselectivoconsumoadvalorem1,
    this.otrosimpuestoadicionales1,
    this.tipoimpuesto2,
    this.tasaimpuestoadicional2,
    this.montoimpuestoselectivoconsumoespecifico2,
    this.montoimpuestoselectivoconsumoadvalorem2,
    this.otrosimpuestoadicionales2,
    this.tipoimpuesto3,
    this.tasaimpuestoadicional3,
    this.montoimpuestoselectivoconsumoespecifico3,
    this.montoimpuestoselectivoconsumoadvalorem3,
    this.otrosimpuestoadicionales3,
    this.tipoimpuesto4,
    this.tasaimpuestoadicional4,
    this.montoimpuestoselectivoconsumoespecifico4,
    this.montoimpuestoselectivoconsumoadvalorem4,
    this.otrosimpuestoadicionales4,
    this.montototal,
    this.montonofacturable,
    this.montoperiodo,
    this.saldoanterior,
    this.montoavancepago,
    this.valorpagar,
    this.totalitbisretenido,
    this.totalisrretencion,
    this.totalitbispercepcion,
    this.totalisrpercepcion,
    this.tipomoneda,
    this.tipocambio,
    this.montogravadototalotramoneda,
    this.montogravado1otramoneda,
    this.montogravado2otramoneda,
    this.montogravado3otramoneda,
    this.montoexentootramoneda,
    this.totalitbisotramoneda,
    this.totalitbis1otramoneda,
    this.totalitbis2otramoneda,
    this.totalitbis3otramoneda,
    this.montoimpuestoadicionalotramoneda,
    this.tipoimpuestootramoneda1,
    this.tasaimpuestoadicionalotramoneda1,
    this.montoimpuestoselectivoconsumoespecificootramoneda1,
    this.montoimpuestoselectivoconsumoadvaloremotramoneda1,
    this.otrosimpuestoadicionalesotramoneda1,
    this.tipoimpuestootramoneda2,
    this.tasaimpuestoadicionalotramoneda2,
    this.montoimpuestoselectivoconsumoespecificootramoneda2,
    this.montoimpuestoselectivoconsumoadvaloremotramoneda2,
    this.otrosimpuestoadicionalesotramoneda2,
    this.tipoimpuestootramoneda3,
    this.tasaimpuestoadicionalotramoneda3,
    this.montoimpuestoselectivoconsumoespecificootramoneda3,
    this.montoimpuestoselectivoconsumoadvaloremotramoneda3,
    this.otrosimpuestoadicionalesotramoneda3,
    this.tipoimpuestootramoneda4,
    this.tasaimpuestoadicionalotramoneda4,
    this.montoimpuestoselectivoconsumoespecificootramoneda4,
    this.montoimpuestoselectivoconsumoadvaloremotramoneda4,
    this.otrosimpuestoadicionalesotramoneda4,
    this.montototalotramoneda,
    this.fechahorafirma,
    this.codigoseguridad,
    this.linkOriginal,
    this.tipoComprobante,
    this.tablatelefonoemisor,
    this.tablaformaspago,
    this.detalleFactura,
    this.tipoTabEnvioFactura,

    // Nuevos campos del ERP actualizado
    this.rncPaciente,
    this.aseguradora,
    this.noAutorizacion,
    this.nss,
    this.medico,
    this.cedulaMedico,
    this.tipoFacturaTitulo,
    this.montoCobertura,
  });

  // Constructor desde JSON - acepta cualquier campo sin errores
  factory ERPInvoice.fromJson(Map<String, dynamic> json) {
    return ERPInvoice(
      fFacturaSecuencia:
          json['f_factura_secuencia'] ?? json['fFacturaSecuencia'],
      version: json['Version']?.toString() ?? json['version']?.toString(),
      tipoecf: json['TipoeCF']?.toString() ?? json['tipoecf']?.toString(),
      encf: json['ENCF']?.toString() ?? json['encf']?.toString(),
      fechavencimientosecuencia:
          json['FechaVencimientoSecuencia']?.toString() ??
          json['fechavencimientosecuencia']?.toString(),
      indicadorenviodiferido:
          json['IndicadorEnvioDiferido']?.toString() ??
          json['indicadorenviodiferido']?.toString(),
      indicadormontogravado:
          json['IndicadorMontoGravado']?.toString() ??
          json['indicadormontogravado']?.toString(),
      indicadornotacredito:
          json['IndicadorNotaCredito']?.toString() ??
          json['indicadornotacredito']?.toString(),
      tipoingresos:
          json['TipoIngresos']?.toString() ?? json['tipoingresos']?.toString(),
      tipopago: json['TipoPago']?.toString() ?? json['tipopago']?.toString(),
      formapago1:
          json['FormaPago[1]']?.toString() ?? json['formapago1']?.toString(),
      montopago1:
          json['MontoPago[1]']?.toString() ?? json['montopago1']?.toString(),
      formapago2:
          json['FormaPago[2]']?.toString() ?? json['formapago2']?.toString(),
      montopago2:
          json['MontoPago[2]']?.toString() ?? json['montopago2']?.toString(),
      formapago3:
          json['FormaPago[3]']?.toString() ?? json['formapago3']?.toString(),
      montopago3:
          json['MontoPago[3]']?.toString() ?? json['montopago3']?.toString(),
      formapago4:
          json['FormaPago[4]']?.toString() ?? json['formapago4']?.toString(),
      montopago4:
          json['MontoPago[4]']?.toString() ?? json['montopago4']?.toString(),
      formapago5:
          json['FormaPago[5]']?.toString() ?? json['formapago5']?.toString(),
      montopago5:
          json['MontoPago[5]']?.toString() ?? json['montopago5']?.toString(),
      formapago6:
          json['FormaPago[6]']?.toString() ?? json['formapago6']?.toString(),
      montopago6:
          json['MontoPago[6]']?.toString() ?? json['montopago6']?.toString(),
      formapago7:
          json['FormaPago[7]']?.toString() ?? json['formapago7']?.toString(),
      montopago7:
          json['MontoPago[7]']?.toString() ?? json['montopago7']?.toString(),
      tipocuentapago:
          json['TipoCuentaPago']?.toString() ??
          json['tipocuentapago']?.toString(),
      numerocuentapago:
          json['NumeroCuentaPago']?.toString() ??
          json['numerocuentapago']?.toString(),
      bancopago: json['BancoPago']?.toString() ?? json['bancopago']?.toString(),
      fechadesde:
          json['FechaDesde']?.toString() ?? json['fechadesde']?.toString(),
      fechahasta:
          json['FechaHasta']?.toString() ?? json['fechahasta']?.toString(),
      fechalimitepago:
          json['FechaLimitePago']?.toString() ??
          json['fechalimitepago']?.toString(),
      terminopago:
          json['TerminoPago']?.toString() ?? json['terminopago']?.toString(),
      totalpaginas:
          json['TotalPaginas']?.toString() ?? json['totalpaginas']?.toString(),
      rncemisor: json['RNCEmisor']?.toString() ?? json['rncemisor']?.toString(),
      razonsocialemisor:
          json['RazonSocialEmisor']?.toString() ??
          json['razonsocialemisor']?.toString(),
      nombrecomercial:
          json['NombreComercial']?.toString() ??
          json['nombrecomercial']?.toString(),
      sucursal: json['Sucursal']?.toString() ?? json['sucursal']?.toString(),
      direccionemisor:
          json['DireccionEmisor']?.toString() ??
          json['direccionemisor']?.toString(),
      municipio: json['Municipio']?.toString() ?? json['municipio']?.toString(),
      provincia: json['Provincia']?.toString() ?? json['provincia']?.toString(),
      telefonoemisor1:
          json['TelefonoEmisor[1]']?.toString() ??
          json['telefonoemisor1']?.toString(),
      telefonoemisor2:
          json['TelefonoEmisor[2]']?.toString() ??
          json['telefonoemisor2']?.toString(),
      telefonoemisor3:
          json['TelefonoEmisor[3]']?.toString() ??
          json['telefonoemisor3']?.toString(),
      correoemisor:
          json['CorreoEmisor']?.toString() ?? json['correoemisor']?.toString(),
      website: json['WebSite']?.toString() ?? json['website']?.toString(),
      actividadeconomica:
          json['ActividadEconomica']?.toString() ??
          json['actividadeconomica']?.toString(),
      codigovendedor:
          json['CodigoVendedor']?.toString() ??
          json['codigovendedor']?.toString(),
      numerofacturainterna:
          json['NumeroFacturaInterna']?.toString() ??
          json['numerofacturainterna']?.toString(),
      numeropedidointerno:
          json['NumeroPedidoInterno']?.toString() ??
          json['numeropedidointerno']?.toString(),
      zonaventa: json['ZonaVenta']?.toString() ?? json['zonaventa']?.toString(),
      rutaventa: json['RutaVenta']?.toString() ?? json['rutaventa']?.toString(),
      informacionadicionalemisor:
          json['InformacionAdicionalEmisor']?.toString() ??
          json['informacionadicionalemisor']?.toString(),
      fechaemision:
          json['FechaEmision']?.toString() ?? json['fechaemision']?.toString(),
      rnccomprador:
          json['RNCComprador']?.toString() ?? json['rnccomprador']?.toString(),
      identificadorextranjero:
          json['IdentificadorExtranjero']?.toString() ??
          json['identificadorextranjero']?.toString(),
      razonsocialcomprador:
          json['RazonSocialComprador']?.toString() ??
          json['razonsocialcomprador']?.toString(),
      contactocomprador:
          json['ContactoComprador']?.toString() ??
          json['contactocomprador']?.toString(),
      correocomprador:
          json['CorreoComprador']?.toString() ??
          json['correocomprador']?.toString(),
      direccioncomprador:
          json['DireccionComprador']?.toString() ??
          json['direccioncomprador']?.toString(),
      municipiocomprador:
          json['MunicipioComprador']?.toString() ??
          json['municipiocomprador']?.toString(),
      provinciacomprador:
          json['ProvinciaComprador']?.toString() ??
          json['provinciacomprador']?.toString(),
      paiscomprador:
          json['PaisComprador']?.toString() ??
          json['paiscomprador']?.toString(),
      fechaentrega:
          json['FechaEntrega']?.toString() ?? json['fechaentrega']?.toString(),
      contactoentrega:
          json['ContactoEntrega']?.toString() ??
          json['contactoentrega']?.toString(),
      direccionentrega:
          json['DireccionEntrega']?.toString() ??
          json['direccionentrega']?.toString(),
      telefonoadicional:
          json['TelefonoAdicional']?.toString() ??
          json['telefonoadicional']?.toString(),
      fechaordencompra:
          json['FechaOrdenCompra']?.toString() ??
          json['fechaordencompra']?.toString(),
      numeroordencompra:
          json['NumeroOrdenCompra']?.toString() ??
          json['numeroordencompra']?.toString(),
      codigointernocomprador:
          json['CodigoInternoComprador']?.toString() ??
          json['codigointernocomprador']?.toString(),
      responsablepago:
          json['ResponsablePago']?.toString() ??
          json['responsablepago']?.toString(),
      informacionadicionalcomprador:
          json['InformacionAdicionalComprador']?.toString() ??
          json['informacionadicionalcomprador']?.toString(),
      fechaembarque:
          json['FechaEmbarque']?.toString() ??
          json['fechaembarque']?.toString(),
      numeroembarque:
          json['NumeroEmbarque']?.toString() ??
          json['numeroembarque']?.toString(),
      numerocontenedor:
          json['NumeroContenedor']?.toString() ??
          json['numerocontenedor']?.toString(),
      numeroreferencia:
          json['NumeroReferencia']?.toString() ??
          json['numeroreferencia']?.toString(),
      nombrepuertoembarque:
          json['NombrePuertoEmbarque']?.toString() ??
          json['nombrepuertoembarque']?.toString(),
      condicionesentrega:
          json['CondicionesEntrega']?.toString() ??
          json['condicionesentrega']?.toString(),
      totalfob: json['TotalFOB']?.toString() ?? json['totalfob']?.toString(),
      seguro: json['Seguro']?.toString() ?? json['seguro']?.toString(),
      flete: json['Flete']?.toString() ?? json['flete']?.toString(),
      otrosgastos:
          json['OtrosGastos']?.toString() ?? json['otrosgastos']?.toString(),
      totalcif: json['TotalCIF']?.toString() ?? json['totalcif']?.toString(),
      regimenaduanero:
          json['RegimenAduanero']?.toString() ??
          json['regimenaduanero']?.toString(),
      nombrepuertosalida:
          json['NombrePuertoSalida']?.toString() ??
          json['nombrepuertosalida']?.toString(),
      nombrepuertodesembarque:
          json['NombrePuertoDesembarque']?.toString() ??
          json['nombrepuertodesembarque']?.toString(),
      pesobruto: json['PesoBruto']?.toString() ?? json['pesobruto']?.toString(),
      pesoneto: json['PesoNeto']?.toString() ?? json['pesoneto']?.toString(),
      unidadpesobruto:
          json['UnidadPesoBruto']?.toString() ??
          json['unidadpesobruto']?.toString(),
      unidadpesoneto:
          json['UnidadPesoNeto']?.toString() ??
          json['unidadpesoneto']?.toString(),
      cantidadbulto:
          json['CantidadBulto']?.toString() ??
          json['cantidadbulto']?.toString(),
      unidadbulto:
          json['UnidadBulto']?.toString() ?? json['unidadbulto']?.toString(),
      volumenbulto:
          json['VolumenBulto']?.toString() ?? json['volumenbulto']?.toString(),
      unidadvolumen:
          json['UnidadVolumen']?.toString() ??
          json['unidadvolumen']?.toString(),
      viatransporte:
          json['ViaTransporte']?.toString() ??
          json['viatransporte']?.toString(),
      paisorigen:
          json['PaisOrigen']?.toString() ?? json['paisorigen']?.toString(),
      direcciondestino:
          json['DireccionDestino']?.toString() ??
          json['direcciondestino']?.toString(),
      paisdestino:
          json['PaisDestino']?.toString() ?? json['paisdestino']?.toString(),
      rncidentificacioncompaniatransportista:
          json['RNCIdentificacionCompaniaTransportista']?.toString() ??
          json['rncidentificacioncompaniatransportista']?.toString(),
      nombrecompaniatransportista:
          json['NombreCompaniaTransportista']?.toString() ??
          json['nombrecompaniatransportista']?.toString(),
      numeroviaje:
          json['NumeroViaje']?.toString() ?? json['numeroviaje']?.toString(),
      conductor: json['Conductor']?.toString() ?? json['conductor']?.toString(),
      documentotransporte:
          json['DocumentoTransporte']?.toString() ??
          json['documentotransporte']?.toString(),
      ficha: json['Ficha']?.toString() ?? json['ficha']?.toString(),
      placa: json['Placa']?.toString() ?? json['placa']?.toString(),
      rutatransporte:
          json['RutaTransporte']?.toString() ??
          json['rutatransporte']?.toString(),
      zonatransporte:
          json['ZonaTransporte']?.toString() ??
          json['zonatransporte']?.toString(),
      numeroalbaran:
          json['NumeroAlbaran']?.toString() ??
          json['numeroalbaran']?.toString(),
      montogravadototal:
          json['MontoGravadoTotal']?.toString() ??
          json['montogravadototal']?.toString(),
      montogravadoi1:
          json['MontoGravadoI1']?.toString() ??
          json['montogravadoi1']?.toString(),
      montogravadoi2:
          json['MontoGravadoI2']?.toString() ??
          json['montogravadoi2']?.toString(),
      montogravadoi3:
          json['MontoGravadoI3']?.toString() ??
          json['montogravadoi3']?.toString(),
      montoexento:
          json['MontoExento']?.toString() ?? json['montoexento']?.toString(),
      itbis1: json['ITBIS1']?.toString() ?? json['itbis1']?.toString(),
      itbis2: json['ITBIS2']?.toString() ?? json['itbis2']?.toString(),
      itbis3: json['ITBIS3']?.toString() ?? json['itbis3']?.toString(),
      totalitbis:
          json['TotalITBIS']?.toString() ?? json['totalitbis']?.toString(),
      totalitbis1:
          json['TotalITBIS1']?.toString() ?? json['totalitbis1']?.toString(),
      totalitbis2:
          json['TotalITBIS2']?.toString() ?? json['totalitbis2']?.toString(),
      totalitbis3:
          json['TotalITBIS3']?.toString() ?? json['totalitbis3']?.toString(),
      montoimpuestoadicional:
          json['MontoImpuestoAdicional']?.toString() ??
          json['montoimpuestoadicional']?.toString(),
      montototal:
          json['MontoTotal']?.toString() ?? json['montototal']?.toString(),
      montonofacturable:
          json['MontoNoFacturable']?.toString() ??
          json['montonofacturable']?.toString(),
      montoperiodo:
          json['MontoPeriodo']?.toString() ?? json['montoperiodo']?.toString(),
      saldoanterior:
          json['SaldoAnterior']?.toString() ??
          json['saldoanterior']?.toString(),
      montoavancepago:
          json['MontoAvancePago']?.toString() ??
          json['montoavancepago']?.toString(),
      valorpagar:
          json['ValorPagar']?.toString() ?? json['valorpagar']?.toString(),
      totalitbisretenido:
          json['TotalITBISRetenido']?.toString() ??
          json['totalitbisretenido']?.toString(),
      totalisrretencion:
          json['TotalISRRetencion']?.toString() ??
          json['totalisrretencion']?.toString(),
      totalitbispercepcion:
          json['TotalITBISPercepcion']?.toString() ??
          json['totalitbispercepcion']?.toString(),
      totalisrpercepcion:
          json['TotalISRPercepcion']?.toString() ??
          json['totalisrpercepcion']?.toString(),
      tipomoneda:
          json['TipoMoneda']?.toString() ?? json['tipomoneda']?.toString(),
      tipocambio:
          json['TipoCambio']?.toString() ?? json['tipocambio']?.toString(),
      fechahorafirma:
          json['FechaHoraFirma']?.toString() ??
          json['fechahorafirma']?.toString(),
      codigoseguridad:
          json['CodigoSeguridad']?.toString() ??
          json['codigoseguridad']?.toString(),
      linkOriginal:
          json['link_original'] ?? json['linkOriginal'] ?? json['xmlPublicUrl'],
      tipoComprobante: json['tipo_comprobante'] ?? json['tipoComprobante'],
      tablatelefonoemisor:
          json['TablaTelefonoEmisor']?.toString() ??
          json['tablatelefonoemisor']?.toString(),
      tablaformaspago:
          json['TablaFormasPago']?.toString() ??
          json['tablaformaspago']?.toString(),
      detalleFactura:
          json['DetalleFactura']?.toString() ??
          json['detalleFactura']?.toString() ??
          json['detalle_factura']?.toString(),
      tipoTabEnvioFactura:
          json['TipoTabEnvioFactura']?.toString() ??
          json['tipoTabEnvioFactura']?.toString(),

      // Nuevos campos del ERP actualizado
      rncPaciente: json['rnc_paciente']?.toString(),
      aseguradora: json['aseguradora']?.toString(),
      noAutorizacion: json['no_autorizacion']?.toString(),
      nss: json['nss']?.toString(),
      medico: json['medico']?.toString(),
      cedulaMedico: json['cedula_medico']?.toString(),
      tipoFacturaTitulo: json['tipo_factura_titulo']?.toString(),
      montoCobertura: json['monto_cobertura']?.toString(),
    );
  }

  // Métodos de conveniencia para compatibilidad con el código existente
  String? get fDocumento => encf;
  bool? get fAnulada => null; // No viene del ERP
  bool? get fPagada => null; // No viene del ERP
  String? get fSubtotal => montogravadototal;
  String? get fItbis => totalitbis;
  String? get fTotal => montototal;
  DateTime? get fechaHoraFirma => _parseDate(fechahorafirma);
  String? get fArsNombre => null; // No viene del ERP

  // Getters adicionales para facilitar el uso
  String get numeroFactura => encf ?? numerofacturainterna ?? '';
  String get clienteNombre => razonsocialcomprador ?? '';
  String get clienteRnc => rnccomprador ?? '';
  String get empresaNombre => razonsocialemisor ?? nombrecomercial ?? '';
  String get empresaRnc => rncemisor ?? '';

  // Montos como double para cálculos
  double get totalAmount => _parseAmount(montototal);
  double get subtotalAmount => _parseAmount(montogravadototal);
  double get itbisAmount => _parseAmount(totalitbis);
  double get exentoAmount => _parseAmount(montoexento);

  // Estado de la factura
  String get estado => 'Procesada'; // Por defecto, ya que viene del ERP

  // Información de contacto
  String get clienteEmail => correocomprador ?? '';
  String get clienteDireccion => direccioncomprador ?? '';
  String get empresaEmail => correoemisor ?? '';
  String get empresaDireccion => direccionemisor ?? '';
  String get empresaTelefono => telefonoemisor1 ?? '';

  // Parser de fecha mejorado
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // Formato DD-MM-YYYY (común en el ERP dominicano)
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]), // año
            int.parse(parts[1]), // mes
            int.parse(parts[0]), // día
          );
        }
      }
      // Formato DD/MM/YYYY
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]), // año
            int.parse(parts[1]), // mes
            int.parse(parts[0]), // día
          );
        }
      }
      // Formato ISO
      return DateTime.tryParse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Parser de montos
  double _parseAmount(String? amountStr) {
    if (amountStr == null || amountStr.isEmpty) return 0.0;
    try {
      // Remover comas y espacios
      final cleanAmount = amountStr.replaceAll(',', '').replaceAll(' ', '');
      return double.tryParse(cleanAmount) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Getter para fecha de emisión como DateTime
  DateTime? get fechaemisionDateTime => _parseDate(fechaemision);

  // Getter para fecha de vencimiento como DateTime
  DateTime? get fechaVencimientoDateTime =>
      _parseDate(fechavencimientosecuencia);

  // Método para convertir a Map (útil para debugging)
  Map<String, dynamic> toMap() {
    return {
      'numeroFactura': numeroFactura,
      'fechaEmision': fechaemision,
      'clienteNombre': clienteNombre,
      'clienteRnc': clienteRnc,
      'empresaNombre': empresaNombre,
      'empresaRnc': empresaRnc,
      'subtotal': fSubtotal,
      'itbis': fItbis,
      'total': fTotal,
      'estado': estado,
    };
  }

  // Constructor desde el modelo Invoice legacy (para compatibilidad)
  factory ERPInvoice.fromLegacyInvoice(dynamic legacyInvoice) {
    // Asumiendo que legacyInvoice es un Datum del modelo anterior
    return ERPInvoice(
      encf: legacyInvoice.encf,
      fechaemision: legacyInvoice.fechaemision?.toString(),
      rncemisor: legacyInvoice.rncemisor,
      razonsocialemisor: legacyInvoice.razonsocialemisor?.toString(),
      rnccomprador: legacyInvoice.rnccomprador,
      razonsocialcomprador: legacyInvoice.razonsocialcomprador?.toString(),
      direccioncomprador: legacyInvoice.direccioncomprador,
      montototal: legacyInvoice.montototal,
      montogravadototal: legacyInvoice.montogravadototal,
      totalitbis: legacyInvoice.totalitbis,
      montoexento: legacyInvoice.montoexento,
      fechahorafirma: legacyInvoice.fechahorafirma?.toString(),
      codigoseguridad: legacyInvoice.codigoseguridad?.toString(),
      fechavencimientosecuencia: legacyInvoice.fechavencimientosecuencia
          ?.toString(),
    );
  }

  // Método toString para debugging
  @override
  String toString() {
    return 'ERPInvoice(numero: $numeroFactura, cliente: $clienteNombre, total: $fTotal, fecha: $fechaemision)';
  }
}
