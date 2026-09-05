#!/usr/bin/env bash
# Run this on the OTHER machine and share the output. It reports only what is
# needed to write that host's monitors.lua and pick the right firmware packages.
echo "### hostname";      hostname
echo; echo "### omarchy";  omarchy version 2>/dev/null || cat /etc/omarchy-version 2>/dev/null
echo; echo "### cpu vendor (picks intel-ucode vs amd-ucode)"
grep -m1 '^vendor_id' /proc/cpuinfo; grep -m1 '^model name' /proc/cpuinfo
echo; echo "### gpu"; lspci -nn 2>/dev/null | grep -Ei 'vga|3d|display'
echo; echo "### monitors (for monitors.lua)"
hyprctl monitors all 2>/dev/null | grep -E 'Monitor|^\s+[0-9]+x[0-9]+@|scale|transform|description' | head -40
echo; echo "### fingerprint reader (decides fprintd/libfprint)"
lsusb 2>/dev/null | grep -i 'fingerprint\|synaptics\|goodix\|validity' || echo "none detected"
echo; echo "### battery (laptop vs desktop)"; ls /sys/class/power_supply/ 2>/dev/null
echo; echo "### already-installed packages, for diffing"; pacman -Qq | wc -l
