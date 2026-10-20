# =====================================================================
#  Genera el script único y lo ejecuta contra tu base local, como lo
#  haría la cátedra: de una sola vez, cortando ante el primer error.
#  Después corre src\99_verificacion.sql con los conteos esperados.
#
#  Uso:  .\herramientas\correr-script.ps1                 (base GD2C_2026)
#        .\herramientas\correr-script.ps1 -Base BICICLETERIA_TP
#  Deja el detalle en herramientas\ultima-corrida.log
# =====================================================================
param(
    [string]$Base      = 'GD2C_2026',
    [string]$Instancia = 'localhost\SQLEXPRESS'
)
$raiz = Split-Path -Parent $PSScriptRoot
$log  = Join-Path $PSScriptRoot 'ultima-corrida.log'

$sqlcmd = (Get-Command sqlcmd -ErrorAction SilentlyContinue).Source
if (-not $sqlcmd) { $sqlcmd = 'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe' }

& (Join-Path $PSScriptRoot 'armar-script.ps1')

# Si tu base local no se llama GD2C_2026, corremos una copia con el USE cambiado.
$script = Join-Path $raiz 'entrega\data\script_creacion_inicial.sql'
$tmp    = Join-Path $env:TEMP 'script_creacion_inicial_local.sql'
(Get-Content $script -Raw -Encoding UTF8) -replace 'USE GD2C_2026;', "USE [$Base];" | Set-Content $tmp -Encoding UTF8

Write-Host "Ejecutando contra $Instancia / $Base ..." -ForegroundColor Cyan
$t = [Diagnostics.Stopwatch]::StartNew()
& $sqlcmd -S $Instancia -E -b -f 65001 -i $tmp *> $log
$codigo = $LASTEXITCODE
$t.Stop()

if ($codigo -ne 0) {
    Write-Host "FALLO (codigo $codigo). Revisa $log" -ForegroundColor Red
    Get-Content $log -Tail 20
} else {
    Write-Host ("OK en {0:mm\:ss} (limite de la catedra: 10 minutos)" -f $t.Elapsed) -ForegroundColor Green
    if ((Get-Content $log -Raw) -match 'Warning|Advertencia') { Write-Host "Ojo: hay warnings en $log" -ForegroundColor Yellow }
    & $sqlcmd -S $Instancia -E -d $Base -W -s ' | ' -i (Join-Path $raiz 'src\99_verificacion.sql')
}
Read-Host "`nEnter para cerrar"
