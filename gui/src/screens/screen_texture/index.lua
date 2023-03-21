local view = require("src/screens/screen_texture/view")
local controller = require("src/screens/screen_texture/controller")

function create_screen(app)
    local c = controller(app)
    local v = view(c)
    return v
end

return create_screen