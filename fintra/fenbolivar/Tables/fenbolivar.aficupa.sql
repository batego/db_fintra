-- Table: fenbolivar.aficupa

-- DROP TABLE fenbolivar.aficupa;

CREATE TABLE fenbolivar.aficupa
(
  cupafiscc numeric(2,0), -- Seccional Afiliado
  cupaficon numeric(6,0), -- Consecutivo Afiliado
  cupafisuc numeric(3,0), -- Sucursal Afiliado
  cupafidia numeric(10,0), -- Cupo Automatico Dia
  cupafipos numeric(10,0), -- Cupo Automatico Posfechado
  cupafiusu text, -- Usuario
  cupafifec timestamp without time zone, -- Fecha y Hora
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fenbolivar.aficupa
  OWNER TO postgres;
COMMENT ON COLUMN fenbolivar.aficupa.cupafiscc IS 'Seccional Afiliado';
COMMENT ON COLUMN fenbolivar.aficupa.cupaficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenbolivar.aficupa.cupafisuc IS 'Sucursal Afiliado';
COMMENT ON COLUMN fenbolivar.aficupa.cupafidia IS 'Cupo Automatico Dia';
COMMENT ON COLUMN fenbolivar.aficupa.cupafipos IS 'Cupo Automatico Posfechado';
COMMENT ON COLUMN fenbolivar.aficupa.cupafiusu IS 'Usuario';
COMMENT ON COLUMN fenbolivar.aficupa.cupafifec IS 'Fecha y Hora';


