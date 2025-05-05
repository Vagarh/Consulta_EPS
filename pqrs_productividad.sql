
-- Este script contiene dos consultas unidas por UNION ALL 
--que analizan la productividad en términos de interacciones
 --registradas en el sistema:

--Seguimientos a nivel de casos (aus_seguimientos)

--Seguimientos a nivel de servicios (aus_servicio_gestiones)

--Cada consulta agrupa por caso o servicio, responsable, ubicación y fecha, 
--y calcula un conteo de interacciones.

#CREACIÓN DE SEGUIMIENTOS - CASOS
SELECT
sg.aus_casos_id					as id_caso,
sg.id							as id,
ac.fecha_hora_crea 				as fecha_creacion_caso,
UPPER(gus.nombre)                               as responsable_caso,
ac.mae_solicitud_origen_valor	as origen,
ac.mae_solicitud_riesgo_vidal_valor as riesgo_vida,
ac.mae_solicitud_estado_valor 	as estado_caso_servicio,
gu.nombre 						as mpio_caso,
CASE gu.mae_region_valor
	WHEN 'MEDELLIN' THEN 'VALLE DE ABURRA'
	ELSE gu.mae_region_valor
END								as region,	 			
sg.usuario_crea 				as usuario,
sg.mae_estado_valor 			as estado_interaccion,
'Casos'					as grupo,
sg.fecha_hora_crea 				as fecha_interaccion,
COUNT(sg.fecha_hora_crea)		as interacciones
FROM aus_seguimientos sg 
LEFT JOIN aus_casos ac on ac.id = sg.aus_casos_id
LEFT JOIN gn_ubicaciones gu on gu.id = ac.gn_ubicaciones_id
LEFT JOIN gn_usuarios gus on gus.id = ac.gn_usuarios_responsable_id
WHERE YEAR(sg.fecha_hora_crea) > '2023'
	and ac.borrado <> 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
UNION ALL

#CREACIÓN DE SEGUIMIENTOS - SERVICIOS
SELECT
acs.aus_casos_id,
acs.id,
ac.fecha_hora_crea,
UPPER(gus.nombre),
ac.mae_solicitud_origen_valor,
ac.mae_solicitud_riesgo_vidal_valor,
acs.mae_estado_valor,
gu.nombre,
CASE gu.mae_region_valor
	WHEN 'MEDELLIN' THEN 'VALLE DE ABURRA'
	ELSE gu.mae_region_valor
END,
asg.usuario_crea,
asg.mae_estado_valor,
'Servicios',
asg.fecha_hora_crea,
COUNT(asg.fecha_hora_crea)
FROM aus_servicio_gestiones asg 
LEFT JOIN aus_caso_servicios acs on acs.id = asg.aus_servicios_id
LEFT JOIN aus_casos ac on ac.id = acs.aus_casos_id
LEFT JOIN gn_ubicaciones gu on gu.id = ac.gn_ubicaciones_id
LEFT JOIN gn_usuarios gus on gus.id = ac.gn_usuarios_responsable_id
WHERE YEAR(asg.fecha_hora_crea) > '2023'
	and ac.borrado <> 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13