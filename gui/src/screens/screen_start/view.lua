local computer = require("computer")
local component = require("component")
local serialization = require("serialization")
local os = require("os")
local event = require("event")
local class = require("class")

local View = require("gui/screenview")
local Header = require("gui/component/component_header")
local Button = require("gui/component/component_button")
local HorizontalCenter = require("gui/component/component_horizontal_center")

local StartView, static, base = class(View)

function StartView:new (controller)
    base.new(self)
    self.__ctrl = controller

    local move = 32

    function load_fn()
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

    local btn_load = Button{text="Laden", click=load_fn, padding=10, name="btn"}
    local hc_load = HorizontalCenter{component=btn_load, y=25}

    self:add_component(Header{text="3D Drucker - Startbildschirm", y=4})
    self:add_component(hc_load)
end


return static