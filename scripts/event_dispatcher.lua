local self = {
    on_init = {},
    on_load = {},
    on_configuration_changed = {},
    nth_ticks_handlers = {},
    events = {}
}

self.register_event = function(name, handler)
    if not name or type(name) ~= "string" or name == "" then
        error("Wrong type of the event name.")
    end

    if name == "on_nth_tick" then
        error("Use the register_on_nth_tick function to register an on_nth_tick event handler.")
    end

    if not handler or type(handler) ~= "function" then
        error("Wrong type of the handler.")
    end

    local init

    if name == "on_init" or name == "on_load" then
        init = (#self[name] == 0)
        table.insert(self[name], handler)

        if not init then
            return
        end

        script[name](function()
            for _, event_handler in pairs(self[name]) do
                event_handler()
            end
        end)

        return
    end

    if name == "on_configuration_changed" then
        init = (#self.on_configuration_changed == 0)
        table.insert(self.on_configuration_changed, handler)

        if not init then
            return
        end

        script.on_configuration_changed(function(data)
            for _, event_handler in pairs(self.on_configuration_changed) do
                event_handler(data)
            end
        end)

        return
    end

    if not self.events[name] then
        self.events[name] = {}
    end

    init = (#self.events[name] == 0)
    table.insert(self.events[name], handler)

    if not init then
        return
    end

    script.on_even(name, function(event)
        for _, event_handler in pairs(self.events[name]) do
            event_handler(event)
        end
    end)
end

return self