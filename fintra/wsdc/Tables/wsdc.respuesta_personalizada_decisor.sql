-- Table: wsdc.respuesta_personalizada_decisor

-- DROP TABLE wsdc.respuesta_personalizada_decisor;

CREATE TABLE wsdc.respuesta_personalizada_decisor
(
  id serial NOT NULL,
  var_cuotas_mensuales character varying NOT NULL DEFAULT ''::character varying,
  var_cartera_castigada character varying NOT NULL DEFAULT ''::character varying,
  var_cartera_recuperada character varying NOT NULL DEFAULT ''::character varying,
  var_cartera_recuperada_telco character varying NOT NULL DEFAULT ''::character varying,
  var_dudoso_recaudo character varying NOT NULL DEFAULT ''::character varying,
  var_dudoso_recaudo_telco character varying NOT NULL DEFAULT ''::character varying,
  var_moras_30_act character varying NOT NULL DEFAULT ''::character varying,
  var_moras_30_act_telco character varying NOT NULL DEFAULT ''::character varying,
  var_moras_60_act character varying NOT NULL DEFAULT ''::character varying,
  var_moras_60_act_telco character varying NOT NULL DEFAULT ''::character varying,
  var_moras_90_act character varying NOT NULL DEFAULT ''::character varying,
  var_moras_90_act_telco character varying NOT NULL DEFAULT ''::character varying,
  var_moras_120_o_mas_act character varying NOT NULL DEFAULT ''::character varying,
  var_moras_120_o_mas_act_telco character varying NOT NULL DEFAULT ''::character varying,
  var_moras_30_his_ult_12_m character varying NOT NULL DEFAULT ''::character varying,
  var_moras_60_his_ult_12_m character varying NOT NULL DEFAULT ''::character varying,
  var_moras_90_his_ult_12_m character varying NOT NULL DEFAULT ''::character varying,
  var_moras_120_his_ult_12_m character varying NOT NULL DEFAULT ''::character varying,
  var_moras_30_his_ult_6_m character varying NOT NULL DEFAULT ''::character varying,
  var_moras_60_his_ult_6_m character varying NOT NULL DEFAULT ''::character varying,
  var_moras_90_his_ult_6_m character varying NOT NULL DEFAULT ''::character varying,
  var_moras_120_his_ult_6_m character varying NOT NULL DEFAULT ''::character varying,
  var_mora_act_telco_90_o_mas character varying NOT NULL DEFAULT ''::character varying,
  var_factor_financiacion character varying NOT NULL DEFAULT ''::character varying,
  var_porcentaje_financiacion character varying NOT NULL DEFAULT ''::character varying,
  var_dictamen_buro_aprobado character varying NOT NULL DEFAULT ''::character varying,
  var_dictamen_buro_estudio character varying NOT NULL DEFAULT ''::character varying,
  var_dictamen_buro_rechazado character varying NOT NULL DEFAULT ''::character varying,
  var_codigo_causal character varying NOT NULL DEFAULT ''::character varying,
  var_bandera character varying NOT NULL DEFAULT ''::character varying,
  var_factor_gastos_familiares character varying NOT NULL DEFAULT ''::character varying,
  var_gastos_familiares character varying NOT NULL DEFAULT ''::character varying,
  var_total_egresos character varying NOT NULL DEFAULT ''::character varying,
  var_disponible character varying NOT NULL DEFAULT ''::character varying,
  var_tasa_interes character varying NOT NULL DEFAULT ''::character varying,
  var_mensaje_1 character varying NOT NULL DEFAULT ''::character varying,
  var_mensaje_2 character varying NOT NULL DEFAULT ''::character varying,
  var_mensaje_3 character varying NOT NULL DEFAULT ''::character varying,
  var_mensaje_4 character varying NOT NULL DEFAULT ''::character varying,
  var_monto_preaprobado character varying NOT NULL DEFAULT ''::character varying,
  var_cartera_castigada_telco character varying NOT NULL DEFAULT ''::character varying,
  var_descripcion_causal character varying NOT NULL DEFAULT ''::character varying,
  tipo_identificacion smallint NOT NULL,
  identificacion character varying NOT NULL,
  user_update character varying NOT NULL,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  last_update timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying NOT NULL,
  nit_empresa character varying NOT NULL DEFAULT '8020220161'::character varying,
  dstrct character varying(4) NOT NULL DEFAULT ''::character varying
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wsdc.respuesta_personalizada_decisor
  OWNER TO postgres;

