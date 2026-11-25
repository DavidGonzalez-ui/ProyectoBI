
-- ETAPA 1: EXTRACCION
-- ==========================================

-- 1.1 Habilitar importacion local
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
 
use proyectoin;

LOAD DATA LOCAL INFILE "C:\\Users\\Smart\\OneDrive\\Desktop\\datos_fuente\\inflacion_largo.csv"
INTO TABLE inflacion_origen
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

-- 1.3 Explorar los datos
SELECT COUNT(*) FROM inflacion_origen;
SELECT * FROM inflacion_origen;
DESC inflacion_origen;

-- ETAPA 2: TRANSFORMACION
-- ==========================================

-- 2.1 Limpiar y convertir los datos
CREATE OR REPLACE VIEW INFLACION_LIMPIA AS
SELECT
    UPPER(TRIM(country_code)) AS country_code,
    TRIM(country_name) AS country_name,
    CAST(TRIM(anio) AS UNSIGNED) AS anio,
    CAST(TRIM(inflacion_anual_pct)
         AS DECIMAL(18,2)) AS inflacion_anual_pct,
    CASE
        WHEN CAST(TRIM(inflacion_anual_pct)
                  AS DECIMAL(18,2)) > 100 THEN 1
        ELSE 0
    END AS inflacion_extrema
FROM inflacion_origen
WHERE NULLIF(TRIM(country_code), '') IS NOT NULL
  AND NULLIF(TRIM(anio), '') IS NOT NULL
  AND NULLIF(TRIM(inflacion_anual_pct), '') IS NOT NULL
  AND TRIM(anio) REGEXP '^[0-9]{4}$'
  AND TRIM(inflacion_anual_pct)
      REGEXP '^-?[0-9]+([.][0-9]+)?$';

-- 2.2 Verificar transformaciones
SELECT * FROM INFLACION_LIMPIA;
DESC INFLACION_LIMPIA;

-- 2.3 Buscar duplicados
SELECT country_code, anio, COUNT(*) AS cantidad
FROM INFLACION_LIMPIA
GROUP BY country_code, anio
HAVING COUNT(*) > 1;

-- 2.4 Estadisticas generales
SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT country_code) AS total_paises,
    MIN(anio) AS primer_anio,
    MAX(anio) AS ultimo_anio,
    ROUND(AVG(inflacion_anual_pct), 2) AS inflacion_promedio,
    MIN(inflacion_anual_pct) AS inflacion_minima,
    MAX(inflacion_anual_pct) AS inflacion_maxima,
    SUM(inflacion_extrema) AS casos_extremos
FROM INFLACION_LIMPIA;

-- ETAPA 3: CARGA
-- ==========================================

-- 3.1 Crear tabla definitiva
DROP TABLE IF EXISTS inflacion_final;

CREATE TABLE inflacion_final AS
SELECT
    country_code,
    country_name,
    anio,
    ROUND(AVG(inflacion_anual_pct), 2)
        AS inflacion_anual_pct,
    MAX(inflacion_extrema) AS inflacion_extrema
FROM INFLACION_LIMPIA
GROUP BY country_code, country_name, anio;

-- 3.2 Validar resultado
SELECT COUNT(*) FROM inflacion_final;
SELECT * FROM inflacion_final;
DESC inflacion_final;

-- 3.3 Consultas para el analisis

-- Inflacion promedio por pais
SELECT
    country_name,
    ROUND(AVG(inflacion_anual_pct), 2)
        AS inflacion_promedio
FROM inflacion_final
GROUP BY country_name
ORDER BY inflacion_promedio DESC;

-- Casos de inflacion extrema
SELECT *
FROM inflacion_final
WHERE inflacion_extrema = 1
ORDER BY inflacion_anual_pct DESC;

-- Evolucion de la inflacion en Ecuador
SELECT anio, inflacion_anual_pct
FROM inflacion_final
WHERE country_code = 'ECU'
ORDER BY anio;

-- Inflacion promedio por año
SELECT
    anio,
    ROUND(AVG(inflacion_anual_pct), 2)
        AS inflacion_promedio
FROM inflacion_final
GROUP BY anio
ORDER BY anio;
