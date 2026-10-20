/* =====================================================================
   99 - Verificación (NO va en la entrega: armar-script.ps1 lo excluye)
   Conteos esperados según el análisis de la Maestra. correr-script.ps1
   lo ejecuta al final. "?" = no hay un número cerrado, revisar a mano.
   ===================================================================== */
SET NOCOUNT ON;
SELECT parte, tabla, filas, esperado,
       CASE WHEN esperado IS NULL THEN '?' WHEN filas = esperado THEN 'OK' ELSE 'REVISAR' END AS estado
FROM (
          SELECT 1 AS parte, 'Provincia' AS tabla, COUNT(*) AS filas, 24 AS esperado FROM NORMALIZADOS.Provincia
UNION ALL SELECT 1, 'Localidad',            COUNT(*), 480    FROM NORMALIZADOS.Localidad
UNION ALL SELECT 1, 'Tipo_Producto',        COUNT(*), 2      FROM NORMALIZADOS.Tipo_Producto
UNION ALL SELECT 1, 'Categoria_Bicicleta',  COUNT(*), 6      FROM NORMALIZADOS.Categoria_Bicicleta
UNION ALL SELECT 1, 'Categoria_Accesorios', COUNT(*), 4      FROM NORMALIZADOS.Categoria_Accesorios
UNION ALL SELECT 1, 'Categoria_Repuestos',  COUNT(*), 4      FROM NORMALIZADOS.Categoria_Repuestos
UNION ALL SELECT 1, 'Marca',                COUNT(*), 7      FROM NORMALIZADOS.Marca
UNION ALL SELECT 1, 'Local',                COUNT(*), 5      FROM NORMALIZADOS.Local
UNION ALL SELECT 1, 'Proveedor',            COUNT(*), 5      FROM NORMALIZADOS.Proveedor
UNION ALL SELECT 2, 'Cliente',              COUNT(*), NULL   FROM NORMALIZADOS.Cliente
UNION ALL SELECT 2, 'Empleado',             COUNT(*), 25     FROM NORMALIZADOS.Empleado
UNION ALL SELECT 2, 'Modelo_Bicicleta',     COUNT(*), NULL   FROM NORMALIZADOS.Modelo_Bicicleta
UNION ALL SELECT 3, 'Producto',             COUNT(*), 18     FROM NORMALIZADOS.Producto
UNION ALL SELECT 3, 'Bicicleta',            COUNT(*), NULL   FROM NORMALIZADOS.Bicicleta
UNION ALL SELECT 3, 'Accesorio',            COUNT(*), NULL   FROM NORMALIZADOS.Accesorio
UNION ALL SELECT 3, 'Venta',                COUNT(*), 43500  FROM NORMALIZADOS.Venta
UNION ALL SELECT 3, 'Detalle_Venta',        COUNT(*), 152418 FROM NORMALIZADOS.Detalle_Venta
UNION ALL SELECT 3, 'Compra',               COUNT(*), 36     FROM NORMALIZADOS.Compra
UNION ALL SELECT 3, 'Detalle_Compra',       COUNT(*), 648    FROM NORMALIZADOS.Detalle_Compra
UNION ALL SELECT 4, 'Bicicleta_Alquiler',   COUNT(*), 80     FROM NORMALIZADOS.Bicicleta_Alquiler
UNION ALL SELECT 4, 'Repuesto',             COUNT(*), 10     FROM NORMALIZADOS.Repuesto
UNION ALL SELECT 4, 'Alquiler',             COUNT(*), 69620  FROM NORMALIZADOS.Alquiler
UNION ALL SELECT 4, 'Reparacion',           COUNT(*), 34493  FROM NORMALIZADOS.Reparacion
UNION ALL SELECT 4, 'Detalle_Reparacion',   COUNT(*), 69213  FROM NORMALIZADOS.Detalle_Reparacion
) v
ORDER BY parte, tabla;
