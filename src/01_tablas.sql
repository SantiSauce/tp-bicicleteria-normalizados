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
