local class = require("class")
local ModelParser = require("src/model_parser")

local TextureController, static = class()

function TextureController:new(app)
    self.__app = app
    self.__model_parser = ModelParser(self.__app:get_state("texture"))
end

function TextureController:get_app()
    return self.__app
end

function TextureController:create_model(name, data)
    return self.__model_parser:parse(name, data)
end

function TextureController:get_texture_loader()
    return self.__app:get_state("texture")
end

return static