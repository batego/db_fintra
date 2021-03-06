-- Table: opav.sl_actores_minutas

-- DROP TABLE opav.sl_actores_minutas;

CREATE TABLE opav.sl_actores_minutas
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying NOT NULL DEFAULT ''::character varying,
  tipo_actor integer NOT NULL,
  tipo_documento character varying(4) NOT NULL,
  documento character varying(15) NOT NULL,
  nombre character varying(160) NOT NULL,
  codciu character varying(6) NOT NULL,
  coddpto character varying(3) NOT NULL,
  codpais character varying(3) NOT NULL,
  direccion character varying(160) NOT NULL,
  telefono character varying(100) NOT NULL,
  tel_extension character varying(4) NOT NULL,
  celular character varying(15) NOT NULL,
  email character varying(100) NOT NULL,
  tarjeta_profesional character varying(15) NOT NULL,
  doc_lugar_exped character varying(50) NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT sl_actores_minutas_codciu_fkey FOREIGN KEY (codciu)
      REFERENCES ciudad (codciu) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT sl_actores_minutas_coddpto_fkey FOREIGN KEY (coddpto)
      REFERENCES estado (department_code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT sl_actores_minutas_tipo_actor_fkey FOREIGN KEY (tipo_actor)
      REFERENCES opav.sl_tipo_actores_contrato (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_actores_minutas
  OWNER TO postgres;
