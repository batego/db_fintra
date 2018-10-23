-- Table: menu

-- DROP TABLE menu;

CREATE TABLE menu
(
  id_opcion numeric(8,0),
  nivel numeric(4,0),
  id_padre numeric(8,0),
  descripcion character varying(30),
  submenu_programa numeric(1,0),
  url character varying(100),
  nombre character varying(60),
  estado character varying(1),
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE menu
  OWNER TO postgres;
GRANT ALL ON TABLE menu TO postgres;
GRANT SELECT ON TABLE menu TO msoto;

