-- Table: tipo_cliente

-- DROP TABLE tipo_cliente;

CREATE TABLE tipo_cliente
(
  id serial NOT NULL,
  cod_tipo_cliente character varying(8) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(100) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tipo_cliente
  OWNER TO postgres;
GRANT ALL ON TABLE tipo_cliente TO postgres;
GRANT SELECT ON TABLE tipo_cliente TO msoto;

