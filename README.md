# TP FRBA Gestión de Bicicletería — K3521 — Grupo 1 NORMALIZADOS

Trabajo práctico de Bases de Datos (UTN FRBA, 2C2026).

| Integrante | Legajo |
|---|---|
| Saucedo, Santiago | 1729664 |
| Shih, David | 2141383 |
| Quispe, Adrián | 1501252 |
| Galanti, Mateo (responsable) | 2089932 |

> ⚠️ **Repo privado.** El enunciado penaliza cualquier indicio de copia con la pérdida de la materia: no lo hagan público ni compartan el link.

## Entregas

| Entrega | Fecha (12:00 hs) | Qué se manda |
|---|---|---|
| DER | 01/10/2026 ✅ | Corregido → se manda con la siguiente |
| **Modelo relacional + migración** | **30/10/2026** | `script_creacion_inicial.sql`, DER corregido, Estrategia.pdf |
| BI | 25/11/2026 | lo anterior + `script_creacion_BI.sql`, DER_BI.jpg, Estrategia actualizada |
| Fecha final | 14/12/2026 | Hay 2 reentregas en total |

Mail: `gestiondedatos.entregas@gmail.com` — asunto y nombre del zip: **`TP2C2026 k3521 NORMALIZADOS 1`** (zip renombrado a `.zip123`, máx. 20 MB). Lo manda **solo el responsable**.

### Correcciones del DER (ya aplicadas en `docs/der/`)
1. Bicicleta_Alquiler → Local (cada local tiene su flota propia).
2. Nuevas entidades Provincia y Localidad.
3. Tipos de datos iguales a la Maestra.

## Estructura

```
src/                      Script dividido por partes (cada uno edita la suya)
  00_esquema.sql          USE GD2C_2026 + (re)creación del esquema NORMALIZADOS
  01_tablas.sql           Tablas, PK, FK, UNIQUE y CHECK (según DER v2)
  02_indices.sql          Índices
  10..14_migracion_*.sql  Migración desde gd_esquema.Maestra   ← TODO
  99_verificacion.sql     Conteos esperados (no va en la entrega)
entrega/                  Lo que va dentro del zip
  Readme.txt  DER.jpg  Estrategia.pdf
  data/script_creacion_inicial.sql   ← GENERADO, no editar a mano
docs/
  Estrategia.docx         Fuente del documento de estrategia
  der/der.dbml  DER.jpg   Fuente del DER (pegar en dbdiagram.io)
herramientas/
  restaurar-base.ps1      Restaura el .bak como GD2C_2026
  correr-script.ps1       Genera el script y lo corre como la cátedra (+ conteos)
  armar-script.ps1        Une src/ en entrega/data/script_creacion_inicial.sql
  armar-entrega.ps1       Arma "TP2C2026 k3521 NORMALIZADOS 1.zip123"
  consultas/              Consultas que respaldan las decisiones del DER
base/                     Poner acá el .bak (no se sube)
```

## Puesta en marcha (cada uno, una vez)

1. Instalar SQL Server 2022 Express + SSMS (instancia `localhost\SQLEXPRESS`).
2. Clonar el repo y copiar `GD2C_2026_20260903_221157.bak` (aula virtual) en `base/`.
3. Click derecho en `herramientas/restaurar-base.ps1` → *Ejecutar con PowerShell*. Restaura la base como **`GD2C_2026`**, que es el nombre que usa el script (`USE GD2C_2026`).
   - Si ya la tenés restaurada con otro nombre, podés seguir usándola: `.\herramientas\correr-script.ps1 -Base TU_BASE`.

## Cómo trabajamos

- **Nunca editar** `entrega/data/script_creacion_inicial.sql`: se genera desde `src/`.
- Cada uno trabaja en su archivo de `src/` (ver *Responsable* en el encabezado) en una rama propia:
  ```
  git checkout -b migracion-maestros
  ... editar src/12_migracion_maestros.sql ...
  .\herramientas\correr-script.ps1        # tiene que dar OK, sin warnings, < 10 min
  git add src/12_migracion_maestros.sql
  git commit -m "Migracion de clientes y empleados"
  git push -u origin migracion-maestros   # y abrir un Pull Request
  ```
- Antes de mergear a `main`: el script completo corre de punta a punta sin errores y los conteos de `99_verificacion.sql` coinciden.
- Reglas de la cátedra que hay que respetar en todo lo que se agregue:
  - Todo objeto (tablas, SP, vistas, triggers, funciones) dentro del esquema `NORMALIZADOS`; si no, rechazan el TP.
  - Migración 100 % T-SQL, en un único script, ejecutable una sola vez sin errores ni warnings, en menos de 10 minutos.
  - **Cada sentencia comentada** explicando su intención.

## Antes de entregar

- [ ] `correr-script.ps1` OK sobre una base recién restaurada
- [ ] Exportar `docs/Estrategia.docx` a `entrega/Estrategia.pdf` (con carátula e índice actualizado)
- [ ] `entrega/DER.jpg` actualizado
- [ ] Email del responsable en `entrega/Readme.txt`
- [ ] `armar-entrega.ps1` → mandar el `.zip123` desde el mail del responsable
