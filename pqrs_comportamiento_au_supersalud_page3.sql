SELECT DISTINCT				
ap.mae_tipo_documento_codigo 									as tipo_identificacion_afectado,
ap.documento													as identificacion_afectado,
aa.fecha_nacimiento 												as fecha_nacimiento_afectado,
TRUNCATE(DATEDIFF(CURRENT_DATE(),aa.fecha_nacimiento)/365.2,0)  as Edad_actual,
COALESCE(ap.mae_sexo_codigo, aa.mae_genero_codigo) 				as genero_afectado,
COALESCE(aa.mae_estado_afiliacion_valor) 	as estado_afiliacion,
aa.mae_regimen_valor 											as regimen_afiliacion,
aa.mae_grupo_poblacional_valor									as grupo_poblacional,
CASE COALESCE (aa.discapacidad,ap.dicapacidad) 
	WHEN 0 THEN 'NO'
	ELSE 'SI'
END 															as discapacidad_afectado,						
CONCAT(dpto.prefijo,mpio.prefijo)								as cod_divipola_afiliacion,
CASE
	WHEN mpio.descripcion = 'MEDELLÍN' THEN 'MEDELLIN'
	ELSE mpio.descripcion
END																as mpio_afiliacion,
CASE 
	WHEN mpio.mae_region_valor = 'MEDELLIN' THEN 'VALLE DE ABURRA'
	ELSE mpio.mae_region_valor
END																as region_afiliacion,
CONCAT(gnu2.prefijo, gnu1.prefijo)								as cod_pqrd,
gnu1.nombre                                                      as municipio_pqrd,
CAST(ac.id as CHAR)															as numero_solicitud_pqrsf,
ac.radicado																	as radicado_SNS,
ac.fecha_hora_crea															as fecha_creacion_caso,
CASE 
    WHEN ac.mae_solicitud_riesgo_vidal_valor = 'No aplica'  THEN 'Peticion general'
    WHEN ac.mae_solicitud_riesgo_vidal_valor = 'Regular'      THEN 'Simple'
    ELSE ac.mae_solicitud_riesgo_vidal_valor END as riesgo_vida,
ac.mae_solicitud_estado_valor												as estado_caso,
ac.mae_solicitud_origen_valor												as origen_pqrd,
ac.mae_solicitud_tipo_valor													as tipo_solicitud,
ac.mae_solicitud_ente_contro_valor											as ente_control,
COALESCE (ac.mae_motivo_especifico_valor,acs.mae_servicio_motivo_valor)		as motivo_especifico,
ac.mae_tipo_motivo_especifico_valor											as tipo_motivo_especifico,
ac.mae_subtipo_motivo_especifico_valor										as subtipo_motivo_especifico,
sgc.fecha_cierre															as fecha_cierre_caso,
ac.cantidad_servicios														as cantidad_servicios,
CASE acs.medicamento
	WHEN 0 THEN 'NO'
	WHEN 1 THEN 'SI'
END																			as medicamento,
CASE acs.servicio_atribuido_ips
	WHEN 0 THEN 'NO'
	WHEN 1 THEN 'SI'
	WHEN 3 THEN 'No aplica'
END																			as servicio_atribuido_ips,
COALESCE (gu.documento, cp.numero_documento)								as nit_responsable_respuesta,
REPLACE (
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
											REPLACE(
												REPLACE (UPPER(COALESCE (gu.nombre, acs.cnt_prestador_sede_destino_valor)), ';', '')
												, ',', '')
										, Char(13), '')
									, Char(10), '')
								, Char(9), '')
							, Char(34), '')
						, '&quot','')															
					, '\r\n','')
				, '\n','')
			, '\t','')
		, '','')
	,'  ','')																as IPS_responsable_respuesta,
acs.mae_servicio_ambito_valor												as ambito_servicio,
COALESCE (acsc.fecha, acsr.fecha)											as fecha_cierre_servicio,
acs.ma_tecnologia_codigo													as codigo_servicio_pqrd,
acs.ma_tecnologia_valor														as descripcion_servicio_pqrd,
CASE 
	WHEN (ac.reabierto = 1 and ac.mae_motivo_reabre_codigo = '1') THEN 'SI'
	ELSE 'NO'
END													AS reabierto_Supersalud
FROM aus_casos ac
LEFT JOIN aus_personas ap ON ap.id = ac.aus_personas_id
LEFT JOIN gn_ubicaciones gnu1 ON gnu1.id = ac.gn_ubicaciones_id
LEFT JOIN gn_ubicaciones gnu2 ON gnu2.id = gnu1.gn_ubicaciones_id
	LEFT JOIN aus_persona_telefonos apt ON apt.aus_personas_id = ap.id
LEFT JOIN aseg_afiliados aa ON aa.numero_documento = ap.documento
	LEFT JOIN gn_ubicaciones mpio ON mpio.id = aa.residencia_ubicacion_id
	LEFT JOIN gn_ubicaciones dpto ON dpto.id = mpio.gn_ubicaciones_id
LEFT JOIN aus_caso_servicios acs ON acs.aus_casos_id = ac.id
	LEFT JOIN gn_usuarios gu ON acs.gn_usuarios_asignado_id = gu.id
	LEFT JOIN gn_usuarios gur on ac.gn_usuarios_responsable_id = gur.id 
	LEFT JOIN cnt_prestadores cp on cp.id = acs.cnt_prestador_sede_destino_id
LEFT JOIN (	select
			sg.aus_casos_id 		as id_caso,
			sg.mae_estado_valor		as estado,
			sg.observacion			as descripcion,
			sg.fecha_hora_crea		as fecha_radicado,
			ROW_NUMBER() OVER (PARTITION BY sg.aus_casos_id ORDER BY sg.fecha_hora_crea DESC) as rn1
			from aus_seguimientos sg
			where sg.mae_estado_valor = 'RADICADO' 
			) AS sgr ON sgr.id_caso = ac.id AND sgr.rn1 = 1
LEFT JOIN (	select
			sg.aus_casos_id 		as id_caso,
			sg.mae_estado_valor		as estado,
			sg.observacion			as descripcion,
			sg.fecha_hora_crea		as fecha_cierre,
			sg.usuario_crea			as usuario,
			ROW_NUMBER() OVER (PARTITION BY sg.aus_casos_id ORDER BY sg.fecha_hora_crea DESC) as rn2
			from aus_seguimientos sg
			where sg.mae_estado_valor = 'CERRADO' 
			) AS sgc ON sgc.id_caso = ac.id AND sgc.rn2 = 1
LEFT JOIN (	select
			acsg.aus_servicios_id 	as id_servicio,
			acsg.mae_estado_valor	as estado,
			acsg.observacion		as descripcion,
			acsg.fecha_hora_crea	as fecha,
			acsg.usuario_crea		as usuario,
			ROW_NUMBER() OVER (PARTITION BY acsg.aus_servicios_id ORDER BY acsg.fecha_hora_crea ASC) as rn3
			from aus_servicio_gestiones acsg
			where acsg.mae_estado_valor in ('Asignado')
			) AS acsa ON acsa.id_servicio = acs.id AND acsa.rn3 = 1
LEFT JOIN (	select
			acsg.aus_servicios_id 	as id_servicio,
			acsg.mae_estado_valor	as estado,
			acsg.observacion		as descripcion,
			acsg.fecha_hora_crea	as fecha,
			acsg.usuario_crea		as usuario,
			ROW_NUMBER() OVER (PARTITION BY acsg.aus_servicios_id ORDER BY acsg.fecha_hora_crea ASC) as rn4
			from aus_servicio_gestiones acsg
			where acsg.mae_estado_valor in ('Estudio')
			) AS acse ON acse.id_servicio = acs.id AND acse.rn4 = 1
LEFT JOIN (	select
			acsg.aus_servicios_id 	as id_servicio,
			acsg.mae_estado_valor	as estado,
			acsg.observacion		as descripcion,
			acsg.fecha_hora_crea	as fecha,
			acsg.usuario_crea		as usuario,
			ROW_NUMBER() OVER (PARTITION BY acsg.aus_servicios_id ORDER BY acsg.fecha_hora_crea ASC) as rn5
			from aus_servicio_gestiones acsg
			where acsg.mae_estado_valor in ('Cerrado')
			) AS acsc ON acsc.id_servicio = acs.id AND acsc.rn5 = 1
LEFT JOIN (	select
			acsg.aus_servicios_id 	as id_servicio,
			acsg.mae_estado_valor	as estado,
			acsg.observacion		as descripcion,
			acsg.fecha_hora_crea	as fecha,
			acsg.usuario_crea		as usuario,
			ROW_NUMBER() OVER (PARTITION BY acsg.aus_servicios_id ORDER BY acsg.fecha_hora_crea ASC) as rn6
			from aus_servicio_gestiones acsg
			where acsg.mae_estado_valor in ('Resuelto')
			) AS acsr ON acsr.id_servicio = acs.id AND acsr.rn6 = 1
LEFT JOIN (	select
			acsg.aus_servicios_id 	as id_servicio,
			acsg.mae_estado_valor	as estado,
			acsg.observacion		as descripcion,
			acsg.fecha_hora_crea	as fecha,
			acsg.usuario_crea		as usuario,
			ROW_NUMBER() OVER (PARTITION BY acsg.aus_servicios_id ORDER BY acsg.fecha_hora_crea ASC) as rn7
			from aus_servicio_gestiones acsg
			where acsg.mae_estado_valor in ('Rechazado')
			) AS acsz ON acsz.id_servicio = acs.id AND acsz.rn7 = 1
WHERE ac.borrado <> 1	
AND year(ac.fecha_hora_crea) > 2022