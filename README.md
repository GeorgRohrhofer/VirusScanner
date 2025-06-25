GitHub-Repository: https://github.com/GeorgRohrhofer/VirusScanner

# ICVS – Inefficient ClamAV Scanner

> **💡 Test File Notice:**  
> The file `eicar.com` is a specially designed test file recognized by antivirus scanners. It is used to verify that the antivirus is working properly and is **100% safe and harmless**.  
> You can safely use this file to test your ICVS-AntiVirus installation. 

# 🛡️ Setup Guide for Windows – Installation Guide (Installer Version)

---

## 📥 Step 1: Download the ClamAV-Installer

1. Go to the official ClamAV downloads page:
   👉 [https://www.clamav.net/downloads](https://www.clamav.net/downloads)

2. Scroll down to the **"Windows"** section.

3. Download the latest **ClamAV for Windows Installer** (e.g. `clamav-x.x.x.x-win-x64.msi`).

---

## 💿 Step 2: Install ClamAV

1. Run the downloaded `.msi` installer.

2. Follow the installation steps in the wizard:

   * Accept the license
   * Choose installation location (e.g. `C:\Program Files\ClamAV`)
   * Complete installation

---

## ⚙️ Step 3: Configure ClamAV

1. Navigate to the ClamAV install directory (default):

   ```
   C:\Program Files\ClamAV
   ```

2. Open **File Explorer** and go to the `conf_examples` directory.

3. Copy the sample configuration files into the main ClamAV folder:

   * Right-click `freshclam.conf.sample` → **Copy** → go to `C:\Program Files\ClamAV` → Right-click → **Paste** → rename to `freshclam.conf`
   * Do the same for `clamd.conf.sample`, rename it to `clamd.conf`

4. Open `freshclam.conf` with a text editor (e.g. Notepad).

5. **Important:** Comment out or remove the line:

   ```
   Example
   ```

   So it becomes:

   ```
   # Example
   ```

6. Repeat the same for `clamd.conf`.

---

## 🛠️ Step 4: Add ClamAV to System PATH

To avoid typing the full path every time:

1. Press `Win + R`, type `sysdm.cpl`, press Enter.

2. Go to **Advanced > Environment Variables**.

3. Under "System variables", select `Path`, then click **Edit**.

4. Click **New**, then add:

   ```
   C:\Program Files\ClamAV
   ```

5. Click OK on all dialogs. You can now run `clamscan.exe` from any terminal.

---

## 🔄 Step 5: Update Virus Definitions

Open **Command Prompt as Administrator**:

* Press `Start`, type `cmd`, right-click **Command Prompt**, select **Run as administrator**.

Then run:

```cmd
freshclam.exe
```

This is automatically run when starting ICVS

## 💿 Step 6: Download and run ICVS

Download the windows release from [Latest Release](https://github.com/GeorgRohrhofer/VirusScanner/releases/latest).

Unzip the zip file and run virus_scanner.exe.

Have fun!

## 🔗 Official Resources

* 🔒 Website: [https://www.clamav.net](https://www.clamav.net)
* 📖 Documentation: [https://docs.clamav.net](https://docs.clamav.net)
