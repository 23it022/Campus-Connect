# ☕ JDK Installation Guide for Windows

## Why You Need JDK

JDK (Java Development Kit) is **required** for Android app development with Flutter. The Android build tools and Gradle need Java to compile your app.

---

## Step 1: Download JDK 17

### Option A: Oracle JDK (Official)
1. Go to: https://www.oracle.com/java/technologies/downloads/#java17
2. Scroll to **Windows** section
3. Download **x64 Installer** (e.g., `jdk-17_windows-x64_bin.exe`)

### Option B: OpenJDK (Free, Recommended)
1. Go to: https://adoptium.net/temurin/releases/
2. Select:
   - **Version**: 17 (LTS)
   - **Operating System**: Windows
   - **Architecture**: x64
3. Click **Download .msi** installer

---

## Step 2: Install JDK

1. **Run the installer** (.exe or .msi file you downloaded)
2. Click **Next** through the installation wizard
3. **Important**: Note the installation path, usually:
   ```
   C:\Program Files\Java\jdk-17
   ```
   Or for Adoptium:
   ```
   C:\Program Files\Eclipse Adoptium\jdk-17.x.x.x-hotspot
   ```
4. Complete the installation

---

## Step 3: Set JAVA_HOME Environment Variable

### Using PowerShell (Quick Method)

Open PowerShell as Administrator and run:

```powershell
# Set JAVA_HOME (replace with your actual JDK path)
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Java\jdk-17', [System.EnvironmentVariableTarget]::Machine)

# Add to PATH
$oldPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
$newPath = "$oldPath;%JAVA_HOME%\bin"
[System.Environment]::SetEnvironmentVariable('Path', $newPath, [System.EnvironmentVariableTarget]::Machine)
```

### Using GUI (Detailed Method)

1. **Press** `Windows + R`
2. **Type**: `sysdm.cpl` and press Enter
3. Click **Advanced** tab
4. Click **Environment Variables** button
5. Under **System variables**, click **New**:
   - **Variable name**: `JAVA_HOME`
   - **Variable value**: `C:\Program Files\Java\jdk-17` (your actual path)
6. Click **OK**
7. Find **Path** in System variables, click **Edit**
8. Click **New**, add: `%JAVA_HOME%\bin`
9. Click **OK** on all windows
10. **Restart your computer** or close all terminals/VS Code

---

## Step 4: Verify Installation

After setting environment variables, **open a NEW PowerShell** window and run:

```powershell
# Check Java version
java -version

# Should show something like:
# openjdk version "17.0.x" 2024-xx-xx
# OpenJDK Runtime Environment...

# Check JAVA_HOME
echo $env:JAVA_HOME

# Should show: C:\Program Files\Java\jdk-17
```

---

## Step 5: Restart VS Code

After installing JDK and setting environment variables:
1. **Close VS Code completely**
2. **Reopen VS Code**
3. Open the CampusConnect project
4. The JDK error should be gone!

---

## Alternative: Use Chocolatey (Package Manager)

If you have Chocolatey installed:

```powershell
# Install JDK 17
choco install openjdk17

# JAVA_HOME is set automatically!
```

---

## Troubleshooting

### Error: "java: command not found" after installation

**Solution**: 
- Make sure you **restarted** your terminal/VS Code
- Verify PATH includes `%JAVA_HOME%\bin`
- Check JAVA_HOME is set correctly: `echo $env:JAVA_HOME`

### VS Code still shows JDK error

**Solution**:
1. Close VS Code completely
2. Reopen VS Code
3. Reload window: `Ctrl+Shift+P` → "Reload Window"

### Multiple Java versions installed

**Solution**:
- Make sure JAVA_HOME points to JDK 17 or higher
- Check: `java -version` (should be 17+)

---

## Next Steps After JDK Installation

Once JDK is installed:

1. ✅ Verify Java: `java -version`
2. ✅ Check Flutter: `flutter doctor`
3. ✅ Install Flutter dependencies: `flutter pub get`
4. ✅ Complete Firebase setup (see FIREBASE_SETUP.md)
5. ✅ Run the app: `flutter run`

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `java -version` | Check Java version |
| `echo $env:JAVA_HOME` | Check JAVA_HOME path |
| `flutter doctor` | Check Flutter setup |
| `flutter doctor -v` | Detailed Flutter diagnostics |

---

**Need Help?**
- JDK Download: https://adoptium.net/
- Java Documentation: https://docs.oracle.com/en/java/
- Flutter Doctor Issues: https://docs.flutter.dev/get-started/install/windows

---

**📌 Recommended Installation**

For beginners, I recommend:
- **Download**: Eclipse Temurin JDK 17 from https://adoptium.net/
- **Install**: Use the MSI installer (easiest)
- **Verify**: Run `java -version` in a new PowerShell window
- **Restart**: Close and reopen VS Code

---

**After completing these steps, you'll be ready to build Android apps with Flutter!** 🚀
