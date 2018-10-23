-- Table: fenalco.fgirador

-- DROP TABLE fenalco.fgirador;

CREATE TABLE fenalco.fgirador
(
  gircon numeric(8,0), -- Numero Consulta
  girdidnom text, -- Nombre Girador consulta
  aficon numeric(6,0), -- Consecutivo Afiliado
  afinumsuc numeric(3,0), -- Numero Sucursal
  gircodsex text, -- Sexo
  girdir text, -- Direccion
  girtel1 numeric(11,0), -- Telefono 1
  girtel2 numeric(11,0), -- Telefono 2
  girtelcel numeric(11,0), -- Celular
  gircodsuc numeric(4,0), -- Codigo de Sucursal
  girnumcun numeric(13,0), -- Nro. Cuenta
  girnumche numeric(8,0), -- Nro. Cheque
  girvalche numeric(9,0), -- Valor Cheque
  rsecod numeric(1,0), -- Respuesta Servicio
  mrscod numeric(2,0), -- Motivo Respuesta
  ocfcod numeric(2,0), -- Codigo Observacion
  girtxtobs text, -- Observacion Adicional
  gircodusu text, -- Codigo Usuario
  girnomusu text, -- Nombre Usuario
  girfec timestamp without time zone, -- Fecha Consulta Girador
  girindsin numeric(1,0), -- GirIndSin
  bancod numeric(2,0), -- Codigo de Banco
  succod numeric(4,0), -- Codigo de Sucursal
  girtxtesp text, -- Espacio
  giracc text, -- Accion
  girfecreg timestamp without time zone, -- Fecha registro
  girusureg text, -- Usuario
  girdoccod numeric(2,0), -- Codigo del documento
  girdidnum numeric(11,0), -- Numero de identificacion
  tipconcod numeric(1,0), -- Tipo de consulta
  aficodscc numeric(2,0), -- Codigo de la  seccional
  girtelcdex text, -- Codigo bepeer o  extension
  gircontact text, -- Contacto del afiliado
  girciucod numeric(3,0), -- Ciudad Codigo
  girdptcod numeric(2,0), -- Departamento de Ciudad
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenalco.fgirador
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.fgirador.gircon IS 'Numero Consulta';
COMMENT ON COLUMN fenalco.fgirador.girdidnom IS 'Nombre Girador consulta';
COMMENT ON COLUMN fenalco.fgirador.aficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenalco.fgirador.afinumsuc IS 'Numero Sucursal';
COMMENT ON COLUMN fenalco.fgirador.gircodsex IS 'Sexo';
COMMENT ON COLUMN fenalco.fgirador.girdir IS 'Direccion';
COMMENT ON COLUMN fenalco.fgirador.girtel1 IS 'Telefono 1';
COMMENT ON COLUMN fenalco.fgirador.girtel2 IS 'Telefono 2';
COMMENT ON COLUMN fenalco.fgirador.girtelcel IS 'Celular';
COMMENT ON COLUMN fenalco.fgirador.gircodsuc IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenalco.fgirador.girnumcun IS 'Nro. Cuenta';
COMMENT ON COLUMN fenalco.fgirador.girnumche IS 'Nro. Cheque';
COMMENT ON COLUMN fenalco.fgirador.girvalche IS 'Valor Cheque';
COMMENT ON COLUMN fenalco.fgirador.rsecod IS 'Respuesta Servicio';
COMMENT ON COLUMN fenalco.fgirador.mrscod IS 'Motivo Respuesta';
COMMENT ON COLUMN fenalco.fgirador.ocfcod IS 'Codigo Observacion';
COMMENT ON COLUMN fenalco.fgirador.girtxtobs IS 'Observacion Adicional';
COMMENT ON COLUMN fenalco.fgirador.gircodusu IS 'Codigo Usuario';
COMMENT ON COLUMN fenalco.fgirador.girnomusu IS 'Nombre Usuario';
COMMENT ON COLUMN fenalco.fgirador.girfec IS 'Fecha Consulta Girador';
COMMENT ON COLUMN fenalco.fgirador.girindsin IS 'GirIndSin';
COMMENT ON COLUMN fenalco.fgirador.bancod IS 'Codigo de Banco';
COMMENT ON COLUMN fenalco.fgirador.succod IS 'Codigo de Sucursal';
COMMENT ON COLUMN fenalco.fgirador.girtxtesp IS 'Espacio';
COMMENT ON COLUMN fenalco.fgirador.giracc IS 'Accion';
COMMENT ON COLUMN fenalco.fgirador.girfecreg IS 'Fecha registro';
COMMENT ON COLUMN fenalco.fgirador.girusureg IS 'Usuario';
COMMENT ON COLUMN fenalco.fgirador.girdoccod IS 'Codigo del documento';
COMMENT ON COLUMN fenalco.fgirador.girdidnum IS 'Numero de identificacion';
COMMENT ON COLUMN fenalco.fgirador.tipconcod IS 'Tipo de consulta';
COMMENT ON COLUMN fenalco.fgirador.aficodscc IS 'Codigo de la  seccional';
COMMENT ON COLUMN fenalco.fgirador.girtelcdex IS 'Codigo bepeer o  extension';
COMMENT ON COLUMN fenalco.fgirador.gircontact IS 'Contacto del afiliado';
COMMENT ON COLUMN fenalco.fgirador.girciucod IS 'Ciudad Codigo';
COMMENT ON COLUMN fenalco.fgirador.girdptcod IS 'Departamento de Ciudad';


