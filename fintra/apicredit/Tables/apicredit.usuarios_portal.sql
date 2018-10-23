-- Table: apicredit.usuarios_portal

-- DROP TABLE apicredit.usuarios_portal;

CREATE TABLE apicredit.usuarios_portal
(
  reg_status character(1) NOT NULL DEFAULT ''::bpchar,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  nombre character varying(150) NOT NULL DEFAULT ''::character varying,
  primer_nombre character varying(100) NOT NULL DEFAULT ''::character varying,
  primer_apellido character varying(100) NOT NULL DEFAULT ''::character varying,
  fecha_nacimiento date NOT NULL DEFAULT '0099-01-01'::date,
  fecha_expedicion date NOT NULL DEFAULT '0099-01-01'::date,
  tipo_identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  email character varying(100) NOT NULL DEFAULT ''::character varying,
  idusuario character varying(100) NOT NULL DEFAULT ''::character varying,
  claveencr text NOT NULL DEFAULT ''::text,
  fecha_ultimo_ingreso date NOT NULL DEFAULT '0099-01-01'::date,
  empresa_ultimo_ingreso character varying(15) DEFAULT ''::character varying,
  ult_fecha_renovo_clave timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  num_dias_para_renovar_clave integer NOT NULL DEFAULT 0,
  cambioclavelogin boolean NOT NULL DEFAULT false,
  token_api character varying(100) NOT NULL DEFAULT ''::character varying,
  codigo_activacion character varying(15) NOT NULL DEFAULT (apicredit.eg_generar_codigo_activacion(15))::character varying,
  tipo_usuario character varying(1) NOT NULL DEFAULT 'C'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  id_usuario_real character varying(100) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.usuarios_portal
  OWNER TO postgres;
GRANT ALL ON TABLE apicredit.usuarios_portal TO postgres;

-- Trigger: usuario_portal_web on apicredit.usuarios_portal

-- DROP TRIGGER usuario_portal_web ON apicredit.usuarios_portal;

CREATE TRIGGER usuario_portal_web
  BEFORE INSERT
  ON apicredit.usuarios_portal
  FOR EACH ROW
  EXECUTE PROCEDURE apicredit.eg_validar_user_login();
  
  -- Se agrega campo id_sucursal Tk4521
  
  ALTER TABLE apicredit.usuarios_portal
  ADD COLUMN id_sucursal int not null default 1;
  
  
    -- Se modifica tipo de dato de la columna id_sucursal Tk4521
    
 ALTER TABLE apicredit.usuarios_portal
 alter column id_sucursal type varchar (15);



