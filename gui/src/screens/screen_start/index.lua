local view = require("src/screens/screen_start/view")
local controller = require("src/screens/screen_start/controller")

function create_screen(app)
    local c = controller(app)
    local v = view(c)
    return v
end

return create_screen