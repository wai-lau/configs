local function handleScreenChange()
    hs.execute("/Users/wai/scripts/set_displays.sh")
end

-- Prevent display sleep, but allow system idle
-- Define work hours (24h format)
local workStart = 9   -- 9 AM
local workEnd   = 17  -- 5 PM

-- Function to update caffeinate state
local function updateCaffeinate()
    local hour = tonumber(os.date("%H"))
    if hour >= workStart and hour < workEnd then
        hs.caffeinate.set("displayIdle", true, true)
    else
        hs.caffeinate.set("displayIdle", false, true)
    end
end

-- Check immediately on load
updateCaffeinate()

-- Re-check every 15 minutes
hs.timer.doEvery(900, updateCaffeinate)

screenWatcher = hs.screen.watcher.new(handleScreenChange)
screenWatcher:start()
