-- Table: trazabilidad_pagadurias

-- DROP TABLE trazabilidad_pagadurias;

CREATE TABLE trazabilidad_pagadurias
(
  reg_status character varying(1) NOT NULL DEFAULT ''::character varying,
  dstrct character varying(4) NOT NULL DEFAULT 'FINV'::character varying,
  cod_neg character varying(15) NOT NULL,
  pagaduria character varying(15) NOT NULL,
  usuario character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT now(),
  comentarios text NOT NULL DEFAULT ''::text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE trazabilidad_pagadurias
  OWNER TO postgres;

