-- Table: opav.sl_lote_ejecucion

-- DROP TABLE opav.sl_lote_ejecucion;

CREATE TABLE opav.sl_lote_ejecucion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id_solicitud integer NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  no_lote character varying(15) NOT NULL DEFAULT ''::character varying,
  descripcion text NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_lote_ejecucion
  OWNER TO postgres;
