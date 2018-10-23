-- Table: con.generador_financiero

-- DROP TABLE con.generador_financiero;

CREATE TABLE con.generador_financiero
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying, -- Estado vacio=activo, A=anulado
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying, -- Sigla de la empresa
  informe character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo del tipo de informe a generar
  secuencia double precision NOT NULL DEFAULT 0, -- Numero secuencial para ordenar las lineas en el excell
  indicador_tercero character varying(1) NOT NULL DEFAULT ''::character varying, -- Letra T para indicar que este codigo muestra la cuenta con todos sus terceros
  tipo_registro character varying(3) NOT NULL DEFAULT ''::character varying, -- B=Linea en blanco, GTx= Total por subnivel S1, Sx=Titulo del subnivel x, T=Titulo, F=Formula
  descripcion text NOT NULL DEFAULT ''::character varying, -- Nombre con el cual apareceran las lineas que no tienen descripcion por cuenta
  cuenta character varying(25) NOT NULL DEFAULT ''::character varying, -- Codigo de cuenta contable
  periodo_1 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_2 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_3 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_4 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_5 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_6 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_7 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_8 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_9 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_10 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_11 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  periodo_12 character varying(6) NOT NULL DEFAULT ''::character varying, -- Campo a uso futuro
  last_update timestamp without time zone NOT NULL DEFAULT now(), -- Fecha ultima modificacion
  user_update character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario de ultima modificacion
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha creacion registro
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario de creacion de registro
  tercero character varying(15) NOT NULL DEFAULT ''::character varying, -- Nit de un tercero especifico para la cuenta
  formula text NOT NULL DEFAULT ''::text -- Formula para efectuar calculo a ser interpretada
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.generador_financiero
  OWNER TO postgres;
GRANT ALL ON TABLE con.generador_financiero TO postgres;
GRANT SELECT ON TABLE con.generador_financiero TO msoto;
COMMENT ON TABLE con.generador_financiero
  IS 'Tabla para registrar los esquemas de reportes financieros';
COMMENT ON COLUMN con.generador_financiero.reg_status IS 'Estado vacio=activo, A=anulado';
COMMENT ON COLUMN con.generador_financiero.dstrct IS 'Sigla de la empresa';
COMMENT ON COLUMN con.generador_financiero.informe IS 'Codigo del tipo de informe a generar';
COMMENT ON COLUMN con.generador_financiero.secuencia IS 'Numero secuencial para ordenar las lineas en el excell';
COMMENT ON COLUMN con.generador_financiero.indicador_tercero IS 'Letra T para indicar que este codigo muestra la cuenta con todos sus terceros';
COMMENT ON COLUMN con.generador_financiero.tipo_registro IS 'B=Linea en blanco, GTx= Total por subnivel S1, Sx=Titulo del subnivel x, T=Titulo, F=Formula';
COMMENT ON COLUMN con.generador_financiero.descripcion IS 'Nombre con el cual apareceran las lineas que no tienen descripcion por cuenta';
COMMENT ON COLUMN con.generador_financiero.cuenta IS 'Codigo de cuenta contable';
COMMENT ON COLUMN con.generador_financiero.periodo_1 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_2 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_3 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_4 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_5 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_6 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_7 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_8 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_9 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_10 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_11 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.periodo_12 IS 'Campo a uso futuro';
COMMENT ON COLUMN con.generador_financiero.last_update IS 'Fecha ultima modificacion';
COMMENT ON COLUMN con.generador_financiero.user_update IS 'Usuario de ultima modificacion';
COMMENT ON COLUMN con.generador_financiero.creation_date IS 'Fecha creacion registro';
COMMENT ON COLUMN con.generador_financiero.creation_user IS 'Usuario de creacion de registro';
COMMENT ON COLUMN con.generador_financiero.tercero IS 'Nit de un tercero especifico para la cuenta';
COMMENT ON COLUMN con.generador_financiero.formula IS 'Formula para efectuar calculo a ser interpretada';


