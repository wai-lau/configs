local function handleScreenChange()
    hs.execute("/Users/wai/scripts/set_displays.sh")
end

screenWatcher = hs.screen.watcher.new(handleScreenChange)
screenWatcher:start()
