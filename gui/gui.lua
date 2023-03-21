local event = require("event")
local component = require("component")
local shell = require("shell")

local StartView = require("src/screens/screen_start/index")
local OverviewView = require("src/screens/screen_overview/index")
local TextureView = require("src/screens/screen_texture/index")

local GuiApp = require("gui/app")
local BlockStorage = require("src/block_storage")
local TextureLoader = require("src/texture_loader")

local config = require("config")

local data_blocks = {}
for address, _ in component.list("database", true) do
    data_blocks[address] = component.proxy(address)
end

local storage = BlockStorage(config.path, component.geolyzer, data_blocks)
local texture_loader = TextureLoader(storage)

local app = GuiApp()
app:set_state("config", config)
app:set_state("texture", texture_loader)

local screen_start = StartView(app)
local screen_overview = OverviewView(app)
local screen_texture = TextureView(app)

app:add_screen("start", screen_start)
app:add_screen("overview", screen_overview)
app:add_screen("texture", screen_texture)

app:run()

local w, h = component.gpu.maxResolution()
component.gpu.setResolution(w, h)