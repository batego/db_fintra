-- Table: equivalencia

-- DROP TABLE equivalencia;

CREATE TABLE equivalencia
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying, -- Indica si el registro esta activo o no...
  cia_inicial character varying(10) NOT NULL DEFAULT ''::character varying, -- Compania inicial donde esta registrado el documento
  cia_final character varying(10) NOT NULL DEFAULT ''::character varying, -- Compania final hacia donde se desea convertir el documento
  clase_inicial character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo de clasificacion para el documento de la compania inicial y que se desea trasladar a la compania final
  codigo_inicial character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero o codigo de un documento en la compania inicial que se desea convertir en un numero o codigo en la compania final
  clase_final character varying(15) NOT NULL DEFAULT ''::character varying, -- Codigo de clasificacion equivalente en la compania final
  codigo_final character varying(30) NOT NULL DEFAULT ''::character varying, -- Numero o codigo equivalente de un documento en la compania final
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone, -- Fecha ultima actualizacion del registro
  user_update character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario que realizo la ultima actualizacion del registro
  creation_date timestamp without time zone NOT NULL DEFAULT now(), -- Fecha de creacion del registro
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying, -- Usuario que realizo la creacion del registro
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equivalencia
  OWNER TO postgres;
GRANT ALL ON TABLE equivalencia TO postgres;
GRANT SELECT ON TABLE equivalencia TO msoto;
COMMENT ON TABLE equivalencia
  IS 'Tabla que permite convertir un codigo de una compania en el codigo que se utiliza en otra compania';
COMMENT ON COLUMN equivalencia.reg_status IS 'Indica si el registro esta activo o no
'''' = Activo
''A''=Registro anulado';
COMMENT ON COLUMN equivalencia.cia_inicial IS 'Compania inicial donde esta registrado el documento';
COMMENT ON COLUMN equivalencia.cia_final IS 'Compania final hacia donde se desea convertir el documento';
COMMENT ON COLUMN equivalencia.clase_inicial IS 'Codigo de clasificacion para el documento de la compania inicial y que se desea trasladar a la compania final';
COMMENT ON COLUMN equivalencia.codigo_inicial IS 'Numero o codigo de un documento en la compania inicial que se desea convertir en un numero o codigo en la compania final';
COMMENT ON COLUMN equivalencia.clase_final IS 'Codigo de clasificacion equivalente en la compania final';
COMMENT ON COLUMN equivalencia.codigo_final IS 'Numero o codigo equivalente de un documento en la compania final ';
COMMENT ON COLUMN equivalencia.last_update IS 'Fecha ultima actualizacion del registro';
COMMENT ON COLUMN equivalencia.user_update IS 'Usuario que realizo la ultima actualizacion del registro';
COMMENT ON COLUMN equivalencia.creation_date IS 'Fecha de creacion del registro';
COMMENT ON COLUMN equivalencia.creation_user IS 'Usuario que realizo la creacion del registro';


