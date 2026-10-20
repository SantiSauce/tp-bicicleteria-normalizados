# TP FRBA Gestión de Bicicletería — K3521 — Grupo 1 NORMALIZADOS

Repo del **`script_creacion_inicial.sql`** (modelo relacional + migración) del TP de Bases de Datos, UTN FRBA 2C2026.
El DER y el documento de Estrategia viven en el **Drive del grupo**, no acá.

> ⚠️ **Repo privado.** El enunciado penaliza cualquier indicio de copia con la pérdida de la materia: no lo hagan público ni compartan el link.

| Integrante | Legajo |
|---|---|
| Saucedo, Santiago | 1729664 |
| Shih, David | 2141383 |
| Quispe, Adrián | 1501252 |
| Galanti, Mateo (responsable) | 2089932 |

**Entrega Modelo relacional + migración: 30/10/2026 hasta las 12:00.** Fecha final del TP: 14/12/2026 (hay 2 reentregas en total).

## Reparto de la migración

La migración está dividida en 4 partes. Cada archivo explica arriba **qué tablas carga, en qué orden, de qué columnas de la Maestra salen, qué criterio usar y cuántas filas se esperan**.

| Parte | Archivo | Tablas | Depende de | Responsable |
|---|---|---|---|---|
| 1 | `src/10_parte1_ubicacion_catalogos_locales.sql` | Provincia, Localidad, Tipo_Producto, 3 categorías, Marca, Local, Proveedor | — | _completar_ |
| 2 | `src/20_parte2_clientes_empleados_modelos.sql` | Cliente, Empleado, Modelo_Bicicleta | 1 | _completar_ |
| 3 | `src/30_parte3_productos_ventas_compras.sql` | Producto, Bicicleta, Accesorio, Venta, Detalle_Venta, Compra, Detalle_Compra | 1, 2 | _completar_ |
| 4 | `src/40_parte4_alquileres_reparaciones.sql` | Bicicleta_Alquiler, Repuesto, Alquiler, Reparacion, Detalle_Reparacion | 1, 2 | _completar_ |

La parte 1 es la más corta y todas dependen de ella: conviene terminarla primero. Las partes 3 y 4 se pueden escribir en paralelo con la 2, pero para **probarlas** necesitan 1 y 2 cargadas.

## Estructura

```
src/                      El script, en partes (cada uno edita SOLO la suya)
  00_esquema.sql          USE GD2C_2026 + (re)creación del esquema NORMALIZADOS     ✅ listo
  01_tablas.sql           24 tablas con PK, FK, UNIQUE y CHECK (DER corregido)        ✅ listo y probado
  02_indices.sql          Índices                                                     ✅ listo
  10/20/30/40_parte*.sql  Migración, una parte por integrante                         ⏳ TODO
  99_verificacion.sql     Conteos esperados por tabla (no va en la entrega)
entrega/
  Readme.txt              Datos del grupo (falta el mail del responsable)
  data/script_creacion_inicial.sql   ← GENERADO desde src/, no editar a mano
herramientas/
  restaurar-base.ps1      Restaura el .bak como GD2C_2026
  correr-script.ps1       Genera el script, lo corre como la cátedra y muestra los conteos
  armar-script.ps1        Une src/ en entrega/data/script_creacion_inicial.sql
  armar-entrega.ps1       Arma "TP2C2026 k3521 NORMALIZADOS 1.zip123"
  consultas/              Consultas que respaldan las decisiones del DER
base/                     Poner acá el .bak (no se sube)
```

## Puesta en marcha (cada uno, una vez)

1. SQL Server 2022 Express + SSMS, instancia `localhost\SQLEXPRESS`.
2. Clonar el repo y copiar `GD2C_2026_20260903_221157.bak` (aula virtual) en `base/`.
3. Click derecho en `herramientas/restaurar-base.ps1` → *Ejecutar con PowerShell*. Restaura la base como **`GD2C_2026`** (el nombre que usa el script).
   - Si ya la tenés con otro nombre: `.\herramientas\correr-script.ps1 -Base TU_BASE`.

## Cómo trabajamos

1. Rama propia por parte:
   ```
   git checkout main
   git pull
   git checkout -b parte2-clientes
   ```
2. Editar **solo** tu archivo de `src/`.
3. Probar: `.\herramientas\correr-script.ps1` → tiene que dar **OK, sin warnings, en menos de 10 min**, y tus tablas en `OK` en la tabla de conteos.
4. Commit chico y seguido (si alguien rompe algo, se vuelve al commit anterior):
   ```
   git add src/20_parte2_clientes_empleados_modelos.sql
   git commit -m "Parte 2: migracion de empleados con local mas frecuente"
   git push -u origin parte2-clientes
   ```
5. Abrir un **Pull Request** a `main`. Otro integrante lo revisa antes de mergear.

**No commitear** `entrega/data/script_creacion_inicial.sql` desde las ramas (genera conflictos): se regenera en `main` cuando están las 4 partes.

### Reglas de la cátedra (si no se cumplen, rechazan el TP sin corregir)
- Todo objeto (tablas, SP, vistas, funciones, triggers) dentro del esquema `NORMALIZADOS`.
- Migración 100 % T-SQL, un único script, se ejecuta **una vez** sobre la base limpia **sin errores ni warnings**, en **menos de 10 minutos**.
- **Cada sentencia comentada** explicando su intención.

## Antes de entregar
- [ ] Las 4 partes mergeadas y `correr-script.ps1` OK sobre una base **recién restaurada**
- [ ] Todos los conteos de `99_verificacion.sql` en OK (o explicados en la Estrategia)
- [ ] Mail del responsable en `entrega/Readme.txt`
- [ ] Copiar del Drive a `entrega/`: `Estrategia.pdf` (con carátula e índice) y `DER.jpg`
- [ ] `armar-entrega.ps1` → mandar el `.zip123` desde el mail del responsable, asunto `TP2C2026 k3521 NORMALIZADOS 1`
