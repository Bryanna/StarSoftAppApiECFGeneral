export const processDGIISetOfTestsJson = async (scenariosFromFirebase) => {
  const testScenarios = scenariosFromFirebase.map((scenario) => {
    const cleanedScenario = { ...scenario };
    delete cleanedScenario.EmpresaID;
    delete cleanedScenario.estatus;

    return Object.fromEntries(
      Object.entries(cleanedScenario)
        .map(([key, value]) => [key, limpiarValores(value)])
        .filter(([_, value]) => value !== null)
    );
  });

  const results = [];
  // console.log("🔑 Extrayendo clave privada y certificado...");
  // const { privateKey, certificate } = extractKeyAndCertificate(
  //   dgiiConfig.certificate.path,
  //   dgiiConfig.certificate.passphrase
  // );

  for (const scenario of testScenarios) {
    try {
      console.log("📄 Generando XML...");

      const RNCEmisor = scenario.RNCEmisor.toString();
      const { certPath, certPassword, cleanup } = await getCertConfig(
        RNCEmisor
      );

      console.log(certPath, certPassword);

      const xmlData = {
        Encabezado: {
          Version: scenario.Version,
          // CasoPrueba: scenario.CasoPrueba,

          // 1) <IdDoc>
          IdDoc: {
            TipoeCF: scenario.TipoeCF,
            eNCF: scenario.ENCF,
            IndicadorNotaCredito: scenario.IndicadorNotaCredito,
            FechaVencimientoSecuencia: scenario.FechaVencimientoSecuencia,
            IndicadorEnvioDiferido: scenario.IndicadorEnvioDiferido,
            IndicadorMontoGravado: scenario.IndicadorMontoGravado,
            IndicadorServicioTodoIncluido:
              scenario.IndicadorServicioTodoIncluido,
            TipoIngresos: scenario.TipoIngresos,
            TipoPago: scenario.TipoPago,
            FechaLimitePago: scenario.FechaLimitePago,
            TerminoPago: scenario.TerminoPago,
            // TablaFormasPago -> <TablaFormasPago><FormaDePago>...</FormaDePago>...
            TablaFormasPago: scenario["FormaPago[1]"]
              ? {
                  FormaDePago: [
                    {
                      FormaPago: scenario["FormaPago[1]"],
                      MontoPago: scenario["MontoPago[1]"],
                    },
                    {
                      FormaPago: scenario["FormaPago[2]"],
                      MontoPago: scenario["MontoPago[2]"],
                    },
                    {
                      FormaPago: scenario["FormaPago[3]"],
                      MontoPago: scenario["MontoPago[3]"],
                    },
                  ].filter((f) => f.FormaPago || f.MontoPago), // quita vacíos
                }
              : null,
            TipoCuentaPago: scenario.TipoCuentaPago,
            NumeroCuentaPago: scenario.NumeroCuentaPago,
            BancoPago: scenario.BancoPago,
            FechaDesde: scenario.FechaDesde,
            FechaHasta: scenario.FechaHasta,
            TotalPaginas: scenario.TotalPaginas,
          },

          // 2) <Emisor>
          Emisor: {
            RNCEmisor: scenario.RNCEmisor,
            RazonSocialEmisor: scenario.RazonSocialEmisor,
            NombreComercial: scenario.NombreComercial,
            Sucursal: scenario.Sucursal,
            DireccionEmisor: scenario.DireccionEmisor,
            Municipio: scenario.Municipio,
            Provincia: scenario.Provincia,
            TablaTelefonoEmisor: scenario["TelefonoEmisor[1]"]
              ? {
                  TelefonoEmisor: [
                    scenario["TelefonoEmisor[1]"],
                    scenario["TelefonoEmisor[2]"],
                    scenario["TelefonoEmisor[3]"],
                  ].filter(Boolean),
                }
              : null,
            CorreoEmisor: scenario.CorreoEmisor,
            WebSite: scenario.WebSite,
            ActividadEconomica: scenario.ActividadEconomica,
            CodigoVendedor: scenario.CodigoVendedor,
            NumeroFacturaInterna: scenario.NumeroFacturaInterna,
            NumeroPedidoInterno: scenario.NumeroPedidoInterno,
            ZonaVenta: scenario.ZonaVenta,
            RutaVenta: scenario.RutaVenta,
            InformacionAdicionalEmisor: scenario.InformacionAdicionalEmisor,
            FechaEmision: scenario.FechaEmision,
          },

          // 3) <Comprador>
          Comprador: {
            RNCComprador: scenario.RNCComprador,
            IdentificadorExtranjero: scenario.IdentificadorExtranjero,
            RazonSocialComprador: scenario.RazonSocialComprador,
            ContactoComprador: scenario.ContactoComprador,
            CorreoComprador: scenario.CorreoComprador,
            DireccionComprador: scenario.DireccionComprador,
            MunicipioComprador: scenario.MunicipioComprador,
            ProvinciaComprador: scenario.ProvinciaComprador,
            FechaEntrega: scenario.FechaEntrega,
            ContactoEntrega: scenario.ContactoEntrega,
            DireccionEntrega: scenario.DireccionEntrega,
            TelefonoAdicional: scenario.TelefonoAdicional,
            FechaOrdenCompra: scenario.FechaOrdenCompra,
            NumeroOrdenCompra: scenario.NumeroOrdenCompra,
            CodigoInternoComprador: scenario.CodigoInternoComprador,
            ResponsablePago: scenario.ResponsablePago,
            InformacionAdicionalComprador:
              scenario.InformacionAdicionalComprador,
          },

          // 4) <InformacionesAdicionales>
          InformacionesAdicionales: {
            FechaEmbarque: scenario.FechaEmbarque,
            NumeroEmbarque: scenario.NumeroEmbarque,
            NumeroContenedor: scenario["NumeroContenedor "], // OJO si en Excel viene con espacio
            NumeroReferencia: scenario.NumeroReferencia,
            PesoBruto: scenario.PesoBruto,
            PesoNeto: scenario.PesoNeto,
            UnidadPesoBruto: scenario.UnidadPesoBruto,
            UnidadPesoNeto: scenario.UnidadPesoNeto,
            CantidadBulto: scenario.CantidadBulto,
            UnidadBulto: scenario.UnidadBulto,
            VolumenBulto: scenario.VolumenBulto,
            UnidadVolumen: scenario.UnidadVolumen,
          },

          // 5) <Transporte>
          Transporte: {
            Conductor: scenario.Conductor,
            DocumentoTransporte: scenario.DocumentoTransporte,
            Ficha: scenario.Ficha,
            Placa: scenario.Placa,
            RutaTransporte: scenario.RutaTransporte,
            ZonaTransporte: scenario.ZonaTransporte,
            NumeroAlbaran: scenario.NumeroAlbaran,
          },

          // 6) <Totales>
          Totales: {
            MontoGravadoTotal: scenario.MontoGravadoTotal,
            MontoGravadoI1: scenario.MontoGravadoI1,
            MontoGravadoI2: scenario.MontoGravadoI2,
            MontoGravadoI3: scenario.MontoGravadoI3,
            MontoExento: scenario.MontoExento,
            ITBIS1: scenario.ITBIS1,
            ITBIS2: scenario.ITBIS2,
            ITBIS3: scenario.ITBIS3,
            TotalITBIS: scenario.TotalITBIS,
            TotalITBIS1: scenario.TotalITBIS1,
            TotalITBIS2: scenario.TotalITBIS2,
            TotalITBIS3: scenario.TotalITBIS3,
            MontoImpuestoAdicional: scenario.MontoImpuestoAdicional,
            ImpuestosAdicionales: (() => {
              const impuestosAdicionales = [];
              for (let i = 1; i <= 20; i++) {
                const impuestoAdicional = {
                  TipoImpuesto: scenario[`TipoImpuesto[${i}]`],
                  TasaImpuestoAdicional:
                    scenario[`TasaImpuestoAdicional[${i}]`],
                  MontoImpuestoSelectivoConsumoEspecifico:
                    scenario[`MontoImpuestoSelectivoConsumoEspecifico[${i}]`],
                  MontoImpuestoSelectivoConsumoAdvalorem:
                    scenario[`MontoImpuestoSelectivoConsumoAdvalorem[${i}]`],
                  OtrosImpuestosAdicionales:
                    scenario[`OtrosImpuestosAdicionales[${i}]`],
                };

                // Verifica si al menos un campo tiene un valor válido
                if (
                  impuestoAdicional.TipoImpuesto ||
                  impuestoAdicional.TasaImpuestoAdicional ||
                  impuestoAdicional.MontoImpuestoSelectivoConsumoEspecifico ||
                  impuestoAdicional.MontoImpuestoSelectivoConsumoAdvalorem ||
                  impuestoAdicional.OtrosImpuestosAdicionales
                ) {
                  impuestosAdicionales.push(impuestoAdicional);
                }
              }

              // Verifica si hay impuestos adicionales antes de crear el objeto
              if (impuestosAdicionales.length > 0) {
                return { ImpuestoAdicional: impuestosAdicionales };
              } else {
                return null;
              }
            })(),
            MontoTotal: scenario.MontoTotal,
            MontoNoFacturable: scenario.MontoNoFacturable,
            MontoPeriodo: scenario.MontoPeriodo,
            SaldoAnterior: scenario.SaldoAnterior,
            MontoAvancePago: scenario.MontoAvancePago,
            ValorPagar: scenario.ValorPagar,
            TotalITBISRetenido: scenario.TotalITBISRetenido,
            TotalISRRetencion: scenario.TotalISRRetencion,
            TotalITBISPercepcion: scenario.TotalITBISPercepcion,
            TotalISRPercepcion: scenario.TotalISRPercepcion,
          },

          // 7) <OtraMoneda>
          OtraMoneda: scenario.TipoMoneda
            ? {
                TipoMoneda: scenario.TipoMoneda,
                TipoCambio: scenario.TipoCambio,
                MontoGravadoTotalOtraMoneda:
                  scenario.MontoGravadoTotalOtraMoneda,
                MontoGravado1OtraMoneda: scenario.MontoGravado1OtraMoneda,
                MontoGravado2OtraMoneda: scenario.MontoGravado2OtraMoneda,
                MontoGravado3OtraMoneda: scenario.MontoGravado3OtraMoneda,
                MontoExentoOtraMoneda: scenario.MontoExentoOtraMoneda,
                TotalITBISOtraMoneda: scenario.TotalITBISOtraMoneda,
                TotalITBIS1OtraMoneda: scenario.TotalITBIS1OtraMoneda,
                TotalITBIS2OtraMoneda: scenario.TotalITBIS2OtraMoneda,
                TotalITBIS3OtraMoneda: scenario.TotalITBIS3OtraMoneda,
                MontoImpuestoAdicionalOtraMoneda:
                  scenario.MontoImpuestoAdicionalOtraMoneda,
                ImpuestosAdicionalesOtraMoneda: scenario.TipoImpuestoOtraMoneda1
                  ? {
                      ImpuestoAdicionalOtraMoneda: [
                        {
                          TipoImpuestoOtraMoneda:
                            scenario.TipoImpuestoOtraMoneda1,
                          TasaImpuestoAdicionalOtraMoneda:
                            scenario.TasaImpuestoAdicionalOtraMoneda1,
                          MontoImpuestoSelectivoConsumoEspecificoOtraMoneda:
                            scenario.MontoImpuestoSelectivoConsumoEspecificoOtraMoneda1,
                          MontoImpuestoSelectivoConsumoAdvaloremOtraMoneda:
                            scenario.MontoImpuestoSelectivoConsumoAdvaloremOtraMoneda1,
                          OtrosImpuestosAdicionalesOtraMoneda:
                            scenario.OtrosImpuestosAdicionalesOtraMoneda1,
                        },
                        {
                          TipoImpuestoOtraMoneda:
                            scenario.TipoImpuestoOtraMoneda2,
                          TasaImpuestoAdicionalOtraMoneda:
                            scenario.TasaImpuestoAdicionalOtraMoneda2,
                          MontoImpuestoSelectivoConsumoEspecificoOtraMoneda:
                            scenario.MontoImpuestoSelectivoConsumoEspecificoOtraMoneda2,
                          MontoImpuestoSelectivoConsumoAdvaloremOtraMoneda:
                            scenario.MontoImpuestoSelectivoConsumoAdvaloremOtraMoneda2,
                          OtrosImpuestosAdicionalesOtraMoneda:
                            scenario.OtrosImpuestosAdicionalesOtraMoneda2,
                        },
                        {
                          TipoImpuestoOtraMoneda:
                            scenario.TipoImpuestoOtraMoneda3,
                          TasaImpuestoAdicionalOtraMoneda:
                            scenario.TasaImpuestoAdicionalOtraMoneda3,
                          MontoImpuestoSelectivoConsumoEspecificoOtraMoneda:
                            scenario.MontoImpuestoSelectivoConsumoEspecificoOtraMoneda3,
                          MontoImpuestoSelectivoConsumoAdvaloremOtraMoneda:
                            scenario.MontoImpuestoSelectivoConsumoAdvaloremOtraMoneda3,
                          OtrosImpuestosAdicionalesOtraMoneda:
                            scenario.OtrosImpuestosAdicionalesOtraMoneda3,
                        },
                      ].filter((x) => x.TipoImpuestoOtraMoneda),
                    }
                  : null,
                MontoTotalOtraMoneda: scenario.MontoTotalOtraMoneda,
              }
            : null,
        }, // Fin Encabezado

        // 8) <DetallesItems>
        DetallesItems: {
          Item: (() => {
            const items = [];
            let maxItems = 0;

            // Encontrar el número máximo de ítems
            for (const key in scenario) {
              const match = key.match(/NumeroLinea\[(\d+)\]/);
              if (match) {
                maxItems = Math.max(maxItems, parseInt(match[1]));
              }
            }

            // Generar nodos <Item> dinámicamente
            for (let i = 1; i <= maxItems; i++) {
              items.push({
                NumeroLinea: scenario[`NumeroLinea[${i}]`],
                TablaCodigosItem: (() => {
                  const codigosItems = [];
                  for (let j = 1; j <= 5; j++) {
                    if (
                      scenario[`TipoCodigo[${i}][${j}]`] &&
                      scenario[`CodigoItem[${i}][${j}]`]
                    ) {
                      codigosItems.push({
                        TipoCodigo: scenario[`TipoCodigo[${i}][${j}]`],
                        CodigoItem: scenario[`CodigoItem[${i}][${j}]`],
                      });
                    }
                  }
                  if (codigosItems.length > 0) {
                    return { CodigosItem: codigosItems };
                  } else {
                    return null;
                  }
                })(),
                IndicadorFacturacion: scenario[`IndicadorFacturacion[${i}]`],
                Retencion: {
                  IndicadorAgenteRetencionoPercepcion:
                    scenario[`IndicadorAgenteRetencionoPercepcion[${i}]`],
                  MontoITBISRetenido: scenario[`MontoITBISRetenido[${i}]`],
                  MontoISRRetenido: scenario[`MontoISRRetenido[${i}]`],
                },
                NombreItem: scenario[`NombreItem[${i}]`],
                IndicadorBienoServicio:
                  scenario[`IndicadorBienoServicio[${i}]`],
                DescripcionItem: scenario[`DescripcionItem[${i}]`],
                CantidadItem: scenario[`CantidadItem[${i}]`],
                UnidadMedida: scenario[`UnidadMedida[${i}]`],
                CantidadReferencia: scenario[`CantidadReferencia[${i}]`],
                UnidadReferencia: scenario[`UnidadReferencia[${i}]`],
                TablaSubcantidad: scenario[`Subcantidad[${i}][1]`]
                  ? {
                      // Verifica si existe al menos un Subcantidad
                      SubcantidadItem: [
                        {
                          Subcantidad: scenario[`Subcantidad[${i}][1]`],
                          CodigoSubcantidad:
                            scenario[`CodigoSubcantidad[${i}][1]`],
                        },
                        {
                          Subcantidad: scenario[`Subcantidad[${i}][2]`],
                          CodigoSubcantidad:
                            scenario[`CodigoSubcantidad[${i}][2]`],
                        },
                        {
                          Subcantidad: scenario[`Subcantidad[${i}][3]`],
                          CodigoSubcantidad:
                            scenario[`CodigoSubcantidad[${i}][3]`],
                        },
                        {
                          Subcantidad: scenario[`Subcantidad[${i}][4]`],
                          CodigoSubcantidad:
                            scenario[`CodigoSubcantidad[${i}][4]`],
                        },
                        {
                          Subcantidad: scenario[`Subcantidad[${i}][5]`],
                          CodigoSubcantidad:
                            scenario[`CodigoSubcantidad[${i}][5]`],
                        },
                      ].filter(
                        (item) => item.Subcantidad || item.CodigoSubcantidad
                      ), // Filtra los vacíos
                    }
                  : null,
                GradosAlcohol: scenario[`GradosAlcohol[${i}]`],
                PrecioUnitarioReferencia:
                  scenario[`PrecioUnitarioReferencia[${i}]`],
                FechaElaboracion: scenario[`FechaElaboracion[${i}]`],
                FechaVencimientoItem: scenario[`FechaVencimientoItem[${i}]`],
                PrecioUnitarioItem: scenario[`PrecioUnitarioItem[${i}]`],
                DescuentoMonto: scenario[`DescuentoMonto[${i}]`],
                TablaSubDescuento: scenario[`TipoSubDescuento[${i}][1]`] // Verifica si existe al menos un SubDescuento
                  ? {
                      SubDescuento: [
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][1]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][1]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][1]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][2]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][2]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][2]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][3]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][3]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][3]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][4]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][4]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][4]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][5]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][5]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][5]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][6]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][6]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][6]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][7]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][7]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][7]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][8]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][8]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][8]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][9]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][9]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][9]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][10]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][10]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][10]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][11]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][11]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][11]`],
                        },
                        {
                          TipoSubDescuento:
                            scenario[`TipoSubDescuento[${i}][12]`],
                          SubDescuentoPorcentaje:
                            scenario[`SubDescuentoPorcentaje[${i}][12]`],
                          MontoSubDescuento:
                            scenario[`MontoSubDescuento[${i}][12]`],
                        },
                      ].filter(
                        (item) =>
                          item.TipoSubDescuento ||
                          item.SubDescuentoPorcentaje ||
                          item.MontoSubDescuento
                      ), // Filtra los vacíos
                    }
                  : null,
                RecargoMonto: scenario[`RecargoMonto[${i}]`],
                TablaSubRecargo: (() => {
                  const subRecargos = [];
                  for (let j = 1; j <= 12; j++) {
                    if (
                      scenario[`TipoSubRecargo[${i}][${j}]`] &&
                      (scenario[`SubRecargoPorcentaje[${i}][${j}]`] ||
                        scenario[`MontosubRecargo[${i}][${j}]`])
                    ) {
                      subRecargos.push({
                        TipoSubRecargo: scenario[`TipoSubRecargo[${i}][${j}]`],
                        SubRecargoPorcentaje:
                          scenario[`SubRecargoPorcentaje[${i}][${j}]`],
                        MontoSubRecargo:
                          scenario[`MontosubRecargo[${i}][${j}]`],
                      });
                    }
                  }
                  if (subRecargos.length > 0) {
                    return { SubRecargo: subRecargos };
                  } else {
                    return null;
                  }
                })(),
                TablaImpuestoAdicional: (() => {
                  const impuestosAdicionalesItem = [];
                  for (let j = 1; j <= 2; j++) {
                    if (scenario[`TipoImpuesto[${i}][${j}]`]) {
                      impuestosAdicionalesItem.push({
                        TipoImpuesto: scenario[`TipoImpuesto[${i}][${j}]`],
                      });
                    }
                  }
                  if (impuestosAdicionalesItem.length > 0) {
                    return { ImpuestoAdicional: impuestosAdicionalesItem };
                  } else {
                    return null;
                  }
                })(),
                OtraMonedaDetalle: (() => {
                  if (
                    scenario[`PrecioOtraMoneda[${i}]`] ||
                    scenario[`DescuentoOtraMoneda[${i}]`] ||
                    scenario[`RecargoOtraMoneda[${i}]`] ||
                    scenario[`MontoItemOtraMoneda[${i}]`]
                  ) {
                    return {
                      PrecioOtraMoneda: scenario[`PrecioOtraMoneda[${i}]`],
                      DescuentoOtraMoneda:
                        scenario[`DescuentoOtraMoneda[${i}]`],
                      RecargoOtraMoneda: scenario[`RecargoOtraMoneda[${i}]`],
                      MontoItemOtraMoneda:
                        scenario[`MontoItemOtraMoneda[${i}]`],
                    };
                  } else {
                    return null;
                  }
                })(),
                MontoItem: scenario[`MontoItem[${i}]`],
              });
            }

            return items;
          })(),
        },

        Subtotales: (() => {
          const subtotales = [];
          for (let i = 1; i <= 20; i++) {
            if (
              scenario[`NumeroSubTotal[${i}]`] ||
              scenario[`DescripcionSubtotal[${i}]`] ||
              scenario[`Orden[${i}]`] ||
              scenario[`SubTotalMontoGravadoTotal[${i}]`] ||
              scenario[`SubTotalMontoGravadoI1[${i}]`] ||
              scenario[`SubTotalMontoGravadoI2[${i}]`] ||
              scenario[`SubTotalMontoGravadoI3[${i}]`] ||
              scenario[`SubTotaITBIS[${i}]`] ||
              scenario[`SubTotaITBIS1[${i}]`] ||
              scenario[`SubTotaITBIS2[${i}]`] ||
              scenario[`SubTotaITBIS3[${i}]`] ||
              scenario[`SubTotalImpuestoAdicional[${i}]`] ||
              scenario[`SubTotalExento[${i}]`] ||
              scenario[`MontoSubTotal[${i}]`] ||
              scenario[`Lineas[${i}]`]
            ) {
              subtotales.push({
                NumeroSubTotal: scenario[`NumeroSubTotal[${i}]`],
                DescripcionSubtotal: scenario[`DescripcionSubtotal[${i}]`],
                Orden: scenario[`Orden[${i}]`],
                SubTotalMontoGravadoTotal:
                  scenario[`SubTotalMontoGravadoTotal[${i}]`],
                SubTotalMontoGravadoI1:
                  scenario[`SubTotalMontoGravadoI1[${i}]`],
                SubTotalMontoGravadoI2:
                  scenario[`SubTotalMontoGravadoI2[${i}]`],
                SubTotalMontoGravadoI3:
                  scenario[`SubTotalMontoGravadoI3[${i}]`],
                SubTotaITBIS: scenario[`SubTotaITBIS[${i}]`],
                SubTotaITBIS1: scenario[`SubTotaITBIS1[${i}]`],
                SubTotaITBIS2: scenario[`SubTotaITBIS2[${i}]`],
                SubTotaITBIS3: scenario[`SubTotaITBIS3[${i}]`],
                SubTotalImpuestoAdicional:
                  scenario[`SubTotalImpuestoAdicional[${i}]`],
                SubTotalExento: scenario[`SubTotalExento[${i}]`],
                MontoSubTotal: scenario[`MontoSubTotal[${i}]`],
                Lineas: scenario[`Lineas[${i}]`],
              });
            }
          }
          if (subtotales.length > 0) {
            return { Subtotal: subtotales };
          } else {
            return null;
          }
        })(),

        DescuentosORecargos: (() => {
          const descuentosORecargos = [];
          for (let i = 1; i <= 20; i++) {
            if (
              scenario[`NumeroLineaDoR[${i}]`] ||
              scenario[`TipoAjuste[${i}]`] ||
              scenario[`IndicadorNorma1007[${i}]`] ||
              scenario[`DescripcionDescuentooRecargo[${i}]`] ||
              scenario[`TipoValor[${i}]`] ||
              scenario[`ValorDescuentooRecargo[${i}]`] ||
              scenario[`MontoDescuentooRecargo[${i}]`] ||
              scenario[`MontoDescuentooRecargoOtraMoneda[${i}]`] ||
              scenario[`IndicadorFacturacionDescuentooRecargo[${i}]`]
            ) {
              descuentosORecargos.push({
                NumeroLinea: scenario[`NumeroLineaDoR[${i}]`],
                TipoAjuste: scenario[`TipoAjuste[${i}]`],
                IndicadorNorma1007: scenario[`IndicadorNorma1007[${i}]`],
                DescripcionDescuentooRecargo:
                  scenario[`DescripcionDescuentooRecargo[${i}]`],
                TipoValor: scenario[`TipoValor[${i}]`],
                ValorDescuentooRecargo:
                  scenario[`ValorDescuentooRecargo[${i}]`],
                MontoDescuentooRecargo:
                  scenario[`MontoDescuentooRecargo[${i}]`],
                MontoDescuentooRecargoOtraMoneda:
                  scenario[`MontoDescuentooRecargoOtraMoneda[${i}]`],
                IndicadorFacturacionDescuentooRecargo:
                  scenario[`IndicadorFacturacionDescuentooRecargo[${i}]`],
              });
            }
          }
          if (descuentosORecargos.length > 0) {
            return { DescuentoORecargo: descuentosORecargos };
          } else {
            return null;
          }
        })(),

        // 11) <Paginacion>
        Paginacion: (() => {
          const paginas = [];

          for (let i = 1; i <= 1000; i++) {
            const pagina = {
              PaginaNo: scenario[`PaginaNo[${i}]`],
              NoLineaDesde: scenario[`NoLineaDesde[${i}]`],
              NoLineaHasta: scenario[`NoLineaHasta[${i}]`],
              SubtotalMontoGravadoPagina:
                scenario[`SubtotalMontoGravadoPagina[${i}]`],
              SubtotalMontoGravado1Pagina:
                scenario[`SubtotalMontoGravado1Pagina[${i}]`],
              SubtotalMontoGravado2Pagina:
                scenario[`SubtotalMontoGravado2Pagina[${i}]`],
              SubtotalMontoGravado3Pagina:
                scenario[`SubtotalMontoGravado3Pagina[${i}]`],
              SubtotalExentoPagina: scenario[`SubtotalExentoPagina[${i}]`],
              SubtotalItbisPagina: scenario[`SubtotalItbisPagina[${i}]`],
              SubtotalItbis1Pagina: scenario[`SubtotalItbis1Pagina[${i}]`],
              SubtotalItbis2Pagina: scenario[`SubtotalItbis2Pagina[${i}]`],
              SubtotalItbis3Pagina: scenario[`SubtotalItbis3Pagina[${i}]`],
              SubtotalImpuestoAdicionalPagina:
                scenario[`SubtotalImpuestoAdicionalPagina[${i}]`],
              SubtotalImpuestoAdicional:
                scenario[
                  `SubtotalImpuestoSelectivoConsumoEspecificoPagina[${i}]`
                ] || scenario[`SubtotalOtrosImpuesto[${i}]`]
                  ? {
                      SubtotalImpuestoSelectivoConsumoEspecificoPagina:
                        scenario[
                          `SubtotalImpuestoSelectivoConsumoEspecificoPagina[${i}]`
                        ],
                      SubtotalOtrosImpuesto:
                        scenario[`SubtotalOtrosImpuesto[${i}]`],
                    }
                  : null,
              MontoSubtotalPagina: scenario[`MontoSubtotalPagina[${i}]`],
              SubtotalMontoNoFacturablePagina:
                scenario[`SubtotalMontoNoFacturablePagina[${i}]`],
            };

            // Verifica si hay al menos un valor en la página
            if (
              Object.values(pagina).some(
                (val) => val !== null && val !== undefined && val !== ""
              )
            ) {
              paginas.push(pagina);
            }
          }

          return paginas.length > 0 ? { Pagina: paginas } : null;
        })(),

        // 12) <InformacionReferencia>
        InformacionReferencia: {
          NCFModificado: scenario.NCFModificado,
          RNCOtroContribuyente: scenario.RNCOtroContribuyente,
          FechaNCFModificado: scenario.FechaNCFModificado,
          CodigoModificacion: scenario.CodigoModificacion,
          RazonModificacion: scenario.RazonModificacion,
        },

        // Ejemplo: <FechaHoraFirma>
        FechaHoraFirma: scenario.FechaHoraFirma,

        // Ejemplo: <any_element>
        any_element: scenario.any_element,
      };

      const xmlDataRFCE = {
        Encabezado: {
          Version: scenario?.Version,
          IdDoc: {
            TipoeCF: scenario?.TipoeCF,
            eNCF: scenario?.ENCF,
            TipoIngresos: scenario?.TipoIngresos,
            TipoPago: scenario?.TipoPago,
            TablaFormasPago: scenario?.["FormaPago[1]"]
              ? {
                  FormaDePago: [
                    {
                      FormaPago: scenario?.["FormaPago[1]"],
                      MontoPago: scenario?.["MontoPago[1]"],
                    },
                    {
                      FormaPago: scenario?.["FormaPago[2]"],
                      MontoPago: scenario?.["MontoPago[2]"],
                    },
                    {
                      FormaPago: scenario?.["FormaPago[3]"],
                      MontoPago: scenario?.["MontoPago[3]"],
                    },
                  ].filter((f) => f.FormaPago || f.MontoPago), // quita vacíos
                }
              : null,
          },
          Emisor: {
            RNCEmisor: scenario?.RNCEmisor,
            RazonSocialEmisor: scenario?.RazonSocialEmisor,
            FechaEmision: scenario?.FechaEmision,
          },
          Comprador: {
            RNCComprador: scenario?.RNCComprador,
            IdentificadorExtranjero: scenario?.IdentificadorExtranjero,
            RazonSocialComprador: scenario?.RazonSocialComprador,
          },
          Totales: {
            MontoGravadoTotal: scenario?.MontoGravadoTotal,
            MontoGravadoI1: scenario?.MontoGravadoI1,
            MontoGravadoI2: scenario?.MontoGravadoI2,
            MontoGravadoI3: scenario?.MontoGravadoI3,
            MontoExento: scenario?.MontoExento,
            TotalITBIS: scenario?.TotalITBIS,
            TotalITBIS1: scenario?.TotalITBIS1,
            TotalITBIS2: scenario?.TotalITBIS2,
            TotalITBIS3: scenario?.TotalITBIS3,
            MontoImpuestoAdicional: scenario?.MontoImpuestoAdicional,
            // ImpuestosAdicionales: (() => {
            //   const impuestosAdicionales = [];
            //   for (let i = 1; i <= 20; i++) {
            //     const impuestoAdicional = {
            //       TipoImpuesto: scenario?.[`TipoImpuesto[${i}]`],
            //       MontoImpuestoSelectivoConsumoEspecifico:
            //         scenario?.[`MontoImpuestoSelectivoConsumoEspecifico[${i}]`],
            //       MontoImpuestoSelectivoConsumoAdvalorem:
            //         scenario?.[`MontoImpuestoSelectivoConsumoAdvalorem[${i}]`],
            //       OtrosImpuestosAdicionales:
            //         scenario?.[`OtrosImpuestosAdicionales[${i}]`],
            //     };

            //     if (
            //       impuestoAdicional.TipoImpuesto ||
            //       impuestoAdicional.MontoImpuestoSelectivoConsumoEspecifico ||
            //       impuestoAdicional.MontoImpuestoSelectivoConsumoAdvalorem ||
            //       impuestoAdicional.OtrosImpuestosAdicionales
            //     ) {
            //       impuestosAdicionales.push(impuestoAdicional);
            //     }
            //   }

            //   return { ImpuestoAdicional: impuestosAdicionales };
            // })(),
            MontoTotal: scenario?.MontoTotal,
            MontoNoFacturable: scenario?.MontoNoFacturable,
            MontoPeriodo: scenario?.MontoPeriodo,
          },
          CodigoSeguridadeCF: "-",
        },
      };

      const shouldGenerateRFCE =
        scenario.TipoeCF === "32" && parseFloat(scenario.MontoTotal) < 250000;

      let signedXML = null;
      let signedRFCE = null;

      const cleanedData = limpiarObjeto(xmlData);
      if (!cleanedData)
        throw new Error("❌ No hay datos válidos para generar XML.");

      const xmlString = generateECFXML(cleanedData, "ECF");
      console.log("✍️ Firmando XML principal...");
      const phpApiResponse = await axios.post(
        "http://127.0.0.1:8000/index.php",
        {
          xmlContent: xmlString,
          certPath: certPath,
          certPassword: certPassword,
        }
      );

      signedXML = phpApiResponse.data;

      console.log("✅ XML principal firmado correctamente.");
      if (shouldGenerateRFCE) {
        const cleanedRFCE = limpiarObjeto(xmlDataRFCE);

        if (!cleanedRFCE) {
          throw new Error("❌ El XML RFCE no contiene datos válidos.");
        }

        // 🔎 Extraer el SignatureValue
        const signatureMatch = signedXML.match(
          /<SignatureValue>(.*?)<\/SignatureValue>/
        );

        if (!signatureMatch) {
          throw new Error(
            "❌ No se pudo extraer el SignatureValue del XML principal."
          );
        }

        const codigoSeguridad = signatureMatch[1].substring(0, 6);
        console.log("🔐 Código de seguridad extraído:", codigoSeguridad);

        // ➕ Insertar el CódigoSeguridadeCF en xmlDataRFCE
        cleanedRFCE.Encabezado.CodigoSeguridadeCF = codigoSeguridad;

        // 🔁 Convertir y firmar RFCE
        const xmlStringRFCE = generateECFXML(cleanedRFCE, "RFCE");

        console.log("✍️ Firmando XML RFCE...");
        const phpRFCE = await axios.post("http://127.0.0.1:8000/index.php", {
          xmlContent: xmlStringRFCE,
          certPath: certPath,
          certPassword: certPassword,
        });

        signedRFCE = phpRFCE.data;
        console.log("✅ XML RFCE firmado correctamente.");
      }

      // **5️⃣ Enviamos el XML firmado a la DGII**
      const fileName = `${scenario.CasoPrueba}.xml`;
      const fileNameRFCE = `${scenario.CasoPrueba}.xml`;
      // const fileName = `${scenario.CasoPrueba}.xml`.trim();
      console.log("📤 Nombre de archivo", fileName);
      console.log("📤 Enviando XML principal:", fileName);
      // const responseXML = await sendECFToDGII(signedXML, fileName, "ECF");
      if (fileNameRFCE && signedRFCE) {
        console.log("📤 Enviando XML RFCE primero:", fileNameRFCE);
        const responseRFCE = await sendRFCE(signedRFCE, fileNameRFCE, "RFCE");
        console.log(
          "✅ Respuesta DGII RFCE:",
          responseRFCE.data || responseRFCE
        );
        results.push({ scenario, status: "success", responseRFCE });
      }

      if (shouldGenerateRFCE) {
        // 🔽 Luego el XML principal
        console.log("📤 Enviando XML principal:", fileName);
        const responseXML = await guardarECF(signedXML, fileName, "ECF");

        console.log("✅ Respuesta DGII:", responseXML.data || responseXML);
        results.push({ scenario, status: "success", responseXML });
      } else {
        // 🔽 Luego el XML principal
        console.log("📤 Enviando XML principal 1:", fileName);
        const responseXML = await sendECF(signedXML, fileName, "ECF");

        console.log("✅ Respuesta DGII:", responseXML.data || responseXML);
        results.push({ scenario, status: "success", responseXML });
      }

      cleanup();
    } catch (error) {
      // console.error("🚨 Error: ", error);
      console.error("🚨 Error en el proceso 222:", error.message);
      results.push({ scenario, status: "error", message: error.message });
    }
  }

  return results;
};
