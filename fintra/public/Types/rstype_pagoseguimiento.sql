-- Type: rstype_pagoseguimiento

-- DROP TYPE rstype_pagoseguimiento;

CREATE TYPE rstype_pagoseguimiento AS
   (rs_ingresoxcuota_fiducia numeric,
    rs_ingresoxcuota_fenalco numeric,
    rs_ingresoxcuota numeric);
ALTER TYPE rstype_pagoseguimiento
  OWNER TO postgres;
