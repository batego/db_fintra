-- Table: opciones_menu_modulos

-- DROP TABLE opciones_menu_modulos;

CREATE TABLE opciones_menu_modulos
(
  id serial NOT NULL,
  reg_status character varying(50) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(50) NOT NULL,
  ruta character varying(200), -- Ruta de ubicacion de la pagina que abre la opcion
  orden integer,
  padre integer DEFAULT 0,
  nivel integer DEFAULT 0,
  usuario text NOT NULL,
  modulo character varying(50) NOT NULL, -- Modulo del aplicativo en que se utiliza el menu
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15),
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(15),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opciones_menu_modulos
  OWNER TO postgres;
GRANT ALL ON TABLE opciones_menu_modulos TO postgres;
GRANT SELECT ON TABLE opciones_menu_modulos TO msoto;
COMMENT ON COLUMN opciones_menu_modulos.ruta IS 'Ruta de ubicacion de la pagina que abre la opcion';
COMMENT ON COLUMN opciones_menu_modulos.modulo IS 'Modulo del aplicativo en que se utiliza el menu';


