# spddump_gui 🚀

A lightweight, powerful graphical user interface (GUI) wrapper for the `spd_dump` utility, built using **LuaRT**. It simplifies flashing, reading, writing, and managing partitions on Unisoc / Spreadtrum devices through a streamlined batch job queue system.

---

## 📌 Overview
* **Version:** V0.1.0 Alpha (20260614)
* **Author:** Iroha9876 (a.k.a. 4NotFound / 4NF)
* **Target OS:** Windows (x86/x64)
* **License:** Free of charge (Reselling strictly prohibited)

---

## ✨ Features

### 🛠️ Core Capabilities
* **Interactive Job Queue:** Queue up multiple flashing actions sequentially and run them all in a single automated session.
* **Easy Mode / Custom Commands:** Create tasks using a guided dropdown window or inject specialized raw commands via the "Custom" expert tab.
* **Persistent Session State:** Retains configuration fields and directories even if you close out of job creation sub-windows.
* **Queue Import/Export:** Save your carefully orchestrated sequence of operations to a `.jobq` or `.txt` file for future reuse or distribution.

### 🌟 New in V0.1.0
* **Partition Erase Capabilities (`e`):** Added native support for securely erasing specific partitions directly from the Easy Mode interface.
* **Enhanced Safety UI:** Integrated prominent visual warnings (highlighted text indicators) for hazardous functions like partition erasing.
* **Unified Layout Engine:** Refactored background multi-window lifecycle structures to reduce resource consumption and minimize memory overhead.

### ⚙️ Environment Configuration
* **Single Executable Mode (`semode`):** When deployed as a compiled standalone executable, the utility automatically detects and provisions necessary environment assets (`spd_dump.exe`, `Channel9.dll`) to ensure error-free runtime execution.
* **Test Mode Connection Profiling:** Validate connection stability between your PC and the target device before deploying execution strings. Succeeding tests automatically reboot the handset safely.
* **Robust Output Logs:** Real-time stdout capture preserves underlying engine responses to an external text file (`spd_dump_output_[timestamp].txt`) for immediate diagnostic reference.

---

## ⚠️ CRITICAL SAFETY DIRECTIVES

> [!WARNING]
> **FLASHING IN BROM / FDL MODE IS A HIGH-RISK OPERATION!** > Proceed only if you completely understand the memory structures of your specific device hardware target.

1. **The Safe Entry Method:** This tool is natively optimized for devices entering BROM safely via hardware key combinations (where `splloader` remains intact).
2. **The `splloader` Rule (DO NOT FORGET):** If you boot or kick into BROM via software control methods (such as `adb reboot autodloader`), **YOU MUST MANUALLY APPEND A WRITE JOB TO THE VERY END OF YOUR QUEUE** (`w splloader [path_to_file]`).  
   *Failure to do this will result in the device becoming indefinitely trapped inside a BROM boot-loop state until a valid loader configuration is forced manually.*

---

## 📦 Job Queue Actions Reference

| Action | Argument Type | GUI Input Field | Generated CLI Syntax | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Set Directory** | Folder Path | Directory Browser | `path [dir]` | Assigns the global backup path for output dumps. |
| **Read** | Partition Name | String Entry | `r [partition]` | Extracts contents of a partition to a file inside the path directory. |
| **Write** | Partition + File | Name Entry & File Picker | `w [partition] [file]` | Flashes a local binary (`.bin`/`.img`) directly to the device partition. |
| **Erase 🛑** | Partition Name | String Entry | `e [partition]` | Completely zeroes out data contents on the specified partition. |
| **Reboot** | None | N/A | `reset` | Reboots the target hardware platform to main system OS. |
| **Recovery** | None | N/A | `reboot-recovery` | Directs device to reboot immediately into recovery mode. |
| **Bootloader** | None | N/A | `reboot-fastboot` | Directs device to drop straight into the fastboot interface. |
| **Power Off** | None | N/A | `poweroff` | Shuts down hardware peripherals safely. |

---

## 🚀 Getting Started

### Prerequisites
1. Ensure appropriate Spreadtrum/Unisoc USB VCOM/BROM drivers are correctly installed on your host system.
2. Ensure you have the proper **FDL1** and **FDL2** binaries appropriate for your device's exact chipset model.

### Basic Steps
1. **Configure Launch Loaders:** Browse and select your `FDL1` and `FDL2` image paths. Update the execution addresses if your specific chipset configuration deviates from the default addresses (`0x5500` / `0x9efffe00`).
2. **Build Your Sequence:** Click **New Job**, select your desired tasks under the Easy or Custom tab, and hit **Done** to push them to the live visual list queue.
3. **Establish Linkage:** Connect your target hardware to the PC using your standard device-specific entry sequence (e.g., holding Volume keys down while attaching the USB cable).
4. **Execute Operations:** Hit **Run Jobs**. Maintain stable cable connectivity and do not disrupt the system until processing logs indicate a full completion state.

---

## ❤️ Credits & Acknowledgments
Special thanks to the open-source authors whose foundational framework and backend toolchains made this GUI automation suite possible:
* **ilyakurdyukov** — Github Author of `spreadtrum_flash`
* **CE1CECL** — Github Author of `spd_dump`
* **samyeyo** — Creator of the elegant **LuaRT** desktop runtime framework
* ~~みくみくにしてやんよ!~~