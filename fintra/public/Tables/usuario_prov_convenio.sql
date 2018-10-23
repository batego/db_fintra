-- Table: usuario_prov_convenio

-- DROP TABLE usuario_prov_convenio;

CREATE TABLE usuario_prov_convenio
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  idusuario character varying(10) NOT NULL DEFAULT ''::character varying,
  id_prov_convenio integer NOT NULL,
  creation_user character varying(10) NOT NULL,
  user_update character varying(10) NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT "usuario_prov_convenio1FK" FOREIGN KEY (idusuario)
      REFERENCES usuarios (idusuario) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT "usuario_prov_convenio2FK" FOREIGN KEY (id_prov_convenio)
      REFERENCES prov_convenio (id_prov_convenio) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE usuario_prov_convenio
  OWNER TO postgres;
GRANT ALL ON TABLE usuario_prov_convenio TO postgres;
GRANT SELECT ON TABLE usuario_prov_convenio TO msoto;
COMMENT ON TABLE usuario_prov_convenio
  IS 'Convenios y sectores/subsectores para los cuales el usuario de un afiliado puede generar negocios';

