local Constants = require "Constants"
local Table = require "core.Table"
local Array = Table.Array
local class = require "core.class"
local sonaxaton = require "core.Sonaxaton"

if not defines.events.on_research_queue_changed then
    defines.events.on_research_queue_changed = script.generate_event_name()
end

local Class = class:new("OnResearchQueueChanged", nil,
    {
    Forces = { get = function(self)
        if not global.Forces then global.Forces = {} end
        return global.Forces
    end },
    NextTickToCheck = {
        get = function(self) return global.NextTickToCheck end,
        set = function(self, value) global.NextTickToCheck = value end,
    }
})

function Class:GetResearchQueue(force)
    if sonaxaton.IsValid() then
        return Array:new(sonaxaton.GetQueue(force))
    else
        return Array:new(force.research_queue):Select(
            function(technology) return technology.name end
        )
    end
end

function Class:HasResearchQueueChanged(force)
    local last = self.Forces[force.index]
    local current = self:GetResearchQueue(force)
    if #last ~= #current then return true end
    for index = 1, #last do if last[index] ~= current[index] then return true end end
end

function Class:AlignResearchQueueCopy(force)
    if self.Forces[force.index] then
        if not self:HasResearchQueueChanged(force) then return end

        local active = self:GetResearchQueue(force)--
            :ToDictionary(function(technology) return { Key = technology, Value = true } end)

        local last = self.Forces[force.index]
            :ToDictionary(function(technology) return { Key = technology, Value = true } end)

        local research = {}
        last--
            :Select(
                function(_, name)
                if not active[name] then
                    local count = force.technologies[name].researched and 0 or -1
                    research[name] = count
                end
            end
            )

        active--
            :Select(
                function(_, name)
                if not last[name] then research[name] = 1 end
            end
            )

        if next(research) then
            script.raise_event(defines.events.on_research_queue_changed, { research = research, force = force, })
        end
    end

    self:RefreshResearchQueueCopy(force)
end

function Class:RefreshResearchQueueCopy(force)
    local new = self:GetResearchQueue(force)
    self.Forces[force.index] = new
end

function Class:CheckResearchQueue(event)
    self.NextTickToCheck = event.tick + self.Latency

    for _, force in pairs(game.forces) do
        self:AlignResearchQueueCopy(force)
    end
end

function Class:SetLatency()
    self.Latency = settings.global["on_research_queue_changed_latency"].value
end

function Class:new()
    local self = self:adopt {}
    self:SetLatency()
    script.on_event(defines.events.on_runtime_mod_setting_changed, function(event) self:SetLatency() end)
    script.on_event(defines.events.on_research_cancelled, function(event) self:CheckResearchQueue(event) end)
    script.on_event(defines.events.on_research_finished, function(event) self:CheckResearchQueue(event) end)
    script.on_event(defines.events.on_research_started, function(event) self:CheckResearchQueue(event) end)
    script.on_event(defines.events.on_research_reversed, function(event) self:CheckResearchQueue(event) end)
    script.on_event(defines.events.on_tick,
        function(event)
        if self.Latency <= 0 or self.NextTickToCheck and self.NextTickToCheck > event.tick then return end
        self:CheckResearchQueue(event)
    end)
    return self
end

return Class
