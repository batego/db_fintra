-- Table: fenalco.siniestr

-- DROP TABLE fenalco.siniestr;

CREATE TABLE fenalco.siniestr
(
  sinconnum numeric(8,0), -- Numero Consulta
  sinindsin text, -- Indicador de Siniestro
  sincontip text, -- Tipo Consulta Siniestro
  sincons numeric(8,0), -- Consecutivo Siniestro
  aficon numeric(6,0), -- Consecutivo Afiliado
  afinumsuc numeric(3,0), -- Numero Sucursal
  rsecod numeric(1,0), -- Respuesta Servicio
  frecod numeric(2,0), -- Fuente Reporte
  aficodscc numeric(2,0), -- Codigo de la  seccional
  sinfecon timestamp without time zone, -- Fecha Consignacion siniestro
  sinferec timestamp without time zone, -- Fecha Recepcion  Cheque siniest
  sinfeorm timestamp without time zone, -- Fecha Orden de  Memorando sinie
  sininind text, -- Indicador de indemnizacion
  sinsusu1 text, -- Usuario siniestro
  finnit numeric(11,0), -- Nit de la  Financiera
  sindir text, -- Direccion
  sindoccod numeric(2,0), -- Tipo Documento del  Siniestro
  sindocabr text, -- Tipo Documento Abreviado
  sintel1 numeric(11,0), -- Telefono 1 siniestro
  sintele2 numeric(11,0), -- Telefono 2 siniestro
  sintelcel numeric(11,0), -- Telefono Celular siniestro
  sindidnum numeric(11,0), -- Numero Documento Siniestro
  sinnomdid text, -- Nombre del Siniestro
  sinfech timestamp without time zone, -- Fecha Consulta
  bancod numeric(2,0), -- Codigo de Banco
  succod numeric(4,0), -- Codigo de Sucursal
  sinnumcun numeric(13,0), -- Numero Cuenta siniestro
  sinnumche numeric(8,0), -- Numero Cheque siniestro
  sinvalche numeric(9,0), -- Valor Cheque siniestro
  cobcodsin numeric(2,0), -- Codigo del Cobrador
  sinsacc text, -- Accion
  sinsfec timestamp without time zone, -- Fecha
  sinsusu text, -- Usuario
  sinposan numeric(3,1), -- Porcentaje sancion siniestro
  sinhon numeric(10,0), -- Honorarios Cobrador
  sinintmor numeric(10,0), -- Intereses Mora Siniestro
  sinvasan numeric(9,0), -- Valor sanci¢n siniestro
  sinvatotre numeric(10,0), -- Valor total recuperador
  sinvaind numeric(10,0), -- valor de Indemnizacion
  sinvapenre numeric(9,0), -- Valor Pendiente  Recup. sinies
  sinfercp timestamp without time zone, -- Fecha Recuperacion
  sinesta text, -- Estado Siniestro
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.siniestr
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.siniestr.sinconnum IS 'Numero Consulta';
COMMENT ON COLUMN fenalco.siniestr.sinindsin IS 'Indicador de Siniestro';
COMMENT ON COLUMN fenalco.siniestr.sincontip IS 'Tipo Consulta Siniestro';
COMMENT ON COLUMN fenalco.siniestr.sincons IS 'Consecutivo Siniestro';
COMMENT ON COLUMN fenalco.siniestr.aficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenalco.siniestr.afinumsuc IS 'Numero Sucursal';
COMMENT ON COLUMN fenalco.siniestr.rsecod IS 'Respuesta Servicio';
COMMENT ON COLUMN fenalco.siniestr.frecod IS 'Fuente Reporte';
COMMENT ON COLUMN fenalco.siniestr.aficodscc IS 'Codigo de la  seccional';
COMMENT ON COLUMN fenalco.siniestr.sinfecon IS 'Fecha Consignacion siniestro';
COMMENT ON COLUMN fenalco.siniestr.sinferec IS 'Fecha Recepcion  Cheque siniest';
COMMENT ON COLUMN fenalco.siniestr.sinfeorm IS 'Fecha Orden de  Memorando sinie';
COMMENT ON COLUMN fenalco.siniestr.sininind IS 'Indicador de indemnizacion';
COMMENT ON COLUMN fenalco.siniestr.sinsusu1 IS 'Usuario siniestro';
COMMENT ON COLUMN fenalco.siniestr.finnit IS 'Nit de la  Financiera';
COMMENT ON COLUMN fenalco.siniestr.sindir IS 'Direccion';
COMMENT ON COLUMN fenalco.siniestr.sindoccod IS 'Tipo Documento del  Siniestro';
COMMENT ON COLUMN fenalco.siniestr.sindocabr IS 'Tipo Documento Abreviado';
COMMENT ON COLUMN fenalco.siniestr.sintel1 IS 'Telefono 1 siniestro';
COMMENT ON COLUMN fenalco.siniestr.sintele2 IS 'Telefono 2 siniestro';
COMMENT ON COLUMN fenalco.siniestr.sintelcel IS 'Telefono Celular siniestro';
COMMENT ON COLUMN fenalco.siniestr.sindidnum IS 'Numero Documento Siniestro';
COMMENT ON COLUMN fenalco.siniestr.sinnomdid IS 'Nombre del Siniestro';
COMMENT ON COLUMN fenalco.siniestr.sinfech IS 'Fecha Consulta';
COMMENT ON COLUMN fenalco.siniestr.bancod IS 'Codigo de Banco';
COMMENT ON COLUMN fenalco.siniestr.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenalco.siniestr.sinnumcun IS 'Numero Cuenta siniestro';
COMMENT ON COLUMN fenalco.siniestr.sinnumche IS 'Numero Cheque siniestro';
COMMENT ON COLUMN fenalco.siniestr.sinvalche IS 'Valor Cheque siniestro';
COMMENT ON COLUMN fenalco.siniestr.cobcodsin IS 'Codigo del Cobrador';
COMMENT ON COLUMN fenalco.siniestr.sinsacc IS 'Accion';
COMMENT ON COLUMN fenalco.siniestr.sinsfec IS 'Fecha';
COMMENT ON COLUMN fenalco.siniestr.sinsusu IS 'Usuario';
COMMENT ON COLUMN fenalco.siniestr.sinposan IS 'Porcentaje sancion siniestro';
COMMENT ON COLUMN fenalco.siniestr.sinhon IS 'Honorarios Cobrador';
COMMENT ON COLUMN fenalco.siniestr.sinintmor IS 'Intereses Mora Siniestro';
COMMENT ON COLUMN fenalco.siniestr.sinvasan IS 'Valor sanci¢n siniestro';
COMMENT ON COLUMN fenalco.siniestr.sinvatotre IS 'Valor total recuperador';
COMMENT ON COLUMN fenalco.siniestr.sinvaind IS 'valor de Indemnizacion';
COMMENT ON COLUMN fenalco.siniestr.sinvapenre IS 'Valor Pendiente  Recup. sinies';
COMMENT ON COLUMN fenalco.siniestr.sinfercp IS 'Fecha Recuperacion';
COMMENT ON COLUMN fenalco.siniestr.sinesta IS 'Estado Siniestro';


