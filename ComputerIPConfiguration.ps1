
# code to get the network adapter configuration objects
$networkAdapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

# Create a custom object to store adapter information
$adapterInfo = @()

foreach ($adapter in $networkAdapters) {
    $adapterData = [PSCustomObject]@{
        Description = $adapter.Description
        Index       = $adapter.Index
        IPAddress   = $adapter.IPAddress -join ', '
        SubnetMask  = $adapter.IPSubnet -join ', '
        DNSDomain   = $adapter.DNSDomain
        DNSServer   = $adapter.DNSServerSearchOrder -join ', '
    }
    $adapterInfo += $adapterData
}

# Code to display the adapter information in a formatted table
$adapterInfo | Format-Table -AutoSize -Property Description, Index, IPAddress, SubnetMask, DNSDomain, DNSServer