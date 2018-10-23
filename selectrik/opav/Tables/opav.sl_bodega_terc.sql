-- Table: opav.sl_bodega_terc

-- DROP TABLE opav.sl_bodega_terc;

CREATE TABLE opav.sl_bodega_terc
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  tipo_bodega integer NOT NULL,
  descripcion character varying(100) NOT NULL DEFAULT ''::character varying,
  id_contratista character varying(5) NOT NULL DEFAULT ''::character varying,
  cod_ciudad character varying(4) NOT NULL DEFAULT ''::character varying,
  direccion character varying(100) NOT NULL DEFAULT ''::character varying,
  nombre_contacto character varying(100) NOT NULL DEFAULT ''::character varying,
  cargo_contacto character varying(100) NOT NULL DEFAULT ''::character varying,
  telefono1_contacto character varying(100) NOT NULL DEFAULT ''::character varying,
  telefono2_contacto character varying(100) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  correo character varying,
  CONSTRAINT fk_id_contratista FOREIGN KEY (id_contratista)
      REFERENCES opav.app_contratistas (id_contratista) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_bodega_terc
  OWNER TO postgres;
