/* =====================================================================
   PARTE 1 de 4 - Ubicación, catálogos, Local y Proveedor
   Responsable: (completar)
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

