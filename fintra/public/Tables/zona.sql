-- Table: zona

-- DROP TABLE zona;

CREATE TABLE zona
(
  codzona character varying(3) NOT NULL,
  desczona character varying(20) DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  rec_status character varying(1) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  user_update character varying NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  frontera character varying(1) NOT NULL DEFAULT 'N'::character varying, -- indica si la zona es frontera o no
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE zona
  OWNER TO postgres;
GRANT ALL ON TABLE zona TO postgres;
GRANT SELECT ON TABLE zona TO msoto;
COMMENT ON COLUMN zona.frontera IS 'indica si la zona es frontera o no';


