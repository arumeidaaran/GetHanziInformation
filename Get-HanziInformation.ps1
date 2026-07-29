$caminoProyecto = $PSScriptRoot

$CSSBase = Get-Content -Path "$caminoProyecto\assets\styleCSSBase.css" -Raw

$htmlModelo = Get-Content -Path "$caminoProyecto\assets\htmlModelo.html" -Raw

do {
    $palabra = Read-Host -Prompt "Escriba el carácter que quieres buscar en chino"

    $url = "https://cn.apihz.cn/api/zici/chazd.php?id=88888888&key=88888888&word=$($palabra)"

    $respuesta = Invoke-WebRequest -Uri $url -UseBasicParsing -Method 'Get'

    $bytes = $respuesta.RawContentStream.ToArray()
    $json = [System.Text.Encoding]::UTF8.GetString($bytes)

    $Resultado = $json | ConvertFrom-Json

    $linhas = foreach ($propriedade in $Resultado.PSObject.Properties) {
        $valorOriginal = [string]$propriedade.Value
        $valorHtml = [System.Net.WebUtility]::HtmlEncode($valorOriginal)

        $conteudo = "<pre>$valorHtml</pre>"

        if (
            $valorOriginal -match '^https?://' -and
            $valorOriginal -match '\.(jpg|jpeg|png|gif|webp)(\?.*)?$'
        ) {
            $conteudo = "<img src='$valorHtml' />"
        }

        $nomeHtml = [System.Net.WebUtility]::HtmlEncode($propriedade.Name)
        "<tr><td>$nomeHtml</td><td>$conteudo</td></tr>"
    }

    $html = $htmlModelo.
        Replace('{{TITLE}}', [System.Net.WebUtility]::HtmlEncode($Resultado.word)).
        Replace('{{ROWS}}', ($linhas -join "`n")).
        Replace('{{CSS}}', $CSSBase)

    $archivoHtml = Join-Path $env:HOMEDRIVE$env:HOMEPATH "hanzi.html"

    $html | Set-Content -Path $archivoHtml -Encoding UTF8

    Start-Process msedge.exe $archivoHtml
} while ($true)
