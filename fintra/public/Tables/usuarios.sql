-- Table: usuarios

-- DROP TABLE usuarios;

CREATE TABLE usuarios
(
  nombre character varying(150) NOT NULL DEFAULT ''::character varying,
  direccion character varying(50) NOT NULL DEFAULT ''::character varying,
  codpais character varying(3) NOT NULL DEFAULT ''::character varying,
  ciudad character varying(30) NOT NULL DEFAULT ''::character varying,
  email character varying(50) NOT NULL DEFAULT ''::character varying,
  telefono character varying(50) NOT NULL DEFAULT ''::character varying,
  tipo character varying(10) NOT NULL DEFAULT ''::character varying,
  nit character varying(20) NOT NULL DEFAULT ''::character varying,
  clientedestinat text NOT NULL DEFAULT ''::text,
  estado character(1) NOT NULL DEFAULT 'A'::bpchar,
  idusuario character varying(10) NOT NULL DEFAULT ''::character varying,
  claveencr text NOT NULL DEFAULT ''::text,
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha creacion registro
  id_agencia character varying(12) NOT NULL DEFAULT ''::character varying, -- Agencia del usuario
  fecha_ini_act timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha Inicio de Activacion
  ult_fecha_renovo_clave timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Ultima Fecha Renovo Clave
  num_dias_vigencia integer NOT NULL DEFAULT 0, -- Numero dias vigencia usuario
  num_dias_para_renovar_clave integer NOT NULL DEFAULT 0, -- Numero dias para renovar clave
  proyect_ind character(1) NOT NULL DEFAULT 'N'::bpchar, -- Indica un Proyecto
  accesoplanviaje character(1) NOT NULL DEFAULT '0'::bpchar, -- Tipo de Acceso al Programa de Plan de Viaje
  perfil character varying(30) NOT NULL DEFAULT ''::character varying,
  dpto character varying(4) DEFAULT ''::character varying, -- DEPARTAMENTO AL QUE PERTENECE EL USUARIO
  reg_status character(1) NOT NULL DEFAULT ''::bpchar, -- Estado del Registro
  last_update timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de Actualizacion
  base character varying(3) NOT NULL DEFAULT ''::character varying,
  cambioclavelogin boolean NOT NULL DEFAULT false, -- Si es TRUE, dispara el cambio de clave del usuario en la aplicacion la proxima vez que inicie sesion....
  cia text NOT NULL DEFAULT 'TSP'::text, -- Distrito
  idvervalor boolean DEFAULT false,
  permitir_reanticipo character varying(1) NOT NULL DEFAULT 'N'::character varying, -- Puede Realizar Re-Anticipos
  fec_ultimo_ingreso date NOT NULL DEFAULT '0099-01-01'::date,
  nits_propietario text NOT NULL DEFAULT ''::text, -- Nit del Propietario
  publicacion character varying(1) NOT NULL DEFAULT ''::character varying, -- Identifica si el usuario tiene publicaciones
  hora_zonificada time without time zone NOT NULL DEFAULT '00:00:00'::time without time zone, -- Indica el tiempo que se debe sumar a la hora del sistema segun el pais donde se encuentre ubicado el usuario.
  renovaciones character(1) NOT NULL DEFAULT 'N'::bpchar,
  spool character varying(15) NOT NULL DEFAULT ''::character varying, -- parece estar disponible porque siempre está vacío
  codigo_usuario integer NOT NULL DEFAULT nextval('usuarios_codigo_usuario_seq'::regclass), -- miguel
  mensaje text NOT NULL DEFAULT ''::character varying, -- se traduce con tablagen.table_type=TRADUCCION y se ve en ventanita y en top.jsp que se parametriza con tablagen.table_type=VAR_SYSTEM
  estado_mensaje character varying(2) NOT NULL DEFAULT ''::character varying, -- 0: nada, 1: mensaje muy corto en top.jsp, 2: mensaje en ventanita con prototype
  tipo_mensaje character varying(50) NOT NULL DEFAULT 'BASICO'::character varying, -- se define con tablagen.table_type=TIPO_MSJ
  fecha_final_mensaje timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- fecha final para mostrar el mensaje
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying,
  empresa_ultimo_ingreso character varying(15) DEFAULT ''::character varying,
  CONSTRAINT chk_upper_idusuario CHECK (upper(idusuario::text) = idusuario::text)
)
WITH (
  OIDS=TRUE
);
ALTER TABLE usuarios
  OWNER TO postgres;
GRANT ALL ON TABLE usuarios TO postgres;
GRANT SELECT ON TABLE usuarios TO blackberry;
GRANT SELECT ON TABLE usuarios TO msoto;
COMMENT ON COLUMN usuarios.creation_date IS 'Fecha creacion registro';
COMMENT ON COLUMN usuarios.id_agencia IS 'Agencia del usuario';
COMMENT ON COLUMN usuarios.fecha_ini_act IS 'Fecha Inicio de Activacion';
COMMENT ON COLUMN usuarios.ult_fecha_renovo_clave IS 'Ultima Fecha Renovo Clave';
COMMENT ON COLUMN usuarios.num_dias_vigencia IS 'Numero dias vigencia usuario';
COMMENT ON COLUMN usuarios.num_dias_para_renovar_clave IS 'Numero dias para renovar clave';
COMMENT ON COLUMN usuarios.proyect_ind IS 'Indica un Proyecto ';
COMMENT ON COLUMN usuarios.accesoplanviaje IS 'Tipo de Acceso al Programa de Plan de Viaje';
COMMENT ON COLUMN usuarios.dpto IS 'DEPARTAMENTO AL QUE PERTENECE EL USUARIO';
COMMENT ON COLUMN usuarios.reg_status IS 'Estado del Registro';
COMMENT ON COLUMN usuarios.last_update IS 'Fecha de Actualizacion';
COMMENT ON COLUMN usuarios.cambioclavelogin IS 'Si es TRUE, dispara el cambio de clave del usuario en la aplicacion la proxima vez que inicie sesion.
En caso contrario, la deja igual.';
COMMENT ON COLUMN usuarios.cia IS 'Distrito';
COMMENT ON COLUMN usuarios.permitir_reanticipo IS 'Puede Realizar Re-Anticipos';
COMMENT ON COLUMN usuarios.nits_propietario IS 'Nit del Propietario';
COMMENT ON COLUMN usuarios.publicacion IS 'Identifica si el usuario tiene publicaciones';
COMMENT ON COLUMN usuarios.hora_zonificada IS 'Indica el tiempo que se debe sumar a la hora del sistema segun el pais donde se encuentre ubicado el usuario.';
COMMENT ON COLUMN usuarios.spool IS 'parece estar disponible porque siempre está vacío';
COMMENT ON COLUMN usuarios.codigo_usuario IS 'miguel';
COMMENT ON COLUMN usuarios.mensaje IS 'se traduce con tablagen.table_type=TRADUCCION y se ve en ventanita y en top.jsp que se parametriza con tablagen.table_type=VAR_SYSTEM';
COMMENT ON COLUMN usuarios.estado_mensaje IS '0: nada, 1: mensaje muy corto en top.jsp, 2: mensaje en ventanita con prototype';
COMMENT ON COLUMN usuarios.tipo_mensaje IS 'se define con tablagen.table_type=TIPO_MSJ';
COMMENT ON COLUMN usuarios.fecha_final_mensaje IS 'fecha final para mostrar el mensaje';


-- Trigger: dv_actualizar_clave_usuario on usuarios

-- DROP TRIGGER dv_actualizar_clave_usuario ON usuarios;

CREATE TRIGGER dv_actualizar_clave_usuario
  AFTER UPDATE
  ON usuarios
  FOR EACH ROW
  EXECUTE PROCEDURE dv_actualizar_clave_usuario();


