# =====================================================================
#  Restaura la base del TP de Bases de Datos K3521 (UTN FRBA)
#  Backup: base\GD2C_2026_20260903_221157.bak  ->  base GD2C_2026 en localhost\SQLEXPRESS
#
#  Uso: click derecho -> "Ejecutar con PowerShell"
#  Pase lo que pase, deja el detalle en:  restaurar-base.log
# =====================================================================

$Log = Join-Path $PSScriptRoot 'restaurar-base.log'
"=== Ejecucion $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" | Out-File $Log -Encoding utf8

function Say([string]$m, [string]$color = 'Gray') {
    Write-Host $m -ForegroundColor $color
    $m | Out-File $Log -Append -Encoding utf8
}

$Instancia  = 'localhost\SQLEXPRESS'
$BaseNueva  = 'GD2C_2026'
$Bak        = Join-Path (Split-Path -Parent $PSScriptRoot) 'base\GD2C_2026_20260903_221157.bak'
$ok         = $false

function Invoke-Sql([string]$Query) {
    # -s "|" es lo que hace que las columnas salgan separadas por barra.
    $r = & sqlcmd -S $Instancia -E -b -h -1 -W -s "|" -Q $Query 2>&1
    if ($LASTEXITCODE -ne 0) { throw ("sqlcmd fallo:`n" + ($r -join "`n")) }
    return $r
}

try {
    Say "== 0. Chequeando sqlcmd ==" 'Cyan'
    $sqlcmdPath = (Get-Command sqlcmd -ErrorAction SilentlyContinue).Source
    if (-not $sqlcmdPath) {
        $alt = 'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn'
        if (Test-Path (Join-Path $alt 'sqlcmd.exe')) {
            $env:Path += ";$alt"
            $sqlcmdPath = Join-Path $alt 'sqlcmd.exe'
        } else {
            throw "No encuentro sqlcmd.exe. Reinstalar las herramientas cliente de SQL Server."
        }
    }
    Say "   $sqlcmdPath" 'Green'

    Say "`n== 1. Verificando el archivo de backup ==" 'Cyan'
    if (-not (Test-Path $Bak)) {
        throw "No encontre el backup en: $Bak"
    }
    Say "   Backup en: $Bak ($([math]::Round((Get-Item $Bak).Length/1MB,1)) MB)" 'Green'

    Say "`n== 2. Permiso de lectura para el servicio de SQL Server ==" 'Cyan'
    try {
        $carpetaBak = Split-Path $Bak -Parent
        $acl = Get-Acl $carpetaBak
        $regla = New-Object System.Security.AccessControl.FileSystemAccessRule(
            'NT SERVICE\MSSQL$SQLEXPRESS','Read','ContainerInherit,ObjectInherit','None','Allow')
        $acl.SetAccessRule($regla)
        Set-Acl $carpetaBak $acl
        Say "   OK" 'Green'
    } catch {
        Say "   Aviso: no pude ajustar permisos ($($_.Exception.Message)). Sigo igual." 'Yellow'
    }

    Say "`n== 3. Servicio de SQL Server ==" 'Cyan'
    $svc = Get-Service -Name 'MSSQL$SQLEXPRESS' -ErrorAction Stop
    if ($svc.Status -ne 'Running') { Start-Service $svc.Name; Start-Sleep 5 }
    Say "   MSSQL`$SQLEXPRESS: $((Get-Service 'MSSQL$SQLEXPRESS').Status)" 'Green'

    Say "`n== 4. Leyendo el contenido del backup ==" 'Cyan'
    $lista = Invoke-Sql "RESTORE FILELISTONLY FROM DISK = N'$Bak'"
    $logicos = @()
    foreach ($linea in $lista) {
        $t = "$linea".Trim()
        if (-not $t -or $t -match 'rows affected') { continue }
        $campos = if ($t -match '\|') { $t -split '\|' } else { $t -split '\s+' }
        if ($campos.Count -ge 3 -and $campos[2].Trim() -match '^[DL]$') {
            $logicos += [pscustomobject]@{ Nombre = $campos[0].Trim(); Tipo = $campos[2].Trim() }
        }
    }
    if ($logicos.Count -eq 0) {
        Say "   Salida cruda de FILELISTONLY:" 'Yellow'
        $lista | ForEach-Object { Say "   | $_" }
        throw "No pude interpretar los archivos logicos del backup."
    }
    $logicos | ForEach-Object { Say "   $($_.Tipo) -> $($_.Nombre)" }

    Say "`n== 5. Restaurando como '$BaseNueva' ==" 'Cyan'
    $dataDir = (Invoke-Sql "SELECT CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS nvarchar(400))")[0].Trim()
    Say "   Destino: $dataDir"

    $moves = @(); $nData = 0; $nLog = 0
    foreach ($f in $logicos) {
        if ($f.Tipo -eq 'D') {
            $nData++
            $ext = if ($nData -eq 1) { 'mdf' } else { 'ndf' }
            $dest = Join-Path $dataDir ("{0}_{1}.{2}" -f $BaseNueva, $nData, $ext)
        } else {
            $nLog++
            $dest = Join-Path $dataDir ("{0}_{1}.ldf" -f $BaseNueva, $nLog)
        }
        $moves += "MOVE N'$($f.Nombre)' TO N'$dest'"
    }

    Invoke-Sql "RESTORE DATABASE [$BaseNueva] FROM DISK = N'$Bak' WITH $($moves -join ', '), REPLACE, RECOVERY, STATS = 20" |
        ForEach-Object { Say "   $_" }
    Say "   Restaurada." 'Green'

    Say "`n== 6. Verificando ==" 'Cyan'
    $conteos = Invoke-Sql "USE [$BaseNueva]; SELECT t.name + ' = ' + CAST(SUM(p.rows) AS varchar(20)) FROM sys.tables t JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1) GROUP BY t.name ORDER BY t.name;"
    $conteos | Where-Object { $_ -match '=' } | ForEach-Object { Say "   $_" }

    $ok = $true
    Say "`n=====================================================" 'Green'
    Say " LISTO. Base '$BaseNueva' en $Instancia" 'Green'
    Say " En SSMS: Server name = $Instancia, Windows Authentication" 'Green'
    Say "=====================================================" 'Green'

} catch {
    Say "`n#####################################################" 'Red'
    Say " FALLO" 'Red'
    Say "#####################################################" 'Red'
    Say "$($_.Exception.Message)" 'Red'
    Say "`n--- Detalle ---" 'DarkGray'
    Say "$($_.ScriptStackTrace)" 'DarkGray'
} finally {
    Say "`nLog guardado en: $Log" 'Cyan'
}
