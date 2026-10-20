# =====================================================================
#  Une los archivos de src\ (00..98) en el script único de la entrega:
#     entrega\data\script_creacion_inicial.sql
#  src\99_verificacion.sql NO se incluye.
#  Uso: click derecho -> "Ejecutar con PowerShell"  (o: .\herramientas\armar-script.ps1)
# =====================================================================
$raiz   = Split-Path -Parent $PSScriptRoot
$src    = Join-Path $raiz 'src'
$salida = Join-Path $raiz 'entrega\data\script_creacion_inicial.sql'

$partes = Get-ChildItem $src -Filter '*.sql' | Where-Object { $_.Name -notlike '99_*' } | Sort-Object Name
$encabezado = @"
/* =====================================================================
   script_creacion_inicial.sql
   TP FRBA Gestión de Bicicletería - 2C2026 - K3521 - Grupo 1 NORMALIZADOS
   Creación del modelo transaccional y migración desde gd_esquema.Maestra.
   ARCHIVO GENERADO por herramientas\armar-script.ps1 - no editar a mano,
   editar los archivos de src\ y volver a generar.
   ===================================================================== */

"@
$cuerpo = foreach ($p in $partes) { Get-Content $p.FullName -Raw -Encoding UTF8; "`r`n" }
($encabezado + ($cuerpo -join '')) | Set-Content $salida -Encoding UTF8
Write-Host "Generado: $salida ($($partes.Count) partes)" -ForegroundColor Green
