-- Table: menusot

-- DROP TABLE menusot;

CREATE TABLE menusot
(
  id character varying(10) NOT NULL,
  nomopcion character varying(50),
  tiposusu character varying(100),
  estopcion character(1),
  tipoopcion character varying(10),
  controllerparams character varying(100),
  grupos text NOT NULL DEFAULT ''::text, -- Grupos de usuarios permitidos para cada opcion del menu.
  usuarios text NOT NULL DEFAULT ''::text, -- Usuarios que tienen acceso a cada opcion del menu.
  id_nivel numeric(5,0) DEFAULT 0,
  id_folder character(1) DEFAULT 'N'::bpchar,
  id_padre character varying(10) DEFAULT 0,
  ayuda text NOT NULL DEFAULT ''::text,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE menusot
  OWNER TO postgres;
GRANT ALL ON TABLE menusot TO postgres;
GRANT SELECT ON TABLE menusot TO msoto;
COMMENT ON COLUMN menusot.grupos IS 'Grupos de usuarios permitidos para cada opcion del menu.';
COMMENT ON COLUMN menusot.usuarios IS 'Usuarios que tienen acceso a cada opcion del menu.';


