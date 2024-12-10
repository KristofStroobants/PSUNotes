function global:My-Test2
{
	param (
		[string]$SourceElementId,
		[string]$InputElementId,
		[string]$ErrorElementId,
		[int]$MaxLength = 19,
		[string]$Action
	)

	$DisplayName = (Get-UDElement -Id $SourceElementId).value -replace '\s', ''
	$SamAccountName = (Get-UDElement -Id $InputElementId).value -replace '\s', ''
	Write-Host "triggered my-test2 by acction $Action."
	if ($DisplayName)
	{
		# Trim or use the entire string based on length
		if ($SamAccountName -eq '')
		{
			$TrimmedSamAccountName = if ($DisplayName.Length -gt $MaxLength) { $DisplayName.Substring(0, $MaxLength) } else { $DisplayName }
			Write-Host "scenarion 1 by acction $Action $SamAccountName"
		}
		else
		{
			$TrimmedSamAccountName = if ($DisplayName.Length -gt $MaxLength) { $DisplayName.Substring(0, $MaxLength) } else { $DisplayName }
			# $TrimmedSamAccountName = $SamAccountName
			Write-Host "scenarion 2 by acction $Action."
		}
		# Check if the SamAccountName already exists
		$exists = Get-ADUser -Filter { SamAccountName -eq $TrimmedSamAccountName }


	
		if ($exists)
		{
			Set-UDElement -Id $InputElementId -Properties @{
				Value = "$TrimmedSamAccountName"
				Icon  = (New-UDIcon -Icon Xmark -Style @{ color = 'red' })
			}
			Set-UDElement -Id $ErrorElementId -Properties @{
				Content = "$TrimmedSamAccountName already exists $Action."
			}
		}
		else
		{
			Set-UDElement -Id $ErrorElementId -Properties @{ Content = '' }
			Set-UDElement -Id $InputElementId -Properties @{
				Icon  = (New-UDIcon -Icon Check -Style @{ color = 'green' })
				Value = "$TrimmedSamAccountName"
			}
						Set-UDElement -Id $ErrorElementId -Properties @{
				Icon  = (New-UDIcon -Icon Check -Style @{ color = 'green' })
			}
		}
		 Set-UDElement -Id "txtSamAccountName" -Properties @{ Value = "$TrimmedSamAccountName" } 
	}
}
