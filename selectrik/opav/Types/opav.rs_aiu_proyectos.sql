-- Type: opav.rs_aiu_proyectos

-- DROP TYPE opav.rs_aiu_proyectos;

CREATE TYPE opav.rs_aiu_proyectos AS
   (_costocontratista numeric,
    _valor_aiu numeric,
    _retabilidad numeric,
    _valor_antes_iva numeric,
    _iva numeric,
    _valortotal numeric,
    _totalcomisionessinaiu numeric,
    _valoraiucomisiones numeric,
    _valorutilidad numeric,
    _ivasobreutilidad numeric,
    _ivarealcomisiones numeric,
    _ivacompensar numeric,
    _lineacompensacion numeric,
    _totaloferta numeric);
ALTER TYPE opav.rs_aiu_proyectos
  OWNER TO postgres;
