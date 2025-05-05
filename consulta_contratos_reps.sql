SELECT DISTINCT  
    cp.numero_documento, 
    cp.razon_social,
    c.contrato,
    c.fecha_inicio ,
    c.fecha_fin ,
    CASE cd.tipo_tecnologia
    WHEN 1 THEN 'Tecnologia'
    WHEN 2 THEN 'Medicamento'
    WHEN 3 THEN 'Insumo'
    WHEN 4 THEN 'Paquete'
    END AS Desctipo_tecnologia,
    cd.ma_servicio_habilitacion_codigo ,
cd.ma_servicio_habilitacion_valor ,
gu.nombre ,
gu.mae_region_valor 
FROM cnt_contratos c
INNER JOIN cnt_contrato_sedes cs ON cs.cnt_contratos_id = c.id 
INNER JOIN cnt_contrato_detalles cd  ON cd.cnt_contratos_id = c.id AND cd.cnt_contrato_sedes_id = cs.id  -- Para identificar las sede de Capita y evento
LEFT JOIN cnt_prestadores cp ON c.cnt_prestadores_id = cp.id 
left join cnt_prestador_sedes cps on cs.cnt_prestador_sedes_id = cps.id 
left join gn_ubicaciones gu on gu.id = cps.ubicacion_id 
where cd.activo = '1' and cd.tipo_tecnologia in ('1','4')
