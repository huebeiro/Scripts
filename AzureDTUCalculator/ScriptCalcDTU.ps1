<#
    .SYNOPSIS
	Coleta de contadores requisitado pela calculadora DTU da Azure.

    .DESCRIPTION
    O Script faz uso do comando Get-Counter para buscar informações 
	de processamento/discos lógicos do sistema e cria os resultados em CSV.
	Script baseado no script disponibilizado por Justin Henriksen 
	( http://justinhenriksen.wordpress.com ) e adaptado para funcionamento no
	Windows Server regionalizado PT-BR.
	Use por sua conta e risco.

    .NOTES
    Versão: 1.1
    Criação: May 1, 2015
    Ult. Modificação: March 15, 2021
    Autor: Justin Henriksen ( http://justinhenriksen.wordpress.com )    
	Modificado por: Adilson Ribeiro
#>


Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

cls

Write-Output "Coletando contadores..."
Write-Output "Aperte Ctrl+C para sair."

#caminho de destino 
$file = 'C:\Users\Administrador\Desktop\Analise\Result\calc-dtu.csv'

<# 	
	Lista de contadores a serem obtidos.
	É possível obter a lista de contadores so sistema
	através do comando: Get-Counter -ListSet *
#>
$counters = @("\\win-6gshas0193g\processador(_total)\% de tempo do processador", 
"\Sistema\Operações de leitura de ficheiro/seg", 
"\Sistema\Operações de escrita de ficheiro/seg", 
"\SQLServer:Databases(_Total)\Log Bytes Flushed/sec") 

$samples = 5

Get-Counter -Counter $counters -SampleInterval 1 -MaxSamples $samples | 
    Export-Counter -FileFormat csv -Path $file -Force
	
	
#A calculadora Azure espera um header para os calculos de DTU
$header = '"Event Time","% Processor Time","Disk Reads/sec","Disk Writes/sec","Log Bytes Flushed/sec"'

$content = Get-Content $file | Select-Object -Skip 1

.{
    $header
    $content
} |
Set-Content $file