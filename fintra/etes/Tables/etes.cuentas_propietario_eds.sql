-- Table: etes.cuentas_propietario_eds

-- DROP TABLE etes.cuentas_propietario_eds;

CREATE TABLE etes.cuentas_propietario_eds
(
  id integer NOT NULL,
  id_propietario integer NOT NULL,
  numero_cuenta integer NOT NULL,
  banco character varying(15) NOT NULL,
  sede_pago character varying(10) NOT NULL,
  tipo_pago character varying(3) NOT NULL,
  tipo_cuenta character varying(3) NOT NULL,
  banco_transfer character varying(15),
  sucursal_transfer character varying(15),
  creation_date timestamp(6) with time zone NOT NULL,
  creation_user character varying(10) NOT NULL,
  reg_status character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.cuentas_propietario_eds
  OWNER TO postgres;

