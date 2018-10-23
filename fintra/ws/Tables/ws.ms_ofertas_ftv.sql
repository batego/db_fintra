-- Table: ws.ms_ofertas_ftv

-- DROP TABLE ws.ms_ofertas_ftv;

CREATE TABLE ws.ms_ofertas_ftv
(
  id_orden numeric(10,0) NOT NULL,
  id_cliente numeric(10,0) NOT NULL,
  costo_oferta_applus numeric(18,2), -- ?
  costo_oferta_eca numeric(18,2), -- ?
  importe_oferta numeric(18,2), -- ?
  id_estado_negocio numeric(2,0) NOT NULL,
  cuotas numeric(2,0),
  valor_cuotas_r numeric(18,2),
  detalle_inconsistencia text DEFAULT ''::text,
  fecha_envio_ws timestamp without time zone,
  last_update_finv timestamp without time zone DEFAULT '2008-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(50) DEFAULT '-'::character varying,
  marca_ws character varying(1) DEFAULT ''::character varying,
  fecha_oferta timestamp without time zone,
  fecha_registro timestamp without time zone,
  num_os character varying(15) DEFAULT ''::character varying,
  estudio_economico character varying(40) DEFAULT 'Consorcio ECA-Applus-Fintravalores'::character varying,
  simbolo_variable text DEFAULT ''::character varying,
  tipo_dtf character varying(8) NOT NULL DEFAULT ''::character varying, -- se utiliza? en 090515 esta a punto de dejarse de utilizar...
  esquema_comision character varying(15) NOT NULL DEFAULT 'MODELO_NUEVO'::character varying,
  consecutivo character varying(30) DEFAULT ''::character varying,
  simbolo_variable_cr text DEFAULT ''::text,
  comentario character varying(50) DEFAULT ''::character varying, -- interno
  f_recepcion timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  esquema_financiacion character varying(10) NOT NULL DEFAULT 'NUEVO'::character varying,
  fecha_solicitud timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  exnum_os character varying(15) DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ws.ms_ofertas_ftv
  OWNER TO postgres;
COMMENT ON COLUMN ws.ms_ofertas_ftv.costo_oferta_applus IS '?';
COMMENT ON COLUMN ws.ms_ofertas_ftv.costo_oferta_eca IS '?';
COMMENT ON COLUMN ws.ms_ofertas_ftv.importe_oferta IS '?';
COMMENT ON COLUMN ws.ms_ofertas_ftv.tipo_dtf IS 'se utiliza? en 090515 esta a punto de dejarse de utilizar...';
COMMENT ON COLUMN ws.ms_ofertas_ftv.comentario IS 'interno';


-- Trigger: appoferticainsert on ws.ms_ofertas_ftv

-- DROP TRIGGER appoferticainsert ON ws.ms_ofertas_ftv;

CREATE TRIGGER appoferticainsert
  AFTER INSERT
  ON ws.ms_ofertas_ftv
  FOR EACH ROW
  EXECUTE PROCEDURE tablaprincipalasecundariainsert();

-- Trigger: appoferticaupdate on ws.ms_ofertas_ftv

-- DROP TRIGGER appoferticaupdate ON ws.ms_ofertas_ftv;

CREATE TRIGGER appoferticaupdate
  AFTER UPDATE
  ON ws.ms_ofertas_ftv
  FOR EACH ROW
  EXECUTE PROCEDURE tablaprincipalasecundariaupdate();

-- Trigger: estadoenestudio on ws.ms_ofertas_ftv

-- DROP TRIGGER estadoenestudio ON ws.ms_ofertas_ftv;

CREATE TRIGGER estadoenestudio
  BEFORE INSERT OR UPDATE
  ON ws.ms_ofertas_ftv
  FOR EACH ROW
  EXECUTE PROCEDURE estadoenestudio();


