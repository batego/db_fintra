-- Table: movimientos_cont_det_backup2

-- DROP TABLE movimientos_cont_det_backup2;

CREATE TABLE movimientos_cont_det_backup2
(
  reg_status character varying(1),
  dstrct character varying(4),
  tipodoc character varying(5),
  numdoc character varying(30),
  grupo_transaccion integer,
  transaccion integer,
  periodo character varying(6),
  cuenta character varying(25),
  auxiliar character varying(25),
  detalle text,
  valor_debito moneda,
  valor_credito moneda,
  tercero character varying(15),
  documento_interno character varying(30),
  last_update timestamp without time zone,
  user_update character varying(10),
  creation_date timestamp without time zone,
  creation_user character varying(10),
  base character varying(3),
  tipodoc_rel character varying(5),
  documento_rel character varying(30),
  abc character varying(4),
  vlr_for moneda,
  tipo_referencia_1 character varying(5),
  referencia_1 character varying(30),
  tipo_referencia_2 character varying(5),
  referencia_2 character varying(30),
  tipo_referencia_3 character varying(5),
  referencia_3 character varying(30)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE movimientos_cont_det_backup2
  OWNER TO postgres;
GRANT ALL ON TABLE movimientos_cont_det_backup2 TO postgres;
GRANT SELECT ON TABLE movimientos_cont_det_backup2 TO msoto;

