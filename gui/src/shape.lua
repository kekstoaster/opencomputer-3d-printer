local class = require("class")

local Shape, static = class()

function Shape:new(block, texture, p1, p2)
    self.__block = block
    self.__texture = texture
    self.__p1 = p1
    self.__p2 = p2
end

function Shape:get_block()
    return self.__block
end

function Shape:get_texture()
    return self.__texture
end

function Shape:get_c1(i)
    return self.__p1[i]
end

function Shape:get_c2(i)
    return self.__p2[i]
end

return static