$instances = gci HKLM:Software\Oracle\KEY*, HKLM:Software\Oracle\HOME* |
               select @{n= "SID"; e= {if ( $_.GetValue( "Oracle_SID") -eq $null) { $_.GetValue( "ID")}
                                     else {$_.GetValue("Oracle_SID" )}}},
                      @{n ="Oracle_Home"; e ={$_.GetValue("Oracle_Home" )}}

$instances.Oracle_Home
$instances.SID
