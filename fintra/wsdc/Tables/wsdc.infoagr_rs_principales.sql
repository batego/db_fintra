-- Table: wsdc.infoagr_rs_principales

-- DROP TABLE wsdc.infoagr_rs_principales;

CREATE TABLE wsdc.infoagr_rs_principales
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  creditovigentes character varying NOT NULL DEFAULT ''::character varying,
  creditoscerrados character varying DEFAULT ''::character varying,
  creditosactualesnegativos character varying NOT NULL DEFAULT ''::character varying,
  histnegult12meses character varying NOT NULL DEFAULT ''::character varying,
  cuentasabiertasahoccb character varying NOT NULL DEFAULT ''::character varying,
  cuentascerradasahoccb character varying NOT NULL DEFAULT ''::character varying,
  consultadasult6meses character varying NOT NULL DEFAULT ''::character varying,
  desacuerdosalafecha character varying NOT NULL DEFAULT ''::character varying,
  antiguedaddesde character varying NOT NULL DEFAULT ''::character varying,
  reclamosvigentes character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.infoagr_rs_principales
  OWNER TO postgres;

