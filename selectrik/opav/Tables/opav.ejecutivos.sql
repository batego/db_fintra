-- Table: opav.ejecutivos

-- DROP TABLE opav.ejecutivos;

CREATE TABLE opav.ejecutivos
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
  id_ejecutivo serial NOT NULL,
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
ALTER TABLE opav.ejecutivos
  OWNER TO postgres;
