# PS script to compile and run a C program or module.
    Param (
    [Parameter(Position = 0, Mandatory=$True)]
    [ValidateNotNull()]
    $source_file)

Function EndOfJob()
{
    # restore environment PATH
    Set-Item -Path Env:Path -Value $originalPath
    Read-Host -Prompt "`n> End of program. Press ENTER to continue."
    exit
}

# temporarily add MinGW folder to environment PATH
$originalPath = $Env:Path
Set-Item -Path Env:Path -Value ("C:\Program Files (x86)\mingw-w64\mingw32\bin;" + $Env:Path )

if ($source_file -eq "")
{
    Write-Host "*** no source file input ***"
    EndOfJob
}
elseif (-not (Test-Path -Path $source_file))
{
    Write-Host "source file not found: " $source_file
    EndOfJob
}

Write-Host "`nCompile C source file" $source_file 
$source_file_name = (Get-Item $source_file ).Basename # file name without extension

# compile source file as source filename(.exe)

if (Select-String -Path $source_file -Pattern "main(" -SimpleMatch -Quiet)
{
    # source.c contains main()
    gcc $source_file -o $source_file_name
}
else
{
    # -nostartfiles switch allows compilation without main()
    gcc -nostartfiles $source_file -o $source_file_name
}


if ($LastExitCode -ne 0)
{
    echo "See above compilation related error."
}

if (-not (Test-Path -Path ($source_file_name + ".exe")))
{
    Write-Host "Executable not found for " $source_file_name "`nCheck Security / Protected folder access blocked for 'ld.exe' or 'as.exe'`nor a source code compile error."
    EndOfJob
}

Write-Host "> Running" $source_file_name "`n"
& .\$source_file_name

EndOfJob
