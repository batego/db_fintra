-- Table: cuentas_fintra_tsp

-- DROP TABLE cuentas_fintra_tsp;

CREATE TABLE cuentas_fintra_tsp
(
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  tipo_iden character varying(5) NOT NULL DEFAULT ''::character varying,
  nombre_cuenta character varying(50) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  tip_cuenta character varying(2) NOT NULL DEFAULT ''::character varying,
  nit_cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  banco character varying(30) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying, -- Estado de la Cuenta
  fecha_envio_ws timestamp without time zone,
  creation_date_real timestamp without time zone DEFAULT now(),
  pk_novedad integer NOT NULL,
  fecha_anulacion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone
)
WITH (
  OIDS=TRUE
);
ALTER TABLE cuentas_fintra_tsp
  OWNER TO postgres;
GRANT ALL ON TABLE cuentas_fintra_tsp TO postgres;
GRANT SELECT ON TABLE cuentas_fintra_tsp TO msoto;
COMMENT ON COLUMN cuentas_fintra_tsp.reg_status IS 'Estado de la Cuenta';


-- Trigger: insertcuentasfintraerased on cuentas_fintra_tsp

-- DROP TRIGGER insertcuentasfintraerased ON cuentas_fintra_tsp;

CREATE TRIGGER insertcuentasfintraerased
  AFTER INSERT OR UPDATE
  ON cuentas_fintra_tsp
  FOR EACH ROW
  EXECUTE PROCEDURE insertcuentasfintraerased();
COMMENT ON TRIGGER insertcuentasfintraerased ON cuentas_fintra_tsp IS 'para que cuando se inserte o update en cuentas_fintra_tsp con fecha_anulacion se borra y se mete en cuentas_fintra_tsp_erased';


