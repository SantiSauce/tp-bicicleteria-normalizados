/* ===== Indices ===== */

-- Indice para unir ventas con sus renglones
CREATE NONCLUSTERED INDEX IX_Detalle_Venta_Nro_Venta ON NORMALIZADOS.Detalle_Venta (Nro_Venta);
GO

-- Indice para unir compras con sus renglones
CREATE NONCLUSTERED INDEX IX_Detalle_Compra_Nro_Compra ON NORMALIZADOS.Detalle_Compra (Nro_Compra);
GO

-- Indice para unir reparaciones con sus repuestos
CREATE NONCLUSTERED INDEX IX_Detalle_Reparacion_Nro_Reparacion ON NORMALIZADOS.Detalle_Reparacion (Nro_Reparacion);
GO

-- Indice para consultar ventas por local
CREATE NONCLUSTERED INDEX IX_Venta_Local ON NORMALIZADOS.Venta (Local_Id);
GO

-- Indice para consultar alquileres por local
CREATE NONCLUSTERED INDEX IX_Alquiler_Local ON NORMALIZADOS.Alquiler (Local_Id);
GO

-- Indice para consultar reparaciones por local
CREATE NONCLUSTERED INDEX IX_Reparacion_Local ON NORMALIZADOS.Reparacion (Local_Id);
GO

-- Indice para buscar los alquileres de una bicicleta
CREATE NONCLUSTERED INDEX IX_Alquiler_Nro_Serie ON NORMALIZADOS.Alquiler (Nro_Serie);
GO

-- Indice para buscar clientes por DNI, nombre y apellido
CREATE NONCLUSTERED INDEX IX_Cliente_Dni ON NORMALIZADOS.Cliente (Dni, Nombre, Apellido);
GO
