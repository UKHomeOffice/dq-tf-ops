Add-Computer -DomainName $domain -ComputerName $env:computername -NewName "BASTION-WIN3" -options JoinWithNewName -Credential $credential -restart -force
New-Item -Path C:\Users\Public\Desktop\ -Name "testfile1.txt" -ItemType "file" -Value "This is a text string."
