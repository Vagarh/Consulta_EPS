SELECT
    a3.fecha_solicitud                                            AS fecha_solicitud,
    a.fecha_autorizacion,
    DATEDIFF(a.fecha_autorizacion, a3.fecha_solicitud)            AS dias_espera,
    a.afiliado_tipo_documento,
    a.afiliado_numero_documento,
    a.afiliado_primer_apellido,
    a.afiliado_segundo_apellido,
    a.afiliado_primer_nombre,
    a.afiliado_segundo_nombre,
    a.afiliado_fecha_nacimiento,
    a.diagnostico_principal,
    a.afiliado_municipio,
    a.mae_modalidad_tecnologia_codigo,
    a.mae_modalidad_tecnologia_valor,
    i.ma_tecnologia_codigo,
    i.ma_tecnologia_valor,
    i.cantidad_autorizada,
    i.fecha_hora_crea,
    a.numero_autorizacion,
    CASE
    WHEN UPPER(a.afiliado_municipio) IN (
        'MEDELLÍN','BELLO','ENVIGADO','ITAGUI','SABANETA','LA ESTRELLA',
        'CALDAS','COPACABANA','GIRARDOTA','BARBOSA'
    ) THEN 'Valle de Aburrá'
    WHEN UPPER(a.afiliado_municipio) IN (
        -- Valle de San Nicolás
        'RIONEGRO','MARINILLA','LA CEJA','EL CARMEN DE VIBORAL','EL RETIRO',
        'EL SANTUARIO','GUARNE','LA UNION','SAN VICENTE FERRER',
        -- Embalses
        'ALEJANDRIA','CONCEPCION','EL PEÑOL','GRANADA','GUATAPE',
        'SAN CARLOS','SAN RAFAEL',
        -- Bosques
        'COCORNA','SAN FRANCISCO','SAN LUIS',
        -- Páramo
        'ABEJORRAL','ARGELIA','NARIÑO','SONSON'
    ) THEN 'Oriente'
    WHEN UPPER(a.afiliado_municipio) IN (
        'SANTA ROSA DE OS','SAN PEDRO DE LOS MILAGROS','SAN JOSE DE LA MONTAÑA',
        'DONMATIAS','ENTRERIOS','BELMIRA','CAROLINA DEL PRINCIPE','GOMEZ PLATA',
        'GUADALUPE','ANGOSTURA','BRICEÑO','CAMPAMENTO','YARUMAL','VALDIVIA',
        'ITUANGO','SAN ANDRES DE CUERQUIA','TOLEDO'
    ) THEN 'Norte'
    WHEN UPPER(a.afiliado_municipio) IN (
        'AMALFI','ANORI','CISNEROS','REMEDIOS','SEGOVIA',
        'SAN ROQUE','SANTO DOMINGO','VEGACHI','YALI','YOLOMBO'
    ) THEN 'Nordeste'
    WHEN UPPER(a.afiliado_municipio) IN (
        -- Cauca Medio
        'ANZA','ARMENIA','BURITICA','CAICEDO','EBEJICO','GIRALDO','HELICONIA',
        'LIBORINA','OLAYA','SABANALARGA','SAN JERONIMO','SANTAFE DE ANTIO',
        'SOPETRAN',
        -- Cuenca Río Sucio
        'ABRIAQUI','CANASGORDAS','DABEIBA','FRONTINO','PEQUE','URAMITA'
    ) THEN 'Occidente'
    WHEN UPPER(a.afiliado_municipio) IN (
        -- Cartama
        'CARAMANTA','JERICO','LA PINTADA','MONTEBELLO','PUEBLORRICO',
        'SANTA BARBARA','TAMESIS','TARSO','VALPARAISO',
        -- Penderisco
        'BETULIA','CONCORDIA','SALGAR','URRAO',
        -- San Juan
        'ANDES','BETANIA','CIUDAD BOLIVAR','HISPANIA','JARDIN',
        -- Sinifaná
        'AMAGA','ANGELOPOLIS','FREDONIA','TITIRIBI','VENECIA'
    ) THEN 'Suroeste'
    WHEN UPPER(a.afiliado_municipio) IN (
        'CAUCASIA','CACERES','EL BAGRE','NECHI','TARAZA','ZARAGOZA'
    ) THEN 'Bajo Cauca'
    WHEN UPPER(a.afiliado_municipio) IN (
        'PUERTO BERRIO','PUERTO NARE','PUERTO TRIUNFO',
        'YONDO','CARACOLI','MACEO'
    ) THEN 'Magdalena Medio'
    WHEN UPPER(a.afiliado_municipio) IN (
        -- Centro
        'APARTADO','CAREPA','CHIGORODO','MUTATA','TURBO',
        -- Norte
        'ARBOLETES','NECOCLI','SAN JUAN DE URA','SAN PEDRO DE URA',
        -- Atrato Medio
        'MURINDO','VIGIA DEL FUERTE'
    ) THEN 'Urabá'
    ELSE 'SIN CLASIFICAR'
END AS subregion_ant
FROM   system_savia.au_anexos4      AS a
JOIN   system_savia.au_anexo4_items AS i   ON i.au_anexos4_id = a.id
LEFT JOIN system_savia.au_anexos3  AS a3   ON a3.id = a.au_anexos3_id
WHERE  i.ma_tecnologia_codigo IN ('890208','890308','890284','890384')
  AND  a3.fecha_solicitud BETWEEN '2024-01-01' AND '2025-03-31';