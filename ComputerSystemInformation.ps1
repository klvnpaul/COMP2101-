function Get-SystemInfo {
    $systemInfo = @{
        HardwareDescription = Get-CimInstance Win32_ComputerSystem
        OSInfo              = Get-CimInstance Win32_OperatingSystem
        ProcessorInfo       = Get-CimInstance Win32_Processor
        MemoryInfo          = Get-CimInstance Win32_PhysicalMemory
        DiskInfo            = Get-DiskInfo
        NetworkInfo         = Get-NetworkInfo
        VideoCardInfo       = Get-VideoCardInfo
    }

    return $systemInfo
}

function Get-DiskInfo {
    $diskInfo = @()
    $diskdrives = Get-CimInstance CIM_DiskDrive

    foreach ($disk in $diskdrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName CIM_DiskPartition
        foreach ($partition in $partitions) {
            $logicaldisks = $partition | Get-CimAssociatedInstance -ResultClassName CIM_LogicalDisk
            foreach ($logicaldisk in $logicaldisks) {
                $diskInfo += [PSCustomObject]@{
                    Manufacturer     = $disk.Manufacturer
                    Location         = $partition.DeviceID
                    Drive            = $logicaldisk.DeviceID
                    "Size(GB)"       = [math]::Round($logicaldisk.Size / 1GB)
                    "Free Space(GB)" = [math]::Round($logicaldisk.FreeSpace / 1GB)
                    "% Free Space"   = [math]::Round(($logicaldisk.FreeSpace / $logicaldisk.Size) * 100)
                }
            }
        }
    }

    return $diskInfo
}

function Get-NetworkInfo {
    $networkAdapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

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

    return $adapterInfo
}

function Get-VideoCardInfo {
    $videoControllers = Get-CimInstance Win32_VideoController

    $videoInfo = @()

    foreach ($controller in $videoControllers) {
        $videoData = [PSCustomObject]@{
            Vendor      = $controller.AdapterCompatibility
            Description = $controller.Description
            Resolution  = "$($controller.CurrentHorizontalResolution) x $($controller.CurrentVerticalResolution)"
        }
        $videoInfo += $videoData
    }

    return $videoInfo
}

$systemInfo = Get-SystemInfo

# Display the system information report
Write-Host "System Hardware Description:"
$systemInfo.HardwareDescription | Format-List

Write-Host "Operating System Information:"
$systemInfo.OSInfo | Format-List

Write-Host "Processor Information:"
$systemInfo.ProcessorInfo | Format-List

Write-Host "Memory Information:"
$systemInfo.MemoryInfo | Format-Table -AutoSize -Property Manufacturer, PartNumber, Description, Capacity, BankLabel, DeviceLocator

Write-Host "Disk Drive Information:"
$systemInfo.DiskInfo | Format-Table -AutoSize -Property Manufacturer, Location, Drive, "Size(GB)", "Free Space(GB)", "% Free Space"

Write-Host "Network Adapter Configuration:"
$systemInfo.NetworkInfo | Format-Table -AutoSize -Property Description, Index, IPAddress, SubnetMask, DNSDomain, DNSServer

Write-Host "Video Card Information:"
$systemInfo.VideoCardInfo | Format-Table -AutoSize -Property Vendor, Description, Resolution