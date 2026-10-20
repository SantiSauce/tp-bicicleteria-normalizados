/* =====================================================================
   CONSULTAS DE RESPALDO — Decisiones de diseño del DER
   TP Gestión de Bicicletería — Base de Datos K3521

   Cómo usar: abrir este archivo en SSMS conectado a BICICLETERIA_TP,
   y ejecutar cada bloque por separado (seleccionar el bloque y F5)
   para mostrarle al equipo el dato real que respalda cada decisión.
   Cada bloque indica a qué sección de Estrategia.docx corresponde.
   ===================================================================== */

USE GD2C_2026;
GO

/* ---------------------------------------------------------------------
   0. Panorama general: tamaño de la tabla y separación por operación
   (Estrategia 2.1) — confirma que cada fila es una única operación
   (Venta, Alquiler, Reparación o Compra) y da el volumen de cada una.
   --------------------------------------------------------------------- */
SELECT
    COUNT(*) AS Total_Filas,
    SUM(CASE WHEN Venta_Nro_Venta IS NOT NULL THEN 1 ELSE 0 END) AS Filas_Venta,
    SUM(CASE WHEN Alquiler_Nro_Alquiler IS NOT NULL THEN 1 ELSE 0 END) AS Filas_Alquiler,
    SUM(CASE WHEN Reparacion_Nro_Reparacion IS NOT NULL THEN 1 ELSE 0 END) AS Filas_Reparacion,
    SUM(CASE WHEN Compra_Nro_Compra IS NOT NULL THEN 1 ELSE 0 END) AS Filas_Compra
FROM [gd_esquema].[Maestra];
GO

/* ---------------------------------------------------------------------
   1. CLIENTE — por qué Cliente_Id es surrogate y no el DNI
   (Estrategia 3.1) — cuenta cuántos DNIs distintos tienen más de un
   Nombre+Apellido asociado: son personas distintas que comparten
   número de documento en los datos de origen (126 casos).
   --------------------------------------------------------------------- */
SELECT COUNT(*) AS DNIs_Compartidos_Por_Personas_Distintas
FROM (
    SELECT Cliente_Dni_Cliente
    FROM [gd_esquema].[Maestra]
    WHERE Cliente_Dni_Cliente IS NOT NULL
    GROUP BY Cliente_Dni_Cliente
    HAVING COUNT(DISTINCT Cliente_Nombre_Cliente + '|' + Cliente_Apellido_Cliente) > 1
) t;
GO

-- Detalle de 5 casos concretos para mostrar en la reunión
SELECT DISTINCT TOP 5
    m.Cliente_Dni_Cliente, m.Cliente_Nombre_Cliente, m.Cliente_Apellido_Cliente,
    m.Cliente_Email_Cliente, m.Cliente_Fecha_Nacimiento_Cliente
FROM [gd_esquema].[Maestra] m
JOIN (
    SELECT Cliente_Dni_Cliente
    FROM [gd_esquema].[Maestra]
    WHERE Cliente_Dni_Cliente IS NOT NULL
    GROUP BY Cliente_Dni_Cliente
    HAVING COUNT(DISTINCT Cliente_Nombre_Cliente + '|' + Cliente_Apellido_Cliente) > 1
) d ON d.Cliente_Dni_Cliente = m.Cliente_Dni_Cliente
ORDER BY m.Cliente_Dni_Cliente;
GO

/* ---------------------------------------------------------------------
   2. EMPLEADO — Dni sí es confiable como identificador único
   (Estrategia 3.3) — a diferencia de Cliente, esto debería dar 0 filas.
   --------------------------------------------------------------------- */
SELECT Empleado_Dni_Empleado, COUNT(DISTINCT Empleado_Nombre_Empleado + '|' + Empleado_Apellido_Empleado) AS Combinaciones
FROM [gd_esquema].[Maestra]
WHERE Empleado_Dni_Empleado IS NOT NULL
GROUP BY Empleado_Dni_Empleado
HAVING COUNT(DISTINCT Empleado_Nombre_Empleado + '|' + Empleado_Apellido_Empleado) > 1;
GO

/* ---------------------------------------------------------------------
   3. EMPLEADO-LOCAL — la regla "un empleado, un local" no se respeta
   en los datos históricos (Estrategia 3.3, el hallazgo más discutible
   del modelo). Muestra que los 25 empleados aparecen en los 5 locales.
   --------------------------------------------------------------------- */
SELECT
    Empleado_Dni_Empleado, Empleado_Nombre_Empleado, Empleado_Apellido_Empleado,
    COUNT(DISTINCT Local_Nombre_Local) AS Cant_Locales_Distintos
FROM [gd_esquema].[Maestra]
WHERE Empleado_Dni_Empleado IS NOT NULL
GROUP BY Empleado_Dni_Empleado, Empleado_Nombre_Empleado, Empleado_Apellido_Empleado
ORDER BY Cant_Locales_Distintos DESC;
GO

-- Detalle: cada empleado con el listado completo de locales a los que aparece asociado
-- (STRING_AGG no admite DISTINCT en SQL Server, por eso se dedupe antes con una subquery)
SELECT
    Empleado_Dni_Empleado, Empleado_Nombre_Empleado, Empleado_Apellido_Empleado,
    STRING_AGG(Local_Nombre_Local, ', ') WITHIN GROUP (ORDER BY Local_Nombre_Local) AS Locales
FROM (
    SELECT DISTINCT Empleado_Dni_Empleado, Empleado_Nombre_Empleado, Empleado_Apellido_Empleado, Local_Nombre_Local
    FROM [gd_esquema].[Maestra]
    WHERE Empleado_Dni_Empleado IS NOT NULL AND Local_Nombre_Local IS NOT NULL
) t
GROUP BY Empleado_Dni_Empleado, Empleado_Nombre_Empleado, Empleado_Apellido_Empleado
ORDER BY Empleado_Apellido_Empleado;
GO

/* ---------------------------------------------------------------------
   4. PROVEEDOR — Cuit sí identifica de forma única a cada proveedor
   (Estrategia 3.4) — debería dar 0 filas (a diferencia de Cliente).
   --------------------------------------------------------------------- */
SELECT Proveedor_Cuit_Proveedor, COUNT(DISTINCT Proveedor_Razon_Social_Proveedor) AS Razones_Sociales_Distintas
FROM [gd_esquema].[Maestra]
WHERE Proveedor_Cuit_Proveedor IS NOT NULL
GROUP BY Proveedor_Cuit_Proveedor
HAVING COUNT(DISTINCT Proveedor_Razon_Social_Proveedor) > 1;
GO

/* ---------------------------------------------------------------------
   5a. CATÁLOGOS ABIERTOS — por qué Marca / Categoria_Bicicleta /
   Tipo_Producto quedaron como tabla catálogo propia (Estrategia 3.5):
   son dominios no enumerados por el enunciado, con más valores
   distintos relevados de los que se esperaba como mínimo.
   --------------------------------------------------------------------- */
SELECT 'Marca' AS Campo, COUNT(DISTINCT Marca_Marca) AS Valores_Distintos FROM [gd_esquema].[Maestra] WHERE Marca_Marca IS NOT NULL
UNION ALL
SELECT 'Categoria_Bicicleta', COUNT(DISTINCT Categoria_Bicicleta_Categoria_Bicicleta) FROM [gd_esquema].[Maestra] WHERE Categoria_Bicicleta_Categoria_Bicicleta IS NOT NULL
UNION ALL
SELECT 'Categoria_Repuestos', COUNT(DISTINCT Categoria_Repuestos_Categoria_Respuesto) FROM [gd_esquema].[Maestra] WHERE Categoria_Repuestos_Categoria_Respuesto IS NOT NULL
UNION ALL
SELECT 'Tipo_Producto', COUNT(DISTINCT Tipo_Producto_Tipo_Producto) FROM [gd_esquema].[Maestra] WHERE Tipo_Producto_Tipo_Producto IS NOT NULL;
GO

/* ---------------------------------------------------------------------
   5b. VALORES FIJOS — por qué Forma_Pago / Estado_Reparacion /
   Estado_Alquiler / Estado_Bici_Alquiler pasaron a CHECK y NO son
   tabla (Estrategia 3.5): son listas cerradas de 2 a 4 valores,
   explícitamente enumeradas por el enunciado. Se listan los valores
   reales encontrados y su frecuencia.
   --------------------------------------------------------------------- */
SELECT 'Forma_Pago' AS Campo, Forma_Pago_Forma_Pago AS Valor, COUNT(*) AS Cantidad
FROM [gd_esquema].[Maestra] WHERE Forma_Pago_Forma_Pago IS NOT NULL
GROUP BY Forma_Pago_Forma_Pago
UNION ALL
SELECT 'Estado_Reparacion', Estado_Reparacion_Estado_Reparacion, COUNT(*)
FROM [gd_esquema].[Maestra] WHERE Estado_Reparacion_Estado_Reparacion IS NOT NULL
GROUP BY Estado_Reparacion_Estado_Reparacion
UNION ALL
SELECT 'Estado_Alquiler', Estado_Alquiler_Estado_Alquiler, COUNT(*)
FROM [gd_esquema].[Maestra] WHERE Estado_Alquiler_Estado_Alquiler IS NOT NULL
GROUP BY Estado_Alquiler_Estado_Alquiler
UNION ALL
SELECT 'Estado_Bici_Alquiler', Estado_Bici_Alquiler_Estado_Bici_Alquiler, COUNT(*)
FROM [gd_esquema].[Maestra] WHERE Estado_Bici_Alquiler_Estado_Bici_Alquiler IS NOT NULL
GROUP BY Estado_Bici_Alquiler_Estado_Bici_Alquiler
ORDER BY Campo, Cantidad DESC;
GO

/* ---------------------------------------------------------------------
   6. REPARACIÓN — Bici_Serie no es una entidad reutilizable
   (Estrategia 3.12) — se verifica que el número de serie que aparece
   en las reparaciones nunca se repite entre reparaciones ni clientes,
   por eso se modela como texto simple y no como FK a Bicicleta_Alquiler.
   --------------------------------------------------------------------- */
SELECT COUNT(*) AS Total_Series_En_Reparacion,
       COUNT(DISTINCT Reparacion_Numero_Serie_Bici_Reparacion) AS Series_Distintas
FROM [gd_esquema].[Maestra]
WHERE Reparacion_Nro_Reparacion IS NOT NULL
  AND Reparacion_Numero_Serie_Bici_Reparacion IS NOT NULL;
GO

-- Confirmación: ningún Numero_Serie de Reparación se repite en más de una reparación
SELECT Reparacion_Numero_Serie_Bici_Reparacion, COUNT(DISTINCT Reparacion_Nro_Reparacion) AS Reparaciones
FROM [gd_esquema].[Maestra]
WHERE Reparacion_Numero_Serie_Bici_Reparacion IS NOT NULL
GROUP BY Reparacion_Numero_Serie_Bici_Reparacion
HAVING COUNT(DISTINCT Reparacion_Nro_Reparacion) > 1;
GO

/* ---------------------------------------------------------------------
   7. CONTEOS GENERALES — volumen de cada entidad candidata, para
   mostrar de un vistazo el tamaño real de cada tabla del modelo.
   --------------------------------------------------------------------- */
SELECT 'Locales distintos' AS Metrica, COUNT(DISTINCT Local_Nombre_Local) AS Valor FROM [gd_esquema].[Maestra]
UNION ALL SELECT 'Clientes distintos (por DNI, sobreestimado)', COUNT(DISTINCT Cliente_Dni_Cliente) FROM [gd_esquema].[Maestra]
UNION ALL SELECT 'Empleados distintos (por DNI)', COUNT(DISTINCT Empleado_Dni_Empleado) FROM [gd_esquema].[Maestra]
UNION ALL SELECT 'Proveedores distintos (por CUIT)', COUNT(DISTINCT Proveedor_Cuit_Proveedor) FROM [gd_esquema].[Maestra]
UNION ALL SELECT 'Productos distintos (por Cod_Producto)', COUNT(DISTINCT Producto_Cod_Producto) FROM [gd_esquema].[Maestra]
UNION ALL SELECT 'Repuestos distintos (por Cod_Repuesto)', COUNT(DISTINCT Repuesto_Cod_Repuesto) FROM [gd_esquema].[Maestra]
UNION ALL SELECT 'Bicis de alquiler distintas (por Nro_Serie)', COUNT(DISTINCT Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler) FROM [gd_esquema].[Maestra];
GO
