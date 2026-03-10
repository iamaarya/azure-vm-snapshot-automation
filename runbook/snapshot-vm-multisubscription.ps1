param(
    [string]$TagName = "Snapshot",
    [string]$TagValue = "Yes"
)

Connect-AzAccount -Identity
Write-Output "[INFO] Connected to Azure using Managed Identity"

$subscriptions = Get-AzSubscription
Write-Output "[INFO] Total subscriptions found: $($subscriptions.Count)"

foreach ($subscription in $subscriptions) {

    Write-Output "----------------------------------------"
    Write-Output "[INFO] Switching to subscription: $($subscription.Name)"

    Set-AzContext -SubscriptionId $subscription.Id | Out-Null

    $vms = Get-AzVM
    Write-Output "[INFO] VMs found: $($vms.Count)"

    foreach ($vm in $vms) {

        if ($vm.Tags[$TagName] -ne $TagValue) {
            Write-Output "[INFO] Skipping VM (tag not matched): $($vm.Name)"
            continue
        }

        $vmName = $vm.Name
        $rgName = $vm.ResourceGroupName

        Write-Output "[INFO] Processing VM: $vmName"

        # Refresh VM object
        $vmDetail = Get-AzVM -ResourceGroupName $rgName -Name $vmName

        # ---------------- OS DISK ----------------

        $osDiskName = $vmDetail.StorageProfile.OsDisk.Name
        Write-Output "[INFO] OS Disk detected: $osDiskName"

        try {

            $osDisk = Get-AzDisk -ResourceGroupName $rgName -DiskName $osDiskName

            $snapshotName = "$vmName-osdisk-$(Get-Date -Format 'yyyyMMddHHmmss')"

            $snapshotConfig = New-AzSnapshotConfig `
                -SourceResourceId $osDisk.Id `
                -Location $osDisk.Location `
                -CreateOption Copy

            New-AzSnapshot `
                -SnapshotName $snapshotName `
                -ResourceGroupName $rgName `
                -Snapshot $snapshotConfig

            Write-Output "[INFO] OS snapshot created: $snapshotName"

        }
        catch {
            Write-Output "[ERROR] Failed to snapshot OS disk for $vmName"
        }

        # ---------------- DATA DISKS ----------------

        if ($vmDetail.StorageProfile.DataDisks.Count -gt 0) {

            foreach ($dataDisk in $vmDetail.StorageProfile.DataDisks) {

                $diskName = $dataDisk.Name
                Write-Output "[INFO] Data Disk detected: $diskName"

                try {

                    $disk = Get-AzDisk -ResourceGroupName $rgName -DiskName $diskName

                    $snapshotName = "$vmName-$diskName-$(Get-Date -Format 'yyyyMMddHHmmss')"

                    $snapshotConfig = New-AzSnapshotConfig `
                        -SourceResourceId $disk.Id `
                        -Location $disk.Location `
                        -CreateOption Copy

                    New-AzSnapshot `
                        -SnapshotName $snapshotName `
                        -ResourceGroupName $rgName `
                        -Snapshot $snapshotConfig

                    Write-Output "[INFO] Data disk snapshot created: $snapshotName"

                }
                catch {
                    Write-Output "[ERROR] Failed to snapshot data disk $diskName"
                }

            }

        }
        else {
            Write-Output "[INFO] No data disks attached to VM: $vmName"
        }

    }

}
