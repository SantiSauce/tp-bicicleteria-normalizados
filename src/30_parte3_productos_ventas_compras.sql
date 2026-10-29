/* ===== Migracion 3: productos, ventas y compras ===== */

-- Productos de ventas y compras
INSERT INTO NORMALIZADOS.Producto (Cod_Producto, Nombre, Descripcion, Precio_Venta, Tipo_Producto_Id)
SELECT DISTINCT m.Producto_Cod_Producto, m.Producto_Nombre_Producto, m.Producto_Descripcion_Producto,
       m.Producto_Precio_Venta_Producto, tp.Tipo_Producto_Id
FROM gd_esquema.Maestra m
JOIN NORMALIZADOS.Tipo_Producto tp ON tp.Descripcion = m.Tipo_Producto_Tipo_Producto
WHERE m.Producto_Cod_Producto IS NOT NULL;
GO

-- Bicicletas en venta, con su modelo
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

-- Accesorios
INSERT INTO NORMALIZADOS.Accesorio (Cod_Producto, Talle, Color, Categoria_Accesorios_Id, Marca_Id)
SELECT DISTINCT m.Producto_Cod_Producto, m.Accesorio_Talle_Accesorio, m.Accesorio_Color_Accesorio,
       ca.Categoria_Accesorios_Id, ma.Marca_Id
FROM gd_esquema.Maestra m
LEFT JOIN NORMALIZADOS.Categoria_Accesorios ca ON ca.Descripcion = m.Categoria_Accesorios_Categoria_Accesorio
LEFT JOIN NORMALIZADOS.Marca                 ma ON ma.Descripcion = m.Marca_Marca
WHERE m.Producto_Cod_Producto IS NOT NULL
  AND m.Tipo_Producto_Tipo_Producto = 'Accesorio';
GO

-- Ventas: una fila por numero de venta (la Maestra repite la cabecera en cada renglon)
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

-- Renglones de venta: todas las filas, sin DISTINCT, porque hay renglones con el mismo producto que no son duplicados
INSERT INTO NORMALIZADOS.Detalle_Venta (Nro_Venta, Cod_Producto, Cantidad, Precio_Unitario, Subtotal)
SELECT m.Venta_Nro_Venta, m.Producto_Cod_Producto,
       m.Detalle_Venta_Cantidad_Prod_Venta, m.Detalle_Venta_Precio_Unitario_Prod_Venta,
       m.Detalle_Venta_Subtotal_Prod_Venta
FROM gd_esquema.Maestra m
WHERE m.Venta_Nro_Venta IS NOT NULL;
GO

-- Compras: una fila por numero de compra
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

-- Renglones de compra
INSERT INTO NORMALIZADOS.Detalle_Compra (Nro_Compra, Cod_Producto, Cantidad, Precio_Unitario)
SELECT m.Compra_Nro_Compra, m.Producto_Cod_Producto,
       m.Detalle_Compra_Cantidad_Prod_Compra, m.Detalle_Compra_Precio_Unitario_Prod_Compra
FROM gd_esquema.Maestra m
WHERE m.Compra_Nro_Compra IS NOT NULL;
GO
