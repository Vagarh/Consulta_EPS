SELECT 
    c.caso_id AS numero_solicitud_pqrsf,
    c.numero_radicado AS radicado_SNS,
    acs.servicio_id AS numero_servicio,
    p.tipo_doc_usuario AS tipo_identificacion_afectado,
    p.doc_usuario AS identificacion_afectado,
    p.fecha_nacimiento AS fecha_nacimiento_afectado,
    p.edad,
    p.genero AS genero_afectado,
    p.estado_afiliacion,
    p.regimen AS regimen_afiliacion,
    p.grupo_poblacional,
    p.discapacidad AS discapacidad_afectado,
    p.cod_divipola_afiliacion,
    p.municipio_afiliacion_nombre AS mpio_afiliacion,
    p.region_afiliacion,
    c.fecha_creacion_caso,
    COALESCE(fc.fecha_cierre_caso, gs.fecha_resuelto, gs.fecha_cerrado) AS fecha_cierre_caso,
    CASE WHEN c.reabierto = 1 AND c.motivo_reabre_codigo = '1' THEN 'SI' ELSE 'NO' END AS reabierto_supersalud,
    CASE WHEN c.estado_caso_valor = 'Solucionado' THEN 'Cerrado' ELSE c.estado_caso_valor END AS estado_caso,
    c.riesgo_vida_valor AS riesgo_de_vida,
    c.origen_caso_valor AS origen_pqrs,
    c.tipo_caso_valor AS tipo_solicitud,
    c.ente_control_valor AS ente_control,
    acs.estado_servicio_valor AS estado_servicio,
    acs.codigo_servicio AS cod_servicio,
    acs.descripcion_servicio AS des_servicio,
    gs.fecha_asignado AS fecha_asignacion_servicio,
    COALESCE(gs.fecha_cerrado, gs.fecha_resuelto) AS fecha_solucion_servicio,
    c.fecha_modificacion_caso,
    CASE acs.medicamento WHEN 1 THEN 'SI' ELSE 'NO' END AS medicamento,
    CASE acs.servicio_atribuido_ips 
         WHEN 1 THEN 'SI' 
         WHEN 3 THEN 'No aplica' 
         ELSE 'NO' END AS servicio_atribuido_ips,
    u_res.nombre_usuario AS responsable_caso,
    u_asig.nombre_usuario AS usuario_asignado_servicio,
    ips.ips_nombre_limpio AS IPS_responsable_respuesta,
    ips.nit_prestador AS nit_responsable_respuesta
FROM 
(
    SELECT 
        ac.id AS caso_id,
        ac.radicado AS numero_radicado,
        ac.aus_personas_id,
        ac.gn_usuarios_responsable_id AS responsable_caso_id,
        ac.gn_ubicaciones_id AS ubicacion_caso_id,
        ac.mae_solicitud_estado_valor AS estado_caso_valor,
        ac.mae_solicitud_tipo_codigo AS tipo_caso_codigo,
        ac.mae_solicitud_tipo_valor AS tipo_caso_valor,
        ac.mae_solicitud_origen_codigo AS origen_caso_codigo,
        ac.mae_solicitud_origen_valor AS origen_caso_valor,
        ac.mae_solicitud_riesgo_vidal_valor AS riesgo_vida_valor,
        ac.mae_solicitud_ente_contro_valor AS ente_control_valor,
        ac.mae_motivo_reabre_codigo AS motivo_reabre_codigo,
        ac.reabierto,
        ac.cantidad_servicios,
        ac.fecha_hora_crea AS fecha_creacion_caso,
        ac.fecha_hora_modifica AS fecha_modificacion_caso,
        ac.borrado
    FROM aus_casos ac
    WHERE ac.borrado <> 1
      AND ac.mae_solicitud_tipo_codigo NOT IN (3, 9, 10)
) c
LEFT JOIN 
(
    SELECT 
        ap.id AS persona_id,
        ap.mae_tipo_documento_codigo AS tipo_doc_usuario,
        ap.documento AS doc_usuario,
        COALESCE(ap.mae_sexo_codigo, aa.mae_genero_codigo) AS genero,
        aa.fecha_nacimiento,
        TRUNCATE(DATEDIFF(CURRENT_DATE, aa.fecha_nacimiento)/365.25, 0) AS edad,
        aa.mae_estado_afiliacion_valor AS estado_afiliacion,
        aa.mae_regimen_valor AS regimen,
        aa.mae_grupo_poblacional_valor AS grupo_poblacional,
        CASE COALESCE(aa.discapacidad, ap.dicapacidad) WHEN 0 THEN 'NO' ELSE 'SI' END AS discapacidad,
        gu.id AS municipio_afiliacion_id,
        UPPER(CASE WHEN gu.mae_region_valor = 'MEDELLIN' THEN 'VALLE DE ABURRA' ELSE gu.mae_region_valor END) AS region_afiliacion,
        CASE WHEN mpio.descripcion = 'MEDELLÍN' THEN 'MEDELLIN' ELSE mpio.descripcion END AS municipio_afiliacion_nombre,
        CONCAT(dpto.prefijo, mpio.prefijo) AS cod_divipola_afiliacion
    FROM aus_personas ap
    LEFT JOIN aseg_afiliados aa 
         ON aa.numero_documento = ap.documento 
        AND aa.mae_tipo_documento_codigo = ap.mae_tipo_documento_codigo
    LEFT JOIN gn_ubicaciones mpio ON mpio.id = aa.residencia_ubicacion_id
    LEFT JOIN gn_ubicaciones dpto ON dpto.id = mpio.gn_ubicaciones_id
    LEFT JOIN gn_ubicaciones gu ON gu.id = aa.afiliacion_ubicaciones_id
) p ON p.persona_id = c.aus_personas_id
LEFT JOIN 
(
    SELECT 
        acs.id AS servicio_id,
        acs.aus_casos_id AS caso_id,
        acs.gn_usuarios_asignado_id AS usuario_asignado_id,
        acs.cnt_prestador_sede_destino_id AS sede_prestador_id,
        acs.mae_estado_valor AS estado_servicio_valor,
        acs.ma_tecnologia_codigo AS codigo_servicio,
        acs.ma_tecnologia_valor AS descripcion_servicio,
        acs.mae_servicio_ambito_valor AS ambito_servicio,
        acs.medicamento,
        acs.servicio_atribuido_ips
    FROM aus_caso_servicios acs
) acs ON acs.caso_id = c.caso_id
LEFT JOIN 
(
    SELECT 
        seg1.aus_casos_id AS caso_id, 
        seg1.fecha_hora_crea AS fecha_cierre_caso
    FROM aus_seguimientos seg1
    WHERE seg1.mae_estado_valor = 'CERRADO'
      AND seg1.fecha_hora_crea = (
          SELECT MAX(seg2.fecha_hora_crea)
          FROM aus_seguimientos seg2
          WHERE seg2.aus_casos_id = seg1.aus_casos_id
            AND seg2.mae_estado_valor = 'CERRADO'
      )
) fc ON fc.caso_id = c.caso_id
LEFT JOIN 
(
    SELECT 
        acsg.aus_servicios_id AS servicio_id,
        MIN(CASE WHEN acsg.mae_estado_valor = 'Asignado' THEN acsg.fecha_hora_crea END) AS fecha_asignado,
        MIN(CASE WHEN acsg.mae_estado_valor = 'Estudio' THEN acsg.fecha_hora_crea END) AS fecha_estudio,
        MIN(CASE WHEN acsg.mae_estado_valor = 'Cerrado' THEN acsg.fecha_hora_crea END) AS fecha_cerrado,
        MIN(CASE WHEN acsg.mae_estado_valor = 'Resuelto' THEN acsg.fecha_hora_crea END) AS fecha_resuelto,
        MIN(CASE WHEN acsg.mae_estado_valor = 'Rechazado' THEN acsg.fecha_hora_crea END) AS fecha_rechazado
    FROM aus_servicio_gestiones acsg
    WHERE acsg.mae_estado_valor IN ('Asignado','Estudio','Cerrado','Resuelto','Rechazado')
    GROUP BY acsg.aus_servicios_id
) gs ON gs.servicio_id = acs.servicio_id
LEFT JOIN 
(
    SELECT id AS usuario_id, UPPER(nombre) AS nombre_usuario, documento 
    FROM gn_usuarios
) u_res ON u_res.usuario_id = c.responsable_caso_id
LEFT JOIN 
(
    SELECT id AS usuario_id, UPPER(nombre) AS nombre_usuario, documento 
    FROM gn_usuarios
) u_asig ON u_asig.usuario_id = acs.usuario_asignado_id
LEFT JOIN 
(
    SELECT 
        cps.id AS sede_prestador_id,
        REPLACE(REPLACE(REPLACE(REPLACE(UPPER(COALESCE(cps.nombre, '')), ';',''), ',',''), CHAR(13), ''), CHAR(10), '') AS ips_nombre_limpio,
        cp.numero_documento AS nit_prestador
    FROM cnt_prestador_sedes cps
    LEFT JOIN cnt_prestadores cp ON cp.id = cps.id
) ips ON ips.sede_prestador_id = acs.sede_prestador_id
WHERE YEAR(c.fecha_creacion_caso) >= 2024;