$SQLInstance = "itsys-sccm"
$SQLDatabase = "CM_PS2"
$search = "
    select
    Name0,
    Creation_Date0,
    Distinguished_Name0,
    Last_Logon_Timestamp0,
    Operating_System_Name_and0
    from v_R_System vrs
    where Operating_System_Name_and0 like 'Microsoft Windows%'
    and Client0 is null
    and Distinguished_Name0 not like '%OU=LIB-Test,DC=ad,DC=siu,DC=edu'
    and Distinguished_Name0 not like '%OU=VDI,DC=ad,DC=siu,DC=edu'
    and Distinguished_Name0 not like '%OU=Servers,DC=ad,DC=siu,DC=edu'
    Order by Name0
    "