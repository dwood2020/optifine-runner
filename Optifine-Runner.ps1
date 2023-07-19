# ==============================================================================
# Runner for OptiFine .jar installer packets
# ==============================================================================


# Finds all files with 'fileName' recursively in all child directories of 
# 'rootDir'.
function Find-File {
    param(
        [String]$fileName,
        [String]$rootDir
    )
    $foundFiles = Get-ChildItem -Path $rootDir -Filter $fileName -File -Recurse
    $foundFilesFull = $foundFiles | ForEach-Object { $_.FullName }
    return $foundFilesFull
}

# Gets the absolute path to the newest bundled Java Runtime.
# E.g. if there is a java.exe in C:\User\foo\java.exe, this function returns
# 'C:\User\foo'.
function Get-JRE-Basepath {
    $mcBaseLoc = Get-Package -Name "Minecraft*" -AllVersions | Select-Object -ExpandProperty Source
    $runtimeSubdir = "/runtime"
    $runtimeLoc = $mcBaseLoc + $runtimeSubdir
    $jreAppName = "java.exe"

    $foundJREs = Find-File -fileName $jreAppName -rootDir $runtimeLoc
    if ($foundJREs.Count -eq 0) {
        Write-Host "Could not find any JRE under '$($runtimeLoc)'.`n"
        return ""
    }

    $newest = Get-Item $foundJREs | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host "Found most recent JRE at: '$($newest)'"

    return $newest.Directory.FullName
}

function Select-File-Dialog {
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = "Select OptiFine JAR packet"
    $openFileDialog.Filter = "JAR files (*.jar)|*.jar"
    $openFileDialog.ShowHelp = $true

    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedFilePath = $openFileDialog.FileName
        Write-Host "Selected file: $selectedFilePath"
        return $selectedFilePath
    }
    else {
        Write-Host "File selection cancelled."
        return ""
    }
}


# Script entry point
Write-Host "Runner for OptiFine .jar installer packets"
Write-Host "------------------------------------------`n"

$jrePath = Get-JRE-Basepath
$optifinePath = Select-File-Dialog

Set-Location $($jrePath)
.\java.exe -jar $($optifinePath)
