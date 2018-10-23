-- Table: apicredit.historico_score_educativo

-- DROP TABLE apicredit.historico_score_educativo;

CREATE TABLE apicredit.historico_score_educativo
(
  id serial NOT NULL,
  reg_status character(1) NOT NULL DEFAULT ''::bpchar,
  s_numero_solicitud integer NOT NULL DEFAULT 0,
  s_identificacion character varying(15) NOT NULL DEFAULT ''::character varying,
  puntaje_maximo_buro numeric(11,2) NOT NULL DEFAULT 0,
  s_cant_cta_ahorros_abiertas numeric(11,2) NOT NULL DEFAULT 0,
  s_tiemp_primer_product_sect_financ numeric(11,2) NOT NULL DEFAULT 0,
  s_tiemp_ultim_product_sect_financ numeric(11,2) NOT NULL DEFAULT 0,
  s_mora_max_semestre numeric(11,2) NOT NULL DEFAULT 0,
  s_mora_max_anio numeric(11,2) NOT NULL DEFAULT 0,
  s_mora_max_actual numeric(11,2) NOT NULL DEFAULT 0,
  s_mora_max_tdc numeric(11,2) NOT NULL DEFAULT 0,
  s_cant_carteras_recup numeric(11,2) NOT NULL DEFAULT 0,
  s_porc_oblig_titular_aldia numeric(11,2) NOT NULL DEFAULT 0,
  s_ultim_peor_calif numeric(11,2) NOT NULL DEFAULT 0,
  s_antig_meses_tdc numeric(11,2) NOT NULL DEFAULT 0,
  s_total_saldo_mora numeric(11,2) NOT NULL DEFAULT 0,
  s_cont_mora_sesenta_semestre_telcos numeric(11,2) NOT NULL DEFAULT 0,
  s_cont_mora_noventa_semestre_telcos numeric(11,2) NOT NULL DEFAULT 0,
  s_cont_mora_mayor_noventa_semestre_telcos numeric(11,2) NOT NULL DEFAULT 0,
  s_cont_mora_treinta_anio_telcos numeric(11,2) NOT NULL DEFAULT 0,
  s_cont_mora_mayor_treinta_anio_telcos numeric(11,2) NOT NULL DEFAULT 0,
  s_cont_mora_treinta_sesenta_anio numeric(11,2) NOT NULL DEFAULT 0,
  s_cont_mora_sesenta_noventa_anio numeric(11,2) NOT NULL DEFAULT 0,
  s_cont_mora_mayor_noventa_anio numeric(11,2) NOT NULL DEFAULT 0,
  s_porc_uso_tarjeta_credit numeric(11,2) NOT NULL DEFAULT 0,
  s_score_total numeric(11,2) NOT NULL DEFAULT 0,
  creation_date timestamp without time zone DEFAULT now(),
  creation_user character varying(10),
  last_update timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  user_update character varying(10) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE apicredit.historico_score_educativo
  OWNER TO postgres;

