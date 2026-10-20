/* =====================================================================
   02 - Índices
   Las PK y UNIQUE ya crean índice. Acá agregamos índices sobre las FK
   que más se usan en joins (detalles y operaciones por local/cliente).
   Ajustar cuando estén las consultas de BI.
   ===================================================================== */

-- Renglones de una venta (join cabecera-detalle).
CREATE NONCLUSTERED INDEX IX_Detalle_Venta_Nro_Venta ON NORMALIZADOS.Detalle_Venta (Nro_Venta);
GO
-- Renglones de una compra.
CREATE NONCLUSTERED INDEX IX_Detalle_Compra_Nro_Compra ON NORMALIZADOS.Detalle_Compra (Nro_Compra);
GO
-- Repuestos de una reparación.
CREATE NONCLUSTERED INDEX IX_Detalle_Reparacion_Nro_Reparacion ON NORMALIZADOS.Detalle_Reparacion (Nro_Reparacion);
GO
-- Operaciones por local (consultas de BI por sucursal).
CREATE NONCLUSTERED INDEX IX_Venta_Local ON NORMALIZADOS.Venta (Local_Id);
GO
CREATE NONCLUSTERED INDEX IX_Alquiler_Local ON NORMALIZADOS.Alquiler (Local_Id);
GO
CREATE NONCLUSTERED INDEX IX_Reparacion_Local ON NORMALIZADOS.Reparacion (Local_Id);
GO
-- Historial de alquileres de una bicicleta.
CREATE NONCLUSTERED INDEX IX_Alquiler_Nro_Serie ON NORMALIZADOS.Alquiler (Nro_Serie);
GO
-- Búsqueda de cliente durante la migración (criterio DNI + nombre + apellido).
CREATE NONCLUSTERED INDEX IX_Cliente_Dni ON NORMALIZADOS.Cliente (Dni, Nombre, Apellido);
GO
