-- contar cuántos afiliados activos hay por municipio de afiliación.

SELECT
	CONCAT(d.prefijo,m.prefijo) AS cod_municipio_afiliacion, 
	COUNT(*) AS cantidad_afiliados
FROM aseg_afiliados aa 
LEFT JOIN gn_ubicaciones m ON m.id = aa.afiliacion_ubicaciones_id 
LEFT JOIN gn_ubicaciones d ON d.id = m.gn_ubicaciones_id
WHERE aa.mae_estado_afiliacion_valor = 'activo'
GROUP BY 1