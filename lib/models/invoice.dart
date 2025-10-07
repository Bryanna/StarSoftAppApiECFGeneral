// To parse this JSON data, do
//
//     final invoiceModel = invoiceModelFromJson(jsonString);

import 'dart:convert';

InvoiceModel invoiceModelFromJson(String str) =>
    InvoiceModel.fromJson(json.decode(str));

String invoiceModelToJson(InvoiceModel data) => json.encode(data.toJson());

class InvoiceModel {
  String? status;
  int? code;
  String? message;
  List<Datum>? data;

  InvoiceModel({this.status, this.code, this.message, this.data});

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
    status: json["status"],
    code: json["code"],
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "code": code,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? fFacturaSecuencia;
  String? fDocumento;
  String? version;
  String? tipoecf;
  String? encf;
  DateTime? fechavencimientosecuencia;
  String? indicadornotacredito;
  dynamic indicadorenviodiferido;
  String? indicadormontogravado;
  String? tipoingresos;
  String? tipopago;
  dynamic fechalimitepago;
  dynamic terminopago;
  int? formapago1;
  String? montopago1;
  int? formapago2;
  String? montopago2;
  dynamic formapago3;
  dynamic montopago3;
  dynamic formapago4;
  dynamic montopago4;
  dynamic formapago5;
  dynamic montopago5;
  dynamic formapago6;
  dynamic montopago6;
  dynamic formapago7;
  dynamic montopago7;
  String? tipocuentapago;
  String? numerocuentapago;
  String? bancopago;
  dynamic fechadesde;
  dynamic fechahasta;
  dynamic totalpaginas;
  String? rncemisor;
  Razonsocialemisor? razonsocialemisor;
  Nombrecomercial? nombrecomercial;
  dynamic sucursal;
  Direccionemisor? direccionemisor;
  String? municipio;
  String? provincia;
  Telefono? telefonoemisor1;
  Telefono? telefonoemisor2;
  dynamic telefonoemisor3;
  String? correoemisor;
  Website? website;
  dynamic actividadeconomica;
  Codigovendedor? codigovendedor;
  Numero? numerofacturainterna;
  Numero? numeropedidointerno;
  Zonaventa? zonaventa;
  dynamic rutaventa;
  String? informacionadicionalemisor;
  DateTime? fechaemision;
  String? rnccomprador;
  String? identificadorextranjero;
  Razonsocialcomprador? razonsocialcomprador;
  Contactocomprador? contactocomprador;
  Correocomprador? correocomprador;
  String? direccioncomprador;
  String? municipiocomprador;
  String? provinciacomprador;
  dynamic paiscomprador;
  DateTime? fechaentrega;
  String? contactoentrega;
  dynamic direccionentrega;
  Telefono? telefonoadicional;
  DateTime? fechaordencompra;
  String? numeroordencompra;
  String? codigointernocomprador;
  dynamic responsablepago;
  dynamic informacionadicionalcomprador;
  dynamic fechaembarque;
  dynamic numeroembarque;
  String? numerocontenedor;
  String? numeroreferencia;
  dynamic nombrepuertoembarque;
  dynamic condicionesentrega;
  dynamic totalfob;
  dynamic seguro;
  dynamic flete;
  dynamic otrosgastos;
  dynamic totalcif;
  dynamic regimenaduanero;
  dynamic nombrepuertosalida;
  dynamic nombrepuertodesembarque;
  dynamic pesobruto;
  dynamic pesoneto;
  dynamic unidadpesobruto;
  dynamic unidadpesoneto;
  dynamic cantidadbulto;
  dynamic unidadbulto;
  dynamic volumenbulto;
  dynamic unidadvolumen;
  dynamic viatransporte;
  dynamic paisorigen;
  dynamic direcciondestino;
  dynamic paisdestino;
  dynamic rncidentificacioncompaniatransportista;
  dynamic nombrecompaniatransportista;
  dynamic numeroviaje;
  String? conductor;
  String? documentotransporte;
  String? ficha;
  String? placa;
  String? rutatransporte;
  String? zonatransporte;
  String? numeroalbaran;
  String? montogravadototal;
  String? montogravadoi1;
  String? montogravadoi2;
  String? montogravadoi3;
  String? montoexento;
  String? itbis1;
  String? itbis2;
  String? itbis3;
  String? totalitbis;
  String? totalitbis1;
  String? totalitbis2;
  String? totalitbis3;
  dynamic montoimpuestoadicional;
  dynamic tipoimpuesto1;
  dynamic tasaimpuestoadicional1;
  dynamic montoimpuestoselectivoconsumoespecifico1;
  dynamic montoimpuestoselectivoconsumoadvalorem1;
  dynamic otrosimpuestoadicionales1;
  dynamic tipoimpuesto2;
  dynamic tasaimpuestoadicional2;
  dynamic montoimpuestoselectivoconsumoespecifico2;
  dynamic montoimpuestoselectivoconsumoadvalorem2;
  dynamic otrosimpuestoadicionales2;
  dynamic tipoimpuesto3;
  dynamic tasaimpuestoadicional3;
  dynamic montoimpuestoselectivoconsumoespecifico3;
  dynamic montoimpuestoselectivoconsumoadvalorem3;
  dynamic otrosimpuestoadicionales3;
  dynamic tipoimpuesto4;
  dynamic tasaimpuestoadicional4;
  dynamic montoimpuestoselectivoconsumoespecifico4;
  dynamic montoimpuestoselectivoconsumoadvalorem4;
  dynamic otrosimpuestoadicionales4;
  String? montototal;
  String? montonofacturable;
  String? montoperiodo;
  dynamic saldoanterior;
  dynamic montoavancepago;
  String? valorpagar;
  String? totalitbisretenido;
  String? totalisrretencion;
  dynamic totalitbispercepcion;
  dynamic totalisrpercepcion;
  String? tipomoneda;
  String? tipocambio;
  dynamic montogravadototalotramoneda;
  dynamic montogravado1Otramoneda;
  dynamic montogravado2Otramoneda;
  dynamic montogravado3Otramoneda;
  String? montoexentootramoneda;
  dynamic totalitbisotramoneda;
  dynamic totalitbis1Otramoneda;
  dynamic totalitbis2Otramoneda;
  dynamic totalitbis3Otramoneda;
  dynamic montoimpuestoadicionalotramoneda;
  dynamic tipoimpuestootramoneda1;
  dynamic tasaimpuestoadicionalotramoneda1;
  dynamic montoimpuestoselectivoconsumoespecificootramoneda1;
  dynamic montoimpuestoselectivoconsumoadvaloremotramoneda1;
  dynamic otrosimpuestoadicionalesotramoneda1;
  dynamic tipoimpuestootramoneda2;
  dynamic tasaimpuestoadicionalotramoneda2;
  dynamic montoimpuestoselectivoconsumoespecificootramoneda2;
  dynamic montoimpuestoselectivoconsumoadvaloremotramoneda2;
  dynamic otrosimpuestoadicionalesotramoneda2;
  dynamic tipoimpuestootramoneda3;
  dynamic tasaimpuestoadicionalotramoneda3;
  dynamic montoimpuestoselectivoconsumoespecificootramoneda3;
  dynamic montoimpuestoselectivoconsumoadvaloremotramoneda3;
  dynamic otrosimpuestoadicionalesotramoneda3;
  dynamic tipoimpuestootramoneda4;
  dynamic tasaimpuestoadicionalotramoneda4;
  dynamic montoimpuestoselectivoconsumoespecificootramoneda4;
  dynamic montoimpuestoselectivoconsumoadvaloremotramoneda4;
  dynamic otrosimpuestoadicionalesotramoneda4;
  String? montototalotramoneda;
  DateTime? fechaHoraFirma;
  String? ncfmodificado;
  DateTime? fechancfmodificado;
  int? codigomodificacion;
  String? razonmodificacion;
  String? codigoSeguridad;
  String? linkOriginal;
  String? tipoComprobante;
  Tablatelefonoemisor? tablatelefonoemisor;
  List<TablaFormasPago>? tablaFormasPago;
  dynamic fHora;
  dynamic fPacienteId;
  dynamic fPacienteNombre;
  dynamic fPacienteCedula;
  dynamic fEdad;
  dynamic fMedicoId;
  dynamic fMedicoNombre;
  dynamic fDiagnostico;
  dynamic fMedicoEmergencia;
  dynamic fArsId;
  dynamic fArsNombre;
  dynamic fAutorizacionArs;
  String? fMontoCobertura;
  String? fDiferenciaPagar;
  String? fSubtotal;
  String? fDescuento;
  String? fBaseImponible;
  String? fMontoExento;
  String? fItbis;
  String? fTotal;
  int? fMoneda;
  String? fTasa;
  String? fEfectivo;
  String? fCheque;
  String? fTarjetaDebito;
  String? fTarjetaCredito;
  String? fTransferencia;
  int? fDiasCredito;
  dynamic fFechaVencimiento;
  String? fBalance;
  bool? fPagada;
  int? fTipoNcf;
  dynamic fNcf;
  dynamic fFechaVenceNcf;
  String? fRncEmisor;
  String? fRncReceptor;
  String? fReceptorNombre;
  String? fReceptorEmail;
  String? fReceptorTelefono;
  String? fDireccionReceptor;
  int? fHechopor;
  int? fCajero;
  int? fVendedor;
  dynamic fObservacion;
  bool? fPosteada;
  bool? fAnulada;
  DateTime? fCreadoEn;
  DateTime? fModificadoEn;

  Datum({
    this.fFacturaSecuencia,
    this.fDocumento,
    this.version,
    this.tipoecf,
    this.encf,
    this.fechavencimientosecuencia,
    this.indicadornotacredito,
    this.indicadorenviodiferido,
    this.indicadormontogravado,
    this.tipoingresos,
    this.tipopago,
    this.fechalimitepago,
    this.terminopago,
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
    this.montogravado1Otramoneda,
    this.montogravado2Otramoneda,
    this.montogravado3Otramoneda,
    this.montoexentootramoneda,
    this.totalitbisotramoneda,
    this.totalitbis1Otramoneda,
    this.totalitbis2Otramoneda,
    this.totalitbis3Otramoneda,
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
    this.fechaHoraFirma,
    this.ncfmodificado,
    this.fechancfmodificado,
    this.codigomodificacion,
    this.razonmodificacion,
    this.codigoSeguridad,
    this.linkOriginal,
    this.tipoComprobante,
    this.tablatelefonoemisor,
    this.tablaFormasPago,
    this.fHora,
    this.fPacienteId,
    this.fPacienteNombre,
    this.fPacienteCedula,
    this.fEdad,
    this.fMedicoId,
    this.fMedicoNombre,
    this.fDiagnostico,
    this.fMedicoEmergencia,
    this.fArsId,
    this.fArsNombre,
    this.fAutorizacionArs,
    this.fMontoCobertura,
    this.fDiferenciaPagar,
    this.fSubtotal,
    this.fDescuento,
    this.fBaseImponible,
    this.fMontoExento,
    this.fItbis,
    this.fTotal,
    this.fMoneda,
    this.fTasa,
    this.fEfectivo,
    this.fCheque,
    this.fTarjetaDebito,
    this.fTarjetaCredito,
    this.fTransferencia,
    this.fDiasCredito,
    this.fFechaVencimiento,
    this.fBalance,
    this.fPagada,
    this.fTipoNcf,
    this.fNcf,
    this.fFechaVenceNcf,
    this.fRncEmisor,
    this.fRncReceptor,
    this.fReceptorNombre,
    this.fReceptorEmail,
    this.fReceptorTelefono,
    this.fDireccionReceptor,
    this.fHechopor,
    this.fCajero,
    this.fVendedor,
    this.fObservacion,
    this.fPosteada,
    this.fAnulada,
    this.fCreadoEn,
    this.fModificadoEn,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    fFacturaSecuencia: json["f_factura_secuencia"],
    fDocumento: json["f_documento"],
    version: json["version"],
    tipoecf: json["tipoecf"],
    encf: json["encf"],
    fechavencimientosecuencia: json["fechavencimientosecuencia"] == null
        ? null
        : DateTime.parse(json["fechavencimientosecuencia"]),
    indicadornotacredito: json["indicadornotacredito"],
    indicadorenviodiferido: json["indicadorenviodiferido"],
    indicadormontogravado: json["indicadormontogravado"],
    tipoingresos: json["tipoingresos"],
    tipopago: json["tipopago"],
    fechalimitepago: json["fechalimitepago"],
    terminopago: json["terminopago"],
    formapago1: json["formapago1"],
    montopago1: json["montopago1"],
    formapago2: json["formapago2"],
    montopago2: json["montopago2"],
    formapago3: json["formapago3"],
    montopago3: json["montopago3"],
    formapago4: json["formapago4"],
    montopago4: json["montopago4"],
    formapago5: json["formapago5"],
    montopago5: json["montopago5"],
    formapago6: json["formapago6"],
    montopago6: json["montopago6"],
    formapago7: json["formapago7"],
    montopago7: json["montopago7"],
    tipocuentapago: json["tipocuentapago"],
    numerocuentapago: json["numerocuentapago"],
    bancopago: json["bancopago"],
    fechadesde: json["fechadesde"],
    fechahasta: json["fechahasta"],
    totalpaginas: json["totalpaginas"],
    rncemisor: json["rncemisor"],
    razonsocialemisor: razonsocialemisorValues.map[json["razonsocialemisor"]],
    nombrecomercial: nombrecomercialValues.map[json["nombrecomercial"]],
    sucursal: json["sucursal"],
    direccionemisor: direccionemisorValues.map[json["direccionemisor"]],
    municipio: json["municipio"],
    provincia: json["provincia"],
    telefonoemisor1: telefonoValues.map[json["telefonoemisor1"]],
    telefonoemisor2: telefonoValues.map[json["telefonoemisor2"]],
    telefonoemisor3: json["telefonoemisor3"],
    correoemisor: json["correoemisor"],
    website: websiteValues.map[json["website"]],
    actividadeconomica: json["actividadeconomica"],
    codigovendedor: codigovendedorValues.map[json["codigovendedor"]],
    numerofacturainterna: numeroValues.map[json["numerofacturainterna"]],
    numeropedidointerno: numeroValues.map[json["numeropedidointerno"]],
    zonaventa: zonaventaValues.map[json["zonaventa"]],
    rutaventa: json["rutaventa"],
    informacionadicionalemisor: json["informacionadicionalemisor"],
    fechaemision: json["fechaemision"] == null
        ? null
        : DateTime.parse(json["fechaemision"]),
    rnccomprador: json["rnccomprador"],
    identificadorextranjero: json["identificadorextranjero"],
    razonsocialcomprador:
        razonsocialcompradorValues.map[json["razonsocialcomprador"]],
    contactocomprador: contactocompradorValues.map[json["contactocomprador"]],
    correocomprador: correocompradorValues.map[json["correocomprador"]],
    direccioncomprador: json["direccioncomprador"],
    municipiocomprador: json["municipiocomprador"],
    provinciacomprador: json["provinciacomprador"],
    paiscomprador: json["paiscomprador"],
    fechaentrega: json["fechaentrega"] == null
        ? null
        : DateTime.parse(json["fechaentrega"]),
    contactoentrega: json["contactoentrega"],
    direccionentrega: json["direccionentrega"],
    telefonoadicional: telefonoValues.map[json["telefonoadicional"]],
    fechaordencompra: json["fechaordencompra"] == null
        ? null
        : DateTime.parse(json["fechaordencompra"]),
    numeroordencompra: json["numeroordencompra"],
    codigointernocomprador: json["codigointernocomprador"],
    responsablepago: json["responsablepago"],
    informacionadicionalcomprador: json["informacionadicionalcomprador"],
    fechaembarque: json["fechaembarque"],
    numeroembarque: json["numeroembarque"],
    numerocontenedor: json["numerocontenedor"],
    numeroreferencia: json["numeroreferencia"],
    nombrepuertoembarque: json["nombrepuertoembarque"],
    condicionesentrega: json["condicionesentrega"],
    totalfob: json["totalfob"],
    seguro: json["seguro"],
    flete: json["flete"],
    otrosgastos: json["otrosgastos"],
    totalcif: json["totalcif"],
    regimenaduanero: json["regimenaduanero"],
    nombrepuertosalida: json["nombrepuertosalida"],
    nombrepuertodesembarque: json["nombrepuertodesembarque"],
    pesobruto: json["pesobruto"],
    pesoneto: json["pesoneto"],
    unidadpesobruto: json["unidadpesobruto"],
    unidadpesoneto: json["unidadpesoneto"],
    cantidadbulto: json["cantidadbulto"],
    unidadbulto: json["unidadbulto"],
    volumenbulto: json["volumenbulto"],
    unidadvolumen: json["unidadvolumen"],
    viatransporte: json["viatransporte"],
    paisorigen: json["paisorigen"],
    direcciondestino: json["direcciondestino"],
    paisdestino: json["paisdestino"],
    rncidentificacioncompaniatransportista:
        json["rncidentificacioncompaniatransportista"],
    nombrecompaniatransportista: json["nombrecompaniatransportista"],
    numeroviaje: json["numeroviaje"],
    conductor: json["conductor"],
    documentotransporte: json["documentotransporte"],
    ficha: json["ficha"],
    placa: json["placa"],
    rutatransporte: json["rutatransporte"],
    zonatransporte: json["zonatransporte"],
    numeroalbaran: json["numeroalbaran"],
    montogravadototal: json["montogravadototal"],
    montogravadoi1: json["montogravadoi1"],
    montogravadoi2: json["montogravadoi2"],
    montogravadoi3: json["montogravadoi3"],
    montoexento: json["montoexento"],
    itbis1: json["itbis1"],
    itbis2: json["itbis2"],
    itbis3: json["itbis3"],
    totalitbis: json["totalitbis"],
    totalitbis1: json["totalitbis1"],
    totalitbis2: json["totalitbis2"],
    totalitbis3: json["totalitbis3"],
    montoimpuestoadicional: json["montoimpuestoadicional"],
    tipoimpuesto1: json["tipoimpuesto1"],
    tasaimpuestoadicional1: json["tasaimpuestoadicional1"],
    montoimpuestoselectivoconsumoespecifico1:
        json["montoimpuestoselectivoconsumoespecifico1"],
    montoimpuestoselectivoconsumoadvalorem1:
        json["montoimpuestoselectivoconsumoadvalorem1"],
    otrosimpuestoadicionales1: json["otrosimpuestoadicionales1"],
    tipoimpuesto2: json["tipoimpuesto2"],
    tasaimpuestoadicional2: json["tasaimpuestoadicional2"],
    montoimpuestoselectivoconsumoespecifico2:
        json["montoimpuestoselectivoconsumoespecifico2"],
    montoimpuestoselectivoconsumoadvalorem2:
        json["montoimpuestoselectivoconsumoadvalorem2"],
    otrosimpuestoadicionales2: json["otrosimpuestoadicionales2"],
    tipoimpuesto3: json["tipoimpuesto3"],
    tasaimpuestoadicional3: json["tasaimpuestoadicional3"],
    montoimpuestoselectivoconsumoespecifico3:
        json["montoimpuestoselectivoconsumoespecifico3"],
    montoimpuestoselectivoconsumoadvalorem3:
        json["montoimpuestoselectivoconsumoadvalorem3"],
    otrosimpuestoadicionales3: json["otrosimpuestoadicionales3"],
    tipoimpuesto4: json["tipoimpuesto4"],
    tasaimpuestoadicional4: json["tasaimpuestoadicional4"],
    montoimpuestoselectivoconsumoespecifico4:
        json["montoimpuestoselectivoconsumoespecifico4"],
    montoimpuestoselectivoconsumoadvalorem4:
        json["montoimpuestoselectivoconsumoadvalorem4"],
    otrosimpuestoadicionales4: json["otrosimpuestoadicionales4"],
    montototal: json["montototal"],
    montonofacturable: json["montonofacturable"],
    montoperiodo: json["montoperiodo"],
    saldoanterior: json["saldoanterior"],
    montoavancepago: json["montoavancepago"],
    valorpagar: json["valorpagar"],
    totalitbisretenido: json["totalitbisretenido"],
    totalisrretencion: json["totalisrretencion"],
    totalitbispercepcion: json["totalitbispercepcion"],
    totalisrpercepcion: json["totalisrpercepcion"],
    tipomoneda: json["tipomoneda"],
    tipocambio: json["tipocambio"],
    montogravadototalotramoneda: json["montogravadototalotramoneda"],
    montogravado1Otramoneda: json["montogravado1otramoneda"],
    montogravado2Otramoneda: json["montogravado2otramoneda"],
    montogravado3Otramoneda: json["montogravado3otramoneda"],
    montoexentootramoneda: json["montoexentootramoneda"],
    totalitbisotramoneda: json["totalitbisotramoneda"],
    totalitbis1Otramoneda: json["totalitbis1otramoneda"],
    totalitbis2Otramoneda: json["totalitbis2otramoneda"],
    totalitbis3Otramoneda: json["totalitbis3otramoneda"],
    montoimpuestoadicionalotramoneda: json["montoimpuestoadicionalotramoneda"],
    tipoimpuestootramoneda1: json["tipoimpuestootramoneda1"],
    tasaimpuestoadicionalotramoneda1: json["tasaimpuestoadicionalotramoneda1"],
    montoimpuestoselectivoconsumoespecificootramoneda1:
        json["montoimpuestoselectivoconsumoespecificootramoneda1"],
    montoimpuestoselectivoconsumoadvaloremotramoneda1:
        json["montoimpuestoselectivoconsumoadvaloremotramoneda1"],
    otrosimpuestoadicionalesotramoneda1:
        json["otrosimpuestoadicionalesotramoneda1"],
    tipoimpuestootramoneda2: json["tipoimpuestootramoneda2"],
    tasaimpuestoadicionalotramoneda2: json["tasaimpuestoadicionalotramoneda2"],
    montoimpuestoselectivoconsumoespecificootramoneda2:
        json["montoimpuestoselectivoconsumoespecificootramoneda2"],
    montoimpuestoselectivoconsumoadvaloremotramoneda2:
        json["montoimpuestoselectivoconsumoadvaloremotramoneda2"],
    otrosimpuestoadicionalesotramoneda2:
        json["otrosimpuestoadicionalesotramoneda2"],
    tipoimpuestootramoneda3: json["tipoimpuestootramoneda3"],
    tasaimpuestoadicionalotramoneda3: json["tasaimpuestoadicionalotramoneda3"],
    montoimpuestoselectivoconsumoespecificootramoneda3:
        json["montoimpuestoselectivoconsumoespecificootramoneda3"],
    montoimpuestoselectivoconsumoadvaloremotramoneda3:
        json["montoimpuestoselectivoconsumoadvaloremotramoneda3"],
    otrosimpuestoadicionalesotramoneda3:
        json["otrosimpuestoadicionalesotramoneda3"],
    tipoimpuestootramoneda4: json["tipoimpuestootramoneda4"],
    tasaimpuestoadicionalotramoneda4: json["tasaimpuestoadicionalotramoneda4"],
    montoimpuestoselectivoconsumoespecificootramoneda4:
        json["montoimpuestoselectivoconsumoespecificootramoneda4"],
    montoimpuestoselectivoconsumoadvaloremotramoneda4:
        json["montoimpuestoselectivoconsumoadvaloremotramoneda4"],
    otrosimpuestoadicionalesotramoneda4:
        json["otrosimpuestoadicionalesotramoneda4"],
    montototalotramoneda: json["montototalotramoneda"],
    fechaHoraFirma: json["FechaHoraFirma"] == null
        ? null
        : DateTime.parse(json["FechaHoraFirma"]),
    ncfmodificado: json["ncfmodificado"],
    fechancfmodificado: json["fechancfmodificado"] == null
        ? null
        : DateTime.parse(json["fechancfmodificado"]),
    codigomodificacion: json["codigomodificacion"],
    razonmodificacion: json["razonmodificacion"],
    codigoSeguridad: json["CodigoSeguridad"],
    linkOriginal: json["link_original"],
    tipoComprobante: json["tipo_comprobante"],
    tablatelefonoemisor: json["tablatelefonoemisor"] == null
        ? null
        : Tablatelefonoemisor.fromJson(json["tablatelefonoemisor"]),
    tablaFormasPago: json["tablaFormasPago"] == null
        ? []
        : List<TablaFormasPago>.from(
            json["tablaFormasPago"]!.map((x) => TablaFormasPago.fromJson(x)),
          ),
    fHora: json["f_hora"],
    fPacienteId: json["f_paciente_id"],
    fPacienteNombre: json["f_paciente_nombre"],
    fPacienteCedula: json["f_paciente_cedula"],
    fEdad: json["f_edad"],
    fMedicoId: json["f_medico_id"],
    fMedicoNombre: json["f_medico_nombre"],
    fDiagnostico: json["f_diagnostico"],
    fMedicoEmergencia: json["f_medico_emergencia"],
    fArsId: json["f_ars_id"],
    fArsNombre: json["f_ars_nombre"],
    fAutorizacionArs: json["f_autorizacion_ars"],
    fMontoCobertura: json["f_monto_cobertura"],
    fDiferenciaPagar: json["f_diferencia_pagar"],
    fSubtotal: json["f_subtotal"],
    fDescuento: json["f_descuento"],
    fBaseImponible: json["f_base_imponible"],
    fMontoExento: json["f_monto_exento"],
    fItbis: json["f_itbis"],
    fTotal: json["f_total"],
    fMoneda: json["f_moneda"],
    fTasa: json["f_tasa"],
    fEfectivo: json["f_efectivo"],
    fCheque: json["f_cheque"],
    fTarjetaDebito: json["f_tarjeta_debito"],
    fTarjetaCredito: json["f_tarjeta_credito"],
    fTransferencia: json["f_transferencia"],
    fDiasCredito: json["f_dias_credito"],
    fFechaVencimiento: json["f_fecha_vencimiento"],
    fBalance: json["f_balance"],
    fPagada: json["f_pagada"],
    fTipoNcf: json["f_tipo_ncf"],
    fNcf: json["f_ncf"],
    fFechaVenceNcf: json["f_fecha_vence_ncf"],
    fRncEmisor: json["f_rnc_emisor"],
    fRncReceptor: json["f_rnc_receptor"],
    fReceptorNombre: json["f_receptor_nombre"],
    fReceptorEmail: json["f_receptor_email"],
    fReceptorTelefono: json["f_receptor_telefono"],
    fDireccionReceptor: json["f_direccion_receptor"],
    fHechopor: json["f_hechopor"],
    fCajero: json["f_cajero"],
    fVendedor: json["f_vendedor"],
    fObservacion: json["f_observacion"],
    fPosteada: json["f_posteada"],
    fAnulada: json["f_anulada"],
    fCreadoEn: json["f_creado_en"] == null
        ? null
        : DateTime.parse(json["f_creado_en"]),
    fModificadoEn: json["f_modificado_en"] == null
        ? null
        : DateTime.parse(json["f_modificado_en"]),
  );

  Map<String, dynamic> toJson() => {
    "f_factura_secuencia": fFacturaSecuencia,
    "f_documento": fDocumento,
    "version": version,
    "tipoecf": tipoecf,
    "encf": encf,
    "fechavencimientosecuencia": fechavencimientosecuencia?.toIso8601String(),
    "indicadornotacredito": indicadornotacredito,
    "indicadorenviodiferido": indicadorenviodiferido,
    "indicadormontogravado": indicadormontogravado,
    "tipoingresos": tipoingresos,
    "tipopago": tipopago,
    "fechalimitepago": fechalimitepago,
    "terminopago": terminopago,
    "formapago1": formapago1,
    "montopago1": montopago1,
    "formapago2": formapago2,
    "montopago2": montopago2,
    "formapago3": formapago3,
    "montopago3": montopago3,
    "formapago4": formapago4,
    "montopago4": montopago4,
    "formapago5": formapago5,
    "montopago5": montopago5,
    "formapago6": formapago6,
    "montopago6": montopago6,
    "formapago7": formapago7,
    "montopago7": montopago7,
    "tipocuentapago": tipocuentapago,
    "numerocuentapago": numerocuentapago,
    "bancopago": bancopago,
    "fechadesde": fechadesde,
    "fechahasta": fechahasta,
    "totalpaginas": totalpaginas,
    "rncemisor": rncemisor,
    "razonsocialemisor": razonsocialemisorValues.reverse[razonsocialemisor],
    "nombrecomercial": nombrecomercialValues.reverse[nombrecomercial],
    "sucursal": sucursal,
    "direccionemisor": direccionemisorValues.reverse[direccionemisor],
    "municipio": municipio,
    "provincia": provincia,
    "telefonoemisor1": telefonoValues.reverse[telefonoemisor1],
    "telefonoemisor2": telefonoValues.reverse[telefonoemisor2],
    "telefonoemisor3": telefonoemisor3,
    "correoemisor": correoemisor,
    "website": websiteValues.reverse[website],
    "actividadeconomica": actividadeconomica,
    "codigovendedor": codigovendedorValues.reverse[codigovendedor],
    "numerofacturainterna": numeroValues.reverse[numerofacturainterna],
    "numeropedidointerno": numeroValues.reverse[numeropedidointerno],
    "zonaventa": zonaventaValues.reverse[zonaventa],
    "rutaventa": rutaventa,
    "informacionadicionalemisor": informacionadicionalemisor,
    "fechaemision": fechaemision?.toIso8601String(),
    "rnccomprador": rnccomprador,
    "identificadorextranjero": identificadorextranjero,
    "razonsocialcomprador":
        razonsocialcompradorValues.reverse[razonsocialcomprador],
    "contactocomprador": contactocompradorValues.reverse[contactocomprador],
    "correocomprador": correocompradorValues.reverse[correocomprador],
    "direccioncomprador": direccioncomprador,
    "municipiocomprador": municipiocomprador,
    "provinciacomprador": provinciacomprador,
    "paiscomprador": paiscomprador,
    "fechaentrega": fechaentrega?.toIso8601String(),
    "contactoentrega": contactoentrega,
    "direccionentrega": direccionentrega,
    "telefonoadicional": telefonoValues.reverse[telefonoadicional],
    "fechaordencompra": fechaordencompra?.toIso8601String(),
    "numeroordencompra": numeroordencompra,
    "codigointernocomprador": codigointernocomprador,
    "responsablepago": responsablepago,
    "informacionadicionalcomprador": informacionadicionalcomprador,
    "fechaembarque": fechaembarque,
    "numeroembarque": numeroembarque,
    "numerocontenedor": numerocontenedor,
    "numeroreferencia": numeroreferencia,
    "nombrepuertoembarque": nombrepuertoembarque,
    "condicionesentrega": condicionesentrega,
    "totalfob": totalfob,
    "seguro": seguro,
    "flete": flete,
    "otrosgastos": otrosgastos,
    "totalcif": totalcif,
    "regimenaduanero": regimenaduanero,
    "nombrepuertosalida": nombrepuertosalida,
    "nombrepuertodesembarque": nombrepuertodesembarque,
    "pesobruto": pesobruto,
    "pesoneto": pesoneto,
    "unidadpesobruto": unidadpesobruto,
    "unidadpesoneto": unidadpesoneto,
    "cantidadbulto": cantidadbulto,
    "unidadbulto": unidadbulto,
    "volumenbulto": volumenbulto,
    "unidadvolumen": unidadvolumen,
    "viatransporte": viatransporte,
    "paisorigen": paisorigen,
    "direcciondestino": direcciondestino,
    "paisdestino": paisdestino,
    "rncidentificacioncompaniatransportista":
        rncidentificacioncompaniatransportista,
    "nombrecompaniatransportista": nombrecompaniatransportista,
    "numeroviaje": numeroviaje,
    "conductor": conductor,
    "documentotransporte": documentotransporte,
    "ficha": ficha,
    "placa": placa,
    "rutatransporte": rutatransporte,
    "zonatransporte": zonatransporte,
    "numeroalbaran": numeroalbaran,
    "montogravadototal": montogravadototal,
    "montogravadoi1": montogravadoi1,
    "montogravadoi2": montogravadoi2,
    "montogravadoi3": montogravadoi3,
    "montoexento": montoexento,
    "itbis1": itbis1,
    "itbis2": itbis2,
    "itbis3": itbis3,
    "totalitbis": totalitbis,
    "totalitbis1": totalitbis1,
    "totalitbis2": totalitbis2,
    "totalitbis3": totalitbis3,
    "montoimpuestoadicional": montoimpuestoadicional,
    "tipoimpuesto1": tipoimpuesto1,
    "tasaimpuestoadicional1": tasaimpuestoadicional1,
    "montoimpuestoselectivoconsumoespecifico1":
        montoimpuestoselectivoconsumoespecifico1,
    "montoimpuestoselectivoconsumoadvalorem1":
        montoimpuestoselectivoconsumoadvalorem1,
    "otrosimpuestoadicionales1": otrosimpuestoadicionales1,
    "tipoimpuesto2": tipoimpuesto2,
    "tasaimpuestoadicional2": tasaimpuestoadicional2,
    "montoimpuestoselectivoconsumoespecifico2":
        montoimpuestoselectivoconsumoespecifico2,
    "montoimpuestoselectivoconsumoadvalorem2":
        montoimpuestoselectivoconsumoadvalorem2,
    "otrosimpuestoadicionales2": otrosimpuestoadicionales2,
    "tipoimpuesto3": tipoimpuesto3,
    "tasaimpuestoadicional3": tasaimpuestoadicional3,
    "montoimpuestoselectivoconsumoespecifico3":
        montoimpuestoselectivoconsumoespecifico3,
    "montoimpuestoselectivoconsumoadvalorem3":
        montoimpuestoselectivoconsumoadvalorem3,
    "otrosimpuestoadicionales3": otrosimpuestoadicionales3,
    "tipoimpuesto4": tipoimpuesto4,
    "tasaimpuestoadicional4": tasaimpuestoadicional4,
    "montoimpuestoselectivoconsumoespecifico4":
        montoimpuestoselectivoconsumoespecifico4,
    "montoimpuestoselectivoconsumoadvalorem4":
        montoimpuestoselectivoconsumoadvalorem4,
    "otrosimpuestoadicionales4": otrosimpuestoadicionales4,
    "montototal": montototal,
    "montonofacturable": montonofacturable,
    "montoperiodo": montoperiodo,
    "saldoanterior": saldoanterior,
    "montoavancepago": montoavancepago,
    "valorpagar": valorpagar,
    "totalitbisretenido": totalitbisretenido,
    "totalisrretencion": totalisrretencion,
    "totalitbispercepcion": totalitbispercepcion,
    "totalisrpercepcion": totalisrpercepcion,
    "tipomoneda": tipomoneda,
    "tipocambio": tipocambio,
    "montogravadototalotramoneda": montogravadototalotramoneda,
    "montogravado1otramoneda": montogravado1Otramoneda,
    "montogravado2otramoneda": montogravado2Otramoneda,
    "montogravado3otramoneda": montogravado3Otramoneda,
    "montoexentootramoneda": montoexentootramoneda,
    "totalitbisotramoneda": totalitbisotramoneda,
    "totalitbis1otramoneda": totalitbis1Otramoneda,
    "totalitbis2otramoneda": totalitbis2Otramoneda,
    "totalitbis3otramoneda": totalitbis3Otramoneda,
    "montoimpuestoadicionalotramoneda": montoimpuestoadicionalotramoneda,
    "tipoimpuestootramoneda1": tipoimpuestootramoneda1,
    "tasaimpuestoadicionalotramoneda1": tasaimpuestoadicionalotramoneda1,
    "montoimpuestoselectivoconsumoespecificootramoneda1":
        montoimpuestoselectivoconsumoespecificootramoneda1,
    "montoimpuestoselectivoconsumoadvaloremotramoneda1":
        montoimpuestoselectivoconsumoadvaloremotramoneda1,
    "otrosimpuestoadicionalesotramoneda1": otrosimpuestoadicionalesotramoneda1,
    "tipoimpuestootramoneda2": tipoimpuestootramoneda2,
    "tasaimpuestoadicionalotramoneda2": tasaimpuestoadicionalotramoneda2,
    "montoimpuestoselectivoconsumoespecificootramoneda2":
        montoimpuestoselectivoconsumoespecificootramoneda2,
    "montoimpuestoselectivoconsumoadvaloremotramoneda2":
        montoimpuestoselectivoconsumoadvaloremotramoneda2,
    "otrosimpuestoadicionalesotramoneda2": otrosimpuestoadicionalesotramoneda2,
    "tipoimpuestootramoneda3": tipoimpuestootramoneda3,
    "tasaimpuestoadicionalotramoneda3": tasaimpuestoadicionalotramoneda3,
    "montoimpuestoselectivoconsumoespecificootramoneda3":
        montoimpuestoselectivoconsumoespecificootramoneda3,
    "montoimpuestoselectivoconsumoadvaloremotramoneda3":
        montoimpuestoselectivoconsumoadvaloremotramoneda3,
    "otrosimpuestoadicionalesotramoneda3": otrosimpuestoadicionalesotramoneda3,
    "tipoimpuestootramoneda4": tipoimpuestootramoneda4,
    "tasaimpuestoadicionalotramoneda4": tasaimpuestoadicionalotramoneda4,
    "montoimpuestoselectivoconsumoespecificootramoneda4":
        montoimpuestoselectivoconsumoespecificootramoneda4,
    "montoimpuestoselectivoconsumoadvaloremotramoneda4":
        montoimpuestoselectivoconsumoadvaloremotramoneda4,
    "otrosimpuestoadicionalesotramoneda4": otrosimpuestoadicionalesotramoneda4,
    "montototalotramoneda": montototalotramoneda,
    "FechaHoraFirma": fechaHoraFirma?.toIso8601String(),
    "ncfmodificado": ncfmodificado,
    "fechancfmodificado": fechancfmodificado?.toIso8601String(),
    "codigomodificacion": codigomodificacion,
    "razonmodificacion": razonmodificacion,
    "CodigoSeguridad": codigoSeguridad,
    "link_original": linkOriginal,
    "tipo_comprobante": tipoComprobante,
    "tablatelefonoemisor": tablatelefonoemisor?.toJson(),
    "tablaFormasPago": tablaFormasPago == null
        ? []
        : List<dynamic>.from(tablaFormasPago!.map((x) => x.toJson())),
    "f_hora": fHora,
    "f_paciente_id": fPacienteId,
    "f_paciente_nombre": fPacienteNombre,
    "f_paciente_cedula": fPacienteCedula,
    "f_edad": fEdad,
    "f_medico_id": fMedicoId,
    "f_medico_nombre": fMedicoNombre,
    "f_diagnostico": fDiagnostico,
    "f_medico_emergencia": fMedicoEmergencia,
    "f_ars_id": fArsId,
    "f_ars_nombre": fArsNombre,
    "f_autorizacion_ars": fAutorizacionArs,
    "f_monto_cobertura": fMontoCobertura,
    "f_diferencia_pagar": fDiferenciaPagar,
    "f_subtotal": fSubtotal,
    "f_descuento": fDescuento,
    "f_base_imponible": fBaseImponible,
    "f_monto_exento": fMontoExento,
    "f_itbis": fItbis,
    "f_total": fTotal,
    "f_moneda": fMoneda,
    "f_tasa": fTasa,
    "f_efectivo": fEfectivo,
    "f_cheque": fCheque,
    "f_tarjeta_debito": fTarjetaDebito,
    "f_tarjeta_credito": fTarjetaCredito,
    "f_transferencia": fTransferencia,
    "f_dias_credito": fDiasCredito,
    "f_fecha_vencimiento": fFechaVencimiento,
    "f_balance": fBalance,
    "f_pagada": fPagada,
    "f_tipo_ncf": fTipoNcf,
    "f_ncf": fNcf,
    "f_fecha_vence_ncf": fFechaVenceNcf,
    "f_rnc_emisor": fRncEmisor,
    "f_rnc_receptor": fRncReceptor,
    "f_receptor_nombre": fReceptorNombre,
    "f_receptor_email": fReceptorEmail,
    "f_receptor_telefono": fReceptorTelefono,
    "f_direccion_receptor": fDireccionReceptor,
    "f_hechopor": fHechopor,
    "f_cajero": fCajero,
    "f_vendedor": fVendedor,
    "f_observacion": fObservacion,
    "f_posteada": fPosteada,
    "f_anulada": fAnulada,
    "f_creado_en": fCreadoEn?.toIso8601String(),
    "f_modificado_en": fModificadoEn?.toIso8601String(),
  };
}

enum Codigovendedor {
  AA0000000100000000010000000002000000000300000000050000000006,
}

final codigovendedorValues = EnumValues({
  "AA0000000100000000010000000002000000000300000000050000000006": Codigovendedor
      .AA0000000100000000010000000002000000000300000000050000000006,
});

enum Contactocomprador { MARCOS_LATIPLOL }

final contactocompradorValues = EnumValues({
  "MARCOS LATIPLOL": Contactocomprador.MARCOS_LATIPLOL,
});

enum Correocomprador {
  DOCUMENTOSELECTRONICOSDE0612345678969789_123_COM,
  MARCOSLATIPLOL_KKKK_COM,
}

final correocompradorValues = EnumValues({
  "DOCUMENTOSELECTRONICOSDE0612345678969789@123.COM":
      Correocomprador.DOCUMENTOSELECTRONICOSDE0612345678969789_123_COM,
  "MARCOSLATIPLOL@KKKK.COM": Correocomprador.MARCOSLATIPLOL_KKKK_COM,
});

enum Direccionemisor {
  AVE_ISABEL_AGUIAR_NO_269_ZONA_INDUSTRIAL_DE_HERRERA,
  DOCUMENTOS_ELECTRONICOS_DE_02,
}

final direccionemisorValues = EnumValues({
  "AVE. ISABEL AGUIAR NO. 269, ZONA INDUSTRIAL DE HERRERA":
      Direccionemisor.AVE_ISABEL_AGUIAR_NO_269_ZONA_INDUSTRIAL_DE_HERRERA,
  "DOCUMENTOS ELECTRONICOS DE 02":
      Direccionemisor.DOCUMENTOS_ELECTRONICOS_DE_02,
});

enum Nombrecomercial { DOCUMENTOS_ELECTRONICOS, DOCUMENTOS_ELECTRONICOS_DE_02 }

final nombrecomercialValues = EnumValues({
  "DOCUMENTOS ELECTRONICOS": Nombrecomercial.DOCUMENTOS_ELECTRONICOS,
  "DOCUMENTOS ELECTRONICOS DE 02":
      Nombrecomercial.DOCUMENTOS_ELECTRONICOS_DE_02,
});

enum Numero { EMPTY, THE_123456789016, THE_123456789020 }

final numeroValues = EnumValues({
  "": Numero.EMPTY,
  "123456789016": Numero.THE_123456789016,
  "123456789020": Numero.THE_123456789020,
});

enum Razonsocialcomprador {
  ALEJA_FERMIN_SANTOS,
  DOCUMENTOS_ELECTRONICOS_DE_01,
  DOCUMENTOS_ELECTRONICOS_DE_03,
  DOCUMENTOS_ELECTRONICOS_DE_11,
}

final razonsocialcompradorValues = EnumValues({
  "ALEJA FERMIN SANTOS": Razonsocialcomprador.ALEJA_FERMIN_SANTOS,
  "DOCUMENTOS ELECTRONICOS DE 01":
      Razonsocialcomprador.DOCUMENTOS_ELECTRONICOS_DE_01,
  "DOCUMENTOS ELECTRONICOS DE 03":
      Razonsocialcomprador.DOCUMENTOS_ELECTRONICOS_DE_03,
  "DOCUMENTOS ELECTRONICOS DE 11":
      Razonsocialcomprador.DOCUMENTOS_ELECTRONICOS_DE_11,
});

enum Razonsocialemisor {
  DOCUMENTOS_ELECTRONICOS_DE_02,
  DOCUMENTOS_ELECTRONICOS_PRUEBA_FACTURA_DE_CONSUMO_MENOR_250_MIL,
}

final razonsocialemisorValues = EnumValues({
  "DOCUMENTOS ELECTRONICOS DE 02":
      Razonsocialemisor.DOCUMENTOS_ELECTRONICOS_DE_02,
  "DOCUMENTOS ELECTRONICOS PRUEBA FACTURA DE CONSUMO MENOR 250MIL":
      Razonsocialemisor
          .DOCUMENTOS_ELECTRONICOS_PRUEBA_FACTURA_DE_CONSUMO_MENOR_250_MIL,
});

class TablaFormasPago {
  String? formaPago;
  double? montoPago;

  TablaFormasPago({this.formaPago, this.montoPago});

  factory TablaFormasPago.fromJson(Map<String, dynamic> json) =>
      TablaFormasPago(
        formaPago: json["FormaPago"],
        montoPago: json["MontoPago"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "FormaPago": formaPago,
    "MontoPago": montoPago,
  };
}

class Tablatelefonoemisor {
  List<Telefono>? telefonoEmisor;

  Tablatelefonoemisor({this.telefonoEmisor});

  factory Tablatelefonoemisor.fromJson(Map<String, dynamic> json) =>
      Tablatelefonoemisor(
        telefonoEmisor: json["TelefonoEmisor"] == null
            ? []
            : List<Telefono>.from(
                json["TelefonoEmisor"]!.map((x) => telefonoValues.map[x]!),
              ),
      );

  Map<String, dynamic> toJson() => {
    "TelefonoEmisor": telefonoEmisor == null
        ? []
        : List<dynamic>.from(
            telefonoEmisor!.map((x) => telefonoValues.reverse[x]),
          ),
  };
}

enum Telefono { THE_8094727676, THE_8094911918 }

final telefonoValues = EnumValues({
  "809-472-7676": Telefono.THE_8094727676,
  "809-491-1918": Telefono.THE_8094911918,
});

enum Website { WWW_FACTURAELECTRONICA_COM }

final websiteValues = EnumValues({
  "www.facturaelectronica.com": Website.WWW_FACTURAELECTRONICA_COM,
});

enum Zonaventa { NORTE }

final zonaventaValues = EnumValues({"NORTE": Zonaventa.NORTE});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
