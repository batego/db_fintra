-- Table: ex_ejecutivos

-- DROP TABLE ex_ejecutivos;

CREATE TABLE ex_ejecutivos
(
  nit character varying(15) DEFAULT ''::character varying,
  nombre character varying(160) DEFAULT ''::character varying,
  depto character varying(50) DEFAULT ''::character varying,
  ciudad character varying(50) DEFAULT ''::character varying,
  direccion character varying(60) DEFAULT ''::character varying,
  tel1 character varying(50) DEFAULT ''::character varying,
  correo character varying(100) DEFAULT ''::character varying,
  creation_user character varying(10) DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT now(),
  last_update timestamp without time zone DEFAULT now(),
  user_update character varying(10) DEFAULT ''::character varying,
  reg_status character varying(1) DEFAULT ''::character varying,
  id_ejecutivo integer NOT NULL DEFAULT nextval('ejecutivos_id_ejecutivo_seq'::regclass),
  idusuario character varying(10) DEFAULT ''::character varying,
  cargo character varying(50) DEFAULT ''::character varying,
  mercado character varying(15) DEFAULT ''::character varying,
  excorreo character varying(100) DEFAULT ''::character varying,
  distrito character varying(30) NOT NULL DEFAULT ''::character varying,
  comentario character varying(50) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_ejecutivos
  OWNER TO postgres;
GRANT ALL ON TABLE ex_ejecutivos TO postgres;
GRANT SELECT ON TABLE ex_ejecutivos TO msoto;

