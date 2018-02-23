<#
.Synopsis
   
.DESCRIPTION
   
.EXAMPLE
   
#>


$session = New-PSSession automation -Authentication Credssp -Credential (Get-Credential campus\nme47)
Copy-Item -Path 'C:\temp\20180215 AW Leavers list with logonids for Lucy.csv' -ToSession $session -Destination C:\temp
Enter-PSSession -Session $session
$FIMServiceUri = 'http://mimadmin.ncl.ac.uk:5725'
Add-PSSnapin fimautomation
$ADCred = Get-Credential -UserName 'campus\sme47' -Message "please enter password"

$users = Import-Csv -Path 'C:\temp\20180215 AW Leavers list with logonids for Lucy.csv'
$fimUsers = @()
foreach($user in $users) {

    $personelNo = $user.pern

    #if($user.'HR Action' -like "Leaver action to be processed to make immediate leaver."){
        $fimuser = Export-FIMConfig -Uri $FIMServiceUri -OnlyBaseResources -CustomConfig "/Person[SAPNumbers = $personelNo]"
        $fimuser = $fimuser | Convert-FimExportToPSObject
        #$fimuser
        $fimobject = New-Object -TypeName psobject
        $fimobject | Add-Member -MemberType NoteProperty -name AccountName -Value $fimuser.AccountName
        $fimobject | Add-Member -MemberType NoteProperty -name Disabled -Value $fimuser.Disabled
        $fimobject | Add-Member -MemberType NoteProperty -name EmployeeID -Value $fimuser.EmployeeID
        $fimobject | Add-Member -MemberType NoteProperty -name Email -Value $fimuser.Email
        $fimobject | Add-Member -MemberType NoteProperty -name NCLAccountType -Value $fimuser.NCLAccountType
        $fimobject | Add-Member -MemberType NoteProperty -name NCLKnownAs -Value $fimuser.NCLKnownAs
        $fimobject | Add-Member -MemberType NoteProperty -name NCLForenames -Value $fimuser.NCLForenames
        $fimobject | Add-Member -MemberType NoteProperty -name LastName -Value $fimuser.LastName
        $fimobject | Add-Member -MemberType NoteProperty -name DisplayName -Value $fimuser.DisplayName
        $fimobject | Add-Member -MemberType NoteProperty -name SAPGroup -Value $fimuser.SAPGroup
        $fimobject | Add-Member -MemberType NoteProperty -name SAPSubgroup -Value $fimuser.SAPSubgroup
        $fimobject | Add-Member -MemberType NoteProperty -name OrganizationalUnit -Value $user.'Organizational Unit'
        $fimobject | Add-Member -MemberType NoteProperty -name Position -Value $user.Position
        $fimobject | Add-Member -MemberType NoteProperty -name Fac -Value $user.Fac
        $fimobject | Add-Member -MemberType NoteProperty -name ContBeg -Value $user.ContBeg
        $fimobject | Add-Member -MemberType NoteProperty -name PlEnddate -Value $user.PlEnddate
        $fimobject | Add-Member -MemberType NoteProperty -name Action -Value $user.Action
        $fimobject | Add-Member -MemberType NoteProperty -name HRAction -Value $user.'HR action'
        $ADinfo = Get-aduser -Identity $($fimuser.AccountName) -property LastLogonDate -Credential $ADCred
        $fimobject | Add-Member -MemberType NoteProperty -name LastLogonDate -Value $ADinfo.LastLogonDate
        $fimobject | Add-Member -MemberType NoteProperty -name Enabled -Value $ADinfo.Enabled
        $fimobject | Add-Member -MemberType NoteProperty -name UserPrincipalName -Value $ADinfo.UserPrincipalName
        $fimusers += $fimobject
    #}
}

$fimusers | Export-Csv -Path c:\temp\HRData.csv -NoTypeInformation

