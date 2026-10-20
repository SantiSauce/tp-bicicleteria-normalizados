-- Verificaciones para las correcciones del DER (v2) — correr sobre la base restaurada del TP

-- 1) ¿Cada bicicleta de alquiler aparece en un solo local?
--    Si devuelve 0 filas, la flota de cada local está bien separada en los datos.
SELECT Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler AS nro_serie,
       COUNT(DISTINCT Local_Nombre_Local)         AS locales_distintos
FROM gd_esquema.Maestra
WHERE Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler IS NOT NULL
GROUP BY Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler
HAVING COUNT(DISTINCT Local_Nombre_Local) > 1;

-- 2) Cantidad de bicicletas por local (para el doc de estrategia)
SELECT Local_Nombre_Local, COUNT(DISTINCT Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler) AS bicis
FROM gd_esquema.Maestra
WHERE Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler IS NOT NULL
GROUP BY Local_Nombre_Local;

-- 3) ¿Hay localidades con el mismo nombre en provincias distintas?
WITH loc AS (
  SELECT Cliente_Localidad  AS localidad, Cliente_Provincia  AS provincia FROM gd_esquema.Maestra
  UNION SELECT Empleado_Localidad,  Empleado_Provincia  FROM gd_esquema.Maestra
  UNION SELECT Local_Localidad,     Local_Provincia     FROM gd_esquema.Maestra
  UNION SELECT Proveedor_Localidad, Proveedor_Provincia FROM gd_esquema.Maestra
)
SELECT localidad, COUNT(DISTINCT provincia) AS provincias
FROM loc WHERE localidad IS NOT NULL
GROUP BY localidad HAVING COUNT(DISTINCT provincia) > 1;

-- 4) Totales que tendrían las nuevas tablas
WITH loc AS (
  SELECT Cliente_Localidad  AS localidad, Cliente_Provincia  AS provincia FROM gd_esquema.Maestra
  UNION SELECT Empleado_Localidad,  Empleado_Provincia  FROM gd_esquema.Maestra
  UNION SELECT Local_Localidad,     Local_Provincia     FROM gd_esquema.Maestra
  UNION SELECT Proveedor_Localidad, Proveedor_Provincia FROM gd_esquema.Maestra
)
SELECT COUNT(DISTINCT provincia) AS provincias,
       COUNT(*)                  AS localidades
FROM loc WHERE localidad IS NOT NULL;
