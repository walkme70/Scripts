$_exe = "m4v"
Get-ChildItem *.$_exe -Recurse | Rename-Item -NewName {$_.Name.Replace("[","(") }
Get-ChildItem *.$_exe -Recurse | Rename-Item -NewName {$_.Name.Replace("]",")") }