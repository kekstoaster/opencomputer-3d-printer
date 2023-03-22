local computer = require("computer")
local component = require("component")
local serialization = require("serialization")
local os = require("os")
local event = require("event")
local class = require("class")

local View = require("gui/screenview")
local Header = require("gui/component/component_header")
local Button = require("gui/component/component_button")
local LabelRow = require("gui/component/component_label_row")
local HorizontalCenter = require("gui/component/component_horizontal_center")
local VerticalBox = require("gui/component/component_vertical_box")
local TextInput = require("gui/component/component_input")

local OverviewView, static, base = class(View)

function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end


function OverviewView:new (controller)
    base.new(self)
    self.__ctrl = controller
    self.__model = nil


    local move = 32
    local lbl_count = LabelRow{x=10, y=34, text="Anzahl: "}
    local txt_count = TextInput{x=20, y=33, text=1}

    function print_fn()
        local num = tonumber(txt_count:get_text())
        if num <= 1 then
            component.printer3d.commit()
        else
            event.push("screen", "print", self.__lbl_object_name:get_text(), num)
        end
    end

    function texture_fn()
        event.push("screen", "texture")
    end

    function back_fn()
        event.push("screen", "start")
    end

    self.__lbl_missing_count = LabelRow{x=10, y=15, text="<< leer >>"}
    self.__lbl_object_name = LabelRow{x=10, y=30, text="<< leer >>"}
    self.__box = VerticalBox{x=10, y=17}



    self.__btn_texture = Button{text="Texturen", x=10, y=40, click=texture_fn, padding=10, name="btn"}

    local btn_load = Button{text="Drucken", click=print_fn, padding=10, name="btn"}
    local btn_back = Button{text="Zurück", x=100, y=40, click=back_fn, padding=10, name="btn"}
    local hc_load = HorizontalCenter{component=btn_load, y=40}

    self:add_component(Header{text="3D Drucker - Einstellungen", y=4})
    self:add_component(self.__lbl_object_name)
    self:add_component(lbl_count)
    self:add_component(txt_count)
    self:add_component(self.__lbl_missing_count)
    self:add_component(self.__box)
    self:add_component(btn_back)
    self:add_component(self.__btn_texture)
    self:add_component(hc_load)
end

function OverviewView:init()
    self.__model = self.__ctrl:get_app():get_state("model")

    local multi = 16 / self.__model:get_size()

    component.printer3d.reset()

    if self.__model:get_name() ~= nil then
        component.printer3d.setLabel(self.__model:get_name())
        self.__lbl_object_name:set_text(self.__model:get_name())
    else
        component.printer3d.setLabel("Eine böse Macht")
        self.__lbl_object_name:set_text("Eine böse Macht")
    end

    local shapes = self.__model:get_shapes()
    if #shapes > 24 then
        self.__lbl_missing_count:set_text("Model enthält zu viele Formen. Nur 24 sind zulässig!")
        return
    end

    missing_textures = {}
    for k,shape in ipairs(self.__model:get_shapes()) do
        component.printer3d.addShape((shape:get_c1(1) - 1) * multi, ((16 / multi) - shape:get_c2(3)) * multi, (shape:get_c1(2) - 1) * multi, shape:get_c2(1) * multi, ((16 / multi) - shape:get_c1(3) + 1) * multi, shape:get_c2(2) * multi, shape:get_texture() or "")
        if shape:get_texture() == nil then
            hash = self.__ctrl:get_texture_loader():get_hash(shape:get_block())
            missing_textures[hash] = shape:get_block()
        end
    end

    missing = getTableSize(missing_textures)

    if missing > 0 then
        self.__lbl_missing_count:set_text("Fehlende Texturen: " .. missing)
    else
        self.__lbl_missing_count:set_text("<< leer >>")
    end

    self.__box:clear()
    for k, v in pairs(missing_textures) do
        self.__box:add_component(LabelRow{text=serialization.serialize(v)})
    end

end

return static