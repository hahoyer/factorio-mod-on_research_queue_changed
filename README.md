Provides an event called `on_research_queue_changed` that is raised at any change of research queue.
It is ment to replace `on_research_cancelled`, `on_research_finished` and `on_research_started`.
It uses almost the same interface as `on_research_cancelled`.

###How to use: 
- In your mod, add a dependency to this mod.
- In your control.lua add a function like this:
      local function InitialiseOnResearchQueueChanged() 
          defines.events.on_research_queue_changed = remote.call("on_research_queue_changed", "get_event_name")
          script.on_event(defines.events.on_research_queue_changed, function (event) ... end)
      end
- call this function in the `on_init` handler and in the `on_configuration_changed` handler
- The event structure is almost exactly like that of [`on_research_cancelled`](https://lua-api.factorio.com/latest/events.html#on_research_cancelled). The only difference is that the numbers for each technology are 
  - -1 for cancelled, 
  - 0 for completed and 
  - 1 for started research.

###Remark: 
- Since the mod monitors the research queue with some latency, it may not detect all changes. For example, if another mod manipulates the research queue directly and adds and removes a technology between two checks, this will not be detected in `on_research_queue_changed`.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/G2G4BH6WX)
