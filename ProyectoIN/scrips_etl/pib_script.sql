
-- ETAPA 1: EXTRACCION
-- ==========================================

-- 1.1 Habilitar importacion local
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
 
use proyectoin;

LOAD DATA LOCAL INFILE "C:\\Users\\Smart\\OneDrive\\Desktop\\datos_fuente\\pib_per_capita_largo.csv"
INTO TABLE pib_origen
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

-- 1.3 Explorar los datos
SELECT COUNT(*) FROM pib_origen;
SELECT * FROM pib_origen;
DESC pib_origen;

-- ETAPA 2: TRANSFORMACION
-- ==========================================

-- 2.1 Limpiar y convertir tipos de datos
CREATE OR REPLACE VIEW PIB_LIMPIO AS
SELECT
    UPPER(TRIM(country_code)) AS country_code,
    TRIM(country_name) AS country_name,
    CAST(TRIM(anio) AS UNSIGNED) AS anio,
    CAST(TRIM(pib_per_capita_usd)
         AS DECIMAL(18,2)) AS pib_per_capita_usd
FROM pib_origen
WHERE NULLIF(TRIM(country_code), '') IS NOT NULL
  AND NULLIF(TRIM(anio), '') IS NOT NULL
  AND NULLIF(TRIM(pib_per_capita_usd), '') IS NOT NULL
  AND TRIM(anio) REGEXP '^[0-9]{4}$'
  AND TRIM(pib_per_capita_usd)
      REGEXP '^[0-9]+([.][0-9]+)?$';

-- 2.2 Verificar transformaciones
SELECT * FROM PIB_LIMPIO;
DESC PIB_LIMPIO;

-- 2.3 Comprobar duplicados
SELECT country_code, anio, COUNT(*) AS cantidad
FROM PIB_LIMPIO
GROUP BY country_code, anio
HAVING COUNT(*) > 1;

-- 2.4 Estadisticas generales
SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT country_code) AS total_paises,
    MIN(anio) AS primer_anio,
    MAX(anio) AS ultimo_anio,
    ROUND(AVG(pib_per_capita_usd), 2) AS promedio_pib,
    MIN(pib_per_capita_usd) AS pib_minimo,
    MAX(pib_per_capita_usd) AS pib_maximo
FROM PIB_LIMPIO;

-- ETAPA 3: CARGA
-- ==========================================

-- 3.1 Crear tabla definitiva
DROP TABLE IF EXISTS pib_final;

CREATE TABLE pib_final AS
SELECT
    country_code,
    country_name,
    anio,
    ROUND(AVG(pib_per_capita_usd), 2)
        AS pib_per_capita_usd
FROM PIB_LIMPIO
GROUP BY country_code, country_name, anio;

-- 3.2 Validar resultado
SELECT COUNT(*) FROM pib_final;
SELECT * FROM pib_final;
DESC pib_final;

-- 3.3 Consultas para el analisis

-- PIB promedio por pais
SELECT
    country_name,
    ROUND(AVG(pib_per_capita_usd), 2) AS pib_promedio
FROM pib_final
GROUP BY country_name
ORDER BY pib_promedio DESC;

-- Evolucion del PIB de Ecuador
SELECT anio, pib_per_capita_usd
FROM pib_final
WHERE country_code = 'ECU'
ORDER BY anio;

-- PIB promedio por año
SELECT
    anio,
    ROUND(AVG(pib_per_capita_usd), 2) AS pib_promedio
FROM pib_final
GROUP BY anio
ORDER BY anio;
