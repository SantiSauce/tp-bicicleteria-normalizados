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


-- TODO Parte 3: escribir acá los INSERT (o SP + EXEC) en el orden de arriba.

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