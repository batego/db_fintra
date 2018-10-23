-- Table: tem_btg_not_ajust_apacheco_cab_comp

-- DROP TABLE tem_btg_not_ajust_apacheco_cab_comp;

CREATE TABLE tem_btg_not_ajust_apacheco_cab_comp
(
  reg_status character varying(1),
  dstrct character varying(4),
  tipodoc character varying(5),
  numdoc character varying(30),
  grupo_transaccion integer,
  sucursal character varying(5),
  periodo character varying(6),
  fechadoc date,
  detalle text,
  tercero character varying(15),
  total_debito moneda,
  total_credito moneda,
  total_items integer,
  moneda character varying(3),
  fecha_aplicacion timestamp without time zone,
  aprobador character varying(15),
  last_update timestamp without time zone,
  user_update character varying(10),
  creation_date timestamp without time zone,
  creation_user character varying(10),
  base character varying(3),
  usuario_aplicacion character varying(10),
  tipo_operacion character varying(5),
  moneda_foranea character varying(3),
  vlr_for moneda,
  ref_1 character varying(30),
  ref_2 character varying(30)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tem_btg_not_ajust_apacheco_cab_comp
  OWNER TO postgres;

