Set-Alias -Name pn -Value pnpm
Set-Alias -Name vim -Value nvim

Oh-My-Posh init pwsh --config "$env:POSH_THEMES_PATH\powerlevel10k_modern.omp.json" | Invoke-Expression

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
  Import-Module "$ChocolateyProfile"
}

function Update-File
{
  param (
    [string[]]$Paths,
    [switch]$NoCreate,
    [switch]$AccessTime,
    [switch]$ModifyTime,
    [string]$Date,
    [string]$Timestamp,
    [string]$Reference,
    [switch]$NoDereference,
    [switch]$Help
  )

  # Handle long flags
  for ($i = 0; $i -lt $args.Length; $i++)
  {
    switch -wildcard ($args[$i])
    {
      '--no-create'
      { $NoCreate = $true 
      }
      '--access-time'
      { $AccessTime = $true 
      }
      '--modify-time'
      { $ModifyTime = $true 
      }
      '--date'
      { $Date = $args[$i + 1]; $i++ 
      }
      '--time'
      { $Timestamp = $args[$i + 1]; $i++ 
      }
      '--reference'
      { $Reference = $args[$i + 1]; $i++ 
      }
      '--no-dereference'
      { $NoDereference = $true 
      }
      '--help'
      { $Help = $true 
      }
      default
      { $Paths += $args[$i] 
      }
    }
  }

  if ($Help)
  {
    Write-Host "Usage: touch [OPTIONS] FILE..."
    Write-Host "Update the access and modification times of each FILE to the current time."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -c, --no-create       do not create any files"
    Write-Host "  -a, --access-time     change only the access time"
    Write-Host "  -m, --modify-time     change only the modification time"
    Write-Host "  -d, --date=STRING     parse STRING and use it instead of current time"
    Write-Host "  -t, --time=STAMP      use [[CC]YY]MMDDhhmm[.ss] instead of current time"
    Write-Host "  -r, --reference=FILE  use this file's times instead of current time"
    Write-Host "  -h, --no-dereference  affect symbolic links instead of any referenced file"
    Write-Host "      --help            display this help and exit"
    return
  }

  if (-not $Paths)
  {
    Write-Error "No files specified."
    return
  }

  foreach ($Path in $Paths)
  {
    if (-not (Test-Path -Path $Path) -and -not $NoCreate)
    {
      New-Item -ItemType File -Path $Path
    } elseif (Test-Path -Path $Path)
    {
      if ($Reference)
      {
        $refItem = Get-Item $Reference
        $refAccessTime = $refItem.LastAccessTime
        $refModifyTime = $refItem.LastWriteTime
      } else
      {
        $currentTime = Get-Date
        $refAccessTime = $currentTime
        $refModifyTime = $currentTime
      }

      if ($AccessTime)
      {
        Set-ItemProperty -Path $Path -Name LastAccessTime -Value $refAccessTime
      }

      if ($ModifyTime)
      {
        Set-ItemProperty -Path $Path -Name LastWriteTime -Value $refModifyTime
      }

      if (-not $AccessTime -and -not $ModifyTime)
      {
        Set-ItemProperty -Path $Path -Name LastAccessTime -Value $refAccessTime
        Set-ItemProperty -Path $Path -Name LastWriteTime -Value $refModifyTime
      }

      if ($Date)
      {
        $dateValue = [datetime]::Parse($Date)
        if ($AccessTime)
        {
          Set-ItemProperty -Path $Path -Name LastAccessTime -Value $dateValue
        }
        if ($ModifyTime)
        {
          Set-ItemProperty -Path $Path -Name LastWriteTime -Value $dateValue
        }
        if (-not $AccessTime -and -not $ModifyTime)
        {
          Set-ItemProperty -Path $Path -Name LastAccessTime -Value $dateValue
          Set-ItemProperty -Path $Path -Name LastWriteTime -Value $dateValue
        }
      }

      if ($Timestamp)
      {
        $timestampValue = [datetime]::ParseExact($Timestamp, 'yyyyMMddHHmm.ss', $null, [System.Globalization.CultureInfo]::InvariantCulture)
        Set-ItemProperty -Path $Path -Name LastAccessTime -Value $timestampValue
        Set-ItemProperty -Path $Path -Name LastWriteTime -Value $timestampValue
      }
    }
  }
}


Set-Alias -Name touch -Value Update-File
