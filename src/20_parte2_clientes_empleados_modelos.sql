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

