#
# Copyright 2020 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package centreon::common::powershell::hyperv::2012::scvmmintegrationservice;

use strict;
use warnings;
use centreon::plugins::misc;

sub get_powershell {
    my (%options) = @_;
    my $no_ps = (defined($options{no_ps})) ? 1 : 0;
    
    return '' if ($no_ps == 1);

    my $ps = '
$culture = new-object "System.Globalization.CultureInfo" "en-us"    
[System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture
$ProgressPreference = "SilentlyContinue"

Try {
    $ErrorActionPreference = "Stop"
    Import-Module -Name "virtualmachinemanager" 

    $username = "' . $options{scvmm_username} . '"
    $password = ConvertTo-SecureString "' . $options{scvmm_password} . '" -AsPlainText -Force
    $UserCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password

    $connection = Get-VMMServer -ComputerName "' . $options{scvmm_hostname} . '" -TCPPort ' . $options{scvmm_port} . ' -Credential $UserCredential
    $vms = Get-SCVirtualMachine -VMMServer $connection

    Foreach ($vm in $vms) {
        $desc = $vm.description -replace "\r",""
        $desc = $desc -replace "\n"," - "
        Write-Host ("[VM={0}]" -f $vm.Name) -NoNewline
        Write-Host ("[Description={0}]" -f $desc) -NoNewline
        Write-Host ("[Status={0}]" -f $vm.Status) -NoNewline
        Write-Host ("[Cloud={0}]" -f $vm.Cloud) -NoNewline
        Write-Host ("[HostGroup={0}]" -f $vm.HostGroupPath) -NoNewline
        Write-Host ("[VMAddition={0}]" -f $vm.VMAddition) -NoNewline
        Write-Host ("[OperatingSystemShutdownEnabled={0}]" -f $vm.OperatingSystemShutdownEnabled) -NoNewline
        Write-Host ("[TimeSynchronizationEnabled={0}]" -f $vm.TimeSynchronizationEnabled) -NoNewline
        Write-Host ("[DataExchangeEnabled={0}]" -f $vm.DataExchangeEnabled) -NoNewline
        Write-Host ("[HeartbeatEnabled={0}]" -f $vm.HeartbeatEnabled) -NoNewline
        Write-Host ("[BackupEnabled={0}]" -f $vm.BackupEnabled)        
    }
} Catch {
    Write-Host $Error[0].Exception
    exit 1
}

exit 0
';

    return centreon::plugins::misc::powershell_encoded($ps);
}

1;

__END__

=head1 DESCRIPTION

Method to get hyper-v informations.

=cut