-- PAGINA 1 TOTAL PQRD

-- Esta consulta es más compleja que la anterior. Está diseñada para mostrar 
--el comportamiento de solicitudes PQRD, incluyendo múltiples detalles del caso,
-- la persona afiliada, el estado del servicio, fechas clave y responsable

SELECT
ac.id												AS numero_solicitud_pqrsf, 
ac.radicado 										AS numero_radicado,
acs.id 												AS numero_servicio,	
ap.mae_tipo_documento_codigo						AS tipo_doc_usuario,
ap.documento 										AS doc_usuario,	
gu.nombre 											AS municipio_afiliacion,
CASE gu.mae_region_valor
	WHEN 'MEDELLIN' THEN 'VALLE DE ABURRA'
	ELSE gu.mae_region_valor
END	 												AS region_afiliacion,
CASE ac.mae_solicitud_estado_valor
	WHEN 'Solucionado' THEN 'Cerrado'
	ELSE ac.mae_solicitud_estado_valor
END 												AS EstadoCaso,
CASE 
	WHEN (ac.reabierto = 1 and ac.mae_motivo_reabre_codigo = '1') THEN 'SI'
	ELSE 'NO'
END													AS reabierto_Supersalud,
ac.fecha_hora_crea,
ac.fecha_hora_modifica,
COALESCE(casoCerrado.fecha_cierre,servicioR.fecha_hora_crea)		AS fecha_cierre,
ac.mae_solicitud_riesgo_vidal_valor 								AS riesgo_de_vida,
resp.nombre 														AS ResponsableCaso,
ac.mae_solicitud_origen_valor,
COALESCE (asig.nombre, ips.nombre)	 								AS IPS_responsable_respuesta,
ips.nombre 															AS IPSDestino,
asig.nombre 														AS usuario_asignado_servicio,
acs.mae_estado_valor												AS EstadoServicio,
acs.ma_tecnologia_codigo 											AS Cod_servicio,
acs.ma_tecnologia_valor 											AS Des_servicio,
COALESCE (servicioA.fecha_hora_crea,servicioE.fecha_hora_crea,acs.fecha_hora_crea) as fecha_asignacion_servicio,
COALESCE (servicioC.fecha_hora_crea,servicioR.fecha_hora_crea) as fecha_solucion_servicio
FROM aus_casos ac 
LEFT JOIN aus_caso_servicios acs on ac.id = acs.aus_casos_id 
LEFT JOIN gn_usuarios resp on ac.gn_usuarios_responsable_id = resp.id 
	LEFT JOIN cnt_prestador_sedes ips on acs.cnt_prestador_sede_destino_id = ips.id 
	LEFT JOIN gn_usuarios asig on acs.gn_usuarios_asignado_id = asig.id
LEFT JOIN aus_personas ap on ap.id = ac.aus_personas_id
	LEFT JOIN aseg_afiliados aa on (aa.mae_tipo_documento_codigo = ap.mae_tipo_documento_codigo and aa.numero_documento = ap.documento
									or ap.mae_tipo_documento_codigo and aa.numero_documento = ap.documento)
	LEFT JOIN gn_ubicaciones gu on gu.id = aa.afiliacion_ubicaciones_id
LEFT JOIN ( select
				seg.aus_casos_id as id,
				seg.mae_estado_valor as estado,
				seg.fecha_hora_crea as fecha_cierre,
				ROW_NUMBER() OVER (PARTITION BY seg.aus_casos_id ORDER BY seg.fecha_hora_crea DESC) as rn
				from aus_seguimientos seg
				where seg.mae_estado_valor = 'CERRADO'
			) as casoCerrado on casoCerrado.id = ac.id and casoCerrado.rn = 1 -- CASOS CERRADOS
LEFT JOIN ( select acs.id as id,
				acs.aus_casos_id as id_caso, 
				asg.mae_estado_valor, 
				asg.fecha_hora_crea,
				asg.observacion,
				ROW_NUMBER() OVER (PARTITION BY acs.id ORDER BY asg.fecha_hora_crea ASC) as rn
				from aus_caso_servicios acs
				left join aus_servicio_gestiones asg on asg.aus_servicios_id = acs.id 
				where asg.mae_estado_valor = 'Asignado' 
				) as servicioA on servicioA.id = acs.id and servicioA.rn = 1
LEFT JOIN ( select acs.id as id,
				acs.aus_casos_id as id_caso, 
				asg.mae_estado_valor, 
				asg.fecha_hora_crea,
				asg.observacion,
				ROW_NUMBER() OVER (PARTITION BY acs.id ORDER BY asg.fecha_hora_crea ASC) as rn
				from aus_caso_servicios acs
				left join aus_servicio_gestiones asg on asg.aus_servicios_id = acs.id 
				where asg.mae_estado_valor = 'Estudio' 
				) as servicioE on servicioE.id = acs.id and servicioE.rn = 1
LEFT JOIN ( select acs.id as id,
				acs.aus_casos_id as id_caso, 
				asg.mae_estado_valor, 
				asg.fecha_hora_crea,
				asg.observacion,
				ROW_NUMBER() OVER (PARTITION BY acs.id ORDER BY asg.fecha_hora_crea ASC) as rn
				from aus_caso_servicios acs
				left join aus_servicio_gestiones asg on asg.aus_servicios_id = acs.id 
				where asg.mae_estado_valor = 'Cerrado'
				) as servicioC on servicioC.id = acs.id and servicioC.rn = 1
LEFT JOIN ( select acs.id as id,
				acs.aus_casos_id as id_caso, 
				asg.mae_estado_valor, 
				asg.fecha_hora_crea,
				asg.observacion,
				ROW_NUMBER() OVER (PARTITION BY acs.id ORDER BY asg.fecha_hora_crea ASC) as rn
				from aus_caso_servicios acs
				left join aus_servicio_gestiones asg on asg.aus_servicios_id = acs.id 
				where asg.mae_estado_valor = 'Resuelto'
				) as servicioR on servicioR.id = acs.id and servicioR.rn = 1
WHERE YEAR(ac.fecha_hora_crea)>2023
	and ac.mae_solicitud_tipo_codigo <> 3 -- Diferente a Felicitación
	and ac.mae_solicitud_tipo_codigo <> 9 -- Diferente a Sugerencia
	and ac.mae_solicitud_tipo_codigo <> 10 -- Diferente a Solicitud de informacion
	and ac.borrado <> 1