-- Type: administrativo.type_cargos

-- DROP TYPE administrativo.type_cargos;

CREATE TYPE administrativo.type_cargos AS
   (cargo__codigo____b character varying(16),
    cargo__nombre____b character varying(64),
    cargo__observaci_b character varying(255),
    cargo__fechorcre_b timestamp without time zone,
    cargo__autocrea__b character varying(16),
    cargo__fehoulmo__b timestamp without time zone,
    cargo__autultmod_b character varying(16),
    procesado character varying(1),
    num_proceso character varying(50),
    creation_date timestamp without time zone);
ALTER TYPE administrativo.type_cargos
  OWNER TO postgres;
