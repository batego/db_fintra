-- Table: fenalco.pgirdat

-- DROP TABLE fenalco.pgirdat;

CREATE TABLE fenalco.pgirdat
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
ALTER TABLE fenalco.pgirdat
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.pgirdat.poscon IS 'Numero Negocio';
COMMENT ON COLUMN fenalco.pgirdat.posdidnom IS 'Nombre Opcional';
COMMENT ON COLUMN fenalco.pgirdat.aficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenalco.pgirdat.afinumsuc IS 'Numero Sucursal';
COMMENT ON COLUMN fenalco.pgirdat.poscodsex IS 'Sexo';
COMMENT ON COLUMN fenalco.pgirdat.posdir IS 'Direccion';
COMMENT ON COLUMN fenalco.pgirdat.postel1 IS 'Telefono 1';
COMMENT ON COLUMN fenalco.pgirdat.postel2 IS 'Telefono 2';
COMMENT ON COLUMN fenalco.pgirdat.postelcel IS 'Celular';
COMMENT ON COLUMN fenalco.pgirdat.poscodsuc IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenalco.pgirdat.posnumcun IS 'Nro. Cuenta';
COMMENT ON COLUMN fenalco.pgirdat.rsecod IS 'Respuesta Servicio';
COMMENT ON COLUMN fenalco.pgirdat.mrscod IS 'Motivo Respuesta';
COMMENT ON COLUMN fenalco.pgirdat.ocfcod IS 'Codigo Observacion';
COMMENT ON COLUMN fenalco.pgirdat.postxtobs IS 'Observacion Adicional';
COMMENT ON COLUMN fenalco.pgirdat.poscodusu IS 'Codigo del Usuario';
COMMENT ON COLUMN fenalco.pgirdat.posfec IS 'Fecha Consulta  Girador post';
COMMENT ON COLUMN fenalco.pgirdat.poscanche IS 'Nro de Cheques';
COMMENT ON COLUMN fenalco.pgirdat.afiperneg IS 'Periodo por Negocio';
COMMENT ON COLUMN fenalco.pgirdat.bancod IS 'Codigo de Banco';
COMMENT ON COLUMN fenalco.pgirdat.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenalco.pgirdat.posfecini IS 'Fecha Inicial';
COMMENT ON COLUMN fenalco.pgirdat.posfecfin IS 'Fecha Final';
COMMENT ON COLUMN fenalco.pgirdat.poslinult IS 'Ultima L¡nea cheque';
COMMENT ON COLUMN fenalco.pgirdat.postxtesp IS 'PosTxtEsp';
COMMENT ON COLUMN fenalco.pgirdat.posfecusu IS 'fecha';
COMMENT ON COLUMN fenalco.pgirdat.posaccusu IS 'Accion';
COMMENT ON COLUMN fenalco.pgirdat.posindsin IS 'PosIndSin';
COMMENT ON COLUMN fenalco.pgirdat.posdoccod IS 'Tipo documento';
COMMENT ON COLUMN fenalco.pgirdat.posdidnum IS 'Numero de identificacion';
COMMENT ON COLUMN fenalco.pgirdat.tipconcod IS 'Tipo de consulta';
COMMENT ON COLUMN fenalco.pgirdat.aficodscc IS 'Codigo de la  seccional';
COMMENT ON COLUMN fenalco.pgirdat.postelcdex IS 'Codigo beeper o  Extension';
COMMENT ON COLUMN fenalco.pgirdat.poscontact IS 'Contacto girador posfechados';
COMMENT ON COLUMN fenalco.pgirdat.posdptcod IS 'Departamento Ciudad';
COMMENT ON COLUMN fenalco.pgirdat.posciucod IS 'Ciudad Codigo';
COMMENT ON COLUMN fenalco.pgirdat.poscob IS 'Cobetura en la  Consulta';


-- Index: fenalco.consecutivo_afi_afidate1

-- DROP INDEX fenalco.consecutivo_afi_afidate1;

CREATE INDEX consecutivo_afi_afidate1
  ON fenalco.pgirdat
  USING btree
  (aficon);

-- Index: fenalco.consecutivo_afi_pgirdat

-- DROP INDEX fenalco.consecutivo_afi_pgirdat;

CREATE INDEX consecutivo_afi_pgirdat
  ON fenalco.pgirdat
  USING btree
  (aficon);

-- Index: fenalco.consecutivo_negocio_pgirdat

-- DROP INDEX fenalco.consecutivo_negocio_pgirdat;

CREATE INDEX consecutivo_negocio_pgirdat
  ON fenalco.pgirdat
  USING btree
  (poscon);


