-- Function: get_comentario_sms(text)

-- DROP FUNCTION get_comentario_sms(text);

CREATE OR REPLACE FUNCTION get_comentario_sms(text)
  RETURNS text AS
$BODY$Declare

  estado  ALIAS FOR $1;
  resp TEXT;

begin

	IF estado  = 'SENT'
	THEN  resp:='El mensaje fue enviado';
	END IF;

        IF estado  = 'QUEUED'
	THEN  resp:='El mensaje estÃ¡ encolado';
	END IF;

        IF estado  = 'DELIVERED'
	THEN  resp:='El mensaje fue entregado al celular';
	END IF;

        IF estado  = 'SENDING_ERROR'
	THEN  resp:='Error de envÃ­o';
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
	THEN  resp:='El nÃºmero estÃ¡ bloqueado';
	END IF;

        IF estado  = 'UNDELIVERABLE'
	THEN  resp:='El mensaje no se pudo entregar al celular';
	END IF;

        IF estado  = 'REJECTED'
	THEN  resp:='El mensaje fue rechazado por el operador';
	END IF;


        IF estado  = 'UNKNOWN'
	THEN  resp:='El estado del mensaje es desconocido';
	END IF;

	IF estado  not in ('UNKNOWN','REJECTED','UNDELIVERABLE','BLOCKED','IN_PROGRESS','INVALID_DESTINATION','NO_CREDITS','SENDING_ERROR','DELIVERED','QUEUED','SENT')
	THEN
	resp:=$1;
	END IF;



	RETURN resp;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION get_comentario_sms(text)
  OWNER TO postgres;
