# This is the NAV Powershell commands
& "C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\NavModelTools.ps1"

## Directions
# Prerequisites before running this script
# Either using Azure DevOps or GitHub or Local Git Repository
# Git Clone or Git Init
# Run this file inside the git repository.

# Once script has ran, run Git commit
# Then git push to upload file to the DevOps or GitHUb

#Files will be named to these.  
#Codeunit\Codeunit 0000000008.txt
#MenuSuite\MenuSuite 0000001010.txt
#Page\Page 0000000001.txt
#Query\Query 0000000019.txt
#Report\Report 0000000002.txt
#Table\Table 0000000003.txt
#XMLPort\XMLport 0000000001.txt

$DBServer = "navdb.domain.com.com"
$DBList = @("NAVBC", "NAVBCDEV", "NAVBCQA")  # Names of NAV databases
$TypeList = @("Codeunit", "MenuSuite", "Page", "Query", "Report", "Table", "XMLport") #objects to export

$scriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptLocation
Get-Location

git reset --hard # discard all local changes and pull the latest changes from the remote repository
git pull    # pull the latest changes from the remote repository

foreach($DB in $DBList){
    foreach($Type in $TypeList) {
        $FileName = $DB + "-" + $Type + ".txt"
        $folderPath = ".\CAL-$DB\$Type"
        $Filter = "Type=" + $Type
        New-Item -ItemType Directory -Force -Path $folderPath
        Remove-Item $folderPath\* -Force
        Export-NAVApplicationObject .\$FileName -DatabaseServer $DBServer -DatabaseName $DB -ExportTxtSkipUnlicensed -Filter $Filter
        Split-NAVApplicationObjectFile -Source .\$FileName -Destination $folderPath
        Remove-Item .\$FileName -Force
        $files = Get-ChildItem -Path $folderPath
        foreach($file in $files) {
            # Use regex to find the number in the filename
            if ($file.Name -match "(\D+)(\d+)(\.\w+)") {
                #$prefix = $matches[1]
                $number = $matches[2]
                $extension = $matches[3]

                # Pad the number with leading zeros to make it 10 digits long
                $paddedNumber = $number.PadLeft(10, '0')

                # Construct the new filename
                $newName = "$Type $paddedNumber$extension"

                # Rename the file
                Rename-Item -Path $file.FullName -NewName $newName
            }
        }
    }
}


git status
Write-Output "Please run the following commands in order if there are any pending changes."
Write-Output "git add ."
Write-Output "git commit -m ""Description""
Write-Output "git push"
#git add .
#git commit -m "Script Update"
#git push
