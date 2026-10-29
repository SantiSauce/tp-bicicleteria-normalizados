/* =====================================================================
   PARTE 3 de 4 - Productos, Ventas y Compras
   Responsable: (completar)
   =====================================================================

   QUÉ HAY QUE HACER
   Cargar el catálogo de productos (con sus dos subtipos) y las dos
   operaciones que los usan: ventas y compras, con cabecera y detalle.

   ORDEN DE CARGA
     1. Producto           (FK a Tipo_Producto)
     2. Bicicleta          (subtipo: PK = FK a Producto; FK a Modelo_Bicicleta)
     3. Accesorio          (subtipo: PK = FK a Producto; FK a Categoria_Accesorios y Marca)
     4. Venta              (FK a Cliente, Empleado, Local)
     5. Detalle_Venta      (FK a Venta y Producto)
     6. Compra             (FK a Proveedor, Empleado, Local)
     7. Detalle_Compra     (FK a Compra y Producto)

   DEPENDE DE:   Parte 1 (catálogos, Local, Proveedor) y Parte 2 (Cliente, Empleado, Modelo)
   El patrón de INSERT...SELECT está explicado en 10_parte1_*.sql.

   ---------------------------------------------------------------------
   DETALLE POR TABLA
   ---------------------------------------------------------------------

   1. PRODUCTO  <- columnas Producto_*   PK natural: Producto_Cod_Producto  (esperado: 18)
      - Aparece tanto en ventas como en compras: cargar desde ambas.
   2. BICICLETA  <- productos cuyo tipo es 'Bicicleta'
      - Meses_Garantia <- Bicicleta_Venta_Meses_Garantia_Bici_Venta
      - Modelo_Bicicleta_Id: JOIN con Modelo_Bicicleta por la misma
        combinación que usó la parte 2 (modelo, rodado, cuadro, color...).
   3. ACCESORIO  <- productos cuyo tipo es 'Accesorio'
      - Talle, Color (Accesorio_*), categoría y marca por JOIN.
      - Un producto es bicicleta O accesorio, nunca los dos.

   4. VENTA  <- una fila por Venta_Nro_Venta (PK natural)              (esperado: 43.500)
      - La Maestra repite la cabecera en cada renglón: hay que quedarse con
        una sola fila por número de venta.
      - Cliente_Id: buscar por DNI + Nombre + Apellido (criterio de la parte 2).
      - Empleado_Id por DNI; Local_Id por nombre del local.
      - Forma_Pago tiene CHECK: los valores de la Maestra ya coinciden.
   5. DETALLE_VENTA  <- un renglón por cada fila de venta               (esperado: ~152.418)
      - Cantidad, Precio_Unitario y Subtotal: columnas Detalle_Venta_*.
      - Si da distinto, revisar si hay renglones repetidos.

   6. COMPRA  <- una fila por Compra_Nro_Compra                         (esperado: 36)
      - Proveedor_Id por CUIT.
   7. DETALLE_COMPRA  <- un renglón por cada fila de compra             (esperado: 648)
      - No tiene subtotal (no viene en la Maestra).

   PERFORMANCE: la Maestra tiene ~292 mil filas y todo el script tiene que
   correr en menos de 10 minutos. Evitar cursores y subconsultas fila a fila:
   hacer JOINs de conjunto.

   CHECKLIST ANTES DE HACER EL PULL REQUEST
   [ ] correr-script.ps1 da OK, sin errores ni warnings, y en tiempo razonable
   [ ] conteos de 99_verificacion.sql de estas tablas coinciden
   [ ] SUM(Subtotal) de cada venta coincide con su Total (o explicar por qué no)
   [ ] cada INSERT tiene su comentario explicando la intención
   ===================================================================== */


/* ---------------------------------------------------------------------
   VERIFICACIONES PREVIAS SOBRE LA MAESTRA (respaldan los criterios de abajo)
   ---------------------------------------------------------------------
   - Los 18 Producto_Cod_Producto tienen Nombre, Descripcion, Precio_Venta y
     Tipo_Producto uniformes en todas sus filas: un DISTINCT alcanza y no
     hace falta elegir "la última" versión del precio.
   - Son 8 productos de tipo 'Bicicleta' y 10 de tipo 'Accesorio'; ninguno
     aparece con los dos tipos, así que los subtipos no se solapan.
   - Las columnas de cada subtipo vienen cargadas según el tipo y NO según
     la operación: un accesorio trae Talle/Color/Categoria/Marca tanto en
     las filas de venta como en las de compra (y NULL en las de bicicleta),
     y viceversa. Por eso el DISTINCT de cada subtipo da exactamente 8 y 10
     filas, sin duplicados por NULL.
   - Cada producto 'Bicicleta' corresponde a una única combinación de modelo
     (Modelo + Rodado + Cuadro + Color + Categoria + Marca).
   - La cabecera de venta y la de compra son uniformes para todas las filas
     de un mismo Nro_Venta / Nro_Compra.
   - Ningún (Dni, Nombre, Apellido) de cliente tiene variantes en el resto de
     sus datos, así que el JOIN con Cliente devuelve una sola fila por venta.
   - Las filas de venta y de compra nunca traen NULL en producto, cliente,
     empleado ni local: todos los JOIN pueden ser INNER sin perder filas.

   PUNTO DEL CHECKLIST: Total de la venta vs. suma de subtotales
   En 274 de las 43.500 ventas (0,6 %) el Venta_Total_Venta de la Maestra no
   coincide con la suma de los subtotales de sus renglones. El desvío viene
   del origen: los subtotales ya están redondeados a 2 decimales fila por fila
   (ej. 4 x 72.206,83 = 288.827,32 pero la Maestra guarda 288.827,33), y en las
   ventas con varios renglones ese redondeo se acumula y pasa el centavo.
   Criterio: se migran los dos valores tal como vienen, sin recalcular el Total,
   para no alterar los datos del origen. Está documentado en la Estrategia.
   --------------------------------------------------------------------- */


-- PRODUCTO: el catálogo general, una fila por código de producto.
-- El mismo producto aparece repetido en miles de filas (una por renglón de
-- venta o de compra), por eso el DISTINCT. Se carga desde ambas operaciones
-- a la vez para no perder productos que solo se hayan comprado o solo vendido.
-- El Tipo_Producto_Id se resuelve por descripción contra el catálogo de la parte 1.
INSERT INTO NORMALIZADOS.Producto (Cod_Producto, Nombre, Descripcion, Precio_Venta, Tipo_Producto_Id)
SELECT DISTINCT m.Producto_Cod_Producto, m.Producto_Nombre_Producto, m.Producto_Descripcion_Producto,
       m.Producto_Precio_Venta_Producto, tp.Tipo_Producto_Id
FROM gd_esquema.Maestra m
JOIN NORMALIZADOS.Tipo_Producto tp ON tp.Descripcion = m.Tipo_Producto_Tipo_Producto
WHERE m.Producto_Cod_Producto IS NOT NULL;
GO

-- BICICLETA: subtipo 1:1 de Producto, solo los productos de tipo 'Bicicleta'.
-- Comparte la PK con Producto (no hay Id propio). El Modelo_Bicicleta_Id se
-- busca por la combinación completa que usó la parte 2 para dar de alta los
-- modelos: los 4 atributos de texto del modelo más su categoría y su marca.
-- La categoría y la marca se comparan a través de sus catálogos para no
-- depender de Ids: así el criterio queda explícito y es el mismo en la parte 4.
INSERT INTO NORMALIZADOS.Bicicleta (Cod_Producto, Meses_Garantia, Modelo_Bicicleta_Id)
SELECT DISTINCT m.Producto_Cod_Producto, m.Bicicleta_Venta_Meses_Garantia_Bici_Venta, mb.Modelo_Bicicleta_Id
FROM gd_esquema.Maestra m
JOIN NORMALIZADOS.Modelo_Bicicleta mb
    ON mb.Modelo = m.Modelo_Bicicleta_Modelo_Bicicleta
   AND mb.Rodado = m.Modelo_Bicicleta_Rodado_Modelo_Bicicleta
   AND mb.Cuadro = m.Modelo_Bicicleta_Cuadro_Modelo_Bicicleta
   AND mb.Color  = m.Modelo_Bicicleta_Color_Modelo_Bicicleta
JOIN NORMALIZADOS.Categoria_Bicicleta cb
    ON cb.Categoria_Bicicleta_Id = mb.Categoria_Bicicleta_Id
   AND cb.Descripcion            = m.Categoria_Bicicleta_Categoria_Bicicleta
JOIN NORMALIZADOS.Marca ma
    ON ma.Marca_Id    = mb.Marca_Id
   AND ma.Descripcion = m.Marca_Marca
WHERE m.Producto_Cod_Producto IS NOT NULL
  AND m.Tipo_Producto_Tipo_Producto = 'Bicicleta';
GO

-- ACCESORIO: subtipo 1:1 de Producto, solo los productos de tipo 'Accesorio'.
-- Talle y Color son los atributos propios del accesorio. Categoría y marca se
-- resuelven por descripción contra los catálogos de la parte 1 (LEFT JOIN
-- porque ambas columnas son nullable en el modelo: si faltara el dato, el
-- accesorio se carga igual en vez de perderse).
INSERT INTO NORMALIZADOS.Accesorio (Cod_Producto, Talle, Color, Categoria_Accesorios_Id, Marca_Id)
SELECT DISTINCT m.Producto_Cod_Producto, m.Accesorio_Talle_Accesorio, m.Accesorio_Color_Accesorio,
       ca.Categoria_Accesorios_Id, ma.Marca_Id
FROM gd_esquema.Maestra m
LEFT JOIN NORMALIZADOS.Categoria_Accesorios ca ON ca.Descripcion = m.Categoria_Accesorios_Categoria_Accesorio
LEFT JOIN NORMALIZADOS.Marca                 ma ON ma.Descripcion = m.Marca_Marca
WHERE m.Producto_Cod_Producto IS NOT NULL
  AND m.Tipo_Producto_Tipo_Producto = 'Accesorio';
GO

-- VENTA: una fila por número de venta (cabecera).
-- La Maestra repite los datos de cabecera en cada renglón de la venta, así
-- que primero nos quedamos con una sola fila por venta (subconsulta con
-- DISTINCT) y después buscamos los Ids de las tablas ya migradas:
--   Cliente  -> por DNI + Nombre + Apellido (criterio de la parte 2)
--   Empleado -> por DNI (único)
--   Local    -> por nombre (único)
INSERT INTO NORMALIZADOS.Venta (Nro_Venta, Fecha_Hora, Total, Forma_Pago, Cliente_Id, Empleado_Id, Local_Id)
SELECT v.Venta_Nro_Venta, v.Venta_Fecha_Hora_Venta, v.Venta_Total_Venta, v.Forma_Pago_Forma_Pago,
       c.Cliente_Id, e.Empleado_Id, l.Local_Id
FROM (
    SELECT DISTINCT Venta_Nro_Venta, Venta_Fecha_Hora_Venta, Venta_Total_Venta, Forma_Pago_Forma_Pago,
           Cliente_Dni_Cliente, Cliente_Nombre_Cliente, Cliente_Apellido_Cliente,
           Empleado_Dni_Empleado, Local_Nombre_Local
    FROM gd_esquema.Maestra
    WHERE Venta_Nro_Venta IS NOT NULL
) v
JOIN NORMALIZADOS.Cliente  c ON c.Dni = v.Cliente_Dni_Cliente
                            AND c.Nombre = v.Cliente_Nombre_Cliente
                            AND c.Apellido = v.Cliente_Apellido_Cliente
JOIN NORMALIZADOS.Empleado e ON e.Dni = v.Empleado_Dni_Empleado
JOIN NORMALIZADOS.Local    l ON l.Nombre = v.Local_Nombre_Local;
GO

-- DETALLE_VENTA: un renglón por cada fila de venta de la Maestra.
-- Acá NO va DISTINCT: cada fila de la Maestra es un renglón real de la venta.
-- Hay 8.364 filas en las que un mismo producto se repite dentro de la misma
-- venta pero con cantidades distintas (son renglones separados del ticket, no
-- duplicados del origen), así que deduplicar perdería ventas de mercadería.
-- El Detalle_Venta_Id es IDENTITY, por eso los renglones repetidos no chocan.
INSERT INTO NORMALIZADOS.Detalle_Venta (Nro_Venta, Cod_Producto, Cantidad, Precio_Unitario, Subtotal)
SELECT m.Venta_Nro_Venta, m.Producto_Cod_Producto,
       m.Detalle_Venta_Cantidad_Prod_Venta, m.Detalle_Venta_Precio_Unitario_Prod_Venta,
       m.Detalle_Venta_Subtotal_Prod_Venta
FROM gd_esquema.Maestra m
WHERE m.Venta_Nro_Venta IS NOT NULL;
GO

-- COMPRA: una fila por número de compra (cabecera), mismo patrón que Venta.
-- La compra no tiene forma de pago (en la Maestra viene siempre en NULL para
-- estas filas, por eso la columna no existe en la tabla). Ids resueltos por
-- clave natural: Proveedor por CUIT, Empleado por DNI y Local por nombre.
INSERT INTO NORMALIZADOS.Compra (Nro_Compra, Fecha_Compra, Total_Compra, Proveedor_Id, Empleado_Id, Local_Id)
SELECT c.Compra_Nro_Compra, c.Compra_Fecha_Compra, c.Compra_Total_Compra,
       pr.Proveedor_Id, e.Empleado_Id, l.Local_Id
FROM (
    SELECT DISTINCT Compra_Nro_Compra, Compra_Fecha_Compra, Compra_Total_Compra,
           Proveedor_Cuit_Proveedor, Empleado_Dni_Empleado, Local_Nombre_Local
    FROM gd_esquema.Maestra
    WHERE Compra_Nro_Compra IS NOT NULL
) c
JOIN NORMALIZADOS.Proveedor pr ON pr.Cuit   = c.Proveedor_Cuit_Proveedor
JOIN NORMALIZADOS.Empleado  e  ON e.Dni     = c.Empleado_Dni_Empleado
JOIN NORMALIZADOS.Local     l  ON l.Nombre  = c.Local_Nombre_Local;
GO

-- DETALLE_COMPRA: un renglón por cada fila de compra de la Maestra.
-- Igual que en las ventas, sin DISTINCT (cada fila es un renglón). Acá además
-- ningún producto se repite dentro de una misma compra. No se carga subtotal
-- porque la Maestra no lo trae: se calcula como Cantidad * Precio_Unitario.
INSERT INTO NORMALIZADOS.Detalle_Compra (Nro_Compra, Cod_Producto, Cantidad, Precio_Unitario)
SELECT m.Compra_Nro_Compra, m.Producto_Cod_Producto,
       m.Detalle_Compra_Cantidad_Prod_Compra, m.Detalle_Compra_Precio_Unitario_Prod_Compra
FROM gd_esquema.Maestra m
WHERE m.Compra_Nro_Compra IS NOT NULL;
GO