-- Table: fenalco.aficupa

-- DROP TABLE fenalco.aficupa;

CREATE TABLE fenalco.aficupa
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
ALTER TABLE fenalco.aficupa
  OWNER TO postgres;
COMMENT ON COLUMN fenalco.aficupa.cupafiscc IS 'Seccional Afiliado';
COMMENT ON COLUMN fenalco.aficupa.cupaficon IS 'Consecutivo Afiliado';
COMMENT ON COLUMN fenalco.aficupa.cupafisuc IS 'Sucursal Afiliado';
COMMENT ON COLUMN fenalco.aficupa.cupafidia IS 'Cupo Automatico Dia';
COMMENT ON COLUMN fenalco.aficupa.cupafipos IS 'Cupo Automatico Posfechado';
COMMENT ON COLUMN fenalco.aficupa.cupafiusu IS 'Usuario';
COMMENT ON COLUMN fenalco.aficupa.cupafifec IS 'Fecha y Hora';


