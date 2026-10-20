# =====================================================================
#  Arma el zip de la entrega con la estructura que pide el enunciado:
#     Readme.txt, Estrategia.pdf, DER.jpg, (DER_BI.jpg), data\*.sql
#  y lo renombra a .zip123 como pide la cátedra (Gmail bloquea .zip).
#  Nombre = asunto del mail: "TP2C2026 k3521 NORMALIZADOS 1"
# =====================================================================
$raiz    = Split-Path -Parent $PSScriptRoot
$entrega = Join-Path $raiz 'entrega'
$nombre  = 'TP2C2026 k3521 NORMALIZADOS 1'

& (Join-Path $PSScriptRoot 'armar-script.ps1')

# Estrategia.pdf y DER.jpg están en el Drive del grupo (no en el repo):
# bajarlos y copiarlos en entrega\ antes de correr esto.
foreach ($obligatorio in 'Readme.txt', 'Estrategia.pdf', 'DER.jpg', 'data\script_creacion_inicial.sql') {
    if (-not (Test-Path (Join-Path $entrega $obligatorio))) {
        Write-Host "Falta entrega\$obligatorio (si es el PDF o el DER, copialo del Drive)" -ForegroundColor Red
        Read-Host 'Enter para cerrar'; exit 1
    }
}

$zip = Join-Path $raiz "$nombre.zip"
Remove-Item $zip, "$zip`123" -ErrorAction SilentlyContinue
Compress-Archive -Path (Join-Path $entrega '*') -DestinationPath $zip
Rename-Item $zip "$nombre.zip123"
$mb = [math]::Round((Get-Item (Join-Path $raiz "$nombre.zip123")).Length / 1MB, 2)
Write-Host "Listo: $nombre.zip123 ($mb MB, limite 20 MB)" -ForegroundColor Green
Write-Host "Asunto del mail: $nombre" -ForegroundColor Green
Read-Host 'Enter para cerrar'
