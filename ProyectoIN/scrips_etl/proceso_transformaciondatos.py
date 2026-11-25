"""
ETL Banco Mundial (WDI): PIB per capita e inflacion.
Uso: deja este archivo en la misma carpeta que los dos .xls y ejecutalo:
    python etl_world_bank.py
Genera dos Excel nuevos (solo hoja "Data", formato largo) en esa misma carpeta.
Requisitos: pip install pandas xlrd openpyxl
"""
import re
import unicodedata
from pathlib import Path

import pandas as pd
from openpyxl.styles import Font
from openpyxl.utils import get_column_letter

# Carpeta donde estan los .xls (la del script; si se usa en notebook, la actual)
CARPETA = Path("C://Users//Smart//OneDrive//Desktop//datos_fuente")

ARCHIVOS = [
    (
        "API_NY.GDP.PCAP.CD_DS2_en_excel_v2_61181.xls",
        "pib_per_capita_usd",
        "pib_per_capita_largo.csv"
    ),
    (
        "API_FP.CPI.TOTL.ZG_DS2_en_excel_v2_60922.xls",
        "inflacion_anual_pct",
        "inflacion_largo.csv"
    ),
]

UMBRAL_INFLACION_EXTREMA = 100  # % anual

# Agregados regionales/de ingreso que no son paises + "Not classified" (INX)
AGREGADOS = {
    "AFE", "AFW", "ARB", "CEB", "CSS", "EAP", "EAR", "EAS", "ECA", "ECS", "EMU", "EUU",
    "FCV", "HIC", "HPC", "IBD", "IBT", "IDA", "IDB", "IDX", "LAC", "LCN", "LDC", "LIC",
    "LMC", "LMY", "LTE", "MEA", "MIC", "MNA", "NAC", "OED", "OSS", "PRE", "PSS", "PST",
    "SAS", "SSA", "SSF", "SST", "TEA", "TEC", "TLA", "TMN", "TSA", "TSS", "UMC", "WLD",
    "INX",
}


def limpiar_texto(texto):
    """Sin tildes ni simbolos, con barras bajas. Ej: "Korea, Rep." -> "Korea_Rep"."""
    if pd.isna(texto):
        return texto
    t = unicodedata.normalize("NFKD", str(texto))
    t = "".join(c for c in t if not unicodedata.combining(c))
    t = t.replace("&", " and ").replace("'", "").replace("’", "")
    return re.sub(r"[^A-Za-z0-9]+", "_", t).strip("_")


def procesar(archivo, col_valor, salida):
    # EXTRACCION: hoja Data, omitiendo las filas informativas (encabezado en la fila 4)
    df = pd.read_excel(CARPETA / archivo, sheet_name="Data", header=3)
    df.columns = [str(int(c)) if isinstance(c, (int, float)) else str(c) for c in df.columns]
    n_inicial = len(df)

    # TRANSFORMACION
    df["Country Code"] = df["Country Code"].astype(str).str.strip().str.upper()
    df = df[~df["Country Code"].isin(AGREGADOS)]                      # solo paises
    anios = [c for c in df.columns if c.isdigit()]
    largo = df.melt(id_vars=["Country Code", "Country Name"], value_vars=anios,
                    var_name="anio", value_name=col_valor)            # ancho -> largo
    largo = largo.rename(columns={"Country Code": "country_code", "Country Name": "country_name"})
    largo["country_name"] = largo["country_name"].map(limpiar_texto)
    largo["anio"] = largo["anio"].astype(int)
    largo[col_valor] = pd.to_numeric(largo[col_valor], errors="coerce").round(2)
    largo = largo.dropna(subset=[col_valor]).drop_duplicates(["country_code", "anio"])
    if col_valor == "inflacion_anual_pct":                             # marcar extremos
        largo["inflacion_extrema"] = (largo[col_valor] > UMBRAL_INFLACION_EXTREMA).astype(int)
    largo = largo.sort_values(["country_code", "anio"]).reset_index(drop=True)

    # VALIDACION
    print(f"{archivo}: {n_inicial} registros -> {largo['country_code'].nunique()} paises, "
          f"{len(largo)} filas ({largo['anio'].min()}-{largo['anio'].max()}), "
          f"duplicados: {largo.duplicated(['country_code', 'anio']).sum()}")

    # CARGA: Generar archivo CSV para MySQL
    largo.to_csv(
        CARPETA / salida,
        index=False,
        sep=",",
        encoding="utf-8",
        lineterminator="\n"
    )

    print(f"  -> CSV generado: {CARPETA / salida}")


if __name__ == "__main__" or "__file__" not in globals():
    for archivo, col, salida in ARCHIVOS:
        procesar(archivo, col, salida)