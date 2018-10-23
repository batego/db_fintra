-- Table: fin.preanticipos

-- DROP TABLE fin.preanticipos;

CREATE TABLE fin.preanticipos
(
  cedcon character varying(15) NOT NULL DEFAULT ''::character varying,
  val moneda NOT NULL DEFAULT 0,
  estado_pago character varying(2) NOT NULL DEFAULT 'N'::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  anticipo_gas integer,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  id serial NOT NULL, -- pk
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE fin.preanticipos
  OWNER TO postgres;
COMMENT ON TABLE fin.preanticipos
  IS 'tabla con preanticipos';
COMMENT ON COLUMN fin.preanticipos.id IS 'pk';


