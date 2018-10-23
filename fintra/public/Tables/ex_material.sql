-- Table: ex_material

-- DROP TABLE ex_material;

CREATE TABLE ex_material
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  idmaterial integer NOT NULL DEFAULT nextval('material_idmaterial_seq'::regclass),
  descripcion character varying(500) NOT NULL DEFAULT ''::character varying,
  precio numeric(15,2) NOT NULL DEFAULT 0.0,
  cod_material character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_material character varying(1) NOT NULL DEFAULT 'M'::character varying, -- M: material, D: mano de obra, O: otros
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  aprobacion character varying(1) NOT NULL DEFAULT 'P'::character varying,
  medida character varying(15) DEFAULT 'UNIDADES'::character varying,
  valor_compra numeric(15,2) NOT NULL DEFAULT 0.0, -- este campo probablemente va a ser quitado ya  que se creó pensando en el precio más los incrementos pero dichos incrementos dependen de la oferta y ésta tabla es independiente. de una u otra manera el nombre del campo no está bonito
  idmaterial_asociado integer DEFAULT 0,
  fecha_anulacion timestamp with time zone DEFAULT '0099-01-01 00:00:00-04:56:20'::timestamp with time zone,
  user_anulacion character varying(10) DEFAULT ''::character varying,
  alcance text DEFAULT ''::text,
  categoria character varying(100) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ex_material
  OWNER TO postgres;
GRANT ALL ON TABLE ex_material TO postgres;
GRANT SELECT ON TABLE ex_material TO msoto;
COMMENT ON COLUMN ex_material.tipo_material IS 'M: material, D: mano de obra, O: otros';
COMMENT ON COLUMN ex_material.valor_compra IS 'este campo probablemente va a ser quitado ya  que se creó pensando en el precio más los incrementos pero dichos incrementos dependen de la oferta y ésta tabla es independiente. de una u otra manera el nombre del campo no está bonito';


