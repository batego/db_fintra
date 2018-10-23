-- Table: historial_mod_proveedor

-- DROP TABLE historial_mod_proveedor;

CREATE TABLE historial_mod_proveedor
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying, -- Estado del registro anulado o no
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying, -- Distrito del registro
  nit character varying(15) NOT NULL DEFAULT ''::character varying, -- Identificacion del Propietario que se cambio a la placa
  branch_code_mod character varying(15) NOT NULL DEFAULT ''::character varying, -- Banco modificado del proveedor
  bank_account_no_mod character varying(30) NOT NULL DEFAULT ''::character varying, -- Agencia modificada del proveedor
  agency_id_mod character varying(10) NOT NULL DEFAULT ''::character varying, -- Sede de pago modificada del proveedor
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de creacion del registro
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario de creacion del registro
  last_update timestamp without time zone NOT NULL DEFAULT now(), -- Ultima actualizacion del registro
  user_update character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario de actualizacion del registro
  base character varying(3) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE historial_mod_proveedor
  OWNER TO postgres;
GRANT ALL ON TABLE historial_mod_proveedor TO postgres;
GRANT SELECT ON TABLE historial_mod_proveedor TO msoto;
COMMENT ON TABLE historial_mod_proveedor
  IS 'Tabla que almacena un historial de las modificaciones que se han hecho a las sedes de pago de un proveedor';
COMMENT ON COLUMN historial_mod_proveedor.reg_status IS 'Estado del registro anulado o no';
COMMENT ON COLUMN historial_mod_proveedor.dstrct IS 'Distrito del registro';
COMMENT ON COLUMN historial_mod_proveedor.nit IS 'Identificacion del Propietario que se cambio a la placa';
COMMENT ON COLUMN historial_mod_proveedor.branch_code_mod IS 'Banco modificado del proveedor';
COMMENT ON COLUMN historial_mod_proveedor.bank_account_no_mod IS 'Agencia modificada del proveedor';
COMMENT ON COLUMN historial_mod_proveedor.agency_id_mod IS 'Sede de pago modificada del proveedor';
COMMENT ON COLUMN historial_mod_proveedor.creation_date IS 'Fecha de creacion del registro';
COMMENT ON COLUMN historial_mod_proveedor.creation_user IS 'Usuario de creacion del registro';
COMMENT ON COLUMN historial_mod_proveedor.last_update IS 'Ultima actualizacion del registro';
COMMENT ON COLUMN historial_mod_proveedor.user_update IS 'Usuario de actualizacion del registro';


