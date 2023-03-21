local class = require("class")
local io = require("io")
local component = require("component")
local filesystem = require("filesystem")
local serialization = require("serialization")


local BlockStorage, static = class()

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

function to_hex_char(char_code)
    if char_code < 10 then
        return char_code
    else
        return string.char(55 + char_code)
    end
end

function to_hex_string(str)
    local result = ""
    for i = 1, #str do
        local c = str:sub(i,i)
        -- do something with c
        cc = string.byte(c)
        c1 = math.floor(cc / 16)
        c2 = cc % 16
        result = result .. to_hex_char(c1) .. to_hex_char(c2)
    end
    return result
end

function identical_blocks(b1, b2)
    if b1 == nil or b2 == nil then
        return false
    end

    if b1.name ~= b2.name then
        return false
    end

    if b1.color ~= b2.color then
        return false
    end

    if b1.metadata ~= b2.metadata then
        return false
    end

    for k, v in pairs(b1.properties) do
        if b2.properties[k] ~= v then
            return false
        end
    end
    return true
end

function BlockStorage:new(path, geolyzer, database_list)
    self.__path = path
    self.__geolyzer = geolyzer
    self.__database_list = database_list
end

function BlockStorage:get_path()
    return self.__path
end

function BlockStorage:get_geolyzer()
    return self.__geolyzer
end

function BlockStorage_reduced_block(block)
    return {
        name=block.name,
        color=block.color,
        metadata=block.metadata,
        properties=block.properties
    }
end

function BlockStorage_get_path(self, block)
    local parts = split(block.name, ":")
    local view_block = BlockStorage_reduced_block(block)
    local dirpath = filesystem.concat(self.__path, parts[1], parts[2], block.color .. "")

    local it = filesystem.list(dirpath)
    local filename

    repeat
        filename = it()
        if filename == nil then
            break
        end
        local filepath = filesystem.concat(dirpath, filename)

        buffer = io.open(filepath, "r")
        values = buffer:read("*a")
        values = serialization.unserialize(values)
        buffer:close()

        if identical_blocks(block, values.block) then
            return values, filepath, dirpath, filename
        end
    until filename == nil

    local hash = self:get_hash(block)
    return nil, filesystem.concat(dirpath, hash), dirpath, hash
end

function BlockStorage_find_empty_slot(self)
    for _, v in pairs(self.__database_list) do
        for i =1,81 do
            result = v.get(i)
            if result == nil then
                return v.address, i
            end
        end
    end
end

function BlockStorage:get_hash(block)
    local content = serialization.serialize(block)
    local hash = component.data.md5(content)
    return to_hex_string(hash)
end

function BlockStorage:store_block(name, texture)
    local block = self:get_geolyzer().analyze(1)
    local values, path, dirpath = BlockStorage_get_path(self, block)
    local buffer

    if values == nil then
        values = {}
    end

    values.name = name
    values.texture = texture
    values.block = BlockStorage_reduced_block(block)

    if values.database == nil then
        local addr, slot = BlockStorage_find_empty_slot(self)
        local db = self.__database_list[addr]
        self:get_geolyzer().store(1, addr, slot)
        values.database = {
            address=addr,
            slot=slot,
            hash=db.computeHash(slot)
        }
    end

    if not filesystem.isDirectory(dirpath) then
        filesystem.makeDirectory(dirpath)
    end

    buffer = io.open(path, "w")
    buffer:write(serialization.serialize(values))
    buffer:close()

    return values
end

function BlockStorage:get_block(block)
    local values = BlockStorage_get_path(self, block)
    return values
end

return static