Provides an event called "on_research_queue_changed" that is raised at any change of research queue.
It is ment to replace on_research_cancelled, on_research_finished and on_research_started.
It uses almost the same interface as on_research_cancelled.

How to use: 

script.on_event(defines.events.on_research_queue_changed, function(event) 
--[ where event is like:
   research :: dictionary[string → uint]: A mapping of technology name to -1 for deleted, 0 for finished and 1 for added researches.
   force :: the ordering force
   name :: defines.events: Identifier of the event
   tick :: uint: Tick the event was generated.
]--
end)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/G2G4BH6WX)
