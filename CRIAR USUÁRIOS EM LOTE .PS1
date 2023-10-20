# Configurações
$csvFilePath = "C:\AD.csv"
$ouPath = "OU=Alunos,DC=uneflabs,DC=corp"
$errorReportPath = "C:\erros_SCRIP_ALUNOS_AD.txt"

# Inicializar lista de erros
$errors = @()

# Carregar os dados do arquivo CSV
$csvData = Import-Csv -Path $csvFilePath

# Loop através dos dados do CSV
foreach ($row in $csvData) {
    $login = $row.RA
    $nome = $row.NOME
    $senha = $row.CPF

    $newUserParams = @{
        Name = $nome  # Usar o nome completo para o campo "Name"
        DisplayName = $nome
        SamAccountName = $login
        UserPrincipalName = "$login@uneflabs.corp"
        AccountPassword = (ConvertTo-SecureString $senha -AsPlainText -Force)
        Enabled = $true
        Path = $ouPath  # Especificar a OU onde os usuários serão criados
    }

    try {
        New-ADUser @newUserParams
    } catch {
        $errorInfo = @{
            Login = $login
            Nome = $nome
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
    Write-Host "Nenhum erro foi encontrado durante a execução."
}
