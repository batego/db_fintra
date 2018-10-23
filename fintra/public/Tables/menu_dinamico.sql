-- Table: menu_dinamico

-- DROP TABLE menu_dinamico;

CREATE TABLE menu_dinamico
(
  id_opcion numeric(8,0) NOT NULL,
  nivel numeric(4,0) NOT NULL,
  id_padre numeric(8,0) NOT NULL,
  descripcion character varying(60) NOT NULL DEFAULT ''::character varying,
  submenu_programa numeric(1,0) NOT NULL,
  url text NOT NULL DEFAULT ''::character varying,
  nombre character varying(60) NOT NULL DEFAULT ''::character varying,
  rec_status character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  orden numeric(4,0) NOT NULL DEFAULT 0,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE menu_dinamico
  OWNER TO postgres;
GRANT ALL ON TABLE menu_dinamico TO postgres;
GRANT SELECT ON TABLE menu_dinamico TO msoto;

