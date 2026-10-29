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
