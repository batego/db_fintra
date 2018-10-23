-- Table: fenbolivar.pgirdat

-- DROP TABLE fenbolivar.pgirdat;

CREATE TABLE fenbolivar.pgirdat
(
  poscon numeric(8,0), -- Numero Negocio
  posdidnom text, -- Nombre Opcional
  aficon numeric(6,0), -- Consecutivo Afiliado
  afinumsuc numeric(3,0), -- Numero Sucursal
  poscodsex text, -- Sexo
  posdir text, -- Direccion
  postel1 numeric(11,0), -- Telefono 1
  postel2 numeric(11,0), -- Telefono 2
  postelcel numeric(11,0), -- Celular
  poscodsuc numeric(4,0), -- Codigo de Sucursal
  posnumcun numeric(13,0), -- Nro. Cuenta
  rsecod numeric(1,0), -- Respuesta Servicio
  mrscod numeric(2,0), -- Motivo Respuesta
  ocfcod numeric(2,0), -- Codigo Observacion
  postxtobs text, -- Observacion Adicional
  poscodusu text, -- Codigo del Usuario
  posfec timestamp without time zone, -- Fecha Consulta  Girador post
  poscanche numeric(2,0), -- Nro de Cheques
  afiperneg numeric(2,0), -- Periodo por Negocio
  bancod numeric(2,0), -- Codigo de Banco
  succod numeric(4,0), -- Codigo de Sucursal
  posfecini timestamp without time zone, -- Fecha Inicial
  posfecfin timestamp without time zone, -- Fecha Final
  poslinult numeric(2,0), -- Ultima L¡nea cheque
  postxtesp text, -- PosTxtEsp
  posfecusu timestamp without time zone, -- fecha
  posaccusu text, -- Accion
  posindsin numeric(1,0), -- PosIndSin
  posdoccod numeric(2,0), -- Tipo documento
  posdidnum numeric(11,0), -- Numero de identificacion
  tipconcod numeric(1,0), -- Tipo de consulta
  aficodscc numeric(2,0), -- Codigo de la  seccional
  postelcdex text, -- Codigo beeper o  Extension
  poscontact text, -- Contacto girador posfechados
  posdptcod numeric(2,0), -- Departamento Ciudad
  posciucod numeric(3,0), -- Ciudad Codigo
  poscob numeric(9,0), -- Cobetura en la  Consulta
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.pgirdat
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.pgirdat.poscon IS 'Numero Negocio';
COMMENT ON COLUMN fenbolivar.pgirdat.posdidnom IS 'Nombre Opcional';
COMMENT ON COLUMN fenbolivar.pgirdat.aficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenbolivar.pgirdat.afinumsuc IS 'Numero Sucursal';
COMMENT ON COLUMN fenbolivar.pgirdat.poscodsex IS 'Sexo';
COMMENT ON COLUMN fenbolivar.pgirdat.posdir IS 'Direccion';
COMMENT ON COLUMN fenbolivar.pgirdat.postel1 IS 'Telefono 1';
COMMENT ON COLUMN fenbolivar.pgirdat.postel2 IS 'Telefono 2';
COMMENT ON COLUMN fenbolivar.pgirdat.postelcel IS 'Celular';
COMMENT ON COLUMN fenbolivar.pgirdat.poscodsuc IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenbolivar.pgirdat.posnumcun IS 'Nro. Cuenta';
COMMENT ON COLUMN fenbolivar.pgirdat.rsecod IS 'Respuesta Servicio';
COMMENT ON COLUMN fenbolivar.pgirdat.mrscod IS 'Motivo Respuesta';
COMMENT ON COLUMN fenbolivar.pgirdat.ocfcod IS 'Codigo Observacion';
COMMENT ON COLUMN fenbolivar.pgirdat.postxtobs IS 'Observacion Adicional';
COMMENT ON COLUMN fenbolivar.pgirdat.poscodusu IS 'Codigo del Usuario';
COMMENT ON COLUMN fenbolivar.pgirdat.posfec IS 'Fecha Consulta  Girador post';
COMMENT ON COLUMN fenbolivar.pgirdat.poscanche IS 'Nro de Cheques';
COMMENT ON COLUMN fenbolivar.pgirdat.afiperneg IS 'Periodo por Negocio';
COMMENT ON COLUMN fenbolivar.pgirdat.bancod IS 'Codigo de Banco';
COMMENT ON COLUMN fenbolivar.pgirdat.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenbolivar.pgirdat.posfecini IS 'Fecha Inicial';
COMMENT ON COLUMN fenbolivar.pgirdat.posfecfin IS 'Fecha Final';
COMMENT ON COLUMN fenbolivar.pgirdat.poslinult IS 'Ultima L¡nea cheque';
COMMENT ON COLUMN fenbolivar.pgirdat.postxtesp IS 'PosTxtEsp';
COMMENT ON COLUMN fenbolivar.pgirdat.posfecusu IS 'fecha';
COMMENT ON COLUMN fenbolivar.pgirdat.posaccusu IS 'Accion';
COMMENT ON COLUMN fenbolivar.pgirdat.posindsin IS 'PosIndSin';
COMMENT ON COLUMN fenbolivar.pgirdat.posdoccod IS 'Tipo documento';
COMMENT ON COLUMN fenbolivar.pgirdat.posdidnum IS 'Numero de identificacion';
COMMENT ON COLUMN fenbolivar.pgirdat.tipconcod IS 'Tipo de consulta';
COMMENT ON COLUMN fenbolivar.pgirdat.aficodscc IS 'Codigo de la  seccional';
COMMENT ON COLUMN fenbolivar.pgirdat.postelcdex IS 'Codigo beeper o  Extension';
COMMENT ON COLUMN fenbolivar.pgirdat.poscontact IS 'Contacto girador posfechados';
COMMENT ON COLUMN fenbolivar.pgirdat.posdptcod IS 'Departamento Ciudad';
COMMENT ON COLUMN fenbolivar.pgirdat.posciucod IS 'Ciudad Codigo';
COMMENT ON COLUMN fenbolivar.pgirdat.poscob IS 'Cobetura en la  Consulta';


-- Index: fenbolivar.consecutivo_afbi_afidate1

-- DROP INDEX fenbolivar.consecutivo_afbi_afidate1;

CREATE INDEX consecutivo_afbi_afidate1
  ON fenbolivar.pgirdat
  USING btree
  (aficon);

-- Index: fenbolivar.consecutivo_afbi_pgirdat

-- DROP INDEX fenbolivar.consecutivo_afbi_pgirdat;

CREATE INDEX consecutivo_afbi_pgirdat
  ON fenbolivar.pgirdat
  USING btree
  (aficon);

-- Index: fenbolivar.consecutivo_negociofb_pgirdat

-- DROP INDEX fenbolivar.consecutivo_negociofb_pgirdat;

CREATE INDEX consecutivo_negociofb_pgirdat
  ON fenbolivar.pgirdat
  USING btree
  (poscon);


