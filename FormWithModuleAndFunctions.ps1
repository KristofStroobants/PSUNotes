New-UDPage -Url '/CreateSharedMailbox' -Name 'Domain - Koerswedstrijd De zevenkamp' -Content {
	New-UDForm -Content {
		# OU Dropdown
		New-UDRow -Columns {
			New-UDColumn -Size 2 -Content {
				New-UDSelect -Id 'selectOU' -Label 'OU' -Option {
					New-UDSelectOption -Name 'CMMC' -Value 'CMMC'
					New-UDSelectOption -Name 'CM' -Value 'CM'
					New-UDSelectOption -Name 'MC' -Value 'MC'
				} -OnChange {
					Sync-UDElement -Id 'dynamicContent'
				}
			} 
		}

		# Display Name Input
		New-UDRow -Columns {
			New-UDColumn -Size 2 -Content {
				New-UDTextbox -Id 'txtDisplayName' -Label 'Displayname' -Placeholder 'Domain - Koerswedstrijd De zeven kamp' -HelperText 'Please respect naming conventions' -Style @{
					marginRight = '12px'
					width       = '30%'
				} -OnChange {
					Sync-UDElement -Id 'dynamicContent'
				}
			}
			New-UDElement -Tag 'div' -Id 'errorDisplayName' -Attributes @{
				style = @{
					color = 'red'
				}
			}
		}

		# SamAccountName Input
		New-UDRow -Columns {
			New-UDColumn -Size 2 -Content {
				New-UDTextbox -Id 'txtSamAccountName' -Label 'SamAccountName' -Placeholder 'SamAccountName' -Style @{
					marginRight = '12px'
					width       = '30%'
				} -OnValidate {
					# $SamAccountName = (Get-UDElement -Id 'txtSamAccountName').value -replace '\s', ''
					My-Test2 -SourceElementId 'txtSamAccountName' -InputElementId 'txtSamAccountName' -ErrorElementId 'errorSamAccountName' -Action 'onvalidate'
				}
			} 
			New-UDElement -Tag 'div' -Id 'errorSamAccountName'  -Attributes @{
				style = @{
					color = 'red'
				}
			}
		}

		# Email Input
		New-UDRow -Columns {
			New-UDColumn -Size 2 -Content {
				New-UDTextbox -Id 'txtEmail' -Label 'Email' -Placeholder 'Email' -Style @{
					marginRight = '12px'
					width       = '30%'
				}
			}
			New-UDElement -Tag 'div' -Id 'errorEmail'  -Attributes @{
				style = @{
					color = 'red'
				}
			}
		}

		# UPN Input
		New-UDRow -Columns {
			New-UDColumn -Size 2 -Content {

				New-UDTextbox -Id 'txtUPN' -Label 'UserPrincipalName' -Placeholder 'UPN' -Value '' -Style @{
					marginRight = '12px'
					width       = '30%'
				}             -OnValidate {
					$UPN = (Get-UDElement -Id 'txtUPN').value
					if ( $UPN)
					{
						$exists = Get-ADUser -Filter { UserPrincipalName -like $UPN } -Properties DisplayName, UserPrincipalName
						Write-Host $exists
						if ($exists)
						{
							$isValid = $false
							Set-UDElement -Id 'errorUPN' -Properties @{ Content = "$UPN already exists onvalidate." }
							Set-UDElement -Id 'txtUPN' -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
						}
						else
						{
							Set-UDElement -Id 'errorUPN' -Properties @{ Content = '' }
							Set-UDElement -Id 'txtUPN' -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
						}
						Set-UDElement -Id "txtUPN" -Properties @{ Value = "$UPN" } 
					}
				}
            
				New-UDElement -Tag 'div' -Id 'errorUPN'  -Attributes @{
					style = @{
						color = 'red'
					}
				}
			}
		}

		# Dynamic Content for Dependent Fields
		New-UDDynamic -Id 'dynamicContent' -Content {
            Write-Host ('-' * 50)
			$SelectedOU = (Get-UDElement -Id 'selectOU').value
			$DisplayName = (Get-UDElement -Id 'txtDisplayName').value -replace '\s', ''
			$EmailDomain = switch ($SelectedOU)
			{
				'MC' { '@mdomain.be' }
				'CM' { '@domain.com' }
				'CMMC' { '@domain.gg' }
				default { '' }
			}
			Set-UDElement -Id 'txtEmail' -Properties @{ Value = "$DisplayName$EmailDomain" }
			
			#Compute UPN
			$UPN = (Get-UDElement -Id 'txtDisplayName').value -replace '\s', ''
			if ($UPN)
			{
				$TrimmedUPN = if ($UPN.Length -gt 13) { $UPN.substring(0, 13) } else { $UPN }
				Write-Host "wat staat er in upn  $TrimmedUPN"
				$exists = Get-ADUser -LDAPFilter "(userprincipalname=$($TrimmedUPN+$EmailDomain)*)" -Properties DisplayName, UserPrincipalName
				Write-Host "wat staat er in exists $exists dynamic"
				if ($exists)
				{
					Set-UDElement -Id 'txtUPN' -Properties @{ Value = "$($TrimmedUPN+$EmailDomain)" }
					Set-UDElement -Id 'errorUPN' -Properties @{ Content = "$($TrimmedUPN+$EmailDomain) already exists dynamic." }
					Set-UDElement -Id 'txtUPN' -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
				}
				else
				{
					$TrimmedUPN = if ($UPN.Length -gt 13) { $UPN.substring(0, 13) } else { $UPN }
 
					Set-UDElement -Id 'txtUPN' -Properties @{ Value = "$($TrimmedUPN+$EmailDomain)" }
					Set-UDElement -Id 'errorUPN' -Properties @{ Content = '' }
					Set-UDElement -Id 'txtUPN' -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
				}
			}
            
			#Compute SamAccountName
			$SamAccountName = (Get-UDElement -Id 'txtDisplayName').value -replace '\s', ''
			if ($SamAccountName)
			{
				import-module "C:\ProgramData\UniversalAutomation\Repository\Modules\DelegationToolModule\1.0\DelegationToolModule.psm1"
				write-host  'ik was hier he'
				My-Test2 -SourceElementId 'txtDisplayName' -InputElementId 'txtSamAccountName' -ErrorElementId 'errorSamAccountName' -Action 'dynamic'
			}
		}

	}    -OnSubmit {
		$isValid = $true
		$errorMessages = @()

		# Clear previous error messages
		Set-UDElement -Id 'errorDisplayName' -Properties @{ Content = '' }
		Set-UDElement -Id 'errorSamAccountName' -Properties @{ Content = '' }
		Set-UDElement -Id 'errorEmail' -Properties @{ Content = '' }

		# Fetch inputs
		$DisplayName = (Get-UDElement -Id 'txtDisplayName').value
		$SamAccountName = (Get-UDElement -Id 'txtSamAccountName').value
		$Email = (Get-UDElement -Id 'txtEmail').value
		$UPN = (Get-UDElement -Id 'txtUPN').value

		# Validate DisplayName
		if ($DisplayName)
		{
			if ($DisplayName -notmatch '^\w.* - \w.*$')
			{
				$isValid = $false
				Set-UDElement -Id 'errorDisplayName' -Properties @{ Content = "Display name doesn't meet requirements." }
				Set-UDElement -Id 'txtDisplayName' -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
			}
			else
			{
				Set-UDElement -Id 'errorDisplayName' -Properties @{ Content = '' }
				Set-UDElement -Id 'txtDisplayName' -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
			}
		}

		# Validate SamAccountName
		My-Test2 -SourceElementId 'txtSamAccountName' -InputElementId 'txtSamAccountName' -ErrorElementId 'errorSamAccountName' -Action 'submit'

		# Validate Email
		if (-not $Email)
		{
			$isValid = $false
			Set-UDElement -Id 'errorEmail' -Properties @{ Content = 'Email is required.' }
		}

		# Validation for UPN (UserPrincipalName) - Check if it already exists
		if ($UPN)
		{
			$exists = Get-ADUser -Filter { UserPrincipalName -like $UPN } -Properties DisplayName, UserPrincipalName
			if ($exists)
			{
				$isValid = $false
				Set-UDElement -Id 'errorUPN' -Properties @{ Content = "$UPN already exists onsubmit." }
				Set-UDElement -Id 'txtUPN' -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
			}
			else
			{
				Set-UDElement -Id 'errorUPN' -Properties @{ Content = '' }
				Set-UDElement -Id 'txtUPN' -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
			}
		}

		# If validation failed, prevent form submission
		if (-not $isValid)
		{
			return $false
		}

		# If validation passes, submit form (you can perform further actions here)
		Write-Host 'Form submitted successfully'
	} 
}
