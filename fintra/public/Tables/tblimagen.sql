-- Table: tblimagen

-- DROP TABLE tblimagen;

CREATE TABLE tblimagen
(
  id integer,
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
ALTER TABLE tblimagen
  OWNER TO postgres;
GRANT ALL ON TABLE tblimagen TO postgres;
GRANT SELECT, INSERT ON TABLE tblimagen TO blackberry;
GRANT SELECT ON TABLE tblimagen TO msoto;

