$NameInputFile = $args[0]
$NameInputFile

if (-not(Test-Path -Path $NameInputFile -PathType Leaf)) {
    Write-Host "No esta el archivo" 
} else {
    Write-Host "Esta el archivo"
    
    Remove-Item *-information.txt
    $Title = "Digital, Error_apertura, Ruta_digital, Paginas por archivo, Total de paginas por partes, OCR, Observacion"
    $Date = Get-Date -Format "MMddyyyyHHmmss"
    $FileOutput	= "$Date-information.txt"
    
    New-Item $FileOutput
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host $Title
    Write-Output $Title | Out-File $FileOutput -Append

    $ListOfName = Get-Content $NameInputFile

    foreach( $NameItem in $ListOfName ){
        
        $File = Get-ChildItem -File -Recurse | Where {$_.Name -match (Write-Output $NameItem)}
        $NumberOfDigitalFile = (  $File  | Measure-Object ).Count

        if( $NumberOfDigitalFile -eq 0 ){
            Write-Host "$NameItem, , , , , , No se encuentran los archivos digitales"
            Write-Output "$NameItem, , , , , , No se encuentran los archivos digitales" | Out-File $FileOutput -Append
        }

        if( $NumberOfDigitalFile -eq 1 ){

            $ErrorFile = (pdfcpu validate $File.FullName | Out-String -Stream | Select-String -Pattern "ok")
            $Pages = (  pdfinfo $File.FullName | Select-String -Pattern '(?<=Pages:\s*)\d+' ).Matches.Value
            $Metadata = pdffonts $File.FullName 2>$null | Format-Table
            $Text = $Metadata | Select-Object -Index 2

            if( $ErrorFile -eq $NULL ){
                $ErrorFileValue = 0

                if( $Text -ne $null){
                    $OCR = 1
                    Write-Host $File.BaseName ',' $ErrorFileValue ',' $File.FullName ',' $Pages ',' $Pages ',' $OCR ','
                    $File.BaseName + ',' + $ErrorFileValue + ',' + $File.FullName + ',' + $Pages + ',' + $Pages + ',' + $OCR + ',' | Out-File $FileOutput -Append
                } else{
                    $OCR = 0
                    Write-Host $File.BaseName ',' $ErrorFileValue ',' $File.FullName ',' $Pages ',' $Pages ',' $OCR ','
                    $File.BaseName + ',' + $ErrorFileValue + ',' + $File.FullName + ',' + $Pages + ',' + $Pages + ',' + $OCR + ',' | Out-File $FileOutput -Append
                }  
            }else {
                $ErrorFileValue = 1
                if( $Text -ne $null){
                    $OCR = 1
                    Write-Host $File.BaseName ',' $ErrorFileValue ',' $File.FullName ',' $Pages ',' $Pages ',' $OCR ','
                    $File.BaseName + ',' + $ErrorFileValue + ',' + $File.FullName + ',' + $Pages + ',' + $Pages + ',' + $OCR + ',' | Out-File $FileOutput -Append
                } else{
                    $OCR = 0
                    Write-Host $File.BaseName ',' $ErrorFileValue ',' $File.FullName ',' $Pages ',' $Pages ',' $OCR ','
                    $File.BaseName + ',' + $ErrorFileValue + ',' + $File.FullName + ',' + $Pages + ',' + $Pages + ',' + $OCR + ',' | Out-File $FileOutput -Append
                }
                
            }

        }

        if( $NumberOfDigitalFile -gt 1) {

            foreach( $PartDigitalFile in $File) {
                
                $ErrorFile = (pdfcpu validate $PartDigitalFile.FullName | Out-String -Stream | Select-String -Pattern "ok")
                $Pages = ( pdfinfo $PartDigitalFile.FullName | Select-String -Pattern '(?<=Pages:\s*)\d+' ).Matches.Value
                $Metadata = pdffonts $PartDigitalFile.FullName 2>$null | Format-Table
                $Text = $Metadata | Select-Object -Index 2

                $Integer = [int]$Pages
                $Total += $Integer

                 if( $ErrorFile -eq $NULL ){
                    $ErrorFileValue = 0
                    
                    if( $Text -ne $null){
                        $OCR = 1
                        $OCRFile += $OCR

                        Write-Host $PartDigitalFile.BaseName ',' $ErrorFileValue ',' $PartDigitalFile.FullName ',' $Pages ',' $Pages ',' $OCR ','
                        $PartDigitalFile.BaseName + ',' + $ErrorFileValue + ',' + $PartDigitalFile.FullName + ',' + $Pages + ',' + $Pages + ',' + $OCR + ',' | Out-File $FileOutput -Append
                            
                    } else{
                        $OCR = 0
                        $OCRFile += $OCR
                            
                        Write-Host $PartDigitalFile.BaseName ',' $ErrorFileValue ',' $PartDigitalFile.FullName ',' $Pages ',' $Pages ',' $OCR ','
                        $PartDigitalFile.BaseName + ',' + $ErrorFileValue + ',' + $PartDigitalFile.FullName + ',' + $Pages + ',' + $Pages + ',' + $OCR + ',' | Out-File $FileOutput -Append
                    }
                } else {
                    $ErrorFileValue = 1

                    if( $Text -ne $null){
                        $OCR = 1
                        $OCRFile += $OCR

                        Write-Host $PartDigitalFile.BaseName ',' $ErrorFileValue ',' $PartDigitalFile.FullName ',' $Pages ',' $Pages ',' $OCR ','
                        $PartDigitalFile.BaseName + ',' + $ErrorFileValue + ',' + $PartDigitalFile.FullName + ',' + $Pages + ',' + $Pages + ',' + $OCR + ',' | Out-File $FileOutput -Append
                            
                    } else{
                        $OCR = 0
                        $OCRFile += $OCR

                        Write-Host $PartDigitalFile.BaseName ',' $ErrorFileValue ',' $PartDigitalFile.FullName ',' $Pages ',' $Pages ',' $OCR ','
                        $PartDigitalFile.BaseName + ',' + $ErrorFileValue + ',' + $PartDigitalFile.FullName + ',' + $Pages + ',' + $Pages + ',' + $OCR + ',' | Out-File $FileOutput -Append
                    }
                }
            }

            if( $OCRFile -eq $NumberOfDigitalFile ){
                $OCR = 1
                Write-Host "$NameItem, , , , $Total, $OCR, "
                Write-Output "$NameItem, , , , $Total, $OCR, " | Out-File $FileOutput -Append
            }else {
                $OCR = 0
                Write-Host "$NameItem, , , , $Total, $OCR, "
                Write-Output "$NameItem, , , , $Total, $OCR, " | Out-File $FileOutput -Append
            }

            $OCRFile = 0
            $Total = 0
        }
    }
}