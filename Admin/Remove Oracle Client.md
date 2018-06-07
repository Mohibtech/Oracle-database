# Uninstalling Oracle Overview:
* Log in as the Administrator.
* Stop all Oracle Services.
* deinstall.batch from ORACLE_HOME/deinstall directory 
    - C:\app\oracle\product\11.2.0\dbhome_1\deinstall\deinstall.bat [usual path]
* Delete the C:\app\oracle directory.

# Find Oracle Registry Entries
```powershell
Get-Item -Path HKLM:\SOFTWARE\Oracle                                    
Get-Item -Path HKLM:\SOFTWARE\Wow6432Node\Ora*                                  
Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\Ora*
```

# Remove Oracle Registry Entries
```powershell
Get-Item -Path HKLM:\SOFTWARE\Oracle  | remove-item -confirm                                   
Get-Item -Path HKLM:\SOFTWARE\Wow6432Node\Ora*  | remove-item -confirm                                    
Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\Ora*  | remove-item -confirm
```

# Manually remove the registry entry, OracleDBConsoleSID:
> HKLM\System\CurrentControlSet\Services\EventLog\Application\Oracle*

## OraInventory 
Windows: C:\\Program Files\Oracle\Inventory\logs\

