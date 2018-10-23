-- Type: administrativo.type_empleados

-- DROP TYPE administrativo.type_empleados;

CREATE TYPE administrativo.type_empleados AS
   (funcio_identific_b numeric(16),
    funcio_digicheq__b numeric(1),
    funcio_codigo____tit____b character varying(4),
    funcio_nombcort__b character varying(32),
    funcio_apellidos_b character varying(32),
    funcio_nombexte__b character varying(64),
    funcio_codigo____tt_____b character varying(4),
    funcio_direccion_b character varying(64),
    funcio_codigo____ciudad_b character varying(8),
    funcio_telefono1_b character varying(16),
    funcio_codigo____cargo__b character varying(16),
    funcio_fechorcre_b timestamp without time zone,
    funcio_autocrea__b character varying(16),
    funcio_fehoulmo__b timestamp without time zone,
    funcio_autultmod_b character varying(16),
    funcio_codigo____usuari_b character varying(16),
    funcio_codigo____cu_____b character varying(16),
    funcio_indicont__b character varying(1),
    funcio_usupromak_b character varying(30),
    funcio_email_____b character varying(64),
    funcio_codigo____cu_____pad_b character varying(16),
    creation_date timestamp without time zone);
ALTER TYPE administrativo.type_empleados
  OWNER TO postgres;
