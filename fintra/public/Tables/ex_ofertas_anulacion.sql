-- Table: ex_ofertas_anulacion

-- DROP TABLE ex_ofertas_anulacion;

CREATE TABLE ex_ofertas_anulacion
(
  id_solicitud character varying(15) NOT NULL,
  id_anulacion integer NOT NULL DEFAULT nextval('ofertas_anulacion_id_anulacion_seq'::regclass),
  reg_status character varying(1) NOT NULL DEFAULT ' '::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ' '::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ' '::character varying,
  num_anulacion character varying(3) NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_ofertas_anulacion
  OWNER TO postgres;
GRANT ALL ON TABLE ex_ofertas_anulacion TO postgres;
GRANT SELECT ON TABLE ex_ofertas_anulacion TO msoto;

