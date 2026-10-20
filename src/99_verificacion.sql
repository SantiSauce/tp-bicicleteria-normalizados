/* =====================================================================
   99 - Verificación (NO va en la entrega: armar-script.ps1 lo excluye)
   Conteos esperados según el análisis de la Maestra.
   ===================================================================== */
SELECT 'Provincia' AS tabla, COUNT(*) AS filas, 24 AS esperado FROM NORMALIZADOS.Provincia
UNION ALL SELECT 'Localidad', COUNT(*), 480 FROM NORMALIZADOS.Localidad
UNION ALL SELECT 'Local', COUNT(*), 5 FROM NORMALIZADOS.Local
UNION ALL SELECT 'Empleado', COUNT(*), 25 FROM NORMALIZADOS.Empleado
UNION ALL SELECT 'Proveedor', COUNT(*), 5 FROM NORMALIZADOS.Proveedor
UNION ALL SELECT 'Producto', COUNT(*), 18 FROM NORMALIZADOS.Producto
UNION ALL SELECT 'Repuesto', COUNT(*), 10 FROM NORMALIZADOS.Repuesto
UNION ALL SELECT 'Bicicleta_Alquiler', COUNT(*), 80 FROM NORMALIZADOS.Bicicleta_Alquiler
UNION ALL SELECT 'Venta', COUNT(*), 43500 FROM NORMALIZADOS.Venta
UNION ALL SELECT 'Compra', COUNT(*), 36 FROM NORMALIZADOS.Compra
UNION ALL SELECT 'Alquiler', COUNT(*), 69620 FROM NORMALIZADOS.Alquiler
UNION ALL SELECT 'Reparacion', COUNT(*), 34493 FROM NORMALIZADOS.Reparacion
UNION ALL SELECT 'Detalle_Venta', COUNT(*), 152418 FROM NORMALIZADOS.Detalle_Venta
UNION ALL SELECT 'Detalle_Compra', COUNT(*), 648 FROM NORMALIZADOS.Detalle_Compra
UNION ALL SELECT 'Detalle_Reparacion', COUNT(*), 69213 FROM NORMALIZADOS.Detalle_Reparacion;
