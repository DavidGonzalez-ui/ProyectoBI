# ProyectoBI
Integracion de los datos

### Descripción del proyecto

Las organizaciones y las instituciones generan y publican datos que pueden ser utilizados para analizar diferentes situaciones y apoyar la toma de decisiones. Sin embargo, los datos disponibles en distintas fuentes no siempre presentan estructuras, formatos o niveles de calidad compatibles, por lo que es necesario prepararlos e integrarlos antes de utilizarlos.

En este proyecto, cada grupo seleccionará un tema o contexto de interés y trabajará con dos conjuntos de datos procedentes de fuentes públicas y abiertas. A partir de ellos, deberá identificar una necesidad de información, examinar la calidad de los datos, diseñar e implementar un proceso ETL básico y obtener un conjunto de datos integrado y preparado para su posterior análisis.

El propósito es aplicar los conocimientos adquiridos sobre integración, transformación y preparación de datos, utilizando herramientas y técnicas apropiadas para construir una solución básica que pueda servir como punto de partida para una aplicación de Inteligencia de Negocios.

### Objetivo

Implementar un proceso básico de extracción, transformación e integración de datos procedentes de fuentes públicas y abiertas, aplicando operaciones de limpieza, normalización y validación, para obtener un conjunto de datos organizado y preparado para su posterior utilización en una solución de Inteligencia de Negocios.

---

 **Seccion de interes:** Economia

 **Pregunta de analisis:** ¿Los países con mayor PIB per cápita han tenido una inflación más baja y estable que los de menor ingreso?

 **Fuente general de los datos:**  https://www.worldbank.org/ext/en/home

---

## Fuentes de datos

Los dos conjuntos de datos provienen de los **Indicadores de Desarrollo Mundial (World Development Indicators, WDI)** del Banco Mundial, de acceso público y abierto. Se descargaron en formato Excel (`.xls`) y ambos tienen fecha de última actualización del 11 de noviembre de 2026.

En este proyecto se utiliza únicamente la hoja **`Data`** de cada archivo. Las demás hojas del Excel (`Metadata - Countries` y `Metadata - Indicators`) contienen información complementaria que no se usa en el proyecto.

### Fuente 1: PIB per cápita (US$ a precios actuales)

| Característica | Detalle |
|---|---|
| Archivo | `API_NY_GDP_PCAP_CD_DS2_en_excel_v2_61181.xls` |
| Indicador | GDP per capita (current US$) |
| Código del indicador | `NY.GDP.PCAP.CD` |
| Procedencia | Banco Mundial (WDI) |
| Enlace | https://data.worldbank.org/indicator/NY.GDP.PCAP.CD |
| Formato | Excel `.xls` (hoja utilizada: `Data`) |
| Cobertura | 266 registros (países y agregados regionales), de 1960 a 2025 |
| Unidad | Dólares estadounidenses (US$) a precios actuales |

**Contenido:** ingreso promedio por habitante de cada país, calculado como el producto interno bruto dividido entre la población.

### Fuente 2: Inflación, precios al consumidor (% anual)

| Característica | Detalle |
|---|---|
| Archivo | `API_FP_CPI_TOTL_ZG_DS2_en_excel_v2_60922.xls` |
| Indicador | Inflation, consumer prices (annual %) |
| Código del indicador | `FP.CPI.TOTL.ZG` |
| Procedencia | Banco Mundial (WDI), con datos del Fondo Monetario Internacional |
| Enlace | https://data.worldbank.org/indicator/FP.CPI.TOTL.ZG |
| Formato | Excel `.xls` (hoja utilizada: `Data`) |
| Cobertura | 266 registros (países y agregados regionales), de 1960 a 2025 |
| Unidad | Porcentaje de variación anual |

**Contenido:** variación porcentual anual del índice de precios al consumidor, es decir, cuánto subió en promedio el costo de una canasta de bienes y servicios.

## Principales atributos (hoja `Data`)

Ambos archivos tienen la misma estructura. Los primeros registros de la hoja son informativos (fuente y fecha de actualización) y la tabla de datos empieza en la fila 4.

| Atributo | Descripción |
|---|---|
| `Country Name` | Nombre del país o agregado regional |
| `Country Code` | Código de tres letras del país o agregado |
| `Indicator Name` | Nombre del indicador |
| `Indicator Code` | Código del indicador |
| `1960` a `2025` | Valor del indicador en cada año, una columna por año (66 columnas) |
 



