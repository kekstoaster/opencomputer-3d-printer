local class = require("class")

local Model, static = class()

function Model:new(name, size, shapes)
    self.__name = name
    self.__shapes = shapes
    self.__size = size
end

function Model:get_name()
    return self.__name
end

function Model:get_size()
    return self.__size
end

function Model:get_shapes()
    return self.__shapes
end

return static