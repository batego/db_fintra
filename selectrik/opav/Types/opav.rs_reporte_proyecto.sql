-- Type: opav.rs_reporte_proyecto

-- DROP TYPE opav.rs_reporte_proyecto;

CREATE TYPE opav.rs_reporte_proyecto AS
   (multiservicio text,
    id_solicitud character varying,
    nombre_proyecto text,
    nombre_cliente text,
    valor_venta numeric(19,3),
    utilizado numeric(19,3),
    rentabilidad numeric(19,3),
    "% administracion" numeric(11,3),
    "% imprevisto" numeric(11,3),
    "% utilidad" numeric(11,3),
    vlr_administracion numeric(19,3),
    vlr_imprevisto numeric(19,3),
    vlr_utilidad numeric(19,3),
    valor_antes_iva numeric(19,3),
    "% iva" numeric(11,3),
    valor_iva numeric(19,3),
    total numeric(19,3),
    esquema text,
    "% OPAV" numeric(9,6),
    "% FINTRA" numeric(9,6),
    "% PROVINTEGRAL" numeric(9,6),
    "% INTERVENTORIA" numeric(9,6),
    total_esquema numeric(9,6),
    sub_total_esquema numeric(9,6),
    "% ECA" numeric(9,6),
    sub_total_eca numeric(9,6),
    total_comision numeric(9,6),
    valor_contratista_antes_aiu numeric(12,2),
    modalidad_comercial character varying);
ALTER TYPE opav.rs_reporte_proyecto
  OWNER TO postgres;
