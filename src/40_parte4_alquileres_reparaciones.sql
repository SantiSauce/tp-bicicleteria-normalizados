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

