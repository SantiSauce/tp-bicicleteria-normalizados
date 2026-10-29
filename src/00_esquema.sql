-- Base de datos del TP
USE GD2C_2026;
GO

-- Si el esquema ya existe (pruebas anteriores) se borra con todos sus objetos
IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'NORMALIZADOS')
BEGIN
    -- Acumula las sentencias de borrado
    DECLARE @sql NVARCHAR(MAX) = N'';
    -- Primero las FK, para poder borrar las tablas en cualquier orden
    SELECT @sql += N'ALTER TABLE NORMALIZADOS.' + QUOTENAME(OBJECT_NAME(fk.parent_object_id))
                 + N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(10)
    FROM sys.foreign_keys fk
    WHERE fk.schema_id = SCHEMA_ID('NORMALIZADOS');
    -- Vistas, procedimientos, triggers y funciones del esquema
    SELECT @sql += N'DROP ' + CASE o.type WHEN 'V' THEN N'VIEW' WHEN 'P' THEN N'PROCEDURE'
                                          WHEN 'TR' THEN N'TRIGGER' ELSE N'FUNCTION' END
                 + N' NORMALIZADOS.' + QUOTENAME(o.name) + N';' + CHAR(10)
    FROM sys.objects o
    WHERE o.schema_id = SCHEMA_ID('NORMALIZADOS')
      AND o.type IN ('V', 'P', 'TR', 'FN', 'IF', 'TF');
    -- Tablas del esquema
    SELECT @sql += N'DROP TABLE NORMALIZADOS.' + QUOTENAME(t.name) + N';' + CHAR(10)
    FROM sys.tables t
    WHERE t.schema_id = SCHEMA_ID('NORMALIZADOS');
    -- Ejecuta todo lo acumulado
    EXEC sp_executesql @sql;
    -- Por ultimo, el esquema vacio
    EXEC (N'DROP SCHEMA NORMALIZADOS');
END
GO

-- Esquema del grupo
EXEC (N'CREATE SCHEMA NORMALIZADOS');
GO
