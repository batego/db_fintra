-- Table: series

-- DROP TABLE series;

CREATE TABLE series
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  agency_id character varying(10) NOT NULL DEFAULT ''::character varying,
  document_type character varying(15) NOT NULL DEFAULT ''::character varying,
  branch_code text NOT NULL DEFAULT ''::character varying,
  bank_account_no text NOT NULL DEFAULT ''::character varying,
  account_number text NOT NULL DEFAULT ''::character varying,
  prefix character varying(2) NOT NULL DEFAULT ''::character varying,
  serial_initial_no character varying(9) NOT NULL DEFAULT ''::character varying,
  serial_fished_no character varying(9) NOT NULL DEFAULT ''::character varying,
  last_number numeric(9,0),
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  id integer NOT NULL DEFAULT nextval('series_id_seq1'::regclass), -- Serial de cada registro de la tabla
  tipo character varying(2) NOT NULL DEFAULT 'CH'::character varying, -- El tipo de la serie definido en tablagen en la tabla TPAGO
  concepto character varying(10),
  tipo_documento character varying(5) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=TRUE
);
ALTER TABLE series
  OWNER TO postgres;
GRANT ALL ON TABLE series TO postgres;
GRANT SELECT ON TABLE series TO msoto;
COMMENT ON COLUMN series.id IS 'Serial de cada registro de la tabla';
COMMENT ON COLUMN series.tipo IS 'El tipo de la serie definido en tablagen en la tabla TPAGO';


-- Trigger: SerieToNoCruzarConsecutivos on series

-- DROP TRIGGER "SerieToNoCruzarConsecutivos" ON series;

CREATE TRIGGER "SerieToNoCruzarConsecutivos"
  AFTER UPDATE
  ON series
  FOR EACH ROW
  EXECUTE PROCEDURE serietonocruzarconsecutivos();


