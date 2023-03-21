local class = require("class")
local serialization = require("serialization")
local os = require("os")

local Shape = require("src/shape")
local Model = require("src/model")

local ModelParser, static = class()

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

function table_append(t1, t2)
    if t2 == nil then
        return false
    end
    for k,v in ipairs(t2) do
        table.insert(t1, v)
    end
    return true
end

function find_block_increment(block_list, block, x_m, y_m, z_m)
    local block_inc_list = {}
    for k,v in ipairs(block_list) do
        if identical_blocks(data[v[3] - z_m][v[2] - y_m][v[1] - x_m], block) then
            table.insert(block_inc_list, {v[1] - x_m, v[2] - y_m, v[3] - z_m})
        else
            return nil
        end
    end
    return block_inc_list
end

function convert_shape(block_list, base_length, block, texture)
    local p_min = {base_length, base_length, base_length}
    local p_max = {1, 1, 1}
    for k,v in ipairs(block_list) do
        p_min = { math.min(v[1], p_min[1]), math.min(v[2], p_min[2]), math.min(v[3], p_min[3]) }
        p_max = { math.max(v[1], p_max[1]), math.max(v[2], p_max[2]), math.max(v[3], p_max[3]) }
    end
    return Shape(block, texture, p_min, p_max)
end

function find_shape(x, y, z, data, base_length, texture_loader)
    local point = {x, y, z}
    local block_list = {{x, y, z}}
    local texture = texture_loader:get_texture(data[z][y][x])

    for d_i = 1,3 do
        local block_inc_list = {}
        for d_m = 1,point[d_i]-1 do
            dd = {0, 0, 0}
            dd[d_i] = d_m
            if not table_append(block_inc_list, find_block_increment(block_list, data[z][y][x], dd[1], dd[2], dd[3])) then
                break
            end
        end

        for d_m = -1,point[d_i] - base_length,-1 do
            dd = {0, 0, 0}
            dd[d_i] = d_m
            if not table_append(block_inc_list, find_block_increment(block_list, data[z][y][x], dd[1], dd[2], dd[3])) then
                break
            end
        end

        table_append(block_list, block_inc_list)
    end
    return convert_shape(block_list, base_length, data[z][y][x], texture), block_list
end

function disable_blocks(block_flags, block_list)
    for k,v in ipairs(block_list) do
        block_flags[v[3]][v[2]][v[1]] = false
    end
end

function ModelParser:new(texture_loader)
    self.__texture_loader = texture_loader
end

function ModelParser:parse(name, data)
    base_length = #data

    block_flags = {}
    for z = 1, base_length do
        block_flags[z] = {}
        for y = 1, base_length do
            block_flags[z][y] = {}
            for x = 1, base_length do
                block_flags[z][y][x] = (data[z][y][x] ~= nil)
            end
        end
    end

    shapes = {}
    for z = 1, base_length do
        for y = 1, base_length do
            for x = 1, base_length do
                if block_flags[z][y][x] then
                    shape, block_list = find_shape(x, y, z, data, base_length, self.__texture_loader)
                    table.insert(shapes, shape)
                    disable_blocks(block_flags, block_list)
                end
            end
        end
    end

    return Model(name, base_length, shapes)
end

return static