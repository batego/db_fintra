-- View: opav.sl_bodega_view

-- DROP VIEW opav.sl_bodega_view;

CREATE OR REPLACE VIEW opav.sl_bodega_view AS
 SELECT sl_bodega_view.id, sl_bodega_view.tipo_orden, sl_bodega_view.direccion, sl_bodega_view.descripcion, sl_bodega_view.id_contratista, sl_bodega_view.nombre_contacto, sl_bodega_view.telefono1_contacto
   FROM dblink('dbname=selectrik port=5432 host=localhost user=postgres password=bdversion7'::text, '
      SELECT
          id,
	    ''INTEGRADO''::VARCHAR AS TIPO_ORDEN,
	    DIRECCION,
	    DESCRIPCION || '' - '' || DIRECCION as DESCRIPCION,
	    ''''::VARCHAR AS ID_CONTRATISTA,
	    ''''::VARCHAR AS NOMBRE_CONTACTO,
	    ''''::VARCHAR AS TELEFONO1_CONTACTO
      FROM OPAV.SL_BODEGA;
      ;
    '::text) sl_bodega_view(id character varying, tipo_orden character varying, direccion character varying, descripcion character varying, id_contratista character varying, nombre_contacto character varying, telefono1_contacto character varying);

ALTER TABLE opav.sl_bodega_view
  OWNER TO postgres;
