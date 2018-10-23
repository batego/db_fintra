-- Table: doc.tblimagen

-- DROP TABLE doc.tblimagen;

CREATE TABLE doc.tblimagen
(
  id integer DEFAULT nextval('doc.tblimagen_id_seq'::regclass),
  reg_status character varying(1),
  dstrct character varying(4),
  activity_type character varying(15),
  document_type character varying(15),
  document character varying(50),
  filename character varying(100),
  filebinary bytea,
  agencia character varying(4),
  last_update timestamp without time zone,
  user_update character varying(10),
  creation_date timestamp without time zone,
  creation_user character varying(10)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE doc.tblimagen
  OWNER TO postgres;

