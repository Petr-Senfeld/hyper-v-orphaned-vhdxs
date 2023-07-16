########################################################################

# Zadej cestu/cesty k .vhdx souborům
$diskDirectories = @("D:\ProgramData\Microsoft\Windows\Hyper-V\New Virtual Machine\Virtual Hard Disks", "D:\ProgramData\Microsoft\Windows\Hyper-V\New Virtual Machine3\Virtual Hard Disks")

########################################################################

# Získání seznamu virtuálních disků (VHDX souborů) přidělených VMs
$virtualDisks = Get-VM -VMName new* | Select-Object -Property VMId | Get-VHD | Select-Object Path, VhdFormat, VhdType, FileSize
Write-Host "Seznam používaných disků:" 
    $virtualDisks | ForEach-Object { Write-Host "- $_" -BackgroundColor DarkGreen}
Write-Host

$actualDisks = Get-ChildItem -Path $diskDirectories -Filter *.vhdx -Recurse | Select-Object FullName, Length 
$list = $actualDisks.FullName
Write-Host "Seznam disků v poskytnutých adresářích:" 
    $actualDisks | ForEach-Object { Write-Host "- $_"}
Write-Host

# Porovnání 
$unusedDisks = Compare-Object -ReferenceObject $actualDisks.FullName -DifferenceObject $virtualDisks.Path | Select-Object -ExpandProperty InputObject

# Zobrazení nepoužitých disků
if ($unusedDisks) {
    Write-Host "Následující disky jsou nepoužité:"
    $unusedDisks | ForEach-Object { Write-Host "- $_" -BackgroundColor Red}
    Write-Host
    
    # Uživatele požádán o potvrzení smazání nepoužitých disků
    $confirmation = Read-Host "Opravdu chcete smazat tyto disky? Zadejte DELETE pro smazání nebo Q/QUIT pro ukončení skriptu."
    
    if ($confirmation -eq "DELETE") {
        # Smazání nepoužitých disků
        $unusedDisks | ForEach-Object { Remove-Item -Path $_ -Force }
        Write-Host "Nepoužité disky byly úspěšně smazány."
    }
    elseif ($confirmation -eq "QUIT" -or $confirmation -eq "Q") {
        Write-Host "Ukončeno bez smazání disků."
    }
    else {
        Write-Host "Neplatný vstup. Skript byl ukončen bez smazání disků."
    }
}
else {
    Write-Host "Nebyly nalezeny žádné nepoužité disky."
}
