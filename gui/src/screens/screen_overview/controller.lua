local class = require("class")

local StartController, static = class()

function StartController:new(app)
    self.__app = app
    self.__texture = self.__app:get_state("texture")
end

function StartController:get_app()
    return self.__app
end

function StartController:get_texture_loader()
    return self.__texture
end

return static