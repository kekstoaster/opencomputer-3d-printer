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
local TextInput = require("gui/component/component_input")

local TextureView, static, base = class(View)

function TextureView:new (controller)
    base.new(self)
    self.__ctrl = controller
    self.__model = nil

    local move = 32
    local block = {}
    local display = LabelRow{x=20, y=10, text="<< leer >>"}
    local exclude = "minecraft:air"

    local display = LabelRow{x=20, y=10, text="<< leer >>"}
    local lbl_name = LabelRow{x=22, y=16, text="Name:"}
    local lbl_texture = LabelRow{x=20, y=21, text="Textur:"}
    local txt_name = TextInput{x=30, y=15, size=50}
    local txt_texture = TextInput{x=30, y=20, size=50}

    self.__display = display
    self.__txt_name = txt_name
    self.__txt_texture = txt_texture

    function identical_blocks(b1, b2)
        if b1 == nil or b2 == nil or
           b1.name ~= b2.name or
           b1.color ~= b2.color or
           b1.metadata ~= b2.metadata then
            return false
        end

        for k, v in pairs(b1.properties) do
            if b2.properties[k] ~= v then
                return false
            end
        end
        return true
    end

    function load_fn()
        block = self.__ctrl:get_texture_loader():scan_block()
        local view_block = {
            name=block.name,
            color=block.color,
            metadata=block.metadata,
            properties=block.properties
        }

        if block.name ~= exclude then
            display:set_text(serialization.serialize(view_block))
        else
            display:set_text("<< leer >>")
        end

        stored_block = self.__ctrl:get_texture_loader():get_stored_block(view_block)
        if stored_block ~= nil then
            txt_name:set_text(stored_block.name or "")
            txt_texture:set_text(stored_block.texture or "")
        else
            txt_name:set_text(block.name)
        end
    end

    function save_fn()
        local block2 = self.__ctrl:get_texture_loader():scan_block()
        if identical_blocks(block, block2) and block.name ~= exclude then
            self.__ctrl:get_texture_loader():save_current_block(txt_name:get_text(), txt_texture:get_text())
            display:set_text("Gespeichert!")
            block = {}
        end
    end

    function back_fn()
        local filename = "/model.print"
        local media = component.disk_drive.media()
        if media == nil then
            return
        end
        fs = component.proxy(media)
        local label = fs.getLabel()

        fp = fs.open(filename)

        data = ""
        chunk = fs.read(fp, 1024)
        while chunk ~= nil do
            data = data .. chunk
            chunk = fs.read(fp, 1024)
        end
        fs.close(fp)
        data = serialization.unserialize(data)

        if data ~= nil then
            data = self.__ctrl:create_model(label, data)
            self.__ctrl:get_app():set_state("model", data)
            event.push("screen", "overview")
        end
    end


    local btn_load = Button{text="Einlesen", x=20, y=34, click=load_fn, padding=10, name="btn"}
    local btn_save = Button{text="Speichern", x=60, y=34, click=save_fn, padding=10, name="btn"}
    local btn_back = Button{text="Zurück", x=100, y=34, click=back_fn, padding=10, name="btn"}

    self:add_component(Header{text="3D Drucker - Texture einlesen", y=4})
    self:add_component(display)
    self:add_component(lbl_name)
    self:add_component(lbl_texture)
    self:add_component(txt_name)
    self:add_component(txt_texture)
    self:add_component(btn_load)
    self:add_component(btn_save)
    self:add_component(btn_back)

end

function TextureView:init()
    self.__display:set_text("<< leer >>")
    self.__txt_name:set_text("")
    self.__txt_texture:set_text("")
end

return static