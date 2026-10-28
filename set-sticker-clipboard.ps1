param(
    [Parameter(Mandatory = $true)]
    [string] $ImagePath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (-not [System.IO.File]::Exists($ImagePath)) {
    throw "Sticker not found: $ImagePath"
}

# Publish both a PNG representation (transparency-friendly when supported)
# and a Windows bitmap representation (broad clipboard compatibility).
$bytes = [System.IO.File]::ReadAllBytes($ImagePath)
$img = [System.Drawing.Image]::FromFile($ImagePath)
try {
    $bitmap = New-Object System.Drawing.Bitmap($img)
    try {
        $data = New-Object System.Windows.Forms.DataObject
        # A MemoryStream is written to the clipboard as raw bytes; a byte[]
        # would be wrapped in a .NET serialization header that browsers can't decode.
        $data.SetData('PNG', $false, (New-Object System.IO.MemoryStream(,$bytes)))
        $data.SetData([System.Windows.Forms.DataFormats]::Bitmap, $true, $bitmap)
        # copy=true keeps clipboard data available after PowerShell exits.
        [System.Windows.Forms.Clipboard]::SetDataObject($data, $true, 10, 100)
    }
    finally {
        $bitmap.Dispose()
    }
}
finally {
    $img.Dispose()
}
