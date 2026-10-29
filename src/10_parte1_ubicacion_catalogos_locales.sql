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
