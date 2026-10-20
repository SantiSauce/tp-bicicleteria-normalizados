/* =====================================================================
   PARTE 1 de 4 - Ubicación, catálogos, Local y Proveedor
   Responsable: Santi
   =====================================================================

   QUÉ HAY QUE HACER
   Cargar las tablas "de base" que todas las demás partes necesitan.
   Por eso esta parte conviene terminarla PRIMERO: es la más corta y
   sin ella no se puede probar nada de lo que viene después.

   ORDEN DE CARGA (respetarlo por las FK)
     1. Provincia
     2. Localidad                  (FK a Provincia)
     3. Tipo_Producto
     4. Categoria_Bicicleta
     5. Categoria_Accesorios
     6. Categoria_Repuestos
     7. Marca
     8. Local                      (FK a Localidad)
     9. Proveedor                  (FK a Localidad)

   DEPENDE DE:   nada (solo de las tablas creadas en 01_tablas.sql)
   LA USAN:      partes 2, 3 y 4

   ---------------------------------------------------------------------
   CÓMO ARMAR CADA INSERT (patrón general para TODAS las partes)
   ---------------------------------------------------------------------
   -- <Comentario: qué carga y con qué criterio>    <- obligatorio (cátedra)
   INSERT INTO NORMALIZADOS.<Tabla> (<columnas sin la PK IDENTITY>)
   SELECT DISTINCT <columnas de la Maestra>
   FROM gd_esquema.Maestra m
   [JOIN NORMALIZADOS.<TablaPadre> p ON p.<clave natural> = m.<columna>]  -- para traer el Id de la FK
   WHERE m.<columna clave> IS NOT NULL;            -- cada fila es UNA operación: el resto viene en NULL
   GO

   - Las PK "_Id" son IDENTITY: no se insertan, las genera SQL Server.
   - Para llenar una FK se hace JOIN contra la tabla ya cargada usando la
     clave natural (nombre, descripción, CUIT, etc.), nunca hardcodeando Ids.
   - Siempre filtrar los NULL: una fila de compra trae NULL en todo lo de venta.
   - Se puede escribir como INSERT...SELECT sueltos o como stored procedures
     dentro del esquema NORMALIZADOS (00_esquema.sql los borra al re-correr).

   ---------------------------------------------------------------------
   DETALLE POR TABLA
   ---------------------------------------------------------------------

   1-2. PROVINCIA y LOCALIDAD
        Las localidades/provincias aparecen en 4 entidades de la Maestra:
          Cliente_Localidad   / Cliente_Provincia
          Empleado_Localidad  / Empleado_Provincia
          Local_Localidad     / Local_Provincia
          Proveedor_Localidad / Proveedor_Provincia
        Hay que juntar las 4 (UNION) antes de cargar.
        OJO: el mismo nombre de localidad aparece en TODAS las provincias
        (ej. "Ciudad Rosa" está en las 24). Una localidad = par (nombre, provincia).
        Esperado: 24 provincias, 480 localidades.

   3. TIPO_PRODUCTO          <- Tipo_Producto_Tipo_Producto               (esperado: 2)
   4. CATEGORIA_BICICLETA    <- Categoria_Bicicleta_Categoria_Bicicleta   (esperado: 6)
   5. CATEGORIA_ACCESORIOS   <- Categoria_Accesorios_Categoria_Accesorio  (esperado: 4)
   6. CATEGORIA_REPUESTOS    <- Categoria_Repuestos_Categoria_Respuesto   (esperado: 4)
                                (sí, la columna de la Maestra dice "Respuesto")
   7. MARCA                  <- Marca_Marca                               (esperado: 7)
        La usan tanto los modelos de bicicleta como los accesorios.

   8. LOCAL     <- columnas Local_*   (Nombre es único)                   (esperado: 5)
        Localidad_Id: JOIN con Localidad + Provincia por nombre.
   9. PROVEEDOR <- columnas Proveedor_*  (Cuit es único)                  (esperado: 5)
        Solo vienen en las filas de compra.

   CHECKLIST ANTES DE HACER EL PULL REQUEST
   [ ] correr-script.ps1 da OK, sin errores ni warnings
   [ ] los conteos de 99_verificacion.sql de estas tablas coinciden
   [ ] cada INSERT tiene su comentario explicando la intención
   ===================================================================== */


-- TODO Parte 1: escribir acá los INSERT (o SP + EXEC) en el orden de arriba.


-- PROVINCIA: carga cada provincia una sola vez.
-- Las provincias aparecen en 4 lugares de la Maestra (cliente, empleado,
-- local y proveedor), así que las juntamos con UNION, que además elimina
-- los repetidos. Se descartan los NULL (filas donde esa entidad no aplica).
INSERT INTO NORMALIZADOS.Provincia (Nombre)
SELECT Cliente_Provincia   FROM gd_esquema.Maestra WHERE Cliente_Provincia   IS NOT NULL
UNION
SELECT Empleado_Provincia  FROM gd_esquema.Maestra WHERE Empleado_Provincia  IS NOT NULL
UNION
SELECT Local_Provincia     FROM gd_esquema.Maestra WHERE Local_Provincia     IS NOT NULL
UNION
SELECT Proveedor_Provincia FROM gd_esquema.Maestra WHERE Proveedor_Provincia IS NOT NULL;
GO

-- LOCALIDAD: una fila por cada par (localidad, provincia) distinto.
-- El mismo nombre de localidad se repite en varias provincias, por eso la
-- clave es el par. Juntamos los pares de las 4 entidades con UNION (sin
-- repetidos) y buscamos el Provincia_Id por nombre en la tabla ya cargada.
INSERT INTO NORMALIZADOS.Localidad (Nombre, Provincia_Id)
SELECT u.Localidad, p.Provincia_Id
FROM (
    SELECT Cliente_Localidad   AS Localidad, Cliente_Provincia   AS Provincia FROM gd_esquema.Maestra WHERE Cliente_Localidad   IS NOT NULL
    UNION
    SELECT Empleado_Localidad,  Empleado_Provincia  FROM gd_esquema.Maestra WHERE Empleado_Localidad  IS NOT NULL
    UNION
    SELECT Local_Localidad,     Local_Provincia     FROM gd_esquema.Maestra WHERE Local_Localidad     IS NOT NULL
    UNION
    SELECT Proveedor_Localidad, Proveedor_Provincia FROM gd_esquema.Maestra WHERE Proveedor_Localidad IS NOT NULL
) u
JOIN NORMALIZADOS.Provincia p ON p.Nombre = u.Provincia;
GO

-- TIPO_PRODUCTO: tipos de producto distintos (Bicicleta / Accesorio).
INSERT INTO NORMALIZADOS.Tipo_Producto (Descripcion)
SELECT DISTINCT Tipo_Producto_Tipo_Producto
FROM gd_esquema.Maestra
WHERE Tipo_Producto_Tipo_Producto IS NOT NULL;
GO

-- CATEGORIA_BICICLETA: categorías distintas de los modelos de bicicleta.
INSERT INTO NORMALIZADOS.Categoria_Bicicleta (Descripcion)
SELECT DISTINCT Categoria_Bicicleta_Categoria_Bicicleta
FROM gd_esquema.Maestra
WHERE Categoria_Bicicleta_Categoria_Bicicleta IS NOT NULL;
GO

-- CATEGORIA_ACCESORIOS: categorías distintas de los accesorios.
INSERT INTO NORMALIZADOS.Categoria_Accesorios (Descripcion)
SELECT DISTINCT Categoria_Accesorios_Categoria_Accesorio
FROM gd_esquema.Maestra
WHERE Categoria_Accesorios_Categoria_Accesorio IS NOT NULL;
GO

-- CATEGORIA_REPUESTOS: categorías distintas de los repuestos
-- (la columna de la Maestra se llama "Respuesto", así viene en el origen).
INSERT INTO NORMALIZADOS.Categoria_Repuestos (Descripcion)
SELECT DISTINCT Categoria_Repuestos_Categoria_Respuesto
FROM gd_esquema.Maestra
WHERE Categoria_Repuestos_Categoria_Respuesto IS NOT NULL;
GO

-- MARCA: marcas distintas; la usan tanto los modelos de bicicleta como los accesorios.
INSERT INTO NORMALIZADOS.Marca (Descripcion)
SELECT DISTINCT Marca_Marca
FROM gd_esquema.Maestra
WHERE Marca_Marca IS NOT NULL;
GO

-- LOCAL: un registro por local (el nombre lo identifica). La localidad se
-- resuelve buscando el par (localidad, provincia) en las tablas ya cargadas.
INSERT INTO NORMALIZADOS.Local (Nombre, Telefono, Email, Direccion, Localidad_Id)
SELECT DISTINCT m.Local_Nombre_Local, m.Local_Telefono_Local, m.Local_Email_Local,
       m.Local_Direccion_Local, l.Localidad_Id
FROM gd_esquema.Maestra m
JOIN NORMALIZADOS.Provincia p ON p.Nombre = m.Local_Provincia
JOIN NORMALIZADOS.Localidad l ON l.Nombre = m.Local_Localidad AND l.Provincia_Id = p.Provincia_Id
WHERE m.Local_Nombre_Local IS NOT NULL;
GO

-- PROVEEDOR: un registro por proveedor (el CUIT lo identifica). Solo aparece
-- en las filas de compra. Localidad resuelta igual que en Local.
INSERT INTO NORMALIZADOS.Proveedor (Razon_Social, Cuit, Telefono, Email, Direccion, Localidad_Id)
SELECT DISTINCT m.Proveedor_Razon_Social_Proveedor, m.Proveedor_Cuit_Proveedor, m.Proveedor_Telefono_Proveedor,
       m.Proveedor_Email_Proveedor, m.Proveedor_Direccion_Proveedor, l.Localidad_Id
FROM gd_esquema.Maestra m
JOIN NORMALIZADOS.Provincia p ON p.Nombre = m.Proveedor_Provincia
JOIN NORMALIZADOS.Localidad l ON l.Nombre = m.Proveedor_Localidad AND l.Provincia_Id = p.Provincia_Id
WHERE m.Proveedor_Cuit_Proveedor IS NOT NULL;
GO