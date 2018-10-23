-- Function: get_estado_sms(text)

-- DROP FUNCTION get_estado_sms(text);

CREATE OR REPLACE FUNCTION get_estado_sms(text)
  RETURNS text AS
$BODY$Declare

  estado  ALIAS FOR $1;
  resp TEXT;

begin

	IF estado  = 'SENT'
	THEN  resp:='Enviado';
	END IF;

        IF estado  = 'QUEUED'
	THEN  resp:='Encolado';
	END IF;

        IF estado  = 'DELIVERED'
	THEN  resp:='El mensaje fue entregado al celular';
	END IF;

        IF estado  = 'SENDING_ERROR'
	THEN  resp:='No Enviado';
	END IF;

        IF estado  = 'NO_CREDITS'
	THEN  resp:='Sin crÃ©ditos';
	END IF;

        IF estado  = 'INVALID_DESTINATION'
	THEN  resp:='Destino invÃ¡lido';
	END IF;

        IF estado  = 'IN_PROGRESS'
	THEN  resp:='En progreso';
	END IF;

        IF estado  = 'BLOCKED'
	THEN  resp:='Bloqueado';
	END IF;

        IF estado  = 'UNDELIVERABLE'
	THEN  resp:='El mensaje no se pudo entregar al celular';
	END IF;

        IF estado  = 'REJECTED'
	THEN  resp:='Rechazado';
	END IF;


        IF estado  = 'UNKNOWN'
	THEN  resp:='Desconocido';
	END IF;


	RETURN resp;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_estado_sms(text)
  OWNER TO postgres;
