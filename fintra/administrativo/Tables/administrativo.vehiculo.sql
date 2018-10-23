-- Table: administrativo.vehiculo

-- DROP TABLE administrativo.vehiculo;

CREATE TABLE administrativo.vehiculo
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  lote_carga character varying(10) NOT NULL,
  id_marca integer NOT NULL,
  clase character varying(30) NOT NULL DEFAULT ''::character varying,
  id_referencia1 integer NOT NULL,
  id_referencia2 integer NOT NULL,
  referencia3 character varying(60) NOT NULL DEFAULT ''::character varying,
  codigo character varying(30) NOT NULL DEFAULT ''::character varying,
  homologo_codigo character varying(30) NOT NULL DEFAULT ''::character varying,
  id_novedad integer NOT NULL,
  estado character varying(30) NOT NULL DEFAULT ''::character varying,
  "1970" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1971" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1972" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1973" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1974" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1975" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1976" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1977" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1978" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1979" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1980" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1981" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1982" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1983" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1984" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1985" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1986" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1987" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1988" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1989" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1990" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1991" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1992" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1993" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1994" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1995" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1996" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1997" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1998" numeric(11,2) NOT NULL DEFAULT 0.00,
  "1999" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2000" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2001" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2002" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2003" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2004" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2005" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2006" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2007" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2008" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2009" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2010" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2011" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2012" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2013" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2014" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2015" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2016" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2017" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2018" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2019" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2020" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2021" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2022" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2023" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2024" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2025" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2026" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2027" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2028" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2029" numeric(11,2) NOT NULL DEFAULT 0.00,
  "2030" numeric(11,2) NOT NULL DEFAULT 0.00,
  bcpp numeric(11,2) NOT NULL DEFAULT 0.00,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(20) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT fk_clase_vehiculo_lote FOREIGN KEY (lote_carga)
      REFERENCES administrativo.control_lote_fasecolda (lote_carga) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_id_novedad FOREIGN KEY (id_novedad)
      REFERENCES administrativo.novedades_fasecolda (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_marca FOREIGN KEY (id_marca)
      REFERENCES administrativo.marca_vehuculo (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_referencia_1 FOREIGN KEY (id_referencia1)
      REFERENCES administrativo.referencia_1 (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_referencia_2 FOREIGN KEY (id_referencia2)
      REFERENCES administrativo.referencia_2 (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.vehiculo
  OWNER TO postgres;

