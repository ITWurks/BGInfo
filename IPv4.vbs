Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration where IPEnabled = TRUE")

Dim output, addr
output = ""

For Each objItem in colItems
    If Not IsNull(objItem.IPAddress) Then
        For Each addr in objItem.IPAddress
            If InStr(addr, ":") = 0 Then ' Exclude IPv6
                output = output & addr & vbCrLf
            End If
        Next
    End If
Next

Echo output
