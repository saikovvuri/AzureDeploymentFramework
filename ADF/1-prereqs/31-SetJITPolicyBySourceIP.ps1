<#
.SYNOPSIS
    Set-JITAccessPolicy
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    https://docs.microsoft.com/en-us/rest/api/securitycenter/jit-network-access-policies/create-or-update
#>

function Set-JITAccessPolicy
{
    param (
        [parameter(ValueFromPipeline)]
        $VMName = 'JMP02',
        [parameter(ValueFromPipeline)]
        $RGName = 'ACU1-BRW-AOA-RG-D2',
        $SourceIP = '192.127.0.2',
        $JitPolicyName = 'Standard_JIT_Access'
    )
    process
    {
        # can find multiple VM's, limit to the single RG, per policy assignment
        Get-AzVM -ResourceGroupName $RGName | Where-Object Name -Match $VMName -ov VMs

        Write-Warning -Message "Found VM [$($VMs.ID)]"

        $Params = @{
            #Assume all VM's in same RG in the same location
            Location          = $VM[0].location
            ResourceGroupName = $VM[0].ResourceGroupName
            Name              = $JitPolicyName
            Kind              = 'Basic'
            Confirm           = $true
            VirtualMachine    = @(foreach ($VM in $VMs)
                {
                    @{
                        id    = $VM.ID
                        ports = @(
                            @{
                                number                     = 3389
                                protocol                   = 'TCP'
                                AllowedSourceAddressPrefix = $SourceIP
                                maxRequestAccessDuration   = 'PT3H'
                            },
                            @{
                                number                     = 22
                                protocol                   = 'TCP'
                                AllowedSourceAddressPrefix = $SourceIP
                                maxRequestAccessDuration   = 'PT3H'
                            }
                        )
                    }
                })
        }

        Set-AzJitNetworkAccessPolicy @Params
    }
}