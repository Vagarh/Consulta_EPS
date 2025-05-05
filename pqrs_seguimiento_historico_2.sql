-- PAGINA 2	SEGUIMIENTO HISTORICO
#CASOS GENERADOS TODOS LOS CANALES
SELECT 
YEAR (ac.fecha_hora_crea) 					as año,
MONTH(ac.fecha_hora_crea) 					as mes, 
'1-Creados' 								as grupo_caso,
CASE ac.mae_solicitud_origen_codigo
	WHEN 9 THEN 'Supersalud'
	ELSE 'Otros canales'
END 										as origen,
ap.mae_tipo_documento_codigo,
ap.documento,
gu.nombre 									as municipio_afiliacion,
CASE gu.mae_region_valor
	WHEN 'MEDELLIN' THEN 'VALLE DE ABURRA'
	ELSE gu.mae_region_valor
END	 										as region_afiliacion,
COUNT(*) as Nro_pqrd
FROM aus_casos ac
LEFT JOIN aus_personas ap on ap.id = ac.aus_personas_id
LEFT JOIN aseg_afiliados aa on (aa.mae_tipo_documento_codigo = ap.mae_tipo_documento_codigo and aa.numero_documento = ap.documento
									or ap.mae_tipo_documento_codigo and aa.numero_documento = ap.documento)
	LEFT JOIN gn_ubicaciones gu on gu.id = aa.afiliacion_ubicaciones_id
WHERE YEAR (ac.fecha_hora_crea) in('2022','2023','2024')
	and ac.mae_solicitud_tipo_codigo <> 3 -- Diferente a Felicitación
	and ac.mae_solicitud_tipo_codigo <> 9 -- Diferente a Sugerencia
	and ac.mae_solicitud_tipo_codigo <> 10 -- Diferente a Solicitud de informacion
	and ac.borrado <> 1
GROUP BY 1,2,3,4,5,6,7,8
UNION ALL
#CERRADOS EL MISMO MES
SELECT 
YEAR(casoCerrado.fecha_cerrado),
MONTH(casoCerrado.fecha_cerrado),
'2-Cerrado el mismo mes',
CASE ac.mae_solicitud_origen_codigo
	WHEN 9 THEN 'Supersalud'
	ELSE 'Otros canales'
END 										as origen,
ap.mae_tipo_documento_codigo,
ap.documento,
gu.nombre 									as municipio_afiliacion,
CASE gu.mae_region_valor
	WHEN 'MEDELLIN' THEN 'VALLE DE ABURRA'
	ELSE gu.mae_region_valor
END	 										as region_afiliacion,
COUNT(*)
FROM aus_casos ac
INNER JOIN (
			select
			seg.aus_casos_id as id,
			seg.mae_estado_valor as estado,
			seg.fecha_hora_crea as fecha_cerrado,
			ROW_NUMBER() OVER (PARTITION BY seg.aus_casos_id ORDER BY seg.fecha_hora_crea DESC) as rn
			from aus_seguimientos seg
			where seg.mae_estado_valor = 'CERRADO'
			) as casoCerrado on casoCerrado.id = ac.id and casoCerrado.rn = 1
LEFT JOIN aus_personas ap on ap.id = ac.aus_personas_id
LEFT JOIN aseg_afiliados aa on (aa.mae_tipo_documento_codigo = ap.mae_tipo_documento_codigo and aa.numero_documento = ap.documento
									or ap.mae_tipo_documento_codigo and aa.numero_documento = ap.documento)
	LEFT JOIN gn_ubicaciones gu on gu.id = aa.afiliacion_ubicaciones_id
WHERE YEAR (ac.fecha_hora_crea) in ('2022','2023','2024')
	and YEAR (casoCerrado.fecha_cerrado) in ('2022','2023','2024')
	and CONCAT(YEAR(ac.fecha_hora_crea),MONTH(ac.fecha_hora_crea))= CONCAT(YEAR(casoCerrado.fecha_cerrado),month(casoCerrado.fecha_cerrado))
	and (ac.mae_solicitud_estado_valor = 'Cerrado' or ac.mae_solicitud_estado_valor = 'Solucionado')
	and ac.mae_solicitud_tipo_codigo <> 3 -- Diferente a Felicitación
	and ac.mae_solicitud_tipo_codigo <> 9 -- Diferente a Sugerencia
	and ac.mae_solicitud_tipo_codigo <> 10 -- Diferente a Solicitud de informacion
	and ac.borrado <> 1
GROUP BY 1,2,3,4,5,6,7,8
UNION ALL
#CERRADOS MES DIFERENTE A LA FECHA DE CREACION
SELECT 
YEAR(casoCerrado.fecha_cerrado),
MONTH(casoCerrado.fecha_cerrado),
'3-Cerrado meses anteriores',
CASE ac.mae_solicitud_origen_codigo
	WHEN 9 THEN 'Supersalud'
	ELSE 'Otros canales'
END 								as origen,
ap.mae_tipo_documento_codigo,
ap.documento,
gu.nombre 							as municipio_afiliacion,
CASE gu.mae_region_valor
	WHEN 'MEDELLIN' THEN 'VALLE DE ABURRA'
	ELSE gu.mae_region_valor
END	 								as region_afiliacion,
COUNT(*)
FROM aus_casos ac
INNER JOIN (
			select
			seg.aus_casos_id as id,
			seg.mae_estado_valor as estado,
			seg.fecha_hora_crea as fecha_cerrado,
			ROW_NUMBER() OVER (PARTITION BY seg.aus_casos_id ORDER BY seg.fecha_hora_crea DESC) as rn
			from aus_seguimientos seg
			where seg.mae_estado_valor = 'CERRADO'
			) as casoCerrado on casoCerrado.id = ac.id and casoCerrado.rn = 1
LEFT JOIN aus_personas ap on ap.id = ac.aus_personas_id
LEFT JOIN aseg_afiliados aa on (aa.mae_tipo_documento_codigo = ap.mae_tipo_documento_codigo and aa.numero_documento = ap.documento
									or ap.mae_tipo_documento_codigo and aa.numero_documento = ap.documento)
	LEFT JOIN gn_ubicaciones gu on gu.id = aa.afiliacion_ubicaciones_id
	-- and YEAR (ac.fecha_hora_crea) in ('2022','2023','2024')
WHERE YEAR (casoCerrado.fecha_cerrado) in ('2022','2023','2024')
	and CONCAT(YEAR(ac.fecha_hora_crea),MONTH(ac.fecha_hora_crea)) <> CONCAT(YEAR(casoCerrado.fecha_cerrado),MONTH(casoCerrado.fecha_cerrado))
	and (ac.mae_solicitud_estado_valor = 'Cerrado' or ac.mae_solicitud_estado_valor = 'Solucionado')
	and ac.mae_solicitud_tipo_codigo <> 3 -- Diferente a Felicitación
	and ac.mae_solicitud_tipo_codigo <> 9 -- Diferente a Sugerencia
	and ac.mae_solicitud_tipo_codigo <> 10 -- Diferente a Solicitud de informacion
	and ac.borrado <> 1
GROUP BY 1,2,3,4,5,6,7,8
UNION ALL
#ABIERTOS DE TODOS LOS CANALES
SELECT 
YEAR (ac.fecha_hora_crea), 
MONTH(ac.fecha_hora_crea),
'4-Abiertos' estado,
CASE ac.mae_solicitud_origen_codigo
	WHEN 9 THEN 'Supersalud'
	ELSE 'Otros canales'
END 					as origen,
ap.mae_tipo_documento_codigo,
ap.documento,
gu.nombre 									as municipio_afiliacion,
CASE gu.mae_region_valor
	WHEN 'MEDELLIN' THEN 'VALLE DE ABURRA'
	ELSE gu.mae_region_valor
END	 										as region_afiliacion,
COUNT(*)
FROM aus_casos ac 
LEFT JOIN aus_personas ap on ap.id = ac.aus_personas_id 
LEFT JOIN aseg_afiliados aa on (aa.mae_tipo_documento_codigo = ap.mae_tipo_documento_codigo and aa.numero_documento = ap.documento
									or ap.mae_tipo_documento_codigo and aa.numero_documento = ap.documento)
	LEFT JOIN gn_ubicaciones gu on gu.id = aa.afiliacion_ubicaciones_id
WHERE YEAR (ac.fecha_hora_crea) IN ('2023','2024') 
	and ac.mae_solicitud_estado_valor <> 'Cerrado'
	and ac.mae_solicitud_estado_valor <> 'Solucionado'
	and ac.mae_solicitud_tipo_codigo <> 3 -- Diferente a Felicitación
	and ac.mae_solicitud_tipo_codigo <> 9 -- Diferente a Sugerencia
	and ac.mae_solicitud_tipo_codigo <> 10 -- Diferente a Solicitud de informacion
	and ac.borrado <> 1
	-- and month(fecha_hora_crea)= month(fecha_hora_modifica)
GROUP BY 1,2,3,4,5,6,7,8