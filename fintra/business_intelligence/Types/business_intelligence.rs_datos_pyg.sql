-- Type: business_intelligence.rs_datos_pyg

-- DROP TYPE business_intelligence.rs_datos_pyg;

CREATE TYPE business_intelligence.rs_datos_pyg AS
   (master_orden integer,
    orden integer,
    anio character varying,
    periodo character varying,
    nivel_1 character varying,
    nivel_2 character varying,
    nivel_3 character varying,
    nivel_4 character varying,
    nom_ceco_cebe character varying,
    producto character varying,
    clasificacion character varying,
    unidad character varying,
    nit_tercero character varying,
    tercero character varying,
    cuenta_contable character varying,
    valor_debito numeric,
    valor_credito numeric,
    saldo numeric);
ALTER TYPE business_intelligence.rs_datos_pyg
  OWNER TO postgres;
