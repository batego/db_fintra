-- Table: etes.transferencia_anticipos_temp

-- DROP TABLE etes.transferencia_anticipos_temp;

CREATE TABLE etes.transferencia_anticipos_temp
(
  id serial NOT NULL,
  nro_lote text,
  transferido text,
  usuario_sesion text,
  id_transportadora integer,
  transportadora text,
  id_manifiesto integer,
  nombre_agencia text,
  conductor text,
  cedula_propietario text,
  propietario text,
  placa text,
  planilla text,
  fecha_anticipo text,
  usuario_creacion text,
  codigo_proserv text,
  descripcion text,
  reanticipo text,
  usuario_aprobacion text,
  valor_anticipo numeric,
  porcetaje_descuto numeric,
  valor_descuento numeric,
  valor_neto_con_descueto numeric,
  comision numeric,
  valor_consignacion numeric,
  banco_transferencia text,
  cod_banco_transferencia text,
  cuenta_transferencia text,
  tipo_cuenta_transferencia text,
  banco text,
  sucursal text,
  cuenta text,
  tipo_cuenta text,
  nombre_cuenta text,
  nit_cuenta text,
  egreso_grupo text,
  egreso_item text,
  documento_cxp text,
  archivo_banco_generado text,
  creation_date timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE etes.transferencia_anticipos_temp
  OWNER TO postgres;

