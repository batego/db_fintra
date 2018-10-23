-- Table: opav.material

-- DROP TABLE opav.material;

CREATE TABLE opav.material
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  idmaterial serial NOT NULL,
  descripcion character varying(2000) NOT NULL DEFAULT ''::character varying,
  precio numeric(15,2) NOT NULL DEFAULT 0.0,
  cod_material character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_material character varying(1) NOT NULL DEFAULT 'M'::character varying, -- M: material, D: mano de obra, O: otros
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  aprobacion character varying(1) NOT NULL DEFAULT 'P'::character varying,
  medida character varying(15) DEFAULT 'UNIDADES'::character varying,
  valor_compra numeric(15,2) NOT NULL DEFAULT 0.0, -- este campo probablemente va a ser quitado ya  que se creÃ³ pensando en el precio mÃ¡s los incrementos pero dichos incrementos dependen de la oferta y Ã©sta tabla es independiente. de una u otra manera el nombre del campo no estÃ¡ bonito
  idmaterial_asociado integer DEFAULT 0,
  fecha_anulacion timestamp with time zone DEFAULT '0099-01-01 00:00:00-04:56:20'::timestamp with time zone,
  user_anulacion character varying(10) DEFAULT ''::character varying,
  alcance text DEFAULT ''::text,
  categoria character varying(100) DEFAULT ''::character varying,
  idcategoria integer NOT NULL DEFAULT 0, -- Codigo de la Categoria Relacionada en la tabla categoria
  idsubcategoria integer NOT NULL DEFAULT 0, -- Codigo de la Subcategoria Relacionada en la tabla categoria
  idtiposubcategoria integer NOT NULL DEFAULT 0, -- Codigo de la tiposubcategoria Relacionada en la tabla categoria
  unidad_empaque character varying(10) NOT NULL DEFAULT ''::character varying, -- Valor de la Unidad de Empaque
  certificado character varying(1) NOT NULL DEFAULT ''::character varying,
  ente_certificador character varying(90) NOT NULL DEFAULT ''::character varying,
  precio_compra numeric(15,2) DEFAULT 0.00,
  fecha_ultima_compra timestamp with time zone DEFAULT '0099-01-01 00:00:00-04:56:20'::timestamp with time zone,
  fecha_actualizacion_precio_compra timestamp with time zone DEFAULT '0099-01-01 00:00:00-04:56:20'::timestamp with time zone,
  precio_contratista numeric(15,2) DEFAULT 0.00,
  precio_ultima_compra numeric(15,2) DEFAULT 0.00,
  observacion character varying(500) DEFAULT ''::character varying,
  actualizado character varying(2) DEFAULT 'N'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  esquema character varying(20) NOT NULL DEFAULT ''::character varying,
  id_sl_insumo integer NOT NULL DEFAULT 0 -- Este campo determinara si el insumo fue creado desde el Software nuevo y ademas seran los que se presentaran en los dos software para que puedan ser escogidos.
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.material
  OWNER TO postgres;
GRANT ALL ON TABLE opav.material TO postgres;
GRANT ALL ON TABLE opav.material TO fintravaloressa;
COMMENT ON COLUMN opav.material.tipo_material IS 'M: material, D: mano de obra, O: otros';
COMMENT ON COLUMN opav.material.valor_compra IS 'este campo probablemente va a ser quitado ya  que se creÃ³ pensando en el precio mÃ¡s los incrementos pero dichos incrementos dependen de la oferta y Ã©sta tabla es independiente. de una u otra manera el nombre del campo no estÃ¡ bonito';
COMMENT ON COLUMN opav.material.idcategoria IS 'Codigo de la Categoria Relacionada en la tabla categoria';
COMMENT ON COLUMN opav.material.idsubcategoria IS 'Codigo de la Subcategoria Relacionada en la tabla categoria';
COMMENT ON COLUMN opav.material.idtiposubcategoria IS 'Codigo de la tiposubcategoria Relacionada en la tabla categoria';
COMMENT ON COLUMN opav.material.unidad_empaque IS 'Valor de la Unidad de Empaque';
COMMENT ON COLUMN opav.material.id_sl_insumo IS 'Este campo determinara si el insumo fue creado desde el Software nuevo y ademas seran los que se presentaran en los dos software para que puedan ser escogidos.';


-- Trigger: historico_material on opav.material

-- DROP TRIGGER historico_material ON opav.material;

CREATE TRIGGER historico_material
  AFTER UPDATE
  ON opav.material
  FOR EACH ROW
  EXECUTE PROCEDURE inserta_historico_material();
COMMENT ON TRIGGER historico_material ON opav.material IS 'historico materiales
auditar precios';
