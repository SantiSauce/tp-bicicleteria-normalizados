/* =====================================================================
   00 - Base y esquema
   TP FRBA Gestión de Bicicletería - K3521 - Grupo 1 NORMALIZADOS
   ===================================================================== */

-- Trabajamos sobre la base que entrega la cátedra (nombre por defecto al restaurar el .bak).
USE GD2C_2026;
GO

-- Si el esquema ya existe (corridas de prueba), borramos todos sus objetos para poder
-- re-ejecutar el script completo. En la base limpia de la cátedra este bloque no hace nada.
IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'NORMALIZADOS')
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'';

    -- 1) Claves foráneas (primero, para poder borrar las tablas en cualquier orden)
    SELECT @sql += N'ALTER TABLE NORMALIZADOS.' + QUOTENAME(OBJECT_NAME(fk.parent_object_id))
                 + N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(10)
    FROM sys.foreign_keys fk
    WHERE fk.schema_id = SCHEMA_ID('NORMALIZADOS');

    -- 2) Vistas, procedimientos, funciones y triggers de tabla
    SELECT @sql += N'DROP ' + CASE o.type WHEN 'V' THEN N'VIEW' WHEN 'P' THEN N'PROCEDURE'
                                          WHEN 'TR' THEN N'TRIGGER' ELSE N'FUNCTION' END
                 + N' NORMALIZADOS.' + QUOTENAME(o.name) + N';' + CHAR(10)
    FROM sys.objects o
    WHERE o.schema_id = SCHEMA_ID('NORMALIZADOS')
      AND o.type IN ('V', 'P', 'TR', 'FN', 'IF', 'TF');

    -- 3) Tablas
    SELECT @sql += N'DROP TABLE NORMALIZADOS.' + QUOTENAME(t.name) + N';' + CHAR(10)
    FROM sys.tables t
    WHERE t.schema_id = SCHEMA_ID('NORMALIZADOS');

    EXEC sp_executesql @sql;

    -- 4) El esquema
    EXEC (N'DROP SCHEMA NORMALIZADOS');
END
GO

-- Creamos el esquema del grupo: todos los objetos del TP deben pertenecer a él.
EXEC (N'CREATE SCHEMA NORMALIZADOS');
GO
