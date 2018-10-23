-- Table: etes.transportadoras

-- DROP TABLE etes.transportadoras;

CREATE TABLE etes.transportadoras
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cod_transportadora character varying(8) NOT NULL DEFAULT ''::character varying,
  identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  razon_social character varying(300) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  correo character varying(70) NOT NULL DEFAULT ''::character varying,
  documento_representante_legal character varying(15) NOT NULL DEFAULT ''::character varying,
  representante_legal character varying(150) NOT NULL DEFAULT ''::character varying,
  id_periodicidad integer NOT NULL,
  periodo_inicia character varying(4) NOT NULL DEFAULT ''::character varying,
  periodo_finaliza character varying(4) NOT NULL DEFAULT ''::character varying,
  cupo_rotativo numeric(11,2) DEFAULT (0)::numeric,
  idusuario character varying(10),
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  autoriza_venta character varying(1) NOT NULL DEFAULT 'S'::character varying,
  CONSTRAINT fk_transperiodicidad FOREIGN KEY (id_periodicidad)
      REFERENCES etes.periodicidad (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.transportadoras
  OWNER TO postgres;

