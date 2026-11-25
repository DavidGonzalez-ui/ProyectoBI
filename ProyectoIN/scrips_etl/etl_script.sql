DROP SCHEMA IF EXISTS proyectoIN;

CREATE SCHEMA IF NOT EXISTS proyectoIN;
USE proyectoIN;

CREATE TABLE IF NOT EXISTS inflacion_origen (
    country_code VARCHAR(20),
    country_name VARCHAR(150),
    anio VARCHAR(10),
    inflacion_anual_pct VARCHAR(50),
    inflacion_extrema VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS pib_origen (
    country_code VARCHAR(20),
    country_name VARCHAR(150),
    anio VARCHAR(10),
    pib_per_capita_usd VARCHAR(50)
);
