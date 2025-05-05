SELECT
    codigo_reps                       AS `Código prestador`,
    mae_tipo_documento_codigo         AS `Tipo identificación`,
    documento_afiliado                AS `Número identificación`,
    fecha_consulta                    as `Fecha de Consulta`,
    ma_tecnologia_codigo              as  `Codigo de Consulta`,
    mae_finalidad_consulta_codigo     as  `Finalidad consulta`,
    mae_causa_externa_codigo           as  `Causa externa`,
    ma_diagnostico_principal_codigo   as  `Codigo del dx principal`,
    ma_diagnostico_relacionado1_codigo as  `Código del diagnóstico relacionado No. 1`,
    ma_diagnostico_relacionado2_codigo  as  `Código del diagnóstico relacionado No. 2`,
    ma_diagnostico_relacionado3_codigo  as  `Código del diagnóstico relacionado No. 3`
FROM   RIPS_AC_LLAVE
WHERE  documento_afiliado = 1015192869          -- usa comillas si el campo es VARCHAR
  AND   fecha_hora_crea   >= '2015-01-01'; 


SELECT
    codigo_reps                       AS `Código prestador`,
    mae_tipo_documento_codigo         AS `Tipo identificación`,
    documento_afiliado                AS `Número identificación`,
    fecha_ingreso                     as `Fecha Ingreso`,
    mae_causa_externa_valor           as  `Causa Externa`,
    ma_diagnostico_salida_valor       as  `DX Salida`,
    ma_diagnostico_relacionado1_valor as  `Diagnóstico relacionado No. 1 a la salida`,
    ma_diagnostico_relacionado2_valor as  `Diagnóstico relacionado No. 2 a la salida`,
    ma_diagnostico_relacionado3_valor as  `Diagnóstico relacionado No. 3 a la salida`,
    mae_destino_salida_valor          as  `Destino del usuario a la salida de observación`,
    mae_estado_salida_valor           as  `Estado a la salida`,
    mae_causa_externa_valor           as  `Causa básica de muerte en urgencias`,
    fecha_salida                      as  `Fecha de la salida del usuario en observación`
FROM   RIPS_AU_LLAVE
WHERE  documento_afiliado = 1015192869          -- usa comillas si el campo es VARCHAR
  AND  fecha_ingreso      >= '2015-01-01'; 


SELECT
    codigo_reps                       AS `Código prestador`,
    mae_tipo_documento_codigo         AS `Tipo identificación`,
    documento_afiliado                AS `Número identificación`,
    mae_via_ingreso_valor             AS `Vía ingreso`,
    fecha_ingreso                     AS `Fecha ingreso`,
    mae_causa_externa_valor           AS `Causa externa`,
    ma_diagnostico_ingreso_valor      AS `DX principal ingreso`,
    ma_diagnostico_egreso_valor       AS `DX principal egreso`,
    ma_diagnostico_relacionado1_valor AS `DX relacionado 1`,
    ma_diagnostico_relacionado2_valor AS `DX relacionado 2`,
    ma_diagnostico_relacionado3_valor AS `DX relacionado 3`,
    EstadoSalida                      AS `Estado de salida`,
    ma_diagnostico_muerte_codigo      AS `DX muerte`,
    fecha_salida                      AS `Fecha egreso`
FROM   RIPS_AH_LLAVE
WHERE  documento_afiliado = 1015192869          -- usa comillas si el campo es VARCHAR
  AND  fecha_ingreso      >= '2015-01-01';


  SELECT
    codigo_reps                       AS "Código prestador",
    mae_tipo_documento_codigo         AS "Tipo identificación",
    documento_afiliado                AS "Número identificación",
    fecha_procedimiento               AS "Fecha de procedimiento",
    ma_tecnologia_codigo              AS "Codigo procedimiento",
    mae_ambito_atencion_codigo_valor  AS "Ambito",
    mae_finalidad_procedimiento_valor AS "finalidad de procedimiento",
    ma_diagnostico_principal_valor    AS "dx principal",
    ma_diagnostico_relacionado1_valor as "DX relacionado"   
FROM   RIPS_AP_LLAVE
WHERE  documento_afiliado = 1015192869
  AND  fecha_procedimiento >= DATE '2015-01-01';