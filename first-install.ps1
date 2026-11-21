$ErrorActionPreference='Stop'
if ($env:GITHUB_ACTIONS -ne 'true' -or $env:RUNNER_ENVIRONMENT -ne 'github-hosted' -or $env:RUNNER_OS -ne 'Windows' -or $env:GITHUB_REPOSITORY -ne 'teydra/OpenAutark') { throw 'Hosted Windows fixture only.' }
if ((Get-Process -Id $PID).SessionId -eq 0) { throw 'No interactive Windows desktop.' }
Add-Type -AssemblyName System.Drawing, System.Windows.Forms, UIAutomationClient, UIAutomationTypes
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Text;
public static class ShotWindow {
  [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left,Top,Right,Bottom; }
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out Rect r);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  private delegate bool EnumProc(IntPtr hwnd, IntPtr arg);
  [DllImport("user32.dll")] private static extern bool EnumWindows(EnumProc callback, IntPtr arg);
  [DllImport("user32.dll")] private static extern bool IsIconic(IntPtr h);
  public static IntPtr[] VisibleWindows(uint expectedPid) {
    var windows = new List<IntPtr>();
    EnumWindows(delegate(IntPtr h, IntPtr unused) {
      uint pid;
      if (IsWindowVisible(h) && !IsIconic(h) &&
          GetWindowThreadProcessId(h, out pid)!=0 && pid==expectedPid) windows.Add(h);
      return true;
    }, IntPtr.Zero);
    return windows.ToArray();
  }
  [DllImport("user32.dll")] private static extern bool EnumChildWindows(IntPtr h, EnumProc callback, IntPtr arg);
  [DllImport("user32.dll")] private static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] private static extern bool IsWindowEnabled(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] private static extern int GetClassName(IntPtr h,StringBuilder s,int n);
  [DllImport("user32.dll", EntryPoint="SendMessageTimeoutW", CharSet=CharSet.Unicode)]
  private static extern IntPtr ReadButton(IntPtr h,uint m,IntPtr n,StringBuilder s,uint flags,uint ms,out IntPtr result);
  [DllImport("user32.dll", EntryPoint="SendMessageTimeoutW")]
  private static extern IntPtr SendButton(IntPtr h,uint m,IntPtr w,IntPtr l,uint flags,uint ms,out IntPtr result);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,out uint pid);
  [DllImport("user32.dll")] private static extern bool IsChild(IntPtr parent,IntPtr child);
  [DllImport("user32.dll", EntryPoint="PostMessageW", SetLastError=true)]
  private static extern bool PostButton(IntPtr h,uint m,IntPtr w,IntPtr l);
  public static bool QueueFinish(IntPtr parent,IntPtr button,uint expectedPid) {
    uint pp,bp;
    return GetForegroundWindow()==parent && IsChild(parent,button)
      && GetWindowThreadProcessId(parent,out pp)!=0 && pp==expectedPid
      && GetWindowThreadProcessId(button,out bp)!=0 && bp==expectedPid
      && IsWindowVisible(button) && IsWindowEnabled(button)
      && PostButton(button,0x00F5,IntPtr.Zero,IntPtr.Zero);
  }
  public class Button { public IntPtr Handle; public string Caption; }
  public static Button[] Buttons(IntPtr parent) {
    var buttons=new List<Button>();
    EnumChildWindows(parent,delegate(IntPtr hwnd, IntPtr unused) {
      if (!IsWindowVisible(hwnd) || !IsWindowEnabled(hwnd)) return true;
      var name=new StringBuilder(32);
      if (GetClassName(hwnd,name,name.Capacity)==0 || !String.Equals(name.ToString(),"Button",StringComparison.OrdinalIgnoreCase)) return true;
      var text=new StringBuilder(256);
      IntPtr result;
      if (ReadButton(hwnd,0x000D,(IntPtr)text.Capacity,text,2,500,out result)!=IntPtr.Zero && result!=IntPtr.Zero)
        buttons.Add(new Button { Handle=hwnd, Caption=text.ToString().Replace("&","").Trim() });
      return true;
    }, IntPtr.Zero);
    return buttons.ToArray();
  }
  public static bool Checked(IntPtr h) {
    IntPtr result;
    return SendButton(h,0x00F0,IntPtr.Zero,IntPtr.Zero,2,700,out result)!=IntPtr.Zero && result==(IntPtr)1;
  }
  public static bool Click(IntPtr h) {
    IntPtr result;
    return IsWindowVisible(h) && IsWindowEnabled(h) &&
      SendButton(h,0x00F5,IntPtr.Zero,IntPtr.Zero,2,1200,out result)!=IntPtr.Zero;
  }

}
"@
[void][ShotWindow]::SetProcessDPIAware()
$work=Join-Path $env:RUNNER_TEMP 'dotnetpro-first-install'
$captures=Join-Path $work 'screens'
New-Item -Path $captures -ItemType Directory | Out-Null
$os=Get-CimInstance Win32_OperatingSystem
@{edition=$os.Caption;version=$os.Version;build=$os.BuildNumber} | ConvertTo-Json | Set-Content "$captures/environment.json"
$installer="$work/autark-windows-x64.exe"
$exe="$env:LOCALAPPDATA\Programs\Autark\Autark.exe"
$uri='https://github.com/teydra/OpenAutark/releases/download/v0.3.16/autark-windows-x64.exe'
$expected='0639D88CD68F4266EAADB300687AE6E42FD708BC3F14B4D8FC8E4325F6C89026'
$locations=@((Split-Path $exe),"$env:ProgramFiles\Autark","$env:APPDATA\Autark","$env:APPDATA\Autark Companies")
if (@($locations | Where-Object {Test-Path -LiteralPath $_}).Count -ne 0 -or (Get-Process Autark -ErrorAction SilentlyContinue) -or (Get-Service AutarkDesktopBroker -ErrorAction SilentlyContinue)) { throw 'Runner is not a fresh Autark target.' }
curl.exe --fail --silent --show-error --location $uri --output $installer
if ($LASTEXITCODE) { throw 'Public download failed.' }
$hash=(Get-FileHash -LiteralPath $installer).Hash
$sig=Get-AuthenticodeSignature -FilePath $installer
if ($hash -cne $expected -or $sig.Status -ne 'Valid' -or $sig.SignerCertificate.Issuer -notmatch 'Certum') { throw 'Public installer failed integrity or publisher check.' }
@{url=$uri;sha256=$hash;authenticode=[string]$sig.Status;issuer=$sig.SignerCertificate.Issuer;timestamped=[bool]$sig.TimeStamperCertificate} | ConvertTo-Json | Set-Content "$captures/installer-verification.json"
Write-Host 'Public release digest and Authenticode: PASS.'
function WindowFor([string]$name) {
  foreach($p in (Get-Process -Name $name -ErrorAction SilentlyContinue)) {
    if ($p.MainWindowHandle -ne [IntPtr]::Zero) {return $p.MainWindowHandle}
  }
  [IntPtr]::Zero
}
function SaveWindow([IntPtr]$h,[string]$name) {
  if ([ShotWindow]::GetForegroundWindow() -ne $h) {
    [void][ShotWindow]::SetForegroundWindow($h)
    Start-Sleep -Milliseconds 500
  }
  if ([ShotWindow]::GetForegroundWindow() -ne $h) { throw "Cannot confirm foreground window for $name" }
  $r=[ShotWindow+Rect]::new()
  if (![ShotWindow]::GetWindowRect($h,[ref]$r)) { throw "Cannot size window for $name" }
  $w=$r.Right-$r.Left; $ht=$r.Bottom-$r.Top
  if ($w -lt 150 -or $ht -lt 100 -or $w -gt 3000 -or $ht -gt 2000) { throw "Unexpected window dimensions for $name" }
  $bmp=[Drawing.Bitmap]::new($w,$ht); $g=[Drawing.Graphics]::FromImage($bmp)
  try {
    $g.CopyFromScreen($r.Left,$r.Top,0,0,[Drawing.Size]::new($w,$ht))
    $sample=@(foreach($x in 1..7){foreach($y in 1..7){$bmp.GetPixel([int](($w-1)*$x/8),[int](($ht-1)*$y/8)).ToArgb()}})
    if (@($sample | Sort-Object -Unique).Count -le 2) { throw "Capture appears blank for $name" }
    $bmp.Save((Join-Path $captures $name),[Drawing.Imaging.ImageFormat]::Png)
  } finally { $g.Dispose(); $bmp.Dispose() }
}
$setup=Start-Process -FilePath $installer -PassThru
$shown=$false; $scope=$false; $began=$false; $finished=$false; $next=0
$deadline=[DateTime]::UtcNow.AddMinutes(8)
$lastProgress=[DateTime]::UtcNow
do {
  $hwnd=WindowFor 'autark-windows-x64'
  if ($hwnd -ne [IntPtr]::Zero -and !$finished) {
    $windowPid=[uint32]0
    [void][ShotWindow]::GetWindowThreadProcessId($hwnd,[ref]$windowPid)
    if ($windowPid -ne $setup.Id) { throw 'Wizard is not owned by the verified installer process.' }
    if (!$shown) { SaveWindow $hwnd '01-setup.png'; $shown=$true; Write-Host 'Verified installer wizard visible.' }
    $buttons=@([ShotWindow]::Buttons($hwnd))
    $choice=@($buttons | Where-Object Caption -Match '^(?:Only for me|Install for me)(?:$|\s|\()')
    $all=@($buttons | Where-Object Caption -Match '(?i)anyone|all users')
    if ($choice.Count -or $all.Count) {
      if ($choice.Count -ne 1 -or $all.Count -ne 1) { throw 'Cannot identify both install scopes.' }
      if (![ShotWindow]::Checked($choice[0].Handle) -or [ShotWindow]::Checked($all[0].Handle)) { throw 'Default per-user scope was not confirmed; do not proceed.' }
      $scope=$true
    }
    $action=@($buttons | Where-Object Caption -Match '^(Finish|Install|Next(?:\s*>){0,2})$')
    if ($action.Count -gt 1) { throw 'Ambiguous wizard buttons.' }
    if ($action.Count -eq 1) {
      if ([ShotWindow]::GetForegroundWindow() -ne $hwnd) { throw 'Installer lost foreground; do not click.' }
      $label=$action[0].Caption
      if (!$scope) { throw 'Cannot proceed without explicit per-user scope.' }
      if ($label -eq 'Finish') {
        # This signed installer can start copying on the second Next, without an Install-labelled button.
        if (!$began -and $next -lt 2) { throw 'Unexpected finish state.' }
        if (!(Test-Path -LiteralPath $exe) -or (Test-Path "$env:ProgramFiles\Autark\Autark.exe")) {
          throw 'Finish page has no confirmed per-user program.'
        }
        $finishVersion=[Diagnostics.FileVersionInfo]::GetVersionInfo($exe).ProductVersion
        if ($finishVersion -notmatch '^0\.3\.16(?:\.0)?$' -or (Get-AuthenticodeSignature -LiteralPath $exe).Status -ne 'Valid') {
          throw 'Finish page has no verified installed 0.3.16.'
        }
        $began=$true
        SaveWindow $hwnd '02-installation-complete.png'
        # BM_CLICK can destroy the wizard before SendMessageTimeout returns. Queue the
        # single Finish action; the actual verified installer's exit is the confirmation.
        if (![ShotWindow]::QueueFinish($hwnd,$action[0].Handle,[uint32]$setup.Id)) {
          throw 'Could not queue Finish on the verified foreground wizard.'
        }
        $finished=$true
        Write-Host 'Finish queued on the verified wizard; awaiting installer exit.'
        if (!$setup.WaitForExit(75000)) { throw 'Verified installer did not exit after Finish.' }
        break
      } elseif ($label -eq 'Install') {
        if ($began) { throw 'Second Install action.' }; $began=$true
      } else {
        $next++; if ($began -or $next -gt 4) { throw 'Unexpected navigation state.' }
      }
      if (![ShotWindow]::Click($action[0].Handle)) { throw 'Confirmed wizard action did not respond.' }
      Write-Host "Wizard action: $label"
      $lastProgress=[DateTime]::UtcNow
      Start-Sleep -Seconds 2
    }
  }
  if (!$began -and ([DateTime]::UtcNow-$lastProgress).TotalSeconds -gt 35) {
    throw "No recognized wizard action. Window shown=$shown; scope confirmed=$scope; Next count=$next."
  }
  Start-Sleep -Milliseconds 500
  $setup.Refresh()
} while (!$setup.HasExited -and [DateTime]::UtcNow -lt $deadline)
if (!$setup.HasExited -or $setup.ExitCode -ne 0 -or !$finished) { throw "Interactive setup did not finish successfully. Install=$began; Finish=$finished; Exited=$($setup.HasExited)." }
if (!(Test-Path -LiteralPath $exe) -or (Test-Path "$env:ProgramFiles\Autark\Autark.exe")) { throw 'Expected a per-user install only.' }
$info=[Diagnostics.FileVersionInfo]::GetVersionInfo($exe)
$exeSign=Get-AuthenticodeSignature -FilePath $exe
if ($info.ProductVersion -notmatch '^0\.3\.16(?:\.0)?$' -or $exeSign.Status -ne 'Valid') {throw 'Unexpected app version or signature.'}
Write-Host 'Interactive setup and installed signed 0.3.16 per user: PASS.'
if (!(Get-Process Autark -ErrorAction SilentlyContinue)) { Start-Process -FilePath $exe }
function FirstAppWindow {
  $foreground=[ShotWindow]::GetForegroundWindow()
  $found=foreach($p in (Get-Process -Name Autark -ErrorAction SilentlyContinue)) {
    if ($p.Path -ine $exe -or $p.SessionId -ne (Get-Process -Id $PID).SessionId) { continue }
    foreach($h in [ShotWindow]::VisibleWindows([uint32]$p.Id)) {
      $r=[ShotWindow+Rect]::new()
      if (![ShotWindow]::GetWindowRect($h,[ref]$r)) { continue }
      $w=$r.Right-$r.Left; $ht=$r.Bottom-$r.Top
      if ($w -lt 600 -or $ht -lt 400 -or $w -gt 3000 -or $ht -gt 2000) { continue }
      $rect=[Drawing.Rectangle]::new($r.Left,$r.Top,$w,$ht)
      if (-not ([Windows.Forms.Screen]::AllScreens | Where-Object { $_.Bounds.Contains($rect) } | Select-Object -First 1)) { continue }
      [pscustomobject]@{Handle=$h;Owner=$p.Id;Area=$w*$ht;Foreground=($h -eq $foreground);Rect=$rect}
    }
  }
  $found | Sort-Object -Property Foreground,Area -Descending | Select-Object -First 1
}
$until=[DateTime]::UtcNow.AddSeconds(100)
$previous=$null
do {
  Start-Sleep -Milliseconds 500
  $nextWindow=FirstAppWindow
  if ($previous -and $nextWindow -and $nextWindow.Handle -eq $previous.Handle -and
      $nextWindow.Owner -eq $previous.Owner -and $nextWindow.Rect -eq $previous.Rect) { break }
  $previous=$nextWindow
  $nextWindow=$null
} while ([DateTime]::UtcNow -lt $until)
if (!$nextWindow) { throw 'No stable, visible, on-screen Autark window of the verified installation.' }
$main=$nextWindow.Handle
$owner=[uint32]0
if (![ShotWindow]::GetWindowThreadProcessId($main,[ref]$owner) -or $owner -ne $nextWindow.Owner -or
    (Get-Process -Id $owner).Path -ine $exe) { throw 'Captured app is not the installed binary.' }
SaveWindow $main '03-first-start.png'
@{productVersion=$info.ProductVersion;appSignature=[string]$exeSign.Status;scope='per-user';visibleFirstWindow=$true;engineLoginPerformed=$false;fullAgentTurnTested=$false} | ConvertTo-Json | Set-Content "$captures/first-start.json"
Write-Host 'Visible first app window: PASS. No real login or agent run.'
