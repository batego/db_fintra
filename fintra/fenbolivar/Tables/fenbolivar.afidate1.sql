-- Table: fenbolivar.afidate1

-- DROP TABLE fenbolivar.afidate1;

CREATE TABLE fenbolivar.afidate1
(
  aficodscc numeric(2,0), -- Codigo de la  seccional
  aficon numeric(6,0), -- Consecutivo Afiliado
  afinumsuc numeric(3,0), -- Numero Sucursal
  afinomcom text, -- Nombre Comercial
  seccod numeric(2,0), -- Sector
  afitiploc text, -- Tipo de Local
  afivalcan numeric(12,0), -- Canon de Arrendamiento
  aficanmt2 numeric(7,2), -- Area del Establecimiento
  afinomarr text, -- Arrendador
  afidirarr text, -- Direccion del Arrendador
  afinumtela numeric(11,0), -- Telefono del Arrendador
  afinumtel1 numeric(11,0), -- Telefono No.1
  afinumtel2 numeric(11,0), -- Telefono No.2
  afinumcel numeric(11,0), -- Celular
  afinumbep numeric(11,0), -- Beeper
  afinumfax numeric(11,0), -- Fax
  afinumeml text, -- E-mail
  afitip text, -- Tipo de Afiliado/Usuario/Sus
  afivalcso numeric(12,0), -- Valor Cuota de  Sostenimiento
  afinumapr numeric(6,0), -- Apartado
  aficodusu text, -- Codigo del usuario
  afinomusu text, -- Nombre del usuario
  afifec timestamp without time zone, -- Fecha de actualizacion
  afiacc text, -- Ultima accion ejecutada
  afidoccod numeric(2,0), -- Tipo Documento Afiliado
  afididnum numeric(11,0), -- Documento del Afiliado
  afiindvac text, -- Indicador Ventas a  Credito
  afivalvac numeric(12,0), -- Promedio Ventas Credito
  afiindvpm text, -- Indicador Ventas  al Por Mayor
  afivalvpm numeric(12,0), -- Promedio Ventas al  Por Mayor
  afiindvop text, -- Indicador Ventas  otras Plazas
  afivalvop numeric(12,0), -- Promedio Ventas  Otras Plazas
  afiindimp text, -- Indicador de Importacion
  afivalimp numeric(12,0), -- Promedio Importaciones
  afiindexp text, -- Indicador de Exportador
  afivalexp numeric(12,0), -- Promedio Exportaciones
  afiindpac text, -- Indicador Productor Articulos
  afivalpac numeric(12,0), -- Promedio Articulos Comercializ
  afindrep text, -- Indicador Representatividad
  afiindser text, -- Indicador de Servicio
  afiinddag text, -- Indicador Deseo  Aporte Gremio
  afiindora text, -- Indicador Otras Razones
  afidesraz text, -- Descripcion Otras Razones
  afiindami text, -- Indicador Referencia Amigo
  afiindpre text, -- Indicador Referencia Prensa
  afiindrad text, -- Indicador de Radio
  afiindtel text, -- Indicador Referencia Televisio
  afiindomc text, -- Indicador otros Medios
  afidesomc text, -- Descripcion otros Medios
  scccodqafi numeric(2,0), -- Seccional Funcionario Afiliado
  funnumqafi numeric(3,0), -- Codigo Funcionario  que Afilia
  funnomqafi text, -- Nombre funcionario Afiliador
  scccodapr numeric(2,0), -- Seccional Afiliado Presentador
  seccodapr numeric(2,0), -- Sector Afiliado Presentador
  aficonapr numeric(6,0), -- Cons. Afiliado Presentador
  afinumsapr numeric(2,0), -- Sucursal Afiliado Presentador
  afinomcap text, -- Nombre Comercial  Afiliador Pre
  scccodqcob numeric(2,0), -- Seccional Funcionario Cobrador
  funnumqcob numeric(3,0), -- Codigo Funcionario  que Cobra
  funnomqcob text, -- Nombre Funcionario  que cobra
  aficodcla text, -- Clave Afiliado
  ciicod numeric(8,0), -- Codigo CIIU
  tipaficod numeric(2,0), -- Tipo Afiliado
  afifecafi timestamp without time zone, -- Fecha Afiliacion
  afiindmjd text, -- Indicador de  Miembro de Junta
  afifecnjd timestamp without time zone, -- Fecha Nombr. Junta  Directiva
  afifecrjd timestamp without time zone, -- Fecha Vigencia  Junta Directiva
  subseccod numeric(2,0), -- SubSector
  afidocrep numeric(2,0), -- Documento representante
  afinumrep numeric(11,0), -- Numero del representante
  afirazsoc text, -- Razon social
  afidptcod numeric(2,0), -- Departamento
  aficiucod numeric(3,0), -- Ciudad
  zoncod numeric(2,0), -- Zona Ciudad
  afidirloc text, -- Direccion del Local
  afifecret timestamp without time zone, -- Fecha retiro
  afiindpro text, -- Afiliado Procredito
  afiindspr text, -- Sancion de Procredito
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.afidate1
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.afidate1.aficodscc IS 'Codigo de la  seccional';
COMMENT ON COLUMN fenbolivar.afidate1.aficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenbolivar.afidate1.afinumsuc IS 'Numero Sucursal';
COMMENT ON COLUMN fenbolivar.afidate1.afinomcom IS 'Nombre Comercial';
COMMENT ON COLUMN fenbolivar.afidate1.seccod IS 'Sector';
COMMENT ON COLUMN fenbolivar.afidate1.afitiploc IS 'Tipo de Local';
COMMENT ON COLUMN fenbolivar.afidate1.afivalcan IS 'Canon de Arrendamiento';
COMMENT ON COLUMN fenbolivar.afidate1.aficanmt2 IS 'Area del Establecimiento';
COMMENT ON COLUMN fenbolivar.afidate1.afinomarr IS 'Arrendador';
COMMENT ON COLUMN fenbolivar.afidate1.afidirarr IS 'Direccion del Arrendador';
COMMENT ON COLUMN fenbolivar.afidate1.afinumtela IS 'Telefono del Arrendador';
COMMENT ON COLUMN fenbolivar.afidate1.afinumtel1 IS 'Telefono No.1';
COMMENT ON COLUMN fenbolivar.afidate1.afinumtel2 IS 'Telefono No.2';
COMMENT ON COLUMN fenbolivar.afidate1.afinumcel IS 'Celular';
COMMENT ON COLUMN fenbolivar.afidate1.afinumbep IS 'Beeper';
COMMENT ON COLUMN fenbolivar.afidate1.afinumfax IS 'Fax';
COMMENT ON COLUMN fenbolivar.afidate1.afinumeml IS 'E-mail';
COMMENT ON COLUMN fenbolivar.afidate1.afitip IS 'Tipo de Afiliado/Usuario/Sus';
COMMENT ON COLUMN fenbolivar.afidate1.afivalcso IS 'Valor Cuota de  Sostenimiento';
COMMENT ON COLUMN fenbolivar.afidate1.afinumapr IS 'Apartado';
COMMENT ON COLUMN fenbolivar.afidate1.aficodusu IS 'Codigo del usuario';
COMMENT ON COLUMN fenbolivar.afidate1.afinomusu IS 'Nombre del usuario';
COMMENT ON COLUMN fenbolivar.afidate1.afifec IS 'Fecha de actualizacion';
COMMENT ON COLUMN fenbolivar.afidate1.afiacc IS 'Ultima accion ejecutada';
COMMENT ON COLUMN fenbolivar.afidate1.afidoccod IS 'Tipo Documento Afiliado';
COMMENT ON COLUMN fenbolivar.afidate1.afididnum IS 'Documento del Afiliado';
COMMENT ON COLUMN fenbolivar.afidate1.afiindvac IS 'Indicador Ventas a  Credito';
COMMENT ON COLUMN fenbolivar.afidate1.afivalvac IS 'Promedio Ventas Credito';
COMMENT ON COLUMN fenbolivar.afidate1.afiindvpm IS 'Indicador Ventas  al Por Mayor';
COMMENT ON COLUMN fenbolivar.afidate1.afivalvpm IS 'Promedio Ventas al  Por Mayor';
COMMENT ON COLUMN fenbolivar.afidate1.afiindvop IS 'Indicador Ventas  otras Plazas';
COMMENT ON COLUMN fenbolivar.afidate1.afivalvop IS 'Promedio Ventas  Otras Plazas';
COMMENT ON COLUMN fenbolivar.afidate1.afiindimp IS 'Indicador de Importacion';
COMMENT ON COLUMN fenbolivar.afidate1.afivalimp IS 'Promedio Importaciones';
COMMENT ON COLUMN fenbolivar.afidate1.afiindexp IS 'Indicador de Exportador';
COMMENT ON COLUMN fenbolivar.afidate1.afivalexp IS 'Promedio Exportaciones';
COMMENT ON COLUMN fenbolivar.afidate1.afiindpac IS 'Indicador Productor Articulos';
COMMENT ON COLUMN fenbolivar.afidate1.afivalpac IS 'Promedio Articulos Comercializ';
COMMENT ON COLUMN fenbolivar.afidate1.afindrep IS 'Indicador Representatividad';
COMMENT ON COLUMN fenbolivar.afidate1.afiindser IS 'Indicador de Servicio';
COMMENT ON COLUMN fenbolivar.afidate1.afiinddag IS 'Indicador Deseo  Aporte Gremio';
COMMENT ON COLUMN fenbolivar.afidate1.afiindora IS 'Indicador Otras Razones';
COMMENT ON COLUMN fenbolivar.afidate1.afidesraz IS 'Descripcion Otras Razones';
COMMENT ON COLUMN fenbolivar.afidate1.afiindami IS 'Indicador Referencia Amigo';
COMMENT ON COLUMN fenbolivar.afidate1.afiindpre IS 'Indicador Referencia Prensa';
COMMENT ON COLUMN fenbolivar.afidate1.afiindrad IS 'Indicador de Radio';
COMMENT ON COLUMN fenbolivar.afidate1.afiindtel IS 'Indicador Referencia Televisio';
COMMENT ON COLUMN fenbolivar.afidate1.afiindomc IS 'Indicador otros Medios';
COMMENT ON COLUMN fenbolivar.afidate1.afidesomc IS 'Descripcion otros Medios';
COMMENT ON COLUMN fenbolivar.afidate1.scccodqafi IS 'Seccional Funcionario Afiliado';
COMMENT ON COLUMN fenbolivar.afidate1.funnumqafi IS 'Codigo Funcionario  que Afilia';
COMMENT ON COLUMN fenbolivar.afidate1.funnomqafi IS 'Nombre funcionario Afiliador';
COMMENT ON COLUMN fenbolivar.afidate1.scccodapr IS 'Seccional Afiliado Presentador';
COMMENT ON COLUMN fenbolivar.afidate1.seccodapr IS 'Sector Afiliado Presentador';
COMMENT ON COLUMN fenbolivar.afidate1.aficonapr IS 'Cons. Afiliado Presentador';
COMMENT ON COLUMN fenbolivar.afidate1.afinumsapr IS 'Sucursal Afiliado Presentador';
COMMENT ON COLUMN fenbolivar.afidate1.afinomcap IS 'Nombre Comercial  Afiliador Pre';
COMMENT ON COLUMN fenbolivar.afidate1.scccodqcob IS 'Seccional Funcionario Cobrador';
COMMENT ON COLUMN fenbolivar.afidate1.funnumqcob IS 'Codigo Funcionario  que Cobra';
COMMENT ON COLUMN fenbolivar.afidate1.funnomqcob IS 'Nombre Funcionario  que cobra';
COMMENT ON COLUMN fenbolivar.afidate1.aficodcla IS 'Clave Afiliado';
COMMENT ON COLUMN fenbolivar.afidate1.ciicod IS 'Codigo CIIU';
COMMENT ON COLUMN fenbolivar.afidate1.tipaficod IS 'Tipo Afiliado';
COMMENT ON COLUMN fenbolivar.afidate1.afifecafi IS 'Fecha Afiliacion';
COMMENT ON COLUMN fenbolivar.afidate1.afiindmjd IS 'Indicador de  Miembro de Junta';
COMMENT ON COLUMN fenbolivar.afidate1.afifecnjd IS 'Fecha Nombr. Junta  Directiva';
COMMENT ON COLUMN fenbolivar.afidate1.afifecrjd IS 'Fecha Vigencia  Junta Directiva';
COMMENT ON COLUMN fenbolivar.afidate1.subseccod IS 'SubSector';
COMMENT ON COLUMN fenbolivar.afidate1.afidocrep IS 'Documento representante';
COMMENT ON COLUMN fenbolivar.afidate1.afinumrep IS 'Numero del representante';
COMMENT ON COLUMN fenbolivar.afidate1.afirazsoc IS 'Razon social';
COMMENT ON COLUMN fenbolivar.afidate1.afidptcod IS 'Departamento';
COMMENT ON COLUMN fenbolivar.afidate1.aficiucod IS 'Ciudad';
COMMENT ON COLUMN fenbolivar.afidate1.zoncod IS 'Zona Ciudad';
COMMENT ON COLUMN fenbolivar.afidate1.afidirloc IS 'Direccion del Local';
COMMENT ON COLUMN fenbolivar.afidate1.afifecret IS 'Fecha retiro';
COMMENT ON COLUMN fenbolivar.afidate1.afiindpro IS 'Afiliado Procredito';
COMMENT ON COLUMN fenbolivar.afidate1.afiindspr IS 'Sancion de Procredito';


