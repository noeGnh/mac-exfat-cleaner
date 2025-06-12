# Mac exFat Cleaner

## Overview

This toolset helps maintain clean ExFAT volumes on macOS by automatically removing macOS-specific metadata files before ejection. The installation includes:

1. Two executable scripts:
   - `clean-exfat.sh`: Cleans macOS metadata files from all mounted ExFAT volumes
   - `eject-clean.sh`: Wrapper that cleans before ejecting a specific volume

2. A LaunchAgent for automatic cleaning when volumes are unmounted

3. A convenient `eject` alias that performs cleaning before ejection

## Cleaning Behavior

The `clean-exfat.sh` script specifically targets:

- macOS dot-underscore files (`._*`) using both `dot_clean` and `find` commands
- Operates on all mounted ExFAT volumes (identified as 'Microsoft Basic Data')

## Requirements

- macOS system (uses native `diskutil`, `dot_clean`, and `launchctl`)
- Bash shell (for installation script)

## Installation

```bash
chmod +x install.sh
./install.sh
```

The installer will:

1. Create `~/bin/` and `~/Library/LaunchAgents/` if needed
2. Install the scripts with executable permissions
3. Set up the LaunchAgent
4. Configure your shell with an `eject` alias/function

## Usage

### Basic Usage

```bash
eject VolumeName
```

### Manual Cleaning (all ExFAT volumes)

```bash
~/bin/clean-exfat.sh
```

### Manual Cleaning (specific volume)

```bash
~/bin/eject-clean.sh VolumeName
```

## Automatic Cleaning

The LaunchAgent automatically runs `clean-exfat.sh` whenever:

- A volume is unmounted through Finder
- The system shuts down or restarts
- The user logs out

## Uninstallation

1. Remove scripts:

   ```bash
   rm ~/bin/clean-exfat.sh ~/bin/eject-clean.sh
   ```

2. Remove LaunchAgent:

   ```bash
   launchctl unload ~/Library/LaunchAgents/com.rkn.cleanexfat.plist
   rm ~/Library/LaunchAgents/com.rkn.cleanexfat.plist
   ```

3. Remove from shell config:
   - Delete `alias eject` lines from `~/.bashrc`, `~/.zshrc`, etc.
   - For fish: `rm ~/.config/fish/functions/eject.fish`

## Notes

- Only affects ExFAT volumes (identified as 'Microsoft Basic Data')
- Uses macOS's native `dot_clean` tool plus direct deletion for thorough cleaning
- Safe for regular use - doesn't modify any non-metadata files

## Troubleshooting

If the `eject` command isn't recognized:

```bash
source ~/.zshrc  # or .bashrc depending on your shell
```

To verify the LaunchAgent is loaded:

```bash
launchctl list | grep cleanexfat
```
