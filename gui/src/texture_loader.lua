local class = require("class")
local serialization = require("serialization")
local component = require("component")
local os = require("os")


local TextureLoader, static = class()

function split(inputstr, sep)
    sep=sep or '%s'
    local t={}
    for field, s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do
        table.insert(t,field)
        if s == "" then
            return t
        end
    end
end

function create_default_texture(block)
    local parts = split(block.name, ":")
    return parts[1] .. ":blocks/" .. parts[2]
end

function TextureLoader:new(storage)
    self.__storage = storage
end

function TextureLoader:get_texture(block)
    --return create_default_texture(block)
    local values = self.__storage:get_block(block)
    if values ~= nil then
        return values.texture
    end
end


function TextureLoader:get_stored_block(block)
    return self.__storage:get_block(block)
end

function TextureLoader:save_current_block(name, texture)
    self.__storage:store_block(name, texture)
end

function TextureLoader:get_hash(block)
    return self.__storage:get_hash(block)
end

function TextureLoader:scan_block()
    return self.__storage:get_geolyzer().analyze(1)
end

return static