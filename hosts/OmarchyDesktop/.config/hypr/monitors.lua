-- OmarchyDesktop — AMD Ryzen 5 5600G (Cezanne / Radeon Vega iGPU)
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Detected 2026-09-05: HDMI-A-1 — HP X24ih (1CR1031J3Z), 1920x1080@60, scale 1.
-- The catch-all above already covers it. Pin it only if you add a second
-- display and need explicit placement:
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
