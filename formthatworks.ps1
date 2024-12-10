New-UDPage -Url "/CreateSharedMailbox" -Name "CreateSharedMailbox" -Content {
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
                New-UDTextbox -Id 'txtDisplayName' -Label 'Displayname' -Placeholder 'CM - Koerswedstrijd De zeven kamp' -HelperText 'Please respect naming conventions' -Style @{
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
                    $SamAccountName = (Get-UDElement -Id 'txtSamAccountName').value -replace '\s', ''
                    if ($SamAccountName)
                    {
                        # Ensure the length is at least 20 characters, or use the entire string
                        $TrimmedSamAccountName = if ($SamAccountName.Length -lt 19) { $eventdata } else { $SamAccountName.substring(0, 19) }
                   
                        $exists = Get-ADUser  $TrimmedSamAccountName 
                        write-host "Samaccountname is: $($exists.SamAccountName)"
                        if ($exists)
                        {
                            Set-UDElement -Id "txtSamAccountName" -Properties @{ Value = "$($TrimmedSamAccountName)" }
                            Set-UDElement -Id 'errorSamAccountName' -Properties @{ Content = "$TrimmedSamAccountName already exists onvalidate." }
                            Set-UDElement -id "txtSamAccountName" -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
                        }
                        else
                        {

                            Set-UDElement -Id 'errorSamAccountName' -Properties @{ Content = "" }
                            Set-UDElement -id "txtSamAccountName" -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
                        }
                   
                        Set-UDElement -Id "txtSamAccountName" -Properties @{ Value = "$TrimmedSamAccountName" } 
                    }
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

                New-UDTextbox -Id 'txtUPN' -Label 'UserPrincipalName' -Placeholder 'UPN' -value '' -Style @{
                    marginRight = '12px'
                    width       = '30%'
                }             -OnValidate {
                    $UPN = (Get-UDElement -Id 'txtUPN').value
                    if ( $UPN)
                    {
                        $exists = Get-ADUser -Filter { UserPrincipalName -like $UPN } -properties DisplayName, UserPrincipalName
                        write-host $exists
                        if ($exists)
                        {
                            $isValid = $false
                            Set-UDElement -Id 'errorUPN' -Properties @{ Content = "$UPN already exists onvalidate." }
                            Set-UDElement -id "txtUPN" -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
                        }
                        else
                        {

                            Set-UDElement -Id 'errorUPN' -Properties @{ Content = "" }
                            Set-UDElement -id "txtUPN" -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
                        }
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
            $SelectedOU = (Get-UDElement -Id 'selectOU').value
            $DisplayName = (Get-UDElement -Id 'txtDisplayName').value -replace '\s', ''
            $EmailDomain = switch ($SelectedOU)
            {
                "MC" { "@domain.com" }
                "CM" { "@domain.org" }
                "CMMC" { "@domain.gg" }
                default { "" }
            }
            Set-UDElement -Id 'txtEmail' -Properties @{ Value = "$DisplayName$EmailDomain" }
            #Compute UPN
            $UPN = (Get-UDElement -Id 'txtDisplayName').value -replace '\s', ''
            if ($UPN)
            {
                $TrimmedUPN = if ($UPN.Length -gt 13) { $UPN.substring(0, 13) } else { $UPN }
                write-host "wat staat er in upn  $TrimmedUPN"
                $exists = get-aduser -LDAPFilter "(userprincipalname=$TrimmedUPN*)" -properties DisplayName, UserPrincipalName
                write-host "wat staat er in exists $exists dynamic"
                if ($exists)
                {
                     Set-UDElement -Id "txtUPN" -Properties @{ Value = "$($TrimmedUPN+$EmailDomain)" }
                    Set-UDElement -Id 'errorUPN' -Properties @{ Content = "$($TrimmedUPN+$EmailDomain) already exists dynamic." }
                    Set-UDElement -id "txtUPN" -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
                }
                else
                {
                $TrimmedUPN = if ($UPN.Length -gt 13) { $UPN.substring(0, 13) } else { $UPN }
 
                    Set-UDElement -Id "txtUPN" -Properties @{ Value = "$($TrimmedUPN+$EmailDomain)" }
                    Set-UDElement -Id 'errorUPN' -Properties @{ Content = "" }
                    Set-UDElement -id "txtUPN" -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
                }
            }
            
            #Compute SamAccountName
            $SamAccountName = (Get-UDElement -Id 'txtDisplayName').value -replace '\s', ''
            if ($SamAccountName)
            {
                # Ensure the length is at least 20 characters, or use the entire string
                $TrimmedSamAccountName = if ($SamAccountName.Length -gt 19) { $SamAccountName.substring(0, 19) } else { $SamAccountName }
                
                $exists = Get-ADUser -Filter { SamAccountName -like $TrimmedSamAccountName } 
                write-host "dynamic chek on exist $exists"
                if ($exists)
                {
                    
                    Set-UDElement -Id "txtSamAccountName" -Properties @{ Value = "$($TrimmedSamAccountName)" }
                    Set-UDElement -Id 'errorSamAccountName' -Properties @{ Content = "$TrimmedSamAccountName already exists dynamic." }
                    Set-UDElement -id "txtSamAccountName" -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
                }
                else
                {

                    Set-UDElement -Id 'errorSamAccountName' -Properties @{ Content = "" }
                    Set-UDElement -id "txtSamAccountName" -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
                }
                   
                Set-UDElement -Id "txtSamAccountName" -Properties @{ Value = "$TrimmedSamAccountName" } 
            }
        }

    }    -OnSubmit {
        $isValid = $true
        $errorMessages = @()

        # Clear previous error messages
        Set-UDElement -Id 'errorDisplayName' -Properties @{ Content = "" }
        Set-UDElement -Id 'errorSamAccountName' -Properties @{ Content = "" }
        Set-UDElement -Id 'errorEmail' -Properties @{ Content = "" }

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
                Set-UDElement -id "txtDisplayName" -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
            }
            else
            {

                Set-UDElement -Id 'errorDisplayName' -Properties @{ Content = "" }
                Set-UDElement -id "txtDisplayName" -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
            }
        }

        # Validate SamAccountName
        $SamAccountName = (Get-UDElement -Id 'txtSamAccountName').value -replace '\s', ''
        if ($SamAccountName)
        {
            # Ensure the length is at least 20 characters, or use the entire string
            $TrimmedSamAccountName = if ($SamAccountName.Length -gt 19) { $SamAccountName.substring(0, 19) } else { $SamAccountName }
                
            $exists = Get-ADUser -Filter { SamAccountName -like $TrimmedSamAccountName } 
            write-host "dynamic chek on exist $exists"
            if ($exists)
            {
                    
                Set-UDElement -Id "txtSamAccountName" -Properties @{ Value = "$($TrimmedSamAccountName)" }
                Set-UDElement -Id 'errorSamAccountName' -Properties @{ Content = "$TrimmedSamAccountName already exists onsubmit." }
                Set-UDElement -id "txtSamAccountName" -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
            }
            else
            {

                Set-UDElement -Id 'errorSamAccountName' -Properties @{ Content = "" }
                Set-UDElement -id "txtSamAccountName" -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
            }
                   
            Set-UDElement -Id "txtSamAccountName" -Properties @{ Value = "$TrimmedSamAccountName" } 
        }

        # Validate Email
        if (-not $Email)
        {
            $isValid = $false
            Set-UDElement -Id 'errorEmail' -Properties @{ Content = "Email is required." }
        }

        # Validation for UPN (UserPrincipalName) - Check if it already exists
        if ($UPN)
        {
            $exists = Get-ADUser -Filter { UserPrincipalName -like $UPN } -properties DisplayName, UserPrincipalName
            if ($exists)
            {
                $isValid = $false
                Set-UDElement -Id 'errorUPN' -Properties @{ Content = "$UPN already exists onsubmit." }
                Set-UDElement -id "txtUPN" -Properties @{ Icon = (New-UDIcon -Icon Xmark -Style @{ color = 'red' }) }
            }
            else
            {

                Set-UDElement -Id 'errorUPN' -Properties @{ Content = "" }
                Set-UDElement -id "txtUPN" -Properties @{ Icon = (New-UDIcon -Icon Check -Style @{ color = 'green' }) }
            }
        }

        # If validation failed, prevent form submission
        if (-not $isValid)
        {
            return $false
        }

        # If validation passes, submit form (you can perform further actions here)
        Write-Host "Form submitted successfully"
    } 
}
