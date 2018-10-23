-- Table: fin.info_corridas

-- DROP TABLE fin.info_corridas;

CREATE TABLE fin.info_corridas
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  corrida numeric(10,0) NOT NULL DEFAULT 0, -- Numero de la corrida
  tpago character varying(2) NOT NULL DEFAULT ''::character varying, -- Tipo de Pago  B ( Cheque)  T( Transferencia )
  tviaje character varying(2) NOT NULL DEFAULT ''::character varying,
  fechacumini timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha Inicial de cumplido de planillas
  fechacumfin timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha final del cumplido de planillas
  bancos text NOT NULL DEFAULT ''::text, -- Bancos y/o sucursales  de facturas que se incluyen en la corrida
  fproveedor character varying(10) NOT NULL DEFAULT ''::character varying, -- Tipo de filtro de proveedor ( NIT, HC, Nombre )
  proveedores text NOT NULL DEFAULT ''::text, -- Datos del filtro de proveedor
  placas text NOT NULL DEFAULT ''::text, -- Placas a incluir sus facturas dentro de la corrida
  fechavenini timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha inicial de vencimiento de facturas a incluir
  fechavenfin timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha final de vencimiento de facturas a incluir
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  cheque_cero character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Identifica si se marco cheques en cero
  tasa_pes_bol numeric(18,10) NOT NULL DEFAULT 0,
  tasa_pes_dol numeric(18,10) NOT NULL DEFAULT 0
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fin.info_corridas
  OWNER TO postgres;
COMMENT ON TABLE fin.info_corridas
  IS 'Tabla para almacenar informaciÃƒÂ³n de creaciÃƒÂ³n de la corrida';
COMMENT ON COLUMN fin.info_corridas.corrida IS 'Numero de la corrida';
COMMENT ON COLUMN fin.info_corridas.tpago IS 'Tipo de Pago  B ( Cheque)  T( Transferencia )';
COMMENT ON COLUMN fin.info_corridas.fechacumini IS 'Fecha Inicial de cumplido de planillas';
COMMENT ON COLUMN fin.info_corridas.fechacumfin IS 'Fecha final del cumplido de planillas';
COMMENT ON COLUMN fin.info_corridas.bancos IS 'Bancos y/o sucursales  de facturas que se incluyen en la corrida';
COMMENT ON COLUMN fin.info_corridas.fproveedor IS 'Tipo de filtro de proveedor ( NIT, HC, Nombre )';
COMMENT ON COLUMN fin.info_corridas.proveedores IS 'Datos del filtro de proveedor';
COMMENT ON COLUMN fin.info_corridas.placas IS 'Placas a incluir sus facturas dentro de la corrida';
COMMENT ON COLUMN fin.info_corridas.fechavenini IS 'Fecha inicial de vencimiento de facturas a incluir';
COMMENT ON COLUMN fin.info_corridas.fechavenfin IS 'Fecha final de vencimiento de facturas a incluir';
COMMENT ON COLUMN fin.info_corridas.cheque_cero IS 'Identifica si se marco cheques en cero';


