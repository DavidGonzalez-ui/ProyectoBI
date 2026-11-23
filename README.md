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
 
---

## Diagnóstico de calidad de los datos

Se revisó la hoja `Data` de ambos archivos comparando su formato, su clave de acceso y la estandarización de los datos. En general las dos fuentes están bien construidas y son consistentes entre sí, pero presentan algunos problemas que deben tratarse antes de integrarlas.

### Formato

Los dos archivos provienen del mismo portal y tienen exactamente la misma estructura: 266 registros y 70 columnas, de las cuales cuatro son descriptivas (`Country Name`, `Country Code`, `Indicator Name` e `Indicator Code`) y 66 corresponden a los años de 1960 a 2025. El primer problema es que la tabla de datos no empieza en la primera fila de la hoja, ya que las tres primeras filas contienen información de la fuente y la fecha de actualización, por lo que el encabezado real está en la fila 4 y hay que omitir esas filas al importar. Además, los datos están en formato ancho (un año por columna), lo que dificulta consultar y relacionar la información, y los años son números en el encabezado y no texto, algo que debe cuidarse al cargarlos a una base de datos. Por último, las columnas `Indicator Name` e `Indicator Code` tienen el mismo valor en todas las filas de cada archivo, por lo que no aportan información por registro.

### Clave de acceso

La columna `Country Code` identifica a cada país o agregado con un código de tres letras. En ambos archivos no tiene valores vacíos ni repetidos, y los 266 códigos son exactamente los mismos en las dos fuentes, sin registros que existan en una y no en la otra. Los nombres (`Country Name`) también coinciden en todos los casos, aunque el código es más confiable porque el nombre puede variar. No se encontraron espacios sobrantes al inicio o al final de los textos de estas columnas.

El problema de esta clave es que no solo identifica países, sino también agregados regionales y de ingreso (por ejemplo "World" o "Euro area") e incluso un registro llamado "Not classified". Estos registros comparten estructura con los países y pueden distorsionar cualquier comparación entre países si no se separan.

### Valores faltantes

Ambos archivos tienen valores vacíos, pero en distinta proporción. La falta de datos se concentra en los años más antiguos y en ciertos territorios, ya que 4 registros del PIB y 25 de la inflación no tienen ningún dato en todo el periodo (como Cuba, Puerto Rico o Gibraltar, entre otros). Como las dos fuentes no tienen los mismos vacíos, al integrarlas habrá años en que un país tendrá un indicador pero no el otro.

### Estandarización

Los dos indicadores están en unidades y escalas distintas: el PIB per cápita está en dólares y llega a más de 288 mil, mientras que la inflación es un porcentaje que va desde valores negativos hasta más de 23 mil. Los valores numéricos tienen muchos decimales (hasta 15 cifras) que conviene redondear. En la inflación aparecen 568 valores negativos, que corresponden a deflación y son válidos, y 167 valores superiores al 100 %, con un máximo de 23.773 %, que corresponden a episodios de hiperinflación y deben revisarse porque pueden distorsionar promedios y comparaciones.

En cuanto a los textos, los nombres están en inglés y algunos usan abreviaturas o formatos poco uniformes, como "Korea, Dem. People's Rep.", "Somalia, Fed. Rep." o "Puerto Rico (US)", que además incluyen comas y apóstrofes que pueden causar problemas al cargarlos a una base de datos. No se detectaron registros duplicados en ninguno de los dos archivos.

### Resumen de problemas a tratar

- Filas informativas antes del encabezado real.
- Datos en formato ancho, con los años como columnas.
- Valores faltantes distintos en cada fuente, con mayor impacto en la inflación.
- Mezcla de países con agregados regionales y un registro "Not classified".
- Escalas y unidades distintas entre los dos indicadores.
- Valores extremos de inflación y exceso de decimales.
- Nombres con abreviaturas y caracteres especiales.


