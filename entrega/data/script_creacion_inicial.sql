/* =====================================================================
   script_creacion_inicial.sql
   TP FRBA Gestión de Bicicletería - 2C2026 - K3521 - Grupo 1 NORMALIZADOS
   Creación del modelo transaccional y migración desde gd_esquema.Maestra.
   ARCHIVO GENERADO por herramientas\armar-script.ps1 - no editar a mano,
   editar los archivos de src\ y volver a generar.
   ===================================================================== */

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

/* =====================================================================
   01 - Tablas del modelo transaccional (DER v2)
   Tipos iguales a gd_esquema.Maestra: texto varchar(255), importes
   numeric(38,2), fechas datetime2(6), cantidades y números int.
   ===================================================================== */

/* ---------- Ubicación ---------- */

-- Provincia: catálogo de provincias (nombre único).
CREATE TABLE NORMALIZADOS.Provincia (
    Provincia_Id INT IDENTITY(1,1) NOT NULL,
    Nombre       VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Provincia PRIMARY KEY (Provincia_Id),
    CONSTRAINT UQ_Provincia_Nombre UNIQUE (Nombre)
);
GO

-- Localidad: pertenece a una provincia; el mismo nombre puede repetirse en otra provincia.
CREATE TABLE NORMALIZADOS.Localidad (
    Localidad_Id INT IDENTITY(1,1) NOT NULL,
    Nombre       VARCHAR(255)      NOT NULL,
    Provincia_Id INT               NOT NULL,
    CONSTRAINT PK_Localidad PRIMARY KEY (Localidad_Id),
    CONSTRAINT UQ_Localidad_Nombre_Provincia UNIQUE (Nombre, Provincia_Id),
    CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (Provincia_Id) REFERENCES NORMALIZADOS.Provincia (Provincia_Id)
);
GO

/* ---------- Catálogos ---------- */

-- Tipo_Producto: Bicicleta / Accesorio (abierto a nuevos valores).
CREATE TABLE NORMALIZADOS.Tipo_Producto (
    Tipo_Producto_Id INT IDENTITY(1,1) NOT NULL,
    Descripcion      VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Tipo_Producto PRIMARY KEY (Tipo_Producto_Id),
    CONSTRAINT UQ_Tipo_Producto_Descripcion UNIQUE (Descripcion)
);
GO

-- Categoria_Bicicleta: categoría del modelo (MTB, Urbana/Paseo, etc.).
CREATE TABLE NORMALIZADOS.Categoria_Bicicleta (
    Categoria_Bicicleta_Id INT IDENTITY(1,1) NOT NULL,
    Descripcion            VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Categoria_Bicicleta PRIMARY KEY (Categoria_Bicicleta_Id),
    CONSTRAINT UQ_Categoria_Bicicleta_Descripcion UNIQUE (Descripcion)
);
GO

-- Categoria_Accesorios: categoría del accesorio (Iluminacion, Indumentaria, etc.).
CREATE TABLE NORMALIZADOS.Categoria_Accesorios (
    Categoria_Accesorios_Id INT IDENTITY(1,1) NOT NULL,
    Descripcion             VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Categoria_Accesorios PRIMARY KEY (Categoria_Accesorios_Id),
    CONSTRAINT UQ_Categoria_Accesorios_Descripcion UNIQUE (Descripcion)
);
GO

-- Categoria_Repuestos: categoría del repuesto (Frenos, Ruedas y cubiertas, etc.).
CREATE TABLE NORMALIZADOS.Categoria_Repuestos (
    Categoria_Repuestos_Id INT IDENTITY(1,1) NOT NULL,
    Descripcion            VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Categoria_Repuestos PRIMARY KEY (Categoria_Repuestos_Id),
    CONSTRAINT UQ_Categoria_Repuestos_Descripcion UNIQUE (Descripcion)
);
GO

-- Marca: la usan Modelo_Bicicleta y Accesorio.
CREATE TABLE NORMALIZADOS.Marca (
    Marca_Id    INT IDENTITY(1,1) NOT NULL,
    Descripcion VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Marca PRIMARY KEY (Marca_Id),
    CONSTRAINT UQ_Marca_Descripcion UNIQUE (Descripcion)
);
GO

/* ---------- Datos maestros ---------- */

-- Local: sucursal de la bicicletería (nombre único).
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

-- Cliente: el DNI NO es único (hay documentos compartidos por personas distintas, ver Estrategia 2.2).
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

-- Empleado: pertenece a un único local; el DNI sí es único.
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

-- Proveedor: el CUIT es único.
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

-- Modelo_Bicicleta: lo usan Bicicleta (venta), Bicicleta_Alquiler y Reparacion.
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

/* ---------- Producto y subtipos ---------- */

-- Producto: entidad general vendida/comprada; la clave viene de la Maestra (PROD-xxxxx).
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

-- Bicicleta: subtipo 1:1 de Producto (misma clave).
CREATE TABLE NORMALIZADOS.Bicicleta (
    Cod_Producto        VARCHAR(255) NOT NULL,
    Meses_Garantia      INT          NULL,
    Modelo_Bicicleta_Id INT          NOT NULL,
    CONSTRAINT PK_Bicicleta PRIMARY KEY (Cod_Producto),
    CONSTRAINT FK_Bicicleta_Producto FOREIGN KEY (Cod_Producto) REFERENCES NORMALIZADOS.Producto (Cod_Producto),
    CONSTRAINT FK_Bicicleta_Modelo FOREIGN KEY (Modelo_Bicicleta_Id) REFERENCES NORMALIZADOS.Modelo_Bicicleta (Modelo_Bicicleta_Id)
);
GO

-- Accesorio: subtipo 1:1 de Producto (misma clave).
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

-- Bicicleta_Alquiler: flota propia de cada local, identificada por su número de serie.
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

-- Repuesto: usado en reparaciones; Precio es el de lista.
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

/* ---------- Transaccionales ---------- */

-- Venta: cabecera de la venta.
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

-- Detalle_Venta: un renglón por producto vendido.
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

-- Compra: cabecera de la compra a proveedor (sin forma de pago).
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

-- Detalle_Compra: un renglón por producto comprado (el subtotal se calcula).
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

-- Alquiler: una sola bicicleta por alquiler, por eso no tiene detalle.
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

-- Reparacion: Bici_Serie es texto libre (bici del cliente), sin FK.
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

-- Detalle_Reparacion: repuestos usados, con el precio efectivamente cobrado.
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


/* =====================================================================
   PARTE 2 de 4 - Cliente, Empleado y Modelo_Bicicleta
   Responsable: (completar)
   =====================================================================

   QUÉ HAY QUE HACER
   Cargar las personas y los modelos de bicicleta. Es la parte con más
   decisiones de criterio (están explicadas en la Estrategia, punto 3.1).

   ORDEN DE CARGA
     1. Cliente            (FK a Localidad)
     2. Empleado           (FK a Localidad y a Local)
     3. Modelo_Bicicleta   (FK a Categoria_Bicicleta y a Marca)

   DEPENDE DE:   Parte 1 (Localidad, Local, Categoria_Bicicleta, Marca)
   LA USAN:      partes 3 y 4 (todas las operaciones tienen cliente y empleado)

   El patrón de INSERT...SELECT está explicado en 10_parte1_*.sql.

   ---------------------------------------------------------------------
   DETALLE POR TABLA
   ---------------------------------------------------------------------

   1. CLIENTE  <- columnas Cliente_*
      - El DNI NO identifica a una persona: hay 126 DNI con dos personas
        distintas. Criterio acordado: mismo cliente = mismo DNI + Nombre + Apellido.
      - OJO con el DISTINCT: si un mismo (DNI, nombre, apellido) viniera con
        otro teléfono/mail/dirección, un SELECT DISTINCT de todas las columnas
        lo duplicaría. Verificar antes con un GROUP BY y, si pasa, decidir
        cómo elegir una sola fila.
      - Localidad_Id: JOIN con Localidad + Provincia (Cliente_Localidad, Cliente_Provincia).
      - Las filas de compra no tienen cliente (vienen en NULL): filtrarlas.
      - Hay un índice IX_Cliente_Dni (Dni, Nombre, Apellido) pensado para que
        las partes 3 y 4 encuentren el Cliente_Id rápido.

   2. EMPLEADO  <- columnas Empleado_*   (Dni es único)              (esperado: 25)
      - Local_Id es obligatorio, pero en los datos los 25 empleados aparecen
        en los 5 locales. Criterio acordado: a cada empleado se le asigna el
        local en el que MÁS operaciones tiene (contando todas las filas donde
        aparece). Pista: GROUP BY empleado + local, y quedarse con el máximo
        (ROW_NUMBER() OVER (PARTITION BY ... ORDER BY COUNT(*) DESC) sirve).
      - Ojo con los empates: definir un desempate fijo para que el resultado
        sea siempre el mismo.
      - Fecha de nacimiento viene en Empleado_Fecha_Nac_Empleado.

   3. MODELO_BICICLETA  <- columnas Modelo_Bicicleta_*
      - No hay código de modelo. Criterio acordado: mismo modelo = misma
        combinación Modelo + Rodado + Cuadro + Color (+ categoría y marca).
      - Los modelos aparecen en TRES lugares: bicicletas vendidas, bicicletas
        de alquiler y reparaciones. Hay que cargarlos todos (no solo los de venta).
      - Categoria_Bicicleta_Id y Marca_Id: JOIN por descripción.

   CHECKLIST ANTES DE HACER EL PULL REQUEST
   [ ] correr-script.ps1 da OK, sin errores ni warnings
   [ ] Empleado = 25 y ningún cliente duplicado por (Dni, Nombre, Apellido)
   [ ] cada INSERT tiene su comentario explicando la intención
   ===================================================================== */


-- TODO Parte 2: escribir acá los INSERT (o SP + EXEC) en el orden de arriba.


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


/* =====================================================================
   PARTE 4 de 4 - Alquileres y Reparaciones
   Responsable: (completar)
   =====================================================================

   QUÉ HAY QUE HACER
   Cargar la flota de alquiler, los repuestos y las dos operaciones de
   servicio: alquileres (sin detalle) y reparaciones (con detalle de repuestos).

   ORDEN DE CARGA
     1. Bicicleta_Alquiler   (FK a Modelo_Bicicleta y Local)
     2. Repuesto             (FK a Categoria_Repuestos)
     3. Alquiler             (FK a Cliente, Empleado, Local, Bicicleta_Alquiler)
     4. Reparacion           (FK a Cliente, Empleado, Local, Modelo_Bicicleta)
     5. Detalle_Reparacion   (FK a Reparacion y Repuesto)

   DEPENDE DE:   Parte 1 (catálogos, Local) y Parte 2 (Cliente, Empleado, Modelo)
   El patrón de INSERT...SELECT está explicado en 10_parte1_*.sql.

   ---------------------------------------------------------------------
   DETALLE POR TABLA
   ---------------------------------------------------------------------

   1. BICICLETA_ALQUILER  <- columnas Bicicleta_Alquiler_*             (esperado: 80)
      - PK natural: Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler.
      - Local_Id (corrección del DER: cada local tiene su flota): sale del
        local de sus alquileres. Ya verificamos que cada bici aparece en un
        solo local, así que no hay que elegir.
      - Estado_Bici_Alquiler tiene CHECK; Modelo_Bicicleta_Id por JOIN.
   2. REPUESTO  <- columnas Repuesto_*   PK natural: Repuesto_Cod_Repuesto (esperado: 10)
      - Precio es el de lista (Repuesto_Precio_Repuesto).

   3. ALQUILER  <- una fila por Alquiler_Nro_Alquiler                  (esperado: 69.620)
      - Una bicicleta por alquiler: Nro_Serie va directo en la cabecera.
      - Cliente_Id por DNI + Nombre + Apellido; Empleado_Id por DNI; Local_Id por nombre.
      - Forma_Pago y Estado_Alquiler tienen CHECK.

   4. REPARACION  <- una fila por Reparacion_Nro_Reparacion            (esperado: 34.493)
      - Bici_Serie <- Reparacion_Numero_Serie_Bici_Reparacion: es TEXTO, sin
        FK (es la bici del cliente, no la flota).
      - Modelo_Bicicleta_Id por JOIN con los datos de modelo de la fila.
      - Estado_Reparacion tiene CHECK.
   5. DETALLE_REPARACION  <- un renglón por fila de reparación         (esperado: ~69.213)
      - Precio_Unitario es el COBRADO en esa reparación (puede diferir del de lista).

   PERFORMANCE: evitar cursores; JOINs de conjunto. Límite total: 10 minutos.

   CHECKLIST ANTES DE HACER EL PULL REQUEST
   [ ] correr-script.ps1 da OK, sin errores ni warnings
   [ ] conteos de 99_verificacion.sql de estas tablas coinciden
   [ ] Precio_Repuestos de cada reparación = SUM(Subtotal) de su detalle (o explicar)
   [ ] cada INSERT tiene su comentario explicando la intención
   ===================================================================== */


-- TODO Parte 4: escribir acá los INSERT (o SP + EXEC) en el orden de arriba.


