local class = require("class")
local ModelParser = require("src/model_parser")

local StartController, static = class()

function StartController:new(app)
    self.__app = app
    self.__model_parser = ModelParser(self.__app:get_state("texture"))
end

function StartController:get_app()
    return self.__app
end

function StartController:create_model(name, data)
    return self.__model_parser:parse(name, data)
end

return static