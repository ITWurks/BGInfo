strComputer = "."
On Error Resume Next

Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colSettings = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")

Dim gatewayFound
gatewayFound = False

For Each objIP in colSettings
    If Not IsNull(objIP.DefaultIPGateway) Then
        For i = LBound(objIP.DefaultIPGateway) To UBound(objIP.DefaultIPGateway)
            ' Only IPv4 gateway
            If InStr(objIP.DefaultIPGateway(i), ":") = 0 Then
                Echo objIP.DefaultIPGateway(i)
                gatewayFound = True
                Exit For
            End If
        Next
    End If
    If gatewayFound Then Exit For
Next

If Not gatewayFound Then Echo "No IPv4 Gateway Found"
