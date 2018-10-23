-- Table: administrativo.cargos_apoteosys

-- DROP TABLE administrativo.cargos_apoteosys;

CREATE TABLE administrativo.cargos_apoteosys
(
  cargo__codigo____b character varying(16) NOT NULL,
  cargo__nombre____b character varying(64),
  cargo__observaci_b character varying(255),
  cargo__fechorcre_b timestamp without time zone DEFAULT (now())::timestamp without time zone,
  cargo__autocrea__b character varying(16),
  cargo__fehoulmo__b timestamp without time zone DEFAULT (now())::timestamp without time zone,
  cargo__autultmod_b character varying(16),
  procesado character varying(1) DEFAULT 'N'::character varying,
  num_proceso character varying(50) DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT (now())::timestamp without time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrativo.cargos_apoteosys
  OWNER TO postgres;

