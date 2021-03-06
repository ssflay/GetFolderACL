import-module activedirectory

$checkPath = "C:\ACLreport"
if (!(test-path $checkPath))
{
	New-Item C:\ACLreport -itemtype Directory
}


$inpath = read-host -Prompt "Enter the folder path to get ACL from"
$reportname = read-host -Prompt "Enter report name (ex. report.csv). Report wil be saved in C:\ACLreport"

#Create CSV Header
$outpath = $checkPath+"\"+$reportname
$outputTab = @"
FIO;Account;FolderPath;AccessType;Rights;MemberOf
"@
$outputTab | set-content $outpath

$groups = get-acl -Path $inpath | Select-Object -ExpandProperty Access | Where-Object {$_.IdentityReference -notlike "BUILTIN*"} 

foreach ($group in $groups) 
{
	$tempgroup = ($group.IdentityReference).Translate('system.security.principal.securityidentifier')
	$acctype = $group.AccessControlType
	$rights = $group.FileSystemRights
	$memberof = $group.IdentityReference
	
	$groupmember = Get-ADGroupMember -Identity $tempgroup -recursive
	foreach ($member in $groupmember)
	{
		$outName = (get-aduser -identity $member).Name
		$outAcc = (get-aduser -identity $member).samaccountname
		Add-Content $outpath "$outName;$outAcc;$inpath;$acctype;$rights;$memberof"
	}
	
	clear-variable -name tempgroup
	clear-variable -name groupmember
	clear-variable -name outName
	clear-variable -name outAcc
	clear-variable -name acctype
	clear-variable -name rights
	clear-variable -name memberof
}