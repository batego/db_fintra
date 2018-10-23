-- Table: apicredit.rangos_cuotas

-- DROP TABLE apicredit.rangos_cuotas;

CREATE TABLE apicredit.rangos_cuotas
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  inicial numeric(11,2) NOT NULL,
  final numeric(11,2) NOT NULL,
  cuota integer NOT NULL,
  creation_user character varying(50) NOT NULL DEFAULT ''::character varying,
  user_update character varying(50) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  creation_date timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.rangos_cuotas
  OWNER TO postgres;

