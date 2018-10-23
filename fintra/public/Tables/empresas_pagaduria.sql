-- Table: empresas_pagaduria

-- DROP TABLE empresas_pagaduria;

CREATE TABLE empresas_pagaduria
(
  id serial NOT NULL,
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  id_pagaduria integer NOT NULL,
  razon_social character varying(300) NOT NULL DEFAULT ''::character varying,
  nit_empresa character varying(15) NOT NULL DEFAULT ''::character varying,
  dv character varying(1) NOT NULL DEFAULT ''::character varying,
  telefono character varying(15) NOT NULL DEFAULT ''::character varying,
  direccion character varying(160) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT empresas_pagaduria_id_pagaduria_fkey FOREIGN KEY (id_pagaduria)
      REFERENCES pagadurias (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE empresas_pagaduria
  OWNER TO postgres;
GRANT ALL ON TABLE empresas_pagaduria TO postgres;
GRANT SELECT ON TABLE empresas_pagaduria TO msoto;

