-- Table: opav.sl_apoteosys_tablas_campos

-- DROP TABLE opav.sl_apoteosys_tablas_campos;

CREATE TABLE opav.sl_apoteosys_tablas_campos
(
  id integer,
  id_sl_apoteosys_fase_oc integer,
  id_sl_apoteosys_tablas integer,
  nombre_campo character varying(90),
  valor_campo character varying(90),
  descripcion_campo character varying(90),
  creation_user character varying(10),
  creation_date timestamp without time zone,
  reg_status character varying(1)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_apoteosys_tablas_campos
  OWNER TO postgres;
