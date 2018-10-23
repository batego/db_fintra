-- Table: wsdc.productos_valores

-- DROP TABLE wsdc.productos_valores;

CREATE TABLE wsdc.productos_valores
(
  id serial NOT NULL,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT ''::character varying,
  producto character varying NOT NULL DEFAULT ''::character varying,
  valor1 character varying NOT NULL DEFAULT ''::character varying,
  valor2 character varying NOT NULL DEFAULT ''::character varying,
  valor3 character varying NOT NULL DEFAULT ''::character varying,
  valor4 character varying NOT NULL DEFAULT ''::character varying,
  valor5 character varying NOT NULL DEFAULT ''::character varying,
  valor6 character varying NOT NULL DEFAULT ''::character varying,
  valor7 character varying NOT NULL DEFAULT ''::character varying,
  valor8 character varying NOT NULL DEFAULT ''::character varying,
  valor9 character varying NOT NULL DEFAULT ''::character varying,
  valor10 character varying NOT NULL DEFAULT ''::character varying,
  valor1smlv character varying NOT NULL DEFAULT ''::character varying,
  valor2smlv character varying NOT NULL DEFAULT ''::character varying,
  valor3smlv character varying NOT NULL DEFAULT ''::character varying,
  valor4smlv character varying NOT NULL DEFAULT ''::character varying,
  valor5smlv character varying NOT NULL DEFAULT ''::character varying,
  valor6smlv character varying NOT NULL DEFAULT ''::character varying,
  valor7smlv character varying NOT NULL DEFAULT ''::character varying,
  valor8smlv character varying NOT NULL DEFAULT ''::character varying,
  valor9smlv character varying NOT NULL DEFAULT ''::character varying,
  valor10smlv character varying NOT NULL DEFAULT ''::character varying,
  razon1 character varying NOT NULL DEFAULT ''::character varying,
  razon2 character varying NOT NULL DEFAULT ''::character varying,
  razon3 character varying NOT NULL DEFAULT ''::character varying,
  razon4 character varying NOT NULL DEFAULT ''::character varying,
  razon5 character varying NOT NULL DEFAULT ''::character varying,
  razon6 character varying NOT NULL DEFAULT ''::character varying,
  razon7 character varying NOT NULL DEFAULT ''::character varying,
  razon8 character varying NOT NULL DEFAULT ''::character varying,
  razon9 character varying NOT NULL DEFAULT ''::character varying,
  razon10 character varying NOT NULL DEFAULT ''::character varying,
  creation_user character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  user_update character varying NOT NULL,
  last_update timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.productos_valores
  OWNER TO postgres;

