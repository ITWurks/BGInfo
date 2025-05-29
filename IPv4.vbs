Set WMIService = GetObject("winmgmts:\\.\root\cimv2")
Set IPConfigSet = WMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration Where IPEnabled=TRUE")

For Each IPConfig in IPConfigSet
    IPAddresses = IPConfig.IPAddress
    If Not IsNull(IPAddresses) Then
        For Each IPAddress in IPAddresses
            If InStr(IPAddress, ":") = 0 Then ' Ignore IPv6
                Echo IPAddress
                Exit For
            End If
        Next
        Exit For
    End If
Next
