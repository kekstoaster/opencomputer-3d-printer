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
local ProgressBar = require("gui/component/component_progress_bar")

local PrintView, static, base = class(View)

function PrintView:new (controller)
    base.new(self)
    self.__ctrl = controller

    local move = 32
    local display = LabelRow{x=20, y=15, text="<< leer >>"}
    local progress = ProgressBar{x=20, y=20, width=100}

    self.__display = display
    self.__progress = progress

    function cancel_fn()
        self:finish()
    end

    local btn_cancel = Button{text="Abbrechen", x=40, y=34, click=cancel_fn, padding=10, name="btn"}
    local hc_cancel = HorizontalCenter{component=btn_cancel, y=34}

    self:add_component(Header{text="3D Drucker - Druckauftrag", y=4})
    self:add_component(display)
    self:add_component(progress)
    self:add_component(hc_cancel)

end

function PrintView:finish()
    if self.__event_id ~= nil then
        event.cancel(self.__event_id)
    end
    self.__event_id = nil
    event.push("screen", "overview")
end

function PrintView:init(name, count)
    self.__display:set_text(name)
    self.__progress:reset()
    self.__progress:set_max(count)

    local current = 0

    function print_fn()
        if component.printer3d.status() == 'idle' then
            current = current + 1
            self.__progress:advance()
            component.printer3d.commit()
            if current >= count then
                self:finish()
            end
        end
    end

    if self.__event_id ~= nil then
        event.cancel(self.__event_id)
    end
    self.__event_id = event.timer(.2, print_fn, math.huge)
end

return static