local view = require("src/screens/screen_print/view")
local controller = require("src/screens/screen_print/controller")

function create_screen(app)
    local c = controller(app)
    local v = view(c)
    return v
end

return create_screen