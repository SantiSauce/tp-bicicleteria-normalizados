/* =====================================================================
   script_creacion_inicial.sql
   TP FRBA Gestión de Bicicletería - 2C2026 - K3521 - Grupo 1 NORMALIZADOS
   Creación del modelo transaccional y migración desde gd_esquema.Maestra.
   ARCHIVO GENERADO por herramientas\armar-script.ps1 - no editar a mano,
   editar los archivos de src\ y volver a generar.
   ===================================================================== */

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

/* ===== Tablas ===== */

-- Provincias
CREATE TABLE NORMALIZADOS.Provincia (
    Provincia_Id INT IDENTITY(1,1) NOT NULL,
    Nombre       VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Provincia PRIMARY KEY (Provincia_Id),
    CONSTRAINT UQ_Provincia_Nombre UNIQUE (Nombre)
);
GO

-- Localidades: el nombre se repite entre provincias, por eso es unico el par nombre + provincia
CREATE TABLE NORMALIZADOS.Localidad (
    Localidad_Id INT IDENTITY(1,1) NOT NULL,
    Nombre       VARCHAR(255)      NOT NULL,
    Provincia_Id INT               NOT NULL,
    CONSTRAINT PK_Localidad PRIMARY KEY (Localidad_Id),
    CONSTRAINT UQ_Localidad_Nombre_Provincia UNIQUE (Nombre, Provincia_Id),
    CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (Provincia_Id) REFERENCES NORMALIZADOS.Provincia (Provincia_Id)
);
GO

-- Tipos de producto (bicicleta / accesorio)
CREATE TABLE NORMALIZADOS.Tipo_Producto (
    Tipo_Producto_Id INT IDENTITY(1,1) NOT NULL,
    Descripcion      VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Tipo_Producto PRIMARY KEY (Tipo_Producto_Id),
    CONSTRAINT UQ_Tipo_Producto_Descripcion UNIQUE (Descripcion)
);
GO

-- Categorias de bicicleta
CREATE TABLE NORMALIZADOS.Categoria_Bicicleta (
    Categoria_Bicicleta_Id INT IDENTITY(1,1) NOT NULL,
    Descripcion            VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Categoria_Bicicleta PRIMARY KEY (Categoria_Bicicleta_Id),
    CONSTRAINT UQ_Categoria_Bicicleta_Descripcion UNIQUE (Descripcion)
);
GO

-- Categorias de accesorios
CREATE TABLE NORMALIZADOS.Categoria_Accesorios (
    Categoria_Accesorios_Id INT IDENTITY(1,1) NOT NULL,
    Descripcion             VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Categoria_Accesorios PRIMARY KEY (Categoria_Accesorios_Id),
    CONSTRAINT UQ_Categoria_Accesorios_Descripcion UNIQUE (Descripcion)
);
GO

-- Categorias de repuestos
CREATE TABLE NORMALIZADOS.Categoria_Repuestos (
    Categoria_Repuestos_Id INT IDENTITY(1,1) NOT NULL,
    Descripcion            VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Categoria_Repuestos PRIMARY KEY (Categoria_Repuestos_Id),
    CONSTRAINT UQ_Categoria_Repuestos_Descripcion UNIQUE (Descripcion)
);
GO

-- Marcas (las usan los modelos de bicicleta y los accesorios)
CREATE TABLE NORMALIZADOS.Marca (
    Marca_Id    INT IDENTITY(1,1) NOT NULL,
    Descripcion VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Marca PRIMARY KEY (Marca_Id),
    CONSTRAINT UQ_Marca_Descripcion UNIQUE (Descripcion)
);
GO

-- Locales
CREATE TABLE NORMALIZADOS.Local (
    Local_Id     INT IDENTITY(1,1) NOT NULL,
    Nombre       VARCHAR(255)      NOT NULL,
    Telefono     VARCHAR(255)      NULL,
    Email        VARCHAR(255)      NULL,
    Direccion    VARCHAR(255)      NULL,
    Localidad_Id INT               NULL,
    CONSTRAINT PK_Local PRIMARY KEY (Local_Id),
    CONSTRAINT UQ_Local_Nombre UNIQUE (Nombre),
    CONSTRAINT FK_Local_Localidad FOREIGN KEY (Localidad_Id) REFERENCES NORMALIZADOS.Localidad (Localidad_Id)
);
GO

-- Clientes: el DNI no es unico porque hay documentos repetidos entre personas distintas
CREATE TABLE NORMALIZADOS.Cliente (
    Cliente_Id       INT IDENTITY(1,1) NOT NULL,
    Dni              VARCHAR(255)      NULL,
    Nombre           VARCHAR(255)      NULL,
    Apellido         VARCHAR(255)      NULL,
    Telefono         VARCHAR(255)      NULL,
    Email            VARCHAR(255)      NULL,
    Direccion        VARCHAR(255)      NULL,
    Fecha_Nacimiento DATETIME2(6)      NULL,
    Localidad_Id     INT               NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (Cliente_Id),
    CONSTRAINT FK_Cliente_Localidad FOREIGN KEY (Localidad_Id) REFERENCES NORMALIZADOS.Localidad (Localidad_Id)
);
GO

-- Empleados: cada uno pertenece a un local
CREATE TABLE NORMALIZADOS.Empleado (
    Empleado_Id      INT IDENTITY(1,1) NOT NULL,
    Dni              VARCHAR(255)      NOT NULL,
    Nombre           VARCHAR(255)      NULL,
    Apellido         VARCHAR(255)      NULL,
    Puesto           VARCHAR(255)      NULL,
    Fecha_Ingreso    DATETIME2(6)      NULL,
    Telefono         VARCHAR(255)      NULL,
    Email            VARCHAR(255)      NULL,
    Domicilio        VARCHAR(255)      NULL,
    Fecha_Nacimiento DATETIME2(6)      NULL,
    Localidad_Id     INT               NULL,
    Local_Id         INT               NOT NULL,
    CONSTRAINT PK_Empleado PRIMARY KEY (Empleado_Id),
    CONSTRAINT UQ_Empleado_Dni UNIQUE (Dni),
    CONSTRAINT FK_Empleado_Localidad FOREIGN KEY (Localidad_Id) REFERENCES NORMALIZADOS.Localidad (Localidad_Id),
    CONSTRAINT FK_Empleado_Local FOREIGN KEY (Local_Id) REFERENCES NORMALIZADOS.Local (Local_Id)
);
GO

-- Proveedores
CREATE TABLE NORMALIZADOS.Proveedor (
    Proveedor_Id INT IDENTITY(1,1) NOT NULL,
    Razon_Social VARCHAR(255)      NULL,
    Cuit         VARCHAR(255)      NOT NULL,
    Telefono     VARCHAR(255)      NULL,
    Email        VARCHAR(255)      NULL,
    Direccion    VARCHAR(255)      NULL,
    Localidad_Id INT               NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY (Proveedor_Id),
    CONSTRAINT UQ_Proveedor_Cuit UNIQUE (Cuit),
    CONSTRAINT FK_Proveedor_Localidad FOREIGN KEY (Localidad_Id) REFERENCES NORMALIZADOS.Localidad (Localidad_Id)
);
GO

-- Modelos de bicicleta
CREATE TABLE NORMALIZADOS.Modelo_Bicicleta (
    Modelo_Bicicleta_Id    INT IDENTITY(1,1) NOT NULL,
    Modelo                 VARCHAR(255)      NULL,
    Rodado                 VARCHAR(255)      NULL,
    Cuadro                 VARCHAR(255)      NULL,
    Color                  VARCHAR(255)      NULL,
    Categoria_Bicicleta_Id INT               NULL,
    Marca_Id               INT               NULL,
    CONSTRAINT PK_Modelo_Bicicleta PRIMARY KEY (Modelo_Bicicleta_Id),
    CONSTRAINT FK_Modelo_Bicicleta_Categoria FOREIGN KEY (Categoria_Bicicleta_Id) REFERENCES NORMALIZADOS.Categoria_Bicicleta (Categoria_Bicicleta_Id),
    CONSTRAINT FK_Modelo_Bicicleta_Marca FOREIGN KEY (Marca_Id) REFERENCES NORMALIZADOS.Marca (Marca_Id)
);
GO

-- Productos que se venden y se compran
CREATE TABLE NORMALIZADOS.Producto (
    Cod_Producto     VARCHAR(255)  NOT NULL,
    Nombre           VARCHAR(255)  NULL,
    Descripcion      VARCHAR(255)  NULL,
    Precio_Venta     NUMERIC(38,2) NULL,
    Tipo_Producto_Id INT           NOT NULL,
    CONSTRAINT PK_Producto PRIMARY KEY (Cod_Producto),
    CONSTRAINT FK_Producto_Tipo_Producto FOREIGN KEY (Tipo_Producto_Id) REFERENCES NORMALIZADOS.Tipo_Producto (Tipo_Producto_Id)
);
GO

-- Bicicletas en venta (subtipo de producto, misma PK)
CREATE TABLE NORMALIZADOS.Bicicleta (
    Cod_Producto        VARCHAR(255) NOT NULL,
    Meses_Garantia      INT          NULL,
    Modelo_Bicicleta_Id INT          NOT NULL,
    CONSTRAINT PK_Bicicleta PRIMARY KEY (Cod_Producto),
    CONSTRAINT FK_Bicicleta_Producto FOREIGN KEY (Cod_Producto) REFERENCES NORMALIZADOS.Producto (Cod_Producto),
    CONSTRAINT FK_Bicicleta_Modelo FOREIGN KEY (Modelo_Bicicleta_Id) REFERENCES NORMALIZADOS.Modelo_Bicicleta (Modelo_Bicicleta_Id)
);
GO

-- Accesorios (subtipo de producto, misma PK)
CREATE TABLE NORMALIZADOS.Accesorio (
    Cod_Producto            VARCHAR(255) NOT NULL,
    Talle                   VARCHAR(255) NULL,
    Color                   VARCHAR(255) NULL,
    Categoria_Accesorios_Id INT          NULL,
    Marca_Id                INT          NULL,
    CONSTRAINT PK_Accesorio PRIMARY KEY (Cod_Producto),
    CONSTRAINT FK_Accesorio_Producto FOREIGN KEY (Cod_Producto) REFERENCES NORMALIZADOS.Producto (Cod_Producto),
    CONSTRAINT FK_Accesorio_Categoria FOREIGN KEY (Categoria_Accesorios_Id) REFERENCES NORMALIZADOS.Categoria_Accesorios (Categoria_Accesorios_Id),
    CONSTRAINT FK_Accesorio_Marca FOREIGN KEY (Marca_Id) REFERENCES NORMALIZADOS.Marca (Marca_Id)
);
GO

-- Flota de alquiler: cada bicicleta pertenece a un local
CREATE TABLE NORMALIZADOS.Bicicleta_Alquiler (
    Nro_Serie            VARCHAR(255)  NOT NULL,
    Precio_Hora          NUMERIC(38,2) NULL,
    Precio_Dia           NUMERIC(38,2) NULL,
    Estado_Bici_Alquiler VARCHAR(255)  NULL,
    Modelo_Bicicleta_Id  INT           NOT NULL,
    Local_Id             INT           NOT NULL,
    CONSTRAINT PK_Bicicleta_Alquiler PRIMARY KEY (Nro_Serie),
    CONSTRAINT CK_Bicicleta_Alquiler_Estado CHECK (Estado_Bici_Alquiler IN ('Disponible', 'Alquilada', 'Baja')),
    CONSTRAINT FK_Bicicleta_Alquiler_Modelo FOREIGN KEY (Modelo_Bicicleta_Id) REFERENCES NORMALIZADOS.Modelo_Bicicleta (Modelo_Bicicleta_Id),
    CONSTRAINT FK_Bicicleta_Alquiler_Local FOREIGN KEY (Local_Id) REFERENCES NORMALIZADOS.Local (Local_Id)
);
GO

-- Repuestos (precio de lista)
CREATE TABLE NORMALIZADOS.Repuesto (
    Cod_Repuesto           VARCHAR(255)  NOT NULL,
    Descripcion            VARCHAR(255)  NULL,
    Compatibilidad         VARCHAR(255)  NULL,
    Precio                 NUMERIC(38,2) NULL,
    Categoria_Repuestos_Id INT           NULL,
    CONSTRAINT PK_Repuesto PRIMARY KEY (Cod_Repuesto),
    CONSTRAINT FK_Repuesto_Categoria FOREIGN KEY (Categoria_Repuestos_Id) REFERENCES NORMALIZADOS.Categoria_Repuestos (Categoria_Repuestos_Id)
);
GO

-- Ventas
CREATE TABLE NORMALIZADOS.Venta (
    Nro_Venta   INT           NOT NULL,
    Fecha_Hora  DATETIME2(6)  NULL,
    Total       NUMERIC(38,2) NULL,
    Forma_Pago  VARCHAR(255)  NULL,
    Cliente_Id  INT           NOT NULL,
    Empleado_Id INT           NOT NULL,
    Local_Id    INT           NOT NULL,
    CONSTRAINT PK_Venta PRIMARY KEY (Nro_Venta),
    CONSTRAINT CK_Venta_Forma_Pago CHECK (Forma_Pago IN ('Efectivo', 'Transferencia', 'Tarjeta de credito', 'Tarjeta de debito')),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (Cliente_Id) REFERENCES NORMALIZADOS.Cliente (Cliente_Id),
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (Empleado_Id) REFERENCES NORMALIZADOS.Empleado (Empleado_Id),
    CONSTRAINT FK_Venta_Local FOREIGN KEY (Local_Id) REFERENCES NORMALIZADOS.Local (Local_Id)
);
GO

-- Renglones de cada venta
CREATE TABLE NORMALIZADOS.Detalle_Venta (
    Detalle_Venta_Id INT IDENTITY(1,1) NOT NULL,
    Nro_Venta        INT               NOT NULL,
    Cod_Producto     VARCHAR(255)      NOT NULL,
    Cantidad         INT               NULL,
    Precio_Unitario  NUMERIC(38,2)     NULL,
    Subtotal         NUMERIC(38,2)     NULL,
    CONSTRAINT PK_Detalle_Venta PRIMARY KEY (Detalle_Venta_Id),
    CONSTRAINT FK_Detalle_Venta_Venta FOREIGN KEY (Nro_Venta) REFERENCES NORMALIZADOS.Venta (Nro_Venta),
    CONSTRAINT FK_Detalle_Venta_Producto FOREIGN KEY (Cod_Producto) REFERENCES NORMALIZADOS.Producto (Cod_Producto)
);
GO

-- Compras a proveedores
CREATE TABLE NORMALIZADOS.Compra (
    Nro_Compra   INT           NOT NULL,
    Fecha_Compra DATETIME2(6)  NULL,
    Total_Compra NUMERIC(38,2) NULL,
    Proveedor_Id INT           NOT NULL,
    Empleado_Id  INT           NOT NULL,
    Local_Id     INT           NOT NULL,
    CONSTRAINT PK_Compra PRIMARY KEY (Nro_Compra),
    CONSTRAINT FK_Compra_Proveedor FOREIGN KEY (Proveedor_Id) REFERENCES NORMALIZADOS.Proveedor (Proveedor_Id),
    CONSTRAINT FK_Compra_Empleado FOREIGN KEY (Empleado_Id) REFERENCES NORMALIZADOS.Empleado (Empleado_Id),
    CONSTRAINT FK_Compra_Local FOREIGN KEY (Local_Id) REFERENCES NORMALIZADOS.Local (Local_Id)
);
GO

-- Renglones de cada compra
CREATE TABLE NORMALIZADOS.Detalle_Compra (
    Detalle_Compra_Id INT IDENTITY(1,1) NOT NULL,
    Nro_Compra        INT               NOT NULL,
    Cod_Producto      VARCHAR(255)      NOT NULL,
    Cantidad          INT               NULL,
    Precio_Unitario   NUMERIC(38,2)     NULL,
    CONSTRAINT PK_Detalle_Compra PRIMARY KEY (Detalle_Compra_Id),
    CONSTRAINT FK_Detalle_Compra_Compra FOREIGN KEY (Nro_Compra) REFERENCES NORMALIZADOS.Compra (Nro_Compra),
    CONSTRAINT FK_Detalle_Compra_Producto FOREIGN KEY (Cod_Producto) REFERENCES NORMALIZADOS.Producto (Cod_Producto)
);
GO

-- Alquileres: una bicicleta por alquiler, por eso no hay detalle
CREATE TABLE NORMALIZADOS.Alquiler (
    Nro_Alquiler          INT           NOT NULL,
    Fecha_Inicio          DATETIME2(6)  NULL,
    Fecha_Fin_Pactada     DATETIME2(6)  NULL,
    Fecha_Devolucion_Real DATETIME2(6)  NULL,
    Importe_Total         NUMERIC(38,2) NULL,
    Forma_Pago            VARCHAR(255)  NULL,
    Estado_Alquiler       VARCHAR(255)  NULL,
    Cliente_Id            INT           NOT NULL,
    Empleado_Id           INT           NOT NULL,
    Local_Id              INT           NOT NULL,
    Nro_Serie             VARCHAR(255)  NOT NULL,
    CONSTRAINT PK_Alquiler PRIMARY KEY (Nro_Alquiler),
    CONSTRAINT CK_Alquiler_Forma_Pago CHECK (Forma_Pago IN ('Efectivo', 'Transferencia', 'Tarjeta de credito', 'Tarjeta de debito')),
    CONSTRAINT CK_Alquiler_Estado CHECK (Estado_Alquiler IN ('Reservado', 'En curso', 'Devuelto', 'Vencido')),
    CONSTRAINT FK_Alquiler_Cliente FOREIGN KEY (Cliente_Id) REFERENCES NORMALIZADOS.Cliente (Cliente_Id),
    CONSTRAINT FK_Alquiler_Empleado FOREIGN KEY (Empleado_Id) REFERENCES NORMALIZADOS.Empleado (Empleado_Id),
    CONSTRAINT FK_Alquiler_Local FOREIGN KEY (Local_Id) REFERENCES NORMALIZADOS.Local (Local_Id),
    CONSTRAINT FK_Alquiler_Bicicleta FOREIGN KEY (Nro_Serie) REFERENCES NORMALIZADOS.Bicicleta_Alquiler (Nro_Serie)
);
GO

-- Reparaciones: Bici_Serie es la bici del cliente, sin FK
CREATE TABLE NORMALIZADOS.Reparacion (
    Nro_Reparacion         INT           NOT NULL,
    Bici_Serie             VARCHAR(255)  NULL,
    Fecha_Ingreso          DATETIME2(6)  NULL,
    Fecha_Entrega_Estimada DATETIME2(6)  NULL,
    Fecha_Entrega_Real     DATETIME2(6)  NULL,
    Diagnostico            VARCHAR(255)  NULL,
    Precio_Mano_Obra       NUMERIC(38,2) NULL,
    Precio_Repuestos       NUMERIC(38,2) NULL,
    Precio_Total           NUMERIC(38,2) NULL,
    Estado_Reparacion      VARCHAR(255)  NULL,
    Cliente_Id             INT           NOT NULL,
    Empleado_Id            INT           NOT NULL,
    Local_Id               INT           NOT NULL,
    Modelo_Bicicleta_Id    INT           NULL,
    CONSTRAINT PK_Reparacion PRIMARY KEY (Nro_Reparacion),
    CONSTRAINT CK_Reparacion_Estado CHECK (Estado_Reparacion IN ('Presupuestada', 'En proceso', 'Lista', 'Entregada')),
    CONSTRAINT FK_Reparacion_Cliente FOREIGN KEY (Cliente_Id) REFERENCES NORMALIZADOS.Cliente (Cliente_Id),
    CONSTRAINT FK_Reparacion_Empleado FOREIGN KEY (Empleado_Id) REFERENCES NORMALIZADOS.Empleado (Empleado_Id),
    CONSTRAINT FK_Reparacion_Local FOREIGN KEY (Local_Id) REFERENCES NORMALIZADOS.Local (Local_Id),
    CONSTRAINT FK_Reparacion_Modelo FOREIGN KEY (Modelo_Bicicleta_Id) REFERENCES NORMALIZADOS.Modelo_Bicicleta (Modelo_Bicicleta_Id)
);
GO

-- Repuestos usados en cada reparacion, con el precio cobrado
CREATE TABLE NORMALIZADOS.Detalle_Reparacion (
    Detalle_Reparacion_Id INT IDENTITY(1,1) NOT NULL,
    Nro_Reparacion        INT               NOT NULL,
    Cod_Repuesto          VARCHAR(255)      NOT NULL,
    Cantidad              INT               NULL,
    Precio_Unitario       NUMERIC(38,2)     NULL,
    Subtotal              NUMERIC(38,2)     NULL,
    CONSTRAINT PK_Detalle_Reparacion PRIMARY KEY (Detalle_Reparacion_Id),
    CONSTRAINT FK_Detalle_Reparacion_Reparacion FOREIGN KEY (Nro_Reparacion) REFERENCES NORMALIZADOS.Reparacion (Nro_Reparacion),
    CONSTRAINT FK_Detalle_Reparacion_Repuesto FOREIGN KEY (Cod_Repuesto) REFERENCES NORMALIZADOS.Repuesto (Cod_Repuesto)
);
GO

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

/* ===== Migracion 1: ubicacion, catalogos, locales y proveedores ===== */

-- Provincias de clientes, empleados, locales y proveedores (UNION elimina repetidos)
INSERT INTO NORMALIZADOS.Provincia (Nombre)
SELECT Cliente_Provincia   FROM gd_esquema.Maestra WHERE Cliente_Provincia   IS NOT NULL
UNION
SELECT Empleado_Provincia  FROM gd_esquema.Maestra WHERE Empleado_Provincia  IS NOT NULL
UNION
SELECT Local_Provincia     FROM gd_esquema.Maestra WHERE Local_Provincia     IS NOT NULL
UNION
SELECT Proveedor_Provincia FROM gd_esquema.Maestra WHERE Proveedor_Provincia IS NOT NULL;
GO

-- Localidades: pares localidad-provincia distintos de las cuatro entidades
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

-- Tipos de producto
INSERT INTO NORMALIZADOS.Tipo_Producto (Descripcion)
SELECT DISTINCT Tipo_Producto_Tipo_Producto
FROM gd_esquema.Maestra
WHERE Tipo_Producto_Tipo_Producto IS NOT NULL;
GO

-- Categorias de bicicleta
INSERT INTO NORMALIZADOS.Categoria_Bicicleta (Descripcion)
SELECT DISTINCT Categoria_Bicicleta_Categoria_Bicicleta
FROM gd_esquema.Maestra
WHERE Categoria_Bicicleta_Categoria_Bicicleta IS NOT NULL;
GO

-- Categorias de accesorios
INSERT INTO NORMALIZADOS.Categoria_Accesorios (Descripcion)
SELECT DISTINCT Categoria_Accesorios_Categoria_Accesorio
FROM gd_esquema.Maestra
WHERE Categoria_Accesorios_Categoria_Accesorio IS NOT NULL;
GO

-- Categorias de repuestos
INSERT INTO NORMALIZADOS.Categoria_Repuestos (Descripcion)
SELECT DISTINCT Categoria_Repuestos_Categoria_Respuesto
FROM gd_esquema.Maestra
WHERE Categoria_Repuestos_Categoria_Respuesto IS NOT NULL;
GO

-- Marcas
INSERT INTO NORMALIZADOS.Marca (Descripcion)
SELECT DISTINCT Marca_Marca
FROM gd_esquema.Maestra
WHERE Marca_Marca IS NOT NULL;
GO

-- Locales, con su localidad buscada por localidad + provincia
INSERT INTO NORMALIZADOS.Local (Nombre, Telefono, Email, Direccion, Localidad_Id)
SELECT DISTINCT m.Local_Nombre_Local, m.Local_Telefono_Local, m.Local_Email_Local,
       m.Local_Direccion_Local, l.Localidad_Id
FROM gd_esquema.Maestra m
JOIN NORMALIZADOS.Provincia p ON p.Nombre = m.Local_Provincia
JOIN NORMALIZADOS.Localidad l ON l.Nombre = m.Local_Localidad AND l.Provincia_Id = p.Provincia_Id
WHERE m.Local_Nombre_Local IS NOT NULL;
GO

-- Proveedores (solo aparecen en las compras)
INSERT INTO NORMALIZADOS.Proveedor (Razon_Social, Cuit, Telefono, Email, Direccion, Localidad_Id)
SELECT DISTINCT m.Proveedor_Razon_Social_Proveedor, m.Proveedor_Cuit_Proveedor, m.Proveedor_Telefono_Proveedor,
       m.Proveedor_Email_Proveedor, m.Proveedor_Direccion_Proveedor, l.Localidad_Id
FROM gd_esquema.Maestra m
JOIN NORMALIZADOS.Provincia p ON p.Nombre = m.Proveedor_Provincia
JOIN NORMALIZADOS.Localidad l ON l.Nombre = m.Proveedor_Localidad AND l.Provincia_Id = p.Provincia_Id
WHERE m.Proveedor_Cuit_Proveedor IS NOT NULL;
GO

/* ===== Migracion 2: clientes, empleados y modelos ===== */

-- Clientes: uno por cada DNI + nombre + apellido distinto
INSERT INTO NORMALIZADOS.Cliente
    (Dni, Nombre, Apellido, Telefono, Email, Direccion, Fecha_Nacimiento, Localidad_Id)
SELECT DISTINCT
    m.Cliente_Dni_Cliente,
    m.Cliente_Nombre_Cliente,
    m.Cliente_Apellido_Cliente,
    m.Cliente_Telefono_Cliente,
    m.Cliente_Email_Cliente,
    m.Cliente_Direccion_Cliente,
    m.Cliente_Fecha_Nacimiento_Cliente,
    l.Localidad_Id
FROM gd_esquema.Maestra m
LEFT JOIN NORMALIZADOS.Provincia p
    ON p.Nombre = m.Cliente_Provincia
LEFT JOIN NORMALIZADOS.Localidad l
    ON l.Nombre       = m.Cliente_Localidad
   AND l.Provincia_Id = p.Provincia_Id
WHERE m.Cliente_Dni_Cliente IS NOT NULL;
GO

-- Empleados: a cada uno se le asigna el local donde tiene mas operaciones (si empatan, el primero por nombre)
WITH Empleado_Local AS (
    SELECT
        m.Empleado_Dni_Empleado,
        m.Local_Nombre_Local,
        COUNT(*) AS Operaciones,
        ROW_NUMBER() OVER (
            PARTITION BY m.Empleado_Dni_Empleado
            ORDER BY COUNT(*) DESC, m.Local_Nombre_Local ASC
        ) AS rn
    FROM gd_esquema.Maestra m
    WHERE m.Empleado_Dni_Empleado IS NOT NULL
    GROUP BY m.Empleado_Dni_Empleado, m.Local_Nombre_Local
),
Empleado_Datos AS (
    SELECT DISTINCT
        m.Empleado_Dni_Empleado,
        m.Empleado_Nombre_Empleado,
        m.Empleado_Apellido_Empleado,
        m.Empleado_Puesto_Empleado,
        m.Empleado_Fecha_Ingreso_Empleado,
        m.Empleado_Telefono_Empleado,
        m.Empleado_Email_Empleado,
        m.Empleado_Domicilio_Empleado,
        m.Empleado_Fecha_Nac_Empleado,
        m.Empleado_Localidad,
        m.Empleado_Provincia
    FROM gd_esquema.Maestra m
    WHERE m.Empleado_Dni_Empleado IS NOT NULL
)
INSERT INTO NORMALIZADOS.Empleado
    (Dni, Nombre, Apellido, Puesto, Fecha_Ingreso, Telefono, Email, Domicilio,
     Fecha_Nacimiento, Localidad_Id, Local_Id)
SELECT
    d.Empleado_Dni_Empleado,
    d.Empleado_Nombre_Empleado,
    d.Empleado_Apellido_Empleado,
    d.Empleado_Puesto_Empleado,
    d.Empleado_Fecha_Ingreso_Empleado,
    d.Empleado_Telefono_Empleado,
    d.Empleado_Email_Empleado,
    d.Empleado_Domicilio_Empleado,
    d.Empleado_Fecha_Nac_Empleado,
    l.Localidad_Id,
    lo.Local_Id
FROM Empleado_Datos d
INNER JOIN Empleado_Local el
    ON el.Empleado_Dni_Empleado = d.Empleado_Dni_Empleado
   AND el.rn = 1
INNER JOIN NORMALIZADOS.Local lo
    ON lo.Nombre = el.Local_Nombre_Local
LEFT JOIN NORMALIZADOS.Provincia p
    ON p.Nombre = d.Empleado_Provincia
LEFT JOIN NORMALIZADOS.Localidad l
    ON l.Nombre       = d.Empleado_Localidad
   AND l.Provincia_Id = p.Provincia_Id;
GO

-- Modelos de bicicleta de ventas, alquileres y reparaciones
INSERT INTO NORMALIZADOS.Modelo_Bicicleta
    (Modelo, Rodado, Cuadro, Color, Categoria_Bicicleta_Id, Marca_Id)
SELECT
    u.Modelo,
    u.Rodado,
    u.Cuadro,
    u.Color,
    cb.Categoria_Bicicleta_Id,
    ma.Marca_Id
FROM (
    SELECT
        Modelo_Bicicleta_Modelo_Bicicleta   AS Modelo,
        Modelo_Bicicleta_Rodado_Modelo_Bicicleta AS Rodado,
        Modelo_Bicicleta_Cuadro_Modelo_Bicicleta AS Cuadro,
        Modelo_Bicicleta_Color_Modelo_Bicicleta  AS Color,
        Categoria_Bicicleta_Categoria_Bicicleta  AS Categoria,
        Marca_Marca                              AS Marca
    FROM gd_esquema.Maestra
    WHERE Venta_Nro_Venta IS NOT NULL
      AND Modelo_Bicicleta_Modelo_Bicicleta IS NOT NULL
    UNION
    SELECT
        Modelo_Bicicleta_Modelo_Bicicleta,
        Modelo_Bicicleta_Rodado_Modelo_Bicicleta,
        Modelo_Bicicleta_Cuadro_Modelo_Bicicleta,
        Modelo_Bicicleta_Color_Modelo_Bicicleta,
        Categoria_Bicicleta_Categoria_Bicicleta,
        Marca_Marca
    FROM gd_esquema.Maestra
    WHERE Alquiler_Nro_Alquiler IS NOT NULL
      AND Modelo_Bicicleta_Modelo_Bicicleta IS NOT NULL
    UNION
    SELECT
        Modelo_Bicicleta_Modelo_Bicicleta,
        Modelo_Bicicleta_Rodado_Modelo_Bicicleta,
        Modelo_Bicicleta_Cuadro_Modelo_Bicicleta,
        Modelo_Bicicleta_Color_Modelo_Bicicleta,
        Categoria_Bicicleta_Categoria_Bicicleta,
        Marca_Marca
    FROM gd_esquema.Maestra
    WHERE Reparacion_Nro_Reparacion IS NOT NULL
      AND Modelo_Bicicleta_Modelo_Bicicleta IS NOT NULL
) u
LEFT JOIN NORMALIZADOS.Categoria_Bicicleta cb
    ON cb.Descripcion = u.Categoria
LEFT JOIN NORMALIZADOS.Marca ma
    ON ma.Descripcion = u.Marca;
GO

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


