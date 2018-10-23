-- Table: opav.sl_cotizacion

-- DROP TABLE opav.sl_cotizacion;

CREATE TABLE opav.sl_cotizacion
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  id_accion character varying(12) NOT NULL DEFAULT ''::character varying,
  no_cotizacion character varying(15) NOT NULL DEFAULT ''::character varying,
  cod_cli character varying(10) NOT NULL DEFAULT ''::character varying,
  nonmbre_cliente character varying(150) NOT NULL DEFAULT ''::character varying,
  vigencia_cotizacion character varying(150) NOT NULL DEFAULT ''::character varying,
  forma_visualizacion character varying(1) NOT NULL DEFAULT ''::character varying,
  modalidad_comercial character varying(1) NOT NULL DEFAULT ''::character varying,
  material numeric(19,3) NOT NULL DEFAULT 0,
  mano_obra numeric(19,3) NOT NULL DEFAULT 0,
  equipos numeric(19,3) NOT NULL DEFAULT 0,
  herramientas numeric(19,3) NOT NULL DEFAULT 0,
  transporte numeric(19,3) NOT NULL DEFAULT 0,
  tramites numeric(19,3) NOT NULL DEFAULT 0,
  valor_cotizacion numeric(19,3) NOT NULL DEFAULT 0,
  valor_descuento numeric(19,3) NOT NULL DEFAULT 0,
  subtotal numeric(19,3) NOT NULL DEFAULT 0,
  perc_iva numeric(11,3) NOT NULL DEFAULT 0,
  valor_iva numeric(19,3) NOT NULL DEFAULT 0,
  administracion numeric(19,3) NOT NULL DEFAULT 0,
  imprevisto numeric(19,3) NOT NULL DEFAULT 0,
  utilidad numeric(19,3) NOT NULL DEFAULT 0,
  perc_aiu numeric(11,3) NOT NULL DEFAULT 0,
  valor_aiu numeric(19,3) NOT NULL DEFAULT 0,
  perc_administracion numeric(11,3) NOT NULL DEFAULT 0,
  perc_imprevisto numeric(11,3) NOT NULL DEFAULT 0,
  perc_utilidad numeric(11,3) NOT NULL DEFAULT 0,
  total numeric(19,3) NOT NULL DEFAULT 0,
  anticipo character varying(1) NOT NULL DEFAULT ''::character varying,
  perc_anticipo numeric(11,3) NOT NULL DEFAULT 0,
  valor_anticipo numeric(19,3) NOT NULL DEFAULT 0,
  retegarantia character varying(1) NOT NULL DEFAULT ''::character varying,
  perc_retegarantia numeric(11,3) NOT NULL DEFAULT 0,
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  perc_descuento numeric(11,3) NOT NULL DEFAULT 0,
  presupuesto_terminado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  perc_rentabilidad_contratista numeric(11,3) NOT NULL DEFAULT 0,
  valor_rentabilidad_contratista numeric(19,3) NOT NULL DEFAULT 0,
  perc_rentabilidad_esquema numeric(11,3) NOT NULL DEFAULT 0,
  valor_rentabilidad_esquema numeric(19,3) NOT NULL DEFAULT 0,
  distribucion_rentabilidad_esquema character varying(100) NOT NULL DEFAULT '...'::character varying,
  iva_compensar numeric(19,3) NOT NULL DEFAULT 0,
  perc_iva_compensado numeric(11,3) NOT NULL DEFAULT 0,
  CONSTRAINT fk_sl_cotizacion1 FOREIGN KEY (id_accion)
      REFERENCES opav.acciones (id_accion) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opav.sl_cotizacion
  OWNER TO postgres;
