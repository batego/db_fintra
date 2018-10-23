-- Table: historico_pagares_fintracredit

-- DROP TABLE historico_pagares_fintracredit;

CREATE TABLE historico_pagares_fintracredit
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(6) NOT NULL DEFAULT 'FINV'::character varying,
  unidad_negocio integer NOT NULL DEFAULT 0,
  nit_solicitante character varying(15) NOT NULL DEFAULT ''::character varying,
  nit_codeudor character varying(15) NOT NULL DEFAULT ''::character varying,
  nit_estudiante character varying(15) NOT NULL DEFAULT ''::character varying,
  num_pagare character varying(20) NOT NULL DEFAULT ''::character varying,
  tipo_negocio character varying(30) NOT NULL DEFAULT ''::character varying,
  negocio character varying(15) NOT NULL DEFAULT ''::character varying,
  num_solicitud integer NOT NULL DEFAULT 0,
  ultimo_credito_vigente character varying(1) NOT NULL DEFAULT 'S'::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(15) NOT NULL DEFAULT ''::character varying,
  last_update timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(15) NOT NULL DEFAULT ''::character varying,
  nit_afiliado character varying(15) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE historico_pagares_fintracredit
  OWNER TO postgres;
GRANT ALL ON TABLE historico_pagares_fintracredit TO postgres;
GRANT SELECT ON TABLE historico_pagares_fintracredit TO msoto;

-- Trigger: updatehistoricopagaresfintracredit on historico_pagares_fintracredit

-- DROP TRIGGER updatehistoricopagaresfintracredit ON historico_pagares_fintracredit;

CREATE TRIGGER updatehistoricopagaresfintracredit
  BEFORE INSERT
  ON historico_pagares_fintracredit
  FOR EACH ROW
  EXECUTE PROCEDURE updatehistoricopagaresfintracredit();


