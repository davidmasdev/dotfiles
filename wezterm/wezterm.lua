local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Use PowerShell 7 as the default shell on Windows.
if wezterm.target_triple:find("windows") then
    config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- Start each newly launched GUI instance maximized.
wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

-- Show a tmux-style clock and date at the right of the tab bar.
wezterm.on("update-right-status", function(window)
    window:set_right_status(wezterm.strftime(" %H:%M  %a %d %b %Y "))
end)

-- Keep tab labels concise: prefer an explicit title, then the active process title.
wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
    local title = tab.tab_title
    if not title or #title == 0 then
        title = tab.active_pane.title
    end

    local prefix = string.format(" %d  ", tab.tab_index + 1)
    local available = math.max(1, max_width - #prefix - 1)
    if #title > available then
        title = title:sub(1, available - 1) .. "…"
    end

    return prefix .. title .. " "
end)

-- Restore panes to evenly balanced sizes along the requested axis.
local function balance_panes(axis, window, pane)
    local tab = window:active_tab()
    local original_pane_id = pane:pane_id()
    local previous_direction = axis == "x" and "Left" or "Up"
    local next_direction = axis == "x" and "Right" or "Down"
    local size_key = axis == "x" and "cols" or "viewport_rows"
    local tab_size_key = axis == "x" and "cols" or "rows"
    local panes = { pane }
    local visited = { [original_pane_id] = true }

    for _, direction in ipairs({ previous_direction, next_direction }) do
        pane:activate()

        while true do
            local current = tab:active_pane()
            window:perform_action(act.ActivatePaneDirection(direction), current)

            local adjacent = tab:active_pane()
            local adjacent_id = adjacent:pane_id()
            if adjacent_id == current:pane_id() or visited[adjacent_id] then
                break
            end

            visited[adjacent_id] = true
            table.insert(panes, adjacent)
        end
    end

    local target_size = math.floor(tab:get_size()[tab_size_key] / #panes)
    for _, sibling in ipairs(panes) do
        local adjustment = sibling:get_dimensions()[size_key] - target_size
        if adjustment ~= 0 then
            local direction = adjustment < 0 and next_direction or previous_direction
            window:perform_action(
                act.AdjustPaneSize({ direction, math.abs(adjustment) }),
                sibling
            )
        end
    end

    pane:activate()
end

local function reset_pane_sizes(window, pane)
    balance_panes("x", window, pane)
    balance_panes("y", window, pane)
end

-- Open new tabs in the active pane's current working directory.
local spawn_tab_in_current_directory = wezterm.action_callback(function(window, pane)
    local cwd_url = pane:get_current_working_dir()
    local cwd = cwd_url and cwd_url.file_path or nil

    window:perform_action(
        act.SpawnCommandInNewTab {
            domain = "CurrentPaneDomain",
            cwd = cwd,
        },
        pane
    )
end)

-- --------------------------------------------------
-- Basics
-- --------------------------------------------------

-- JetBrains Mono and the Nerd Font symbols are bundled with WezTerm, so this
-- works on both Linux and Windows without relying on a system-specific path.
config.font = wezterm.font_with_fallback({
    { family = "JetBrains Mono", weight = "Regular" },
})
config.font_size = 14.0
config.line_height = 1.08

-- Avoid cursor reappearance issues seen after typing under GNOME/Wayland.
config.hide_mouse_cursor_when_typing = false

-- A restrained dark theme with clear syntax colors and comfortable contrast.
config.color_scheme = "Catppuccin Mocha"

-- Use a compact tmux-like tab bar along the bottom of the window.
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 28
config.status_update_interval = 1000
config.colors = {
    tab_bar = {
        background = "#181825",
        active_tab = {
            bg_color = "#313244",
            fg_color = "#cdd6f4",
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = "#1e1e2e",
            fg_color = "#a6adc8",
        },
        inactive_tab_hover = {
            bg_color = "#45475a",
            fg_color = "#cdd6f4",
        },
        new_tab = {
            bg_color = "#181825",
            fg_color = "#a6adc8",
        },
        new_tab_hover = {
            bg_color = "#45475a",
            fg_color = "#cdd6f4",
        },
    },
}
config.window_frame = {
    font = wezterm.font("JetBrains Mono", { weight = "Regular" }),
    font_size = 11.0,
    active_titlebar_bg = "#1e1e2e",
    inactive_titlebar_bg = "#181825",
    active_titlebar_fg = "#cdd6f4",
    inactive_titlebar_fg = "#7f849c",
    active_titlebar_border_bottom = "#313244",
    inactive_titlebar_border_bottom = "#181825",
    button_fg = "#cdd6f4",
    button_bg = "#1e1e2e",
    button_hover_fg = "#11111b",
    button_hover_bg = "#cba6f7",
}

-- Use native window chrome so the desktop can provide its title bar and,
-- where supported by the compositor, rounded window corners.
config.window_decorations = "TITLE | RESIZE"
config.window_padding = {
    left = 14,
    right = 14,
    top = 12,
    bottom = 12,
}
config.use_resize_increments = false
config.enable_scroll_bar = false

-- Useful for Claude's potentially long output
config.scrollback_lines = 10000

-- Close panes and windows without confirmation prompts
config.window_close_confirmation = "NeverPrompt"

-- --------------------------------------------------
-- Leader
-- --------------------------------------------------
--
-- Ctrl-a acts like tmux's prefix.
--
-- Example:
--   Ctrl-a h    -> pane left
--   Ctrl-a \    -> split right
--   Ctrl-a z    -> zoom pane
--
config.leader = {
    key = "a",
    mods = "CTRL",
    timeout_milliseconds = 1000,
}

config.keys = {
    -- Ctrl-a Ctrl-a sends a real Ctrl-a to the shell/program
    {
        key = "a",
        mods = "LEADER|CTRL",
        action = act.SendKey {
            key = "a",
            mods = "CTRL",
        },
    },

    -- ------------------------------------------------
    -- Vim-style pane navigation
    -- ------------------------------------------------

    {
        key = "h",
        mods = "LEADER",
        action = act.ActivatePaneDirection("Left"),
    },
    {
        key = "j",
        mods = "LEADER",
        action = act.ActivatePaneDirection("Down"),
    },
    {
        key = "k",
        mods = "LEADER",
        action = act.ActivatePaneDirection("Up"),
    },
    {
        key = "l",
        mods = "LEADER",
        action = act.ActivatePaneDirection("Right"),
    },

    -- ------------------------------------------------
    -- Splits
    -- ------------------------------------------------

    -- Ctrl-a \ -> split left/right
    {
        key = "v",
        mods = "LEADER",
        action = act.SplitHorizontal {
            domain = "CurrentPaneDomain",
        },
    },

    -- Ctrl-a - -> split top/bottom
    {
        key = "s",
        mods = "LEADER",
        action = act.SplitVertical {
            domain = "CurrentPaneDomain",
        },
    },

    -- ------------------------------------------------
    -- Resize panes
    --
    -- Upper-case H/J/K/L
    -- ------------------------------------------------

    {
        key = "H",
        mods = "LEADER",
        action = act.AdjustPaneSize({ "Left", 10 }),
    },
    {
        key = "J",
        mods = "LEADER",
        action = act.AdjustPaneSize({ "Down", 10 }),
    },
    {
        key = "K",
        mods = "LEADER",
        action = act.AdjustPaneSize({ "Up", 10 }),
    },
    {
        key = "L",
        mods = "LEADER",
        action = act.AdjustPaneSize({ "Right", 10 }),
    },

    -- Ctrl-a = -> restore evenly balanced pane sizes
    {
        key = "=",
        mods = "LEADER",
        action = wezterm.action_callback(reset_pane_sizes),
    },

    -- ------------------------------------------------
    -- Pane management
    -- ------------------------------------------------

    -- Zoom/unzoom current pane
    {
        key = "z",
        mods = "LEADER",
        action = act.TogglePaneZoomState,
    },

    -- Close pane
    {
        key = "q",
        mods = "LEADER",
        action = act.CloseCurrentPane {
            confirm = false,
        },
    },

    -- Pick a pane visually
    {
        key = "x",
        mods = "LEADER",
        action = act.PaneSelect,
    },

    -- ------------------------------------------------
    -- Tabs
    -- ------------------------------------------------

    -- New tab in the active pane's current directory
    {
        key = "c",
        mods = "LEADER",
        action = spawn_tab_in_current_directory,
    },
    {
        key = "t",
        mods = "CTRL|SHIFT",
        action = spawn_tab_in_current_directory,
    },

    -- Next / previous tab
    {
        key = "n",
        mods = "LEADER",
        action = act.ActivateTabRelative(1),
    },
    {
        key = "p",
        mods = "LEADER",
        action = act.ActivateTabRelative(-1),
    },

    -- ------------------------------------------------
    -- Copy mode
    -- ------------------------------------------------

    -- Enter terminal copy mode
    {
        key = "[",
        mods = "LEADER",
        action = act.ActivateCopyMode,
    },
}

-- Ctrl-a 1..9 -> tab 1..9
for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = act.ActivateTab(i - 1),
    })
end

return config
