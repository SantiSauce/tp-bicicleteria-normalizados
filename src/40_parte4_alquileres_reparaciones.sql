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


/* ---------------------------------------------------------------------
   VERIFICACIONES PREVIAS SOBRE LA MAESTRA (respaldan los criterios de abajo)
   ---------------------------------------------------------------------
   - Las 80 bicicletas de alquiler tienen precio/hora, precio/día, estado,
     modelo Y LOCAL uniformes en todas sus filas: cada bici pertenece a un
     solo local, así que no hay que elegir (confirma la corrección del DER).
   - Los 10 repuestos tienen descripción, compatibilidad, precio de lista y
     categoría uniformes: un DISTINCT alcanza.
   - Hay 69.620 filas de alquiler y 69.620 Nro_Alquiler distintos: un alquiler
     ocupa exactamente una fila (una sola bici por alquiler, sin detalle).
   - Las 69.213 filas de reparación corresponden a 34.493 reparaciones, con la
     cabecera uniforme dentro de cada una; el resto son los renglones de repuestos.
   - Ni los alquileres ni las reparaciones traen NULL en cliente, empleado,
     local, nro de serie, modelo ni repuesto: los JOIN pueden ser INNER.
   - Las bicis de alquiler solo aparecen en filas de alquiler y los repuestos
     solo en filas de reparación, así que no hace falta filtrar por operación.
   - Valores de los CHECK presentes en los datos: Forma_Pago con los 4 valores
     esperados, Estado_Alquiler siempre 'Devuelto', Estado_Bici_Alquiler siempre
     'Disponible' y Estado_Reparacion siempre 'Entregada' (son datos históricos
     ya cerrados). Todos están dentro de los dominios declarados en 01_tablas.sql.

   PUNTO DEL CHECKLIST: Precio_Repuestos vs. suma del detalle
   Verificado: en las 34.493 reparaciones el Reparacion_Precio_Repuestos coincide
   exactamente con la suma de los subtotales de sus renglones (0 diferencias).
   A diferencia de las ventas, acá no hay desvíos por redondeo.
   --------------------------------------------------------------------- */


-- BICICLETA_ALQUILER: la flota propia, una fila por número de serie.
-- El Nro_Serie es la PK natural y la bici se repite en cada alquiler que tuvo,
-- por eso el DISTINCT. El Local_Id sale del local de sus alquileres: ya está
-- verificado que cada bici aparece siempre en el mismo local, así que el
-- DISTINCT no la duplica. El modelo se busca con la misma combinación completa
-- que usó la parte 2 (4 atributos de texto + categoría + marca), comparando
-- categoría y marca a través de sus catálogos para no depender de Ids.
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

-- REPUESTO: catálogo de repuestos, una fila por código.
-- Se repite en cada renglón de reparación que lo usó, de ahí el DISTINCT.
-- Precio es el de LISTA (Repuesto_Precio_Repuesto), no el cobrado: el precio
-- efectivamente cobrado en cada reparación va en Detalle_Reparacion.
-- La categoría se resuelve por descripción (LEFT JOIN porque la columna es
-- nullable en el modelo: si faltara, el repuesto se carga igual).
INSERT INTO NORMALIZADOS.Repuesto (Cod_Repuesto, Descripcion, Compatibilidad, Precio, Categoria_Repuestos_Id)
SELECT DISTINCT m.Repuesto_Cod_Repuesto, m.Repuesto_Desc_Repuesto,
       m.Repuesto_Compatibilidad_Repuesto, m.Repuesto_Precio_Repuesto,
       cr.Categoria_Repuestos_Id
FROM gd_esquema.Maestra m
LEFT JOIN NORMALIZADOS.Categoria_Repuestos cr ON cr.Descripcion = m.Categoria_Repuestos_Categoria_Respuesto
WHERE m.Repuesto_Cod_Repuesto IS NOT NULL;
GO

-- ALQUILER: una fila por alquiler. A diferencia de ventas y reparaciones, acá
-- no hace falta deduplicar: cada alquiler ocupa una sola fila de la Maestra
-- porque se alquila una única bicicleta, que va directo en la cabecera.
-- Ids resueltos por clave natural: Cliente por DNI + Nombre + Apellido
-- (criterio de la parte 2), Empleado por DNI, Local por nombre y la bici de la
-- flota por su número de serie (cargada más arriba en esta misma parte).
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

-- REPARACION: una fila por número de reparación (cabecera).
-- La Maestra repite la cabecera en cada renglón de repuesto, así que primero
-- nos quedamos con una sola fila por reparación (subconsulta con DISTINCT) y
-- después resolvemos los Ids. Bici_Serie se migra como TEXTO y sin FK: es la
-- bicicleta del cliente, no una de la flota de alquiler (ya se verificó que
-- esas series no se repiten entre reparaciones; ver Estrategia 3.12).
-- El modelo de la bici reparada se busca con la misma combinación completa
-- que en el resto del script.
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

-- DETALLE_REPARACION: un renglón por cada fila de reparación de la Maestra.
-- Sin DISTINCT, igual que en los detalles de venta: cada fila es un renglón
-- real. Hay reparaciones que usan el mismo repuesto en más de un renglón
-- (69.213 filas contra 64.506 pares reparación-repuesto distintos), y el
-- Detalle_Reparacion_Id es IDENTITY, así que esos renglones no chocan.
-- Precio_Unitario es el COBRADO en esa reparación, que puede diferir del
-- precio de lista guardado en Repuesto.
INSERT INTO NORMALIZADOS.Detalle_Reparacion (Nro_Reparacion, Cod_Repuesto, Cantidad, Precio_Unitario, Subtotal)
SELECT m.Reparacion_Nro_Reparacion, m.Repuesto_Cod_Repuesto,
       m.Detalle_Reparacion_Cantidad_Repuesto, m.Detalle_Reparacion_Precio_Unitario_Repuesto,
       m.Detalle_Reparacion_Subtotal_Repuesto
FROM gd_esquema.Maestra m
WHERE m.Reparacion_Nro_Reparacion IS NOT NULL;
GO

