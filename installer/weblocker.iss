#define MyAppName "weblocker"
#expr MyAppVersion = MyAppVersion

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\dist\installer
OutputBaseFilename=weblocker-setup-v{#MyAppVersion}
Compression=lzma2/ultra
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\dist\weblocker.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\weblocker.exe"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Registry]
; Register file association for .webloc
Root: HKCR; Subkey: ".webloc"; ValueType: string; ValueName: ""; ValueData: "weblockerfile"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "weblockerfile"; ValueType: string; ValueName: ""; ValueData: "weblocker webloc file"; Flags: uninsdeletekey
Root: HKCR; Subkey: "weblockerfile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\weblocker.exe,0"; Flags: uninsdeletekey
Root: HKCR; Subkey: "weblockerfile\\shell\\open\\command"; ValueType: string; ValueName: ""; ValueData: """{app}\\weblocker.exe"" ""%1"""; Flags: uninsdeletekey

[UninstallDelete]
Type: files; Name: "{app}\weblocker.exe"

[Code]
// nothing for now
