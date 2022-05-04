local Table = require("core.Table")
local Array = Table.Array
local class = require("core.class")
local sonaxaton = require "core.Sonaxaton"

local Class = class:new("core.OnResearchQueueChanged", nil,
    {
    Forces = { get = function(self)
        if not global.Forces then global.Forces = {} end
        return global.Forces
    end }
})

defines.events.on_research_queue_changed = script.generate_event_name()
Class.EventId = defines.events.on_research_queue_changed

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
            script.raise_event(Class.EventId, { research = research, force = force, })
        end
    end

    self:RefreshResearchQueueCopy(force)
end

function Class:RefreshResearchQueueCopy(force)
    self.Forces[force.index] = self:GetResearchQueue(force)
end

function Class:OnTick(event)
    if self.NextTickToCheck and self.NextTickToCheck > event.tick then return end
    self.NextTickToCheck = event.tick + 60

    for _, force in pairs(game.forces) do self:AlignResearchQueueCopy(force) end
end

function Class:OnResearchChanged(event) self:RefreshResearchQueueCopy(event.research.force) end

function Class:RefreshResearchQueueCopies()
    for _, force in pairs(game.forces) do self:RefreshResearchQueueCopy(force) end
end

function Class:new()
    local self = self:adopt {  }
    script.on_event(defines.events.on_research_finished, self.OnResearchChanged, self.class.name)
    script.on_event(defines.events.on_research_started, self.OnResearchChanged, self.class.name)
    script.on_event(defines.events.on_tick, self.OnTick, self.class.name)
    return self
end

return Class
