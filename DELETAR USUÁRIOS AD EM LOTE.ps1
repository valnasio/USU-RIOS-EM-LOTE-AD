# Configurações
$csvFilePath = "C:\AD.csv" # <---- altere para o caminho e nome do arquivo csv com os dafos
$errorReportPath = "C:\erros_EXCLUSAO_AD.txt" # <------- gera os logs de erro 

# Inicializar lista de erros
$errors = @()

# Carregar os dados do arquivo CSV
$csvData = Import-Csv -Path $csvFilePath

# Loop através dos dados do CSV
foreach ($row in $csvData) {
    $login = $row.RA

    try {
        Get-ADUser -Filter {SamAccountName -eq $login} | Remove-ADUser -Confirm:$false -ErrorAction Stop
    } catch {
        $errorInfo = @{
            Login = $login
            Erro = $_.Exception.Message
        }
        $errors += New-Object PSObject -Property $errorInfo
    }
}

# Gerar relatório de erros
if ($errors.Count -gt 0) {
    $errors | Export-Csv -Path $errorReportPath -NoTypeInformation
    Write-Host "Foram encontrados erros. Detalhes foram salvos em $errorReportPath."
} else {
    Write-Host "Exclusão de usuários concluída sem erros."
}
