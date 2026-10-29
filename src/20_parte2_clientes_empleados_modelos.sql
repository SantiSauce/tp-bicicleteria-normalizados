/* =====================================================================
   PARTE 2 de 4 - Cliente, Empleado y Modelo_Bicicleta
   Responsable: David
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



/* 1. CLIENTE
   Se insertan los clientes distintos por la combinación (DNI, Nombre, Apellido).
   Verificación previa: ningún (DNI, Nombre, Apellido) tiene variantes en
   teléfono, email, dirección, fecha de nacimiento ni localidad, por lo que
   el DISTINCT de todas las columnas produce exactamente un registro por persona.
   Se filtran las filas sin cliente (compras, que traen NULL en Cliente_Dni).
   Localidad_Id se resuelve con LEFT JOIN a Provincia y Localidad: la columna
   es nullable en la tabla destino, así que no se pierden clientes si la
   localidad/provincia viniera en NULL. 

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
        las partes 3 y 4 encuentren el Cliente_Id rápido. */

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


/* 2. EMPLEADO
   Cada empleado (DNI único) aparece en los 5 locales. Se le asigna el local
   donde más operaciones tiene (contando todas las filas de la Maestra en las
   que aparece su DNI junto con ese local). Desempate: nombre de local ASC
   para que el resultado sea determinístico.
   Se usa un CTE con ROW_NUMBER para quedarse con la fila del local más
   frecuente, y luego se trae el resto de los datos personales (que son
   uniformes por DNI, verificado previamente).
   Localidad_Id se resuelve igual que en Cliente: LEFT JOIN a Provincia y
   Localidad. 
      2. EMPLEADO  <- columnas Empleado_*   (Dni es único)              (esperado: 25)
      - Local_Id es obligatorio, pero en los datos los 25 empleados aparecen
        en los 5 locales. Criterio acordado: a cada empleado se le asigna el
        local en el que MÁS operaciones tiene (contando todas las filas donde
        aparece). Pista: GROUP BY empleado + local, y quedarse con el máximo
        (ROW_NUMBER() OVER (PARTITION BY ... ORDER BY COUNT(*) DESC) sirve).
      - Ojo con los empates: definir un desempate fijo para que el resultado
        sea siempre el mismo.
      - Fecha de nacimiento viene en Empleado_Fecha_Nac_Empleado. */

;WITH Empleado_Local AS (
    -- Para cada empleado, contar operaciones por local y rankear
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
    -- Datos personales: un solo registro por DNI (DISTINCT, verificado uniforme)
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


/* 3. MODELO_BICICLETA
   Se juntan los modelos de los tres orígenes (venta, alquiler, reparación)
   con UNION (que elimina duplicados). Verificación previa: ninguna de las
   6 columnas de modelo tiene NULLs en los datos, por lo que el UNION
   compara correctamente y no hay riesgo de duplicados por NULL.

   Categoria_Bicicleta_Id y Marca_Id se resuelven con LEFT JOIN por
   descripción contra las tablas cargadas en la Parte 1.

   NOTA PARA PARTES 3 y 4 (criterio de JOIN al buscar Modelo_Bicicleta_Id):
   -------------------------------------------------------------------------
   En los datos actuales NO hay NULLs en ninguna de las 6 columnas de modelo
   (Modelo, Rodado, Cuadro, Color, Categoria, Marca). Sin embargo, si alguna
   columna fuera NULL, un JOIN directo (col = col) no matchearía porque
   NULL = NULL es falso. Para ser defensivos, las partes 3 y 4 deben usar:

       ISNULL(m.Modelo_Bicicleta_Modelo_Bicicleta, '') = ISNULL(mb.Modelo, '')

   en TODAS las columnas del JOIN al buscar Modelo_Bicicleta_Id. Este mismo
   criterio (ISNULL con cadena vacía) se usó implícitamente aquí gracias a
   que UNION trata NULLs como iguales. Mantener la coherencia. 
   
      3. MODELO_BICICLETA  <- columnas Modelo_Bicicleta_*
      - No hay código de modelo. Criterio acordado: mismo modelo = misma
        combinación Modelo + Rodado + Cuadro + Color (+ categoría y marca).
      - Los modelos aparecen en TRES lugares: bicicletas vendidas, bicicletas
        de alquiler y reparaciones. Hay que cargarlos todos (no solo los de venta).
      - Categoria_Bicicleta_Id y Marca_Id: JOIN por descripción. */


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
    -- Origen 1: bicicletas vendidas (filas de venta con modelo no nulo)
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

    -- Origen 2: bicicletas de alquiler
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

    -- Origen 3: reparaciones
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