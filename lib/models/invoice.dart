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
  String? version;
  String? tipoecf;
  String? encf;
  Fechavencimientosecuencia? fechavencimientosecuencia;
  dynamic indicadorenviodiferido;
  String? indicadormontogravado;
  String? indicadornotacredito;
  String? tipoingresos;
  String? tipopago;
  String? formapago1;
  String? montopago1;
  String? formapago2;
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
  dynamic fechalimitepago;
  dynamic terminopago;
  dynamic totalpaginas;
  String? rncemisor;
  Razonsocialemisor? razonsocialemisor;
  Nombrecomercial? nombrecomercial;
  dynamic sucursal;
  Direccionemisor? direccionemisor;
  String? municipio;
  String? provincia;
  Telefono? telefonoemisor1;
  String? telefonoemisor2;
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
  Fechaemision? fechaemision;
  String? rnccomprador;
  String? identificadorextranjero;
  Razonsocialcomprador? razonsocialcomprador;
  Contactocomprador? contactocomprador;
  Correocomprador? correocomprador;
  String? direccioncomprador;
  String? municipiocomprador;
  String? provinciacomprador;
  dynamic paiscomprador;
  Fechaentrega? fechaentrega;
  String? contactoentrega;
  dynamic direccionentrega;
  Telefono? telefonoadicional;
  Fechaordencompra? fechaordencompra;
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
  dynamic fechahorafirma;
  dynamic codigoseguridad;
  String? linkOriginal;
  String? tipoComprobante;
  dynamic tablatelefonoemisor;
  dynamic tablaformaspago;
  dynamic detalleFactura;
  String? tipoTabEnvioFactura;

  Datum({
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
    this.fechahorafirma,
    this.codigoseguridad,
    this.linkOriginal,
    this.tipoComprobante,
    this.tablatelefonoemisor,
    this.tablaformaspago,
    this.detalleFactura,
    this.tipoTabEnvioFactura,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    fFacturaSecuencia: json["f_factura_secuencia"],
    version: json["version"],
    tipoecf: json["tipoecf"],
    encf: json["encf"],
    fechavencimientosecuencia:
        fechavencimientosecuenciaValues.map[json["fechavencimientosecuencia"]]!,
    indicadorenviodiferido: json["indicadorenviodiferido"],
    indicadormontogravado: json["indicadormontogravado"],
    indicadornotacredito: json["indicadornotacredito"],
    tipoingresos: json["tipoingresos"],
    tipopago: json["tipopago"],
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
    fechalimitepago: json["fechalimitepago"],
    terminopago: json["terminopago"],
    totalpaginas: json["totalpaginas"],
    rncemisor: json["rncemisor"],
    razonsocialemisor: razonsocialemisorValues.map[json["razonsocialemisor"]]!,
    nombrecomercial: nombrecomercialValues.map[json["nombrecomercial"]]!,
    sucursal: json["sucursal"],
    direccionemisor: direccionemisorValues.map[json["direccionemisor"]]!,
    municipio: json["municipio"],
    provincia: json["provincia"],
    telefonoemisor1: telefonoValues.map[json["telefonoemisor1"]]!,
    telefonoemisor2: json["telefonoemisor2"],
    telefonoemisor3: json["telefonoemisor3"],
    correoemisor: json["correoemisor"],
    website: websiteValues.map[json["website"]]!,
    actividadeconomica: json["actividadeconomica"],
    codigovendedor: codigovendedorValues.map[json["codigovendedor"]]!,
    numerofacturainterna: numeroValues.map[json["numerofacturainterna"]]!,
    numeropedidointerno: numeroValues.map[json["numeropedidointerno"]]!,
    zonaventa: zonaventaValues.map[json["zonaventa"]]!,
    rutaventa: json["rutaventa"],
    informacionadicionalemisor: json["informacionadicionalemisor"],
    fechaemision: fechaemisionValues.map[json["fechaemision"]]!,
    rnccomprador: json["rnccomprador"],
    identificadorextranjero: json["identificadorextranjero"],
    razonsocialcomprador:
        razonsocialcompradorValues.map[json["razonsocialcomprador"]]!,
    contactocomprador: contactocompradorValues.map[json["contactocomprador"]]!,
    correocomprador: correocompradorValues.map[json["correocomprador"]]!,
    direccioncomprador: json["direccioncomprador"],
    municipiocomprador: json["municipiocomprador"],
    provinciacomprador: json["provinciacomprador"],
    paiscomprador: json["paiscomprador"],
    fechaentrega: fechaentregaValues.map[json["fechaentrega"]]!,
    contactoentrega: json["contactoentrega"],
    direccionentrega: json["direccionentrega"],
    telefonoadicional: telefonoValues.map[json["telefonoadicional"]]!,
    fechaordencompra: fechaordencompraValues.map[json["fechaordencompra"]]!,
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
    fechahorafirma: json["fechahorafirma"],
    codigoseguridad: json["codigoseguridad"],
    linkOriginal: json["link_original"],
    tipoComprobante: json["tipo_comprobante"],
    tablatelefonoemisor: json["tablatelefonoemisor"],
    tablaformaspago: json["tablaformaspago"],
    detalleFactura: json["detalle_factura"],
    tipoTabEnvioFactura: json["tipo_tab_envio_factura"],
  );

  Map<String, dynamic> toJson() => {
    "f_factura_secuencia": fFacturaSecuencia,
    "version": version,
    "tipoecf": tipoecf,
    "encf": encf,
    "fechavencimientosecuencia":
        fechavencimientosecuenciaValues.reverse[fechavencimientosecuencia],
    "indicadorenviodiferido": indicadorenviodiferido,
    "indicadormontogravado": indicadormontogravado,
    "indicadornotacredito": indicadornotacredito,
    "tipoingresos": tipoingresos,
    "tipopago": tipopago,
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
    "fechalimitepago": fechalimitepago,
    "terminopago": terminopago,
    "totalpaginas": totalpaginas,
    "rncemisor": rncemisor,
    "razonsocialemisor": razonsocialemisorValues.reverse[razonsocialemisor],
    "nombrecomercial": nombrecomercialValues.reverse[nombrecomercial],
    "sucursal": sucursal,
    "direccionemisor": direccionemisorValues.reverse[direccionemisor],
    "municipio": municipio,
    "provincia": provincia,
    "telefonoemisor1": telefonoValues.reverse[telefonoemisor1],
    "telefonoemisor2": telefonoemisor2,
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
    "fechaemision": fechaemisionValues.reverse[fechaemision],
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
    "fechaentrega": fechaentregaValues.reverse[fechaentrega],
    "contactoentrega": contactoentrega,
    "direccionentrega": direccionentrega,
    "telefonoadicional": telefonoValues.reverse[telefonoadicional],
    "fechaordencompra": fechaordencompraValues.reverse[fechaordencompra],
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
    "fechahorafirma": fechahorafirma,
    "codigoseguridad": codigoseguridad,
    "link_original": linkOriginal,
    "tipo_comprobante": tipoComprobante,
    "tablatelefonoemisor": tablatelefonoemisor,
    "tablaformaspago": tablaformaspago,
    "detalle_factura": detalleFactura,
    "tipo_tab_envio_factura": tipoTabEnvioFactura,
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

enum Fechaemision { THE_1122018, THE_142020, THE_2122018, THE_242020 }

final fechaemisionValues = EnumValues({
  "1/12/2018": Fechaemision.THE_1122018,
  "1/4/2020": Fechaemision.THE_142020,
  "2/12/2018": Fechaemision.THE_2122018,
  "2/4/2020": Fechaemision.THE_242020,
});

enum Fechaentrega { THE_10102020, THE_11112020 }

final fechaentregaValues = EnumValues({
  "10/10/2020": Fechaentrega.THE_10102020,
  "11/11/2020": Fechaentrega.THE_11112020,
});

enum Fechaordencompra { THE_10112018, THE_10112020 }

final fechaordencompraValues = EnumValues({
  "10/11/2018": Fechaordencompra.THE_10112018,
  "10/11/2020": Fechaordencompra.THE_10112020,
});

enum Fechavencimientosecuencia { THE_31122025 }

final fechavencimientosecuenciaValues = EnumValues({
  "31/12/2025": Fechavencimientosecuencia.THE_31122025,
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

enum Telefono { THE_8094727676 }

final telefonoValues = EnumValues({"809-472-7676": Telefono.THE_8094727676});

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
