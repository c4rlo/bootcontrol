WScript.CreateObject("Scripting.FileSystemObject").CopyFile("f:\\linux.cfg", "f:\\grub.cfg");
WScript.CreateObject("WScript.Shell").Run("shutdown /r /t 0", 0);
