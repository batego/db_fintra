-- Type: administrativo.cargos_apot

-- DROP TYPE administrativo.cargos_apot;

CREATE TYPE administrativo.cargos_apot AS
   (tableoid oid,
    cmax cid,
    xmax xid,
    cmin cid,
    xmin xid,
    ctid tid,
    cargo__codigo____b character varying(16),
    cargo__nombre____b character varying(64),
    cargo__observaci_b character varying(255),
    cargo__fechorcre_b timestamp without time zone,
    cargo__autocrea__b character varying(16),
    cargo__fehoulmo__b timestamp without time zone,
    cargo__autultmod_b character varying(16),
    procesado character varying(1),
    num_proceso character varying(50),
    creation_date timestamp without time zone);
ALTER TYPE administrativo.cargos_apot
  OWNER TO postgres;
