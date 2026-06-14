-- SPD_DUMP GUI Wrapper (spddump_gui.wlua) 0.1.0 by Iroha9876 (a.k.a. 4NF) 2025-2026

-- Branding
local appname = "spddump_gui"
local version = "V0.1.0 Alpha 20260614"

-- Importing Modules
local ui = require "ui"
local console = require "console"
local sys = require "sys"
local os = require "os"
local io = require "io"
local testmode = false -- always set to true if not compiled or not using bundled res folders!!
local semode = true -- 2026.01.27 Single executable mode which will let the executable handle configuration of environment
local embed = nil

-- Global Variables (TODO: merging)

-- Var for FDL Path & Address
local fdl1 = nil
local fdl2 = nil
local fdl1add = nil
local fdl2add = nil

-- Var for Job Running
local joblist = {}
local istest = false
local retainlog = false
local logfilename = ""

-- Var for NewJob Win
local expertmode = false
local ez_current = 0
local dir = ""
local file = ""

-- Common Utils
function ps(str, win)
  print(str)
  if win then
    win:status(str)
  end
end

function string:trim()
    -- Remove leading whitespace
    local s = self:gsub("^%s+", "")
    -- Remove trailing whitespace
    return s:gsub("%s+$", "")
end

-- Embed Helpers
if testmode then
  print("TestMode is enabled using folder resources instead of embed...")
  embed = nil
else
  embed = require "embed"
end

local function getembedfile(filedir)
  if testmode then
    return sys.File:constructor("res/"..filedir)
  else
    return embed.File(filedir)
  end
end

-- UI Construction

-- ABTWin
local ABTWin = ui.Window("About", "float", 400, 240)
local pfp = ui.Picture(ABTWin, getembedfile("pic/pfp.bmp"), 5, 5, 64, 64)
local maintitle = ui.Label(ABTWin, appname.." by Iroha9876 (a.k.a. 4NF)", 72, 5)
maintitle.fontstyle = { ["bold"] = true }
local verlabel = ui.Label(ABTWin, version, 72, 24)
local credits = ui.Label(ABTWin, "Credit to ilyakurdyukov on GitHub for spreadtrum_flash\r\nCredit to CE1CECL on GitHub for spd_dump\r\nCredit to samyeyo on GitHub for LuaRT\r\nみくみくにしてやんよ\r\n　　　∧＿∧\r\n　　　(　･ω･)＝つ≡つ\r\n　　　(っ　　≡つ＝つ\r\n　　　/　　　) ﾊﾞﾊﾞﾊﾞﾊﾞ\r\n　　　( /￣∪", 72, 44)
local ABTExitBTN = ui.Button(ABTWin, "OK", 325, 215, 75, 25)
function ABTExitBTN:onClick()
  ABTWin:hide()
end
ABTWin:center()

-- Jobwin
local jobwin = ui.Window("Create New Job", "float", 350, 200)
local tab = ui.Tab(jobwin, {"Easy", "Custom"}, 0, 0, 350, 175)
tab.selected = tab.items[1]
local commandentry = ui.Entry(tab.items[2], "", 0, 0, 350, 175)
local DiscardBTN = ui.Button(jobwin, "Discard", 0, 175, 175, 25)
local DoneBTN = ui.Button(jobwin, "Done", 175, 175, 175, 25)
local combobox = ui.Combobox(tab.items[1], false, {"Set Directory", "Read", "Write", "Erase", "Reboot", "Recovery", "Bootloader", "Power Off"}, 0, 0, 350)
local notcustlabel = ui.Label(tab.items[1], "↑ Click the spinner above to start ↑")
notcustlabel:center()
  
-- DirPanel
local dirpanel = ui.Panel(tab.items[1], 0, 0, 350, 175)
local dirtitle = ui.Label(dirpanel, "Directory", 25, 25)
dirtitle.fontsize = 10
dirtitle.fontstyle = { ["bold"] = true }
local DirEntry = ui.Entry(dirpanel, "", 25, 50, 225, 25)
local DirPicker = ui.Button(dirpanel, "Browse", 250, 50, 75, 25)
  
-- RPanel
local rpanel = ui.Panel(tab.items[1], 0, 0, 350, 175)
local rtitle = ui.Label(rpanel, "Partition Name", 25, 25)
rtitle.fontsize = 10
rtitle.fontstyle = { ["bold"] = true }
local rEntry = ui.Entry(rpanel, "", 25, 50, 300, 25)

-- EPanel
local epanel = ui.Panel(tab.items[1], 0, 0, 350, 175)
local etitle = ui.Label(epanel, "Partition Name", 25, 25)
etitle.fontsize = 10
etitle.fontstyle = { ["bold"] = true }
local eEntry = ui.Entry(epanel, "", 25, 50, 300, 25)
local ewarn = ui.Label(epanel, "THIS WILL PERMANENTLY ERASE PARTITION!!!\r\nUSE WITH CAUTION!!!", 0, 75)
ewarn.fontsize = 10
ewarn.fgcolor = 0xFF0000
ewarn.fontstyle = { ["bold"] = true }
  
-- WPanel
local wpanel = ui.Panel(tab.items[1], 0, 0, 350, 175)
local wtitle = ui.Label(wpanel, "Partition Name", 25, 25)
wtitle.fontsize = 10
wtitle.fontstyle = { ["bold"] = true }
local wEntry = ui.Entry(wpanel, "", 25, 50, 300, 25)
local ftitle = ui.Label(wpanel, "File", 25, 75)
ftitle.fontsize = 10
ftitle.fontstyle = { ["bold"] = true }
local fEntry = ui.Entry(wpanel, "", 25, 100, 225, 25)
local fPicker = ui.Button(wpanel, "Browse", 250, 100, 75, 25)
  
-- Panels Configuration
local panels = {dirpanel, rpanel, wpanel, epanel}

for index, panel in ipairs(panels) do
    panel.visible = false
  end

-- Main Window Construction
local win = ui.Window(appname.." "..version.." by Iroha9876 (a.k.a. 4NF)", "fixed", 450, 550)

win.menu = ui.Menu()
local File = ui.Menu("Import Job Queue", "Export Job Queue")
local About = ui.Menu("About this SW")
win.menu:add("File", File)
win.menu:add("About", About)

local FDL1Indicator = ui.Label(win, "FDL1", 25, 5)
FDL1Indicator.fontsize = 10
FDL1Indicator.fontstyle = { ["bold"] = true }
local FDL1Picker = ui.Button(win, "Browse", 225, 25, 65, 25)
local FDL1PathEntry = ui.Entry(win, "", 25, 25, 200, 25)
local F1AddressIndicator = ui.Label(win, "Address", 300, 30)
local FDL1Entry = ui.Entry(win, "0x5500", 350, 25, 75, 25)

local FDL2Indicator = ui.Label(win, "FDL2", 25, 50)
FDL2Indicator.fontsize = 10
FDL2Indicator.fontstyle = { ["bold"] = true }
local FDL2Picker = ui.Button(win, "Browse", 225, 70, 65, 25)
local FDL2PathEntry = ui.Entry(win, "", 25, 70, 200, 25)
local F2AddressIndicator = ui.Label(win, "Address", 300, 75)
local FDL2Entry = ui.Entry(win, "0x9efffe00", 350, 70, 75, 25)

local SchedTitle = ui.Label(win, "Job Queue", 25, 95)
SchedTitle.fontsize = 10
SchedTitle.fontstyle = { ["bold"] = true }
local list = ui.List(win, {}, 25, 115, 400, 325)

local NewJobBTN = ui.Button(win, "New Job", 25, 440, 75, 25)
local RemSelBTN = ui.Button(win, "Remove Selected", 100, 440, 125, 25)
local ACBTN = ui.Button(win, "All Clear", 225, 440, 75, 25)

local checkbox = ui.Checkbox(win, "Test Mode", 25, 475)
local retainlogcb = ui.Checkbox(win, "Retain Logs", 110, 475)

local ExitBTN = ui.Button(win, "Exit", 275, 475, 75, 25)
local ConnectBTN = ui.Button(win, "Run Jobs", 350, 475, 75, 25)

win:center()

-- Functions for Main Window
function checkbox:onClick()
  istest = self.checked
  ps("Testmode new status: "..tostring(istest), win)
	if self.checked then 
		ui.info("This mode is intended to test the connection between target device and your PC.\r\nIt will ignore the queue above.\r\nOnce connection succeeds, target device will automatically reboot.")
	end
end

function retainlogcb:onClick()
  retainlog = self.checked
  ps("Retainlog new status: "..tostring(retainlog), win)
	if self.checked then 
		ui.info("You can retain output of spd_dump by using this option.\r\nIt could be helpful for troubleshooting.\r\nWhether the checkbox is checked or not, logs will be displayed in the console when all jobs ran.")
	end
end

function ExitBTN:onClick()
  win.visible = false
end

function FDL1Picker:onClick()
  local userchoice = ui.opendialog("Choose FDL1 File", false, "All files (*.*)|*.*|Binary files (*.bin)|*.bin")
  if userchoice ~= nil then
    fdl1 = userchoice.fullpath
    FDL1PathEntry.text = fdl1
    ps("Using FDL1 file "..fdl1, win)
  end
end

function FDL2Picker:onClick()
  local userchoice = ui.opendialog("Choose FDL2 File", false, "All files (*.*)|*.*|Binary files (*.bin)|*.bin")
  if userchoice ~= nil then
    fdl2 = userchoice.fullpath
    FDL2PathEntry.text = fdl2
    ps("Using FDL2 file "..fdl2, win)
  end
end

function startjob(fdl1, fdl2, fdl1add, fdl2add)
  if not next(joblist) and istest == false then
    ps("No jobs are scheduled, the tool might be stuck forever!!! Automatically adjusting...", win)
    table.insert(joblist, "reset")
    list.items = joblist
    ui.info("No jobs are queued.\r\nIt will cause the tool to froze forever.\r\nFor the safety, a reboot command is added.")
  end
    local jobstring = table.concat(joblist, " ")
    local basecommand = string.format("spd_dump --wait 30 fdl \"%s\" %s fdl \"%s\" %s exec %s", fdl1, fdl1add, fdl2, fdl2add, jobstring)

    if istest then
        basecommand = basecommand .. " reset"
    end
    
    local temp_file = "spd_dump_output_"..os.time()..".txt"
    logfilename = temp_file
    local full_command = string.format("cmd /C \"%s > \"%s\" 2>&1\"", basecommand, temp_file)
    ps("Executing:", win)
    ps(full_command, win)
    ps("Output will be logged after command finishes...", win)

    local result_success = sys.cmd(full_command)
    
    local file, err = io.open(temp_file, "r")
    
    if file then
        print("--- spd_dump Output Start ---")
        for line in file:lines() do
            print(line) 
        end
        file:close()
        print("--- spd_dump Output End ---")
        if not retainlog then
          os.remove(temp_file)
        end
    else
        ps("Warning: Could not read output file. Error: " .. tostring(err), win)
    end
    
    return result_success
end

function ConnectBTN:onClick()
  if FDL1Entry.text ~= nil and FDL2Entry.text ~= nil and FDL1PathEntry.text ~= "" and FDL2PathEntry.text ~= "" then
    fdl1 = FDL1PathEntry.text
    fdl2 = FDL2PathEntry.text
    ui.warn("Establishing Connection\r\nDo not touch target device unless prompted to do so!\r\nClick OK to proceed")
    ps("Param OK running jobs", win)
    ps("Program might appear frozen during operation, this is not an error.\r\nPlease wait patiently until target device restarts.", win)
    local convertedjobs = ""
    local result = startjob(fdl1, fdl2, FDL1Entry.text, FDL2Entry.text)
    if result == true then
      ps("Done", win)
      ui.info("Job completed!")
    else
      ui.error("Job failed...")
      ps("Error", win)
    end
  else
    ui.error("One or more parameter(s) not defined.")
    ps("Job Fail param not defined", win)
  end
  if retainlog then
    ps("Your log has been saved as "..logfilename, win)
  end
end

-- NewJob
function newjob()
  -- Functions for Jobwin
  function DirPicker:onClick()
    userchoice = ui.dirdialog("Please select a folder as backup directory")
    if userchoice then
      dir = userchoice.fullpath
      DirEntry.text = dir
    end
  end
  
  function fPicker:onClick()
    local userchoice = ui.opendialog("Choose File", false, "All files (*.*)|*.*|Binary files (*.bin)|*.bin|Image files(*.img)|*.img")
    if userchoice then
      file = userchoice.fullpath
      fEntry.text = file
    end
  end
  
  function tab:onSelect(item)
    if item == tab.items[2] then
      expertmode = true
    else
      expertmode = false
    end
  end
  
  local function showtab(tab)
    notcustlabel.visible = false
    for index, value in ipairs(panels) do
      value.visible = false
    end
    if tab then
      tab.visible = true
    else
      notcustlabel.visible = true
      notcustlabel.text = "No customizable option"
      notcustlabel:center()
    end
  end
  
  function combobox:onChange()
    ez_current = combobox.selected.index
    if ez_current <= 4 then
      showtab(panels[ez_current])
    else
      showtab()
    end
  end
  
  -- Dual BTN Actions
  function DiscardBTN:onClick()
    jobwin:hide()
  end
  
  function DoneBTN:onClick()
    if expertmode then
      table.insert(joblist, commandentry.text)
    else
      if ez_current ~= 0 then
        if ez_current == 1 then
          table.insert(joblist, "path "..dir)
        elseif ez_current == 2 then
          table.insert(joblist, "r "..rEntry.text)
        elseif ez_current == 3 then
          table.insert(joblist, "w "..wEntry.text.." "..fEntry.text)
        elseif ez_current == 4 then
          table.insert(joblist, "e "..eEntry.text)
        elseif ez_current == 5 then
          table.insert(joblist, "reset")
        elseif ez_current == 6 then
          table.insert(joblist, "reboot-recovery")
        elseif ez_current == 7 then
          table.insert(joblist, "reboot-fastboot")
        elseif ez_current == 8 then
          table.insert(joblist, "poweroff")
        end
      end
    end
    list.items = joblist
    jobwin:hide()
  end
  
  -- Finalize
  jobwin:center()
  jobwin:show()
end

function NewJobBTN:onClick()
  newjob()
end

function RemSelBTN:onClick()
  if list.selected then
    table.remove(joblist, list.selected.index)
    list.items = joblist
  end
end

File.items[2].onClick = function (self)
  local userchoice = ui.savedialog("Export Job Queue", false, "Job Queue (*.jobq)|*.jobq|Text files (*.txt)|*.txt")
  
  if userchoice ~= nil then
    local filename = userchoice.fullpath
    
    local file, err = io.open(filename, "w")
    
    if file then
      for i, job in ipairs(joblist) do
        file:write(job .. "\n")
      end
      file:close()
      ps("Job queue exported to: " .. filename, win)
      ui.info("Job queue saved successfully!")
    else
      ui.error("Failed to open file for writing: " .. tostring(err))
      ps("Export failed: " .. tostring(err), win)
    end
  end
end

File.items[1].onClick = function (self)
  local userchoice = ui.opendialog("Import Job Queue", false, "Job Queue (*.jobq)|*.jobq|Text files (*.txt)|*.txt")
  
  if userchoice ~= nil then
    local filename = userchoice.fullpath
    
    local file, err = io.open(filename, "r")
    
    if file then
      joblist = {} 
      
      for line in file:lines() do
        -- Trim any leading/trailing whitespace
        local trimmed_line = line:trim() 
        if trimmed_line ~= "" then
          table.insert(joblist, trimmed_line)
        end
      end
      
      file:close()
      
      list.items = joblist
      ps("Job queue imported from: " .. filename, win)
      ui.info("Job queue loaded successfully! (" .. #joblist .. " jobs imported)")
    else
      ui.error("Failed to open file for reading: " .. tostring(err))
      ps("Import failed: " .. tostring(err), win)
    end
  end
end

function ACBTN:onClick()
  if ui.confirm("This will remove all queued job from the list.") == "yes" then
    joblist = {}
    list.items = joblist
  end
end

About.items[1].onClick = function (self)
  ABTWin:center()
  ABTWin:show()
end

win:show()

-- Init things
ps("Welcome to the "..appname.." "..version.."!")
ps("This is a free software, do not resell this software.")
win:status(appname.." "..version.." by Iroha9876 (a.k.a. 4NF)")
if not sys.File("nodialogue").exists then 
  ui.info("THIS PROGRAM IS PROVIDED FREE OF CHARGE.\r\n\r\nANY RESELLING OF THIS PROGRAM IS STRICTLY PROHIBITED.\r\nIF YOU PAID FOR THIS SOFTWARE, ASK FOR REFUND ASAP AND REPORT THEM TO ME IF POSSIBLE.\r\n\r\nThis program is currently in alpha.\r\nIt might contain defects and unexpected behaviors.\r\nFlashing device with BROM/FDL mode is a high-risk operation.\r\nOnly use this utility if you REALLY know what you're doing.\r\nAny feedback is welcome.\r\n\r\nThis tool is optimized for devices that doesn't erase splloader (e.g. the safe method of using keycombos to enter BROM.)\r\nALWAYS REMEMBER TO ADD 'w splloader ...' ON THE END OF THE JOB QUEUE IF YOU USED 'adb reboot autodloader' OR KICK!!!\r\nIF NOT, DEVICE WILL STUCK IN BROM FOREVER UNTIL SPLLOADER IS FLASHED!!!\r\n\r\nClick 'OK' to proceed.")
end

if semode == true then
  print("Single Executable Mode is Enabled, Autoconfig Env...")
  for index, value in ipairs({"Channel9.dll", "spd_dump.exe"}) do
    if not sys.File(value).exists then
      local file = getembedfile("exec/"..value)
      print("Required file "..value.." not found, Extracting...")
      file:open("read")
      file:copy(value)
      file:close()
    else
      print("Required file "..value.." found, skipping...")
    end
  end
end

for index, value in ipairs({"Channel9.dll", "spd_dump.exe"}) do
  if not sys.File(value).exists then
    ui.error("Required file "..value.." not found")
    win:hide()
  else
    print("File OK: "..value)
  end
end

repeat
	ui.update()
until not win.visible