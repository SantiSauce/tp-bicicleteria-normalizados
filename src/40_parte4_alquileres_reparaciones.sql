/* ===== Migracion 4: alquileres y reparaciones ===== */

-- Flota de alquiler, con el local donde se alquila cada bicicleta
INSERT INTO NORMALIZADOS.Bicicleta_Alquiler (Nro_Serie, Precio_Hora, Precio_Dia, Estado_Bici_Alquiler, Modelo_Bicicleta_Id, Local_Id)
SELECT DISTINCT m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler,
       m.Bicicleta_Alquiler_Precio_Bici_Alquiler_Hora,
       m.Bicicleta_Alquiler_Precio_Bici_Alquiler_Dia,
       m.Estado_Bici_Alquiler_Estado_Bici_Alquiler,
       mb.Modelo_Bicicleta_Id, l.Local_Id
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
JOIN NORMALIZADOS.Local l ON l.Nombre = m.Local_Nombre_Local
WHERE m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler IS NOT NULL;
GO

-- Repuestos
INSERT INTO NORMALIZADOS.Repuesto (Cod_Repuesto, Descripcion, Compatibilidad, Precio, Categoria_Repuestos_Id)
SELECT DISTINCT m.Repuesto_Cod_Repuesto, m.Repuesto_Desc_Repuesto,
       m.Repuesto_Compatibilidad_Repuesto, m.Repuesto_Precio_Repuesto,
       cr.Categoria_Repuestos_Id
FROM gd_esquema.Maestra m
LEFT JOIN NORMALIZADOS.Categoria_Repuestos cr ON cr.Descripcion = m.Categoria_Repuestos_Categoria_Respuesto
WHERE m.Repuesto_Cod_Repuesto IS NOT NULL;
GO

-- Alquileres: cada uno ocupa una sola fila de la Maestra
INSERT INTO NORMALIZADOS.Alquiler (Nro_Alquiler, Fecha_Inicio, Fecha_Fin_Pactada, Fecha_Devolucion_Real,
                                   Importe_Total, Forma_Pago, Estado_Alquiler,
                                   Cliente_Id, Empleado_Id, Local_Id, Nro_Serie)
SELECT m.Alquiler_Nro_Alquiler, m.Alquiler_Fecha_Inicio_Alquiler,
       m.Alquiler_Fecha_Fin_Pactada_Alquiler, m.Alquiler_Fecha_Devolucion_Real_Alquiler,
       m.Alquiler_Importe_Total_Alquiler, m.Forma_Pago_Forma_Pago, m.Estado_Alquiler_Estado_Alquiler,
       c.Cliente_Id, e.Empleado_Id, l.Local_Id, m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler
FROM gd_esquema.Maestra m
JOIN NORMALIZADOS.Cliente  c ON c.Dni      = m.Cliente_Dni_Cliente
                            AND c.Nombre   = m.Cliente_Nombre_Cliente
                            AND c.Apellido = m.Cliente_Apellido_Cliente
JOIN NORMALIZADOS.Empleado e ON e.Dni    = m.Empleado_Dni_Empleado
JOIN NORMALIZADOS.Local    l ON l.Nombre = m.Local_Nombre_Local
WHERE m.Alquiler_Nro_Alquiler IS NOT NULL;
GO

-- Reparaciones: una fila por numero de reparacion
INSERT INTO NORMALIZADOS.Reparacion (Nro_Reparacion, Bici_Serie, Fecha_Ingreso, Fecha_Entrega_Estimada,
                                     Fecha_Entrega_Real, Diagnostico, Precio_Mano_Obra, Precio_Repuestos,
                                     Precio_Total, Estado_Reparacion,
                                     Cliente_Id, Empleado_Id, Local_Id, Modelo_Bicicleta_Id)
SELECT r.Reparacion_Nro_Reparacion, r.Reparacion_Numero_Serie_Bici_Reparacion,
       r.Reparacion_Fecha_Ingreso_Reparacion, r.Reparacion_Fecha_Entrega_Estimada_Reparacion,
       r.Reparacion_Fecha_Entrega_Real_Reparacion, r.Reparacion_Diagnostico_Reparacion,
       r.Reparacion_Precio_Mano_Obra_Reparacion, r.Reparacion_Precio_Repuestos_Reparacion,
       r.Reparacion_Precio_Total_Reparacion, r.Estado_Reparacion_Estado_Reparacion,
       c.Cliente_Id, e.Empleado_Id, l.Local_Id, mb.Modelo_Bicicleta_Id
FROM (
    SELECT DISTINCT Reparacion_Nro_Reparacion, Reparacion_Numero_Serie_Bici_Reparacion,
           Reparacion_Fecha_Ingreso_Reparacion, Reparacion_Fecha_Entrega_Estimada_Reparacion,
           Reparacion_Fecha_Entrega_Real_Reparacion, Reparacion_Diagnostico_Reparacion,
           Reparacion_Precio_Mano_Obra_Reparacion, Reparacion_Precio_Repuestos_Reparacion,
           Reparacion_Precio_Total_Reparacion, Estado_Reparacion_Estado_Reparacion,
           Cliente_Dni_Cliente, Cliente_Nombre_Cliente, Cliente_Apellido_Cliente,
           Empleado_Dni_Empleado, Local_Nombre_Local,
           Modelo_Bicicleta_Modelo_Bicicleta, Modelo_Bicicleta_Rodado_Modelo_Bicicleta,
           Modelo_Bicicleta_Cuadro_Modelo_Bicicleta, Modelo_Bicicleta_Color_Modelo_Bicicleta,
           Categoria_Bicicleta_Categoria_Bicicleta, Marca_Marca
    FROM gd_esquema.Maestra
    WHERE Reparacion_Nro_Reparacion IS NOT NULL
) r
JOIN NORMALIZADOS.Cliente  c ON c.Dni      = r.Cliente_Dni_Cliente
                            AND c.Nombre   = r.Cliente_Nombre_Cliente
                            AND c.Apellido = r.Cliente_Apellido_Cliente
JOIN NORMALIZADOS.Empleado e ON e.Dni    = r.Empleado_Dni_Empleado
JOIN NORMALIZADOS.Local    l ON l.Nombre = r.Local_Nombre_Local
JOIN NORMALIZADOS.Modelo_Bicicleta mb
    ON mb.Modelo = r.Modelo_Bicicleta_Modelo_Bicicleta
   AND mb.Rodado = r.Modelo_Bicicleta_Rodado_Modelo_Bicicleta
   AND mb.Cuadro = r.Modelo_Bicicleta_Cuadro_Modelo_Bicicleta
   AND mb.Color  = r.Modelo_Bicicleta_Color_Modelo_Bicicleta
JOIN NORMALIZADOS.Categoria_Bicicleta cb
    ON cb.Categoria_Bicicleta_Id = mb.Categoria_Bicicleta_Id
   AND cb.Descripcion            = r.Categoria_Bicicleta_Categoria_Bicicleta
JOIN NORMALIZADOS.Marca ma
    ON ma.Marca_Id    = mb.Marca_Id
   AND ma.Descripcion = r.Marca_Marca;
GO

-- Repuestos usados en cada reparacion: todas las filas, sin DISTINCT
INSERT INTO NORMALIZADOS.Detalle_Reparacion (Nro_Reparacion, Cod_Repuesto, Cantidad, Precio_Unitario, Subtotal)
SELECT m.Reparacion_Nro_Reparacion, m.Repuesto_Cod_Repuesto,
       m.Detalle_Reparacion_Cantidad_Repuesto, m.Detalle_Reparacion_Precio_Unitario_Repuesto,
       m.Detalle_Reparacion_Subtotal_Repuesto
FROM gd_esquema.Maestra m
WHERE m.Reparacion_Nro_Reparacion IS NOT NULL;
GO
