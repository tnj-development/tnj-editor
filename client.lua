------------------------------------ Vars
local CAM_ACTIVE = false
local cam
local CAM_SPEED = 5
local EnableInCam = {245, 249}
local running = false --TODO Rename Var to something better to understand
local PlacingProps = false
local TeleportingPlayer = false
local TaskingPed = false
local tempObj = nil
local ClonePedIG = nil
local SelectedPed = 'None' --TODO make default nil not not a string
local PlacingPeds = false
local EntityHash = nil
local PedHash = nil
local Selected_Ped_Weapon = 'weapon_unarmed' -- Default Weapon When selecting ped, must be the same as ped_weapon = menu3:AddSlider
local Selected_Ped_Armor = 0
local Selected_Ped_Speed = 1 -- 1.0
local CinematicMode = false
local debugging = false
local MoveCoords = nil
local TargetPed = nil
local NoLocation = vector3(0.0, 0.0, 0.0)
local SpawnedObjects = {}
local SpawnedPed = {}
local Pfxing = false

------------------------------------ MenuV Shit

local menu = MenuV:CreateMenu(false, 'Main Settings', 'topright', 84, 124, 226, 'size-125', 'none', 'menuv', 'main_settings', 'default')
local menu2 = MenuV:CreateMenu(false, 'Object Settings', 'topright', 84, 124, 226, 'size-125', 'none', 'menuv', 'obj_settings', 'default')
local menu3 = MenuV:CreateMenu(false, 'NPC Settings', 'topright', 84, 124, 226, 'size-125', 'none', 'menuv', 'npc_settings', 'default')
local menu4 = MenuV:CreateMenu(false, 'Cam Settings', 'topright', 84, 124, 226, 'size-125', 'none', 'menuv', 'cam_settings', 'default')
local menu5 = MenuV:CreateMenu(false, 'Ped Settings', 'topright', 84, 124, 226, 'size-125', 'none', 'menuv', 'ped_settings', 'default')
local menu6 = MenuV:CreateMenu(false, 'Placed Object Settings', 'topright', 84, 124, 226, 'size-125', 'none', 'menuv', 'all_objs', 'default')
local Props = MenuV:CreateMenu(false, 'Placed Object Settings', 'topright', 84, 124, 226, 'size-125', 'none', 'menuv', 'all_objs2', 'default')


local CamSettings = menu:AddButton({
    icon = '🎥',
    label = 'Cam Options',
    value = menu4,
    -- description = 'bruh'
})

local CameraCoordsButton = menu4:AddButton({
    icon = '🎥',
    label = 'Camera Coords',
    value = menu4,
    description = 'Prints the Cam Coords + Rotation to the console'
})
CameraCoordsButton:On('select', function(item, newValue, oldValue)
    local rotation = GetFinalRenderedCamRot(2)
    local location = GetFinalRenderedCamCoord()
    local spec = string.format("Position: vector3(%.3f,%.3f,%.3f)", location.x, location.y, location.z)
    print(spec)
    local spec2 = string.format("Rotation: vector3(%.3f,%.3f,%.3f)", rotation.x, rotation.y, rotation.z)
    print(spec2)
end)


-- TODO: Make this work
-- local CinematicModeButton = menu4:AddCheckbox({
--     icon = '🎥',
--     label = 'Cinematic Cam',
--     value = 'n',
--     -- description = 'bruh'
-- })
-- CinematicModeButton:On('change', function(item, newValue, oldValue)
--     CinematicMode = not CinematicMode
--     TriggerEvent('tnj-editorCin', CinematicMode)
-- end)

local debug_button = menu4:AddCheckbox({
    icon = '💻',
    label = 'Debug',
    value = 'n',
    description = 'qb-adminmenu delete lazer [WIP]'
})
debug_button:On('change', function(item, newValue, oldValue)
    running = not running
    debugging = not debugging
end)

local CamFovSlider = menu4:AddRange({ icon = '⏳', label = 'Camera FOV', min = 1, max = 130, value = 50, saveOnUpdate = true })
CamFovSlider:On('select', function(item, value)
    local cam = getCam()
    local FOV = tonumber(value..'.0')
    SetCamFov(cam, FOV)
end)
CamFovSlider:On('change', function(item, newValue, oldValue)
    -- menu.Title = ('MenuV %s'):format(newValue)
end)

local TeleportPlayerButton = menu:AddCheckbox({
    icon = '🐱‍👤',
    label = 'Teleport',
    value = 'n',
    -- description = 'bruh'
})
TeleportPlayerButton:On('change', function(item, newValue, oldValue)
    running = not running
    TeleportingPlayer = not TeleportingPlayer
    DeleteEntity(ClonePedIG)
    ClonePedIG = nil
end)

local PedSettings = menu:AddButton({
    icon = '👻',
    label = 'NPC Options',
    value = menu3,
    -- description = 'bruh'
})

local TaskNpcButton = menu3:AddCheckbox({
    icon = '🔫',
    label = 'Task Ped',
    value = 'n',
    -- description = 'bruh'
})
TaskNpcButton:On('change', function(item, newValue, oldValue)
    running = not running
    TaskingPed = not TaskingPed
end)

local NpcMoveSpeedButton = menu3:AddRange({ icon = '⏳', label = 'Ped Move Speed', min = 1, max = 3, value = 1, saveOnUpdate = true })
NpcMoveSpeedButton:On('select', function(item, value)
    Selected_Ped_Speed = value
end)
NpcMoveSpeedButton:On('change', function(item, newValue, oldValue)
    -- menu.Title = ('MenuV %s'):format(newValue)
end)

local NpcArmorButton = menu3:AddCheckbox({
    icon = '🦺',
    label = 'Add Armor To Ped',
    value = 'n',
    description = 'Add 100 Armor to a ped when you select them'
})
NpcArmorButton:On('change', function(item, newValue, oldValue)
    if Selected_Ped_Armor == 0 then
        Selected_Ped_Armor = 100
    elseif Selected_Ped_Armor == 100 then
    Selected_Ped_Armor = 0
    end
end)

local NpcWeaponButton = menu3:AddSlider({ icon = '❤️', label = 'Ped Weapon', value = 'demo', values = {
    { label = 'Fists', value = 'weapon_unarmed', description = 'Demo Item 1' },
    { label = 'Pistol', value = 'weapon_pistol', description = 'Demo Item 1' },
    { label = 'Carbine Rifle', value = 'weapon_carbinerifle', description = 'Demo Item 2' },
    { label = 'SMG', value = 'weapon_smg', description = 'Demo Item 3' },
    { label = 'Shotgun', value = 'weapon_pumpshotgun', description = 'Demo Item 4' },
    { label = 'Bat', value = 'weapon_bat', description = 'Demo Item 4' },
    { label = 'Combat MG', value = 'weapon_combatmg', description = 'Demo Item 4' },
    { label = 'Minigun', value = 'weapon_minigun', description = 'Demo Item 4' },
    { label = 'Micro SMG', value = 'weapon_microsmg', description = 'Demo Item 4' }
}})
NpcWeaponButton:On('select', function(item, value)
    if Config.Debug then  print(value) end
    Selected_Ped_Weapon = value
end)

local ObjectSettings = menu:AddButton({
    icon = '📦',
    label = 'Object Options',
    value = menu2,
    -- description = 'bruh'
})

local ChangeObjButton = menu2:AddButton({
    icon = '📦',
    label = 'Change Object',
    value = menu2,
    -- description = 'bruh'
})
ChangeObjButton:On('select', function(item, newValue, oldValue)
    local dialog = exports['qb-input']:ShowInput({
        header = "Place a Prop",
        submitText = "Place Prop",
        inputs = {
            {
                text = "Name of Prop",
                name = "prop",
                type = "text",
                isRequired = true
            },
        },
    })

    if dialog ~= nil then
        EntityHash = dialog.prop
    else
        EntityHash = nil
    end
end)

local PlaceObjButton = menu2:AddCheckbox({
    icon = '📦',
    label = 'Start Placing',
    value = 'n',
    -- description = 'bruh'
})
PlaceObjButton:On('change', function(item, newValue, oldValue)
    running = not running
    PlacingProps = not PlacingProps
    DeleteEntity(tempObj)
    SetEntityAsNoLongerNeeded(tempObj)
    tempObj = nil
end)

local DeleteObjsButton = menu2:AddButton({
    icon = '📦',
    label = 'Delete Placed Objects',
    value = 'n',
    -- description = 'bruh'
})
DeleteObjsButton:On('select', function(item, newValue, oldValue)
    for k, v in pairs(SpawnedObjects) do
        SetEntityVisible(v.entity, false, 0)
        DeleteEntity(v.entity)
        SetEntityAsNoLongerNeeded(v.entity)
    end
    SpawnedObjects = {}
end)

local GetPlacedObjects = menu2:AddButton({
    icon = '📦',
    label = 'Get Placed Objects',
    value = 'n',
    -- description = 'bruh'
})
GetPlacedObjects:On('select', function(item, newValue, oldValue)
    menu6:ClearItems()
    MenuV:OpenMenu(menu6)
    -- Wait(1000)
    for k, v in pairs(SpawnedObjects) do
        local menu_button10 = menu6:AddButton({
            label = k..' | Obj:'..v.entity..' ',
            value = v.entity,
            description = 'Hash: '..v.hash,
            select = function(btn)
                local select = btn.Value -- get all the values from v!
                OpenPlacedObjects(select, k) -- only pass what i select nothing else
            end
        })
    end
end)

local PlacePfx = menu2:AddButton({
    icon = '📦',
    label = 'Start PFX Placement [WIP]',
    value = 'n',
    description = 'Dont use yet'
})
PlacePfx:On('select', function(item, newValue, oldValue)
    Pfxing = false
    local dialog = exports['qb-input']:ShowInput({
        header = "Place a Prop",
        submitText = "Place Prop",
        inputs = {
            {
                text = "Dict of Ptfx",
                name = "dict",
                type = "text",
                isRequired = true
            },
            {
                text = "Name of Ptfx",
                name = "ptfx",
                type = "text",
                isRequired = true
            },
        },
    })

    if dialog ~= nil then
        PtfxCore = dialog.dict
        PtfxName = dialog.ptfx
        running = not running
        Pfxing = not Pfxing
    else
        PtfxCore = nil
        PtfxName = nil
    end
end)

local OutlineBool = false
function OpenPlacedObjects(object, key)
    Props:ClearItems()
    menu6:ClearItems()
    MenuV:CloseMenu(menu6)
    MenuV:OpenMenu(Props)
    local elements = {
        [1] = {
            icon = '',
            label = "Delete Entity",
            value = "testbut1",
            description = "1"
        },
        [2] = {
            icon = '',
            label = "HighLight Prop",
            value = "testbut2",
            description = "2"
        },
        [3] = {
            icon = '',
            label = "Move Object",
            value = "testbut3",
            description = "3"
        }
    }
    for k, v in ipairs(elements) do
        local menu_button10 = Props:AddButton({
            icon = v.icon,
            label = ' ' .. v.label,
            value = v.value,
            description = v.description,
            select = function(btn)
                local values = btn.Value
                if values == 'testbut1' then
                    NetworkRequestControlOfEntity(object)
                    Wait(1000)
                    SetEntityVisible(object, false, 0)
                    DeleteEntity(object)
                    DeleteObject(object)
                    SetEntityAsNoLongerNeeded(object)
                    table.remove(SpawnedObjects, key)
                elseif values == "testbut2" then
                    OutlineBool = not OutlineBool
                    SetEntityDrawOutline(object, OutlineBool)
                elseif values == "testbut3" then
                    ObjectHash = GetEntityModel(object)
                    ObjectHeading = GetEntityHeading(object)
                    NetworkRequestControlOfEntity(object)
                    Wait(1000)
                    SetEntityVisible(object, false, 0)
                    DeleteEntity(object)
                    DeleteObject(object)
                    SetEntityAsNoLongerNeeded(object)
                    table.remove(SpawnedObjects, key)
                    running = true
                    MovingObject = true
                end
            end
        })
    end
end

local CamSettings = menu:AddButton({
    icon = '🤺',
    label = 'Ped Options (WIP)',
    value = menu5,
    -- description = 'bruh'
})

local ChangePedButton = menu5:AddButton({
    icon = '📦',
    label = 'Change Ped',
    value = 'n',
    -- description = 'bruh'
})
ChangePedButton:On('select', function(item, newValue, oldValue)
    local dialog = exports['qb-input']:ShowInput({
        header = "Place a Ped",
        submitText = "Place Ped",
        inputs = {
            {
                text = "Name of Ped",
                name = "prop",
                type = "text",
                isRequired = true
            },
        },
    })

    if dialog ~= nil then
        PedHash = GetHashKey(dialog.prop)
    else
        PedHash = nil
    end
end)

local PlacePedButton = menu5:AddCheckbox({
    icon = '🤺',
    label = 'Start Placing',
    value = 'n',
    -- description = 'bruh'
})
PlacePedButton:On('change', function(item, newValue, oldValue)
    running = not running
    PlacingPeds = not PlacingPeds
    DeleteEntity(tempObj)
    SetEntityAsNoLongerNeeded(tempObj)
    tempObj = nil
end)

local DeletePedsButton = menu5:AddButton({
    icon = '📦',
    label = 'Delete Placed Peds',
    value = 'n',
    -- description = 'bruh'
})
DeletePedsButton:On('select', function(item, newValue, oldValue)
    for k, v in pairs(SpawnedPed) do
        SetEntityVisible(v, false)
        local NetID = NetworkGetNetworkIdFromEntity(v)
        if NetworkDoesNetworkIdExist(NetID) then
            SetNetworkIdCanMigrate(NetID, false)
            SetNetworkIdExistsOnAllMachines(NetID, false)
        end
        DeleteEntity(v)
        SetEntityAsMissionEntity(v, false, false)
        SetEntityAsNoLongerNeeded(v)
    end
end)

local LeaveEditorButton = menu:AddButton({
    icon = '🎥',
    label = 'Exit the Editor',
    value = 'n',
    -- description = 'bruh'
})
LeaveEditorButton:On('select', function(item, newValue, oldValue)
    TriggerEvent('aj:togglecam')
end)

local entityEnumerator = {
__gc = function(enum)
    if enum.destructor and enum.handle then
    enum.destructor(enum.handle)
    end
    enum.destructor = nil
    enum.handle = nil
end
}

------------------------------------ Functions

local function DrawEntityBoundingBox(entity)
    local color = {r = 255, g = 50, b = 50, a = 100}
    local color2 = {r = 255, g = 255, b = 255, a = 255}
    local model = GetEntityModel(entity)
    local min,max = GetModelDimensions(model)
    local top_front_right = GetOffsetFromEntityInWorldCoords(entity,max)
    local top_back_right = GetOffsetFromEntityInWorldCoords(entity,vector3(max.x,min.y,max.z))
    local bottom_front_right = GetOffsetFromEntityInWorldCoords(entity,vector3(max.x,max.y,min.z))
    local bottom_back_right = GetOffsetFromEntityInWorldCoords(entity,vector3(max.x,min.y,min.z))
    local top_front_left = GetOffsetFromEntityInWorldCoords(entity,vector3(min.x,max.y,max.z))
    local top_back_left = GetOffsetFromEntityInWorldCoords(entity,vector3(min.x,min.y,max.z))
    local bottom_front_left = GetOffsetFromEntityInWorldCoords(entity,vector3(min.x,max.y,min.z))
    local bottom_back_left = GetOffsetFromEntityInWorldCoords(entity,min)
    -- LINES
    -- RIGHT SIDE
    DrawLine(top_front_right,top_back_right,color2.r,color2.g,color2.b,color2.a)
    DrawLine(top_front_right,bottom_front_right,color2.r,color2.g,color2.b,color2.a)
    DrawLine(bottom_front_right,bottom_back_right,color2.r,color2.g,color2.b,color2.a)
    DrawLine(top_back_right,bottom_back_right,color2.r,color2.g,color2.b,color2.a)
    -- LEFT SIDE
    DrawLine(top_front_left,top_back_left,color2.r,color2.g,color2.b,color2.a)
    DrawLine(top_back_left,bottom_back_left,color2.r,color2.g,color2.b,color2.a)
    DrawLine(top_front_left,bottom_front_left,color2.r,color2.g,color2.b,color2.a)
    DrawLine(bottom_front_left,bottom_back_left,color2.r,color2.g,color2.b,color2.a)
    -- Connection
    DrawLine(top_front_right,top_front_left,color2.r,color2.g,color2.b,color2.a)
    DrawLine(top_back_right,top_back_left,color2.r,color2.g,color2.b,color2.a)
    DrawLine(bottom_front_left,bottom_front_right,color2.r,color2.g,color2.b,color2.a)
    DrawLine(bottom_back_left,bottom_back_right,color2.r,color2.g,color2.b,color2.a)
    -- POLYGONS
    -- FRONT
    DrawPoly(top_front_left,top_front_right,bottom_front_right,color.r,color.g,color.b,color.a)
    DrawPoly(bottom_front_right,bottom_front_left,top_front_left,color.r,color.g,color.b,color.a)
    -- TOP
    DrawPoly(top_front_right,top_front_left,top_back_right,color.r,color.g,color.b,color.a)
    DrawPoly(top_front_left,top_back_left,top_back_right,color.r,color.g,color.b,color.a)
    -- BACK
    DrawPoly(top_back_right,top_back_left,bottom_back_right,color.r,color.g,color.b,color.a)
    DrawPoly(top_back_left,bottom_back_left,bottom_back_right,color.r,color.g,color.b,color.a)
    -- LEFT
    DrawPoly(top_back_left,top_front_left,bottom_front_left,color.r,color.g,color.b,color.a)
    DrawPoly(bottom_front_left,bottom_back_left,top_back_left,color.r,color.g,color.b,color.a)
    -- RIGHT
    DrawPoly(top_front_right,top_back_right,bottom_front_right,color.r,color.g,color.b,color.a)
    DrawPoly(top_back_right,bottom_back_right,bottom_front_right,color.r,color.g,color.b,color.a)
    -- BOTTOM
    DrawPoly(bottom_front_left,bottom_front_right,bottom_back_right,color.r,color.g,color.b,color.a)
    DrawPoly(bottom_back_right,bottom_back_left,bottom_front_left,color.r,color.g,color.b,color.a)
    return true
end

local function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function getCam()
    if not cam or not DoesCamExist(cam) then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        if Config.Debug then  print('Created camera #'..cam) end
    end
    return cam
end

function startCam()
    if not CAM_ACTIVE then
        MenuV:OpenMenu(menu)
        local location = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        local fov = GetGameplayCamFov()
        local cam = getCam()
        RenderScriptCams(true, true, 500, true, false, false)
        SetCamCoord(cam, location)
        SetCamRot(cam, rot, 2)
        SetCamFov(cam, fov)
        CAM_ACTIVE = true
    end
end

function stopCam(teleport, easeAmount)
    MenuV:CloseMenu(menu4)
    MenuV:CloseMenu(menu3)
    MenuV:CloseMenu(menu2)
    MenuV:CloseMenu(menu)
    if CAM_ACTIVE then
        local player = PlayerId()
        if NetworkIsPlayerConcealed(player) then
            NetworkConcealPlayer(player, false, false)
        end
        
        CAM_ACTIVE = false

        if teleport then
            RenderScriptCams(false, false, 0, false, false, false)
        else
            RenderScriptCams(false, true, easeAmount, false, false, false)
            Wait(easeAmount)
        end
        DestroyCam(getCam(), false)
        cam = nil

        ClearFocus()
        NetworkClearVoiceProximityOverride()
    end
    if Config.Debug then print('Cams no longer active') end
    CAM_ACTIVE = false -- Failsafe i guess
end

function getMouseMovement()
    local x = GetDisabledControlNormal(0, 2)
    local y = 0
    local z = GetDisabledControlNormal(0, 1)
    return vector3(-x, y, -z) * 5.0
end

function getRelativeLocation(location, rotation, distance)
    location = location or vector3(0,0,0)
    rotation = rotation or vector3(0,0,0)
    distance = distance or 10.0
    
    local tZ = math.rad(rotation.z)
    local tX = math.rad(rotation.x)
    
    local absX = math.abs(math.cos(tX))

    local rx = location.x + (-math.sin(tZ) * absX) * distance
    local ry = location.y + (math.cos(tZ) * absX) * distance
    local rz = location.z + (math.sin(tX)) * distance

    return vector3(rx,ry,rz)
end

function normalToRotation(normal, refRotation)
    return quat(refRotation, normal)
end

function DisableAllControls()
    for i=0, 31 do
        DisableAllControlActions(i)
    end
    for _,control in ipairs(EnableInCam) do
        EnableControlAction(0, control, true)
    end
end

function getMovementInput(location, rotation, frameTime)
    local multiplier = 1.0
    if IsDisabledControlPressed(0, 21) then
        multiplier = 10.0
    end

    if IsDisabledControlPressed(0, 35) then
        local camRot = vector3(0,0,rotation.z)
        location = getRelativeLocation(location, camRot + vector3(0,0,-90), CAM_SPEED * frameTime * multiplier)
    elseif IsDisabledControlPressed(0, 34) then
        local camRot = vector3(0,0,rotation.z)
        location = getRelativeLocation(location, camRot + vector3(0,0,90), CAM_SPEED * frameTime * multiplier)
    end

    if IsDisabledControlPressed(0, 32) then
        location = getRelativeLocation(location, rotation, CAM_SPEED * frameTime * multiplier)
    elseif IsDisabledControlPressed(0, 33) then
        location = getRelativeLocation(location, rotation, -CAM_SPEED * frameTime * multiplier)
    end

    if IsDisabledControlPressed(0, 22) then
        location = location + vector3(0,0,CAM_SPEED * frameTime * multiplier)
    elseif IsDisabledControlPressed(0, 36) then
        location = location + vector3(0,0,-CAM_SPEED * frameTime * multiplier)
    end

    return location
end

function doCamFrame()
    if CAM_ACTIVE then
        DisableAllControls()
        local frameTime = GetFrameTime()
        local cam = getCam()
        
        local rotation = GetCamRot(cam,2)
        rotation = rotation + getMouseMovement()
        if rotation.x > 85 then
            rotation = vector3(85, rotation.y, rotation.z)
        elseif rotation.x < -85 then
            rotation = vector3(-85, rotation.y, rotation.z)
        end
        SetCamRot(cam, rotation, 2)
        
        local location = GetCamCoord(cam)
        local newLocation = getMovementInput(location, rotation, frameTime)
        SetCamCoord(cam, newLocation)

        if IsDisabledControlJustPressed(0, 38) then
            CAM_SPEED = CAM_SPEED + 5
            CAM_SPEED = math.min(CAM_SPEED, Config.MaxCamSpeed)
            if Config.Debug then  print('Speed: '..CAM_SPEED) end
        elseif IsDisabledControlJustPressed(0, 44) then
            CAM_SPEED = CAM_SPEED - 5
            CAM_SPEED = math.max(CAM_SPEED, Config.MinCamSpeed)
            if Config.Debug then  print('Speed: '..CAM_SPEED) end
        elseif IsDisabledControlJustPressed(0, 199) then
            MenuV:OpenMenu(menu)
        end

        -- TODO Find better way to display this
        Draw2DText('Camera Speed: ~g~'..CAM_SPEED..'~w~', 4, {255, 255, 255}, 0.4, 0.49, 0.05)

        if running then
            local targetLocation = getRelativeLocation(location, rotation, 100)
            -- TODO: Start using flags from StartShapeTestLosProbe to make it prefom better
            local ray = StartExpensiveSynchronousShapeTestLosProbe(newLocation.x, newLocation.y, newLocation.z, targetLocation.x, targetLocation.y, targetLocation.z, -1, PlayerPedId(), 0)
            local someInt,hit,hitCoords,normal,entity = GetShapeTestResult(ray)
            ------ Debug Shit
            if SelectedPed ~= 'None' and Config.Debug then
                local pedcoords = GetEntityCoords(SelectedPed)
                DrawMarker(
                        2, -- Type
                        pedcoords.x, pedcoords.y, pedcoords.z + 1, -- Pos
                        0.0, 0.0, 0.0, -- Direction
                        0.0, 0.0, 0.0, -- Rot
                        0.7, 0.7, 0.7, -- Scale
                        255, 50, 50, 128, -- Color
                        true, -- bobs
                        true, -- face camera
                        1, -- p19
                        false, -- rotates
                        0, 0, -- texture
                        false -- projects on entities
                    )
                DrawLine(GetEntityCoords(SelectedPed), hitCoords, 255, 50, 50, 255)
                if MoveCoords and MoveCoords ~= NoLocation then
                    DrawLine(GetEntityCoords(SelectedPed), MoveCoords, 112, 249, 180, 255)
                end
                if TargetPed and not IsPedDeadOrDying(TargetPed) then
                    DrawLine(GetEntityCoords(SelectedPed), GetEntityCoords(TargetPed), 112, 249, 180, 255)
                end
            end
            ------ Finding Object / Entity Owners shit
            if hit and debugging then
                DrawMarker(
                    28, -- Type
                    hitCoords,
                    0.0, 0.0, 0.0, -- Direction
                    0.0,
                    0.0,
                    0.0,
                    0.1, 0.1, 0.1,
                    255, 50, 50, 128,
                    false, -- bobs
                    false, -- face camera
                    1, -- Cargo Cult (Rotation order?)
                    false, -- rotates
                    0, 0, -- texture
                    false -- projects on entities
                )
                for k, v in pairs(GetGamePool('CObject')) do
                    DrawEntityBoundingBox(v)
                end
                if (IsEntityAPed(entity) or IsEntityAVehicle(entity) or IsEntityAnObject(entity)) then
                    local coords = GetEntityCoords(entity)
                    DrawText3D(coords.x, coords.y, coords.z, 'Entity: '..entity)
                    DrawText3D(coords.x, coords.y, coords.z + 0.5, 'Hash: '..GetHashKey(entity))
                    -- DrawText3D(coords.x, coords.y, coords.z + 1, 'Test')
                    -- DrawText3D(GetEntityCoords(PlayerPedId(), 'Test')
                    -- DrawEntityBoundingBox(entity)
                    -- Draw2DText('Entity: ~b~'..entity..'~w~ Owner: ~b~'..GetPlayerServerId(NetworkGetEntityOwner(entity))..' ('..GetPlayerName(NetworkGetEntityOwner(entity))..')', 4, {255, 255, 255}, 0.4, 0.55, 0.888)
                    -- Draw2DText('Coords: ~b~'..GetEntityCoords(entity)..'~w~', 4, {255, 255, 255}, 0.4, 0.55, 0.888 + 0.025)
                    -- Draw2DText('Press ~g~ Left Click ~w~ to PLACEHOLDER Entity', 4, {255, 255, 255}, 0.4, 0.55, 0.888 + 0.050)
                    if IsDisabledControlJustPressed(0, 24) then
                        if Config.Debug then  print('Debug Clicked') end
                        SetEntityAsMissionEntity(entity, true, true)
                        NetworkRequestControlOfNetworkId(ObjToNet(entity))
                        DeleteEntity(entity)
                        SetEntityAsNoLongerNeeded(entity)
                    end
                end
            ------ Tasking Ped to Move / Drive / Shoot
            elseif hit and TaskingPed then
                DrawMarker(
                    28, -- Type
                    hitCoords,
                    0.0, 0.0, 0.0, -- Direction
                    0.0,
                    0.0,
                    0.0,
                    0.1, 0.1, 0.1,
                    255, 50, 50, 128,
                    false, -- bobs
                    false, -- face camera
                    1, -- Cargo Cult (Rotation order?)
                    false, -- rotates
                    0, 0, -- texture
                    false -- projects on entities
                )
                if TaskingPed and (IsEntityAPed(entity) or IsEntityAVehicle(entity)) and SelectedPed == 'None' then
                    DrawEntityBoundingBox(entity)
                    if IsDisabledControlJustPressed(0, 140) then -- R
                        NetworkRequestControlOfEntity(entity)
                        SelectedPed = entity
                        ClearPedTasks(SelectedPed)
                        RemoveAllPedWeapons(SelectedPed, true)
                        if Config.Debug then print('Armor:', Selected_Ped_Armor) end
                        SetPedArmour(SelectedPed, Selected_Ped_Armor)
                        TaskSetBlockingOfNonTemporaryEvents(SelectedPed, true)
                        SetEntityAsMissionEntity(SelectedPed, true, true)
                        GiveWeaponToPed(SelectedPed, GetHashKey(Selected_Ped_Weapon), 100000, false, false)
                        SetCurrentPedWeapon(SelectedPed, GetHashKey(Selected_Ped_Weapon), false)
                        
                        SetPedCombatMovement(SelectedPed, 1)
                        SetPedAccuracy(SelectedPed, 100)
                        SetPedAlertness(SelectedPed, 3)

                        SetPedHighlyPerceptive(SelectedPed, true)
                        SetPedCombatAttributes(SelectedPed, 46, true)
                        SetPedCombatAttributes(SelectedPed, 5, true)
                        SetPedCombatAttributes(SelectedPed, 26, true)
                        SetPedCombatAttributes(SelectedPed, 1424, true)
                        SetCanAttackFriendly(SelectedPed, true, true)
                        SetPedConfigFlag(SelectedPed, 140, false)
                        -- local driver = GetPedInVehicleSeat(SelectedPed, -1)
                    end
                end
                if IsDisabledControlJustPressed(0, 25) and TaskingPed and SelectedPed ~= 'None' and hitCoords ~= NoLocation then
                    MoveCoords = nil
                    TargetPed = nil
                    if entity and (IsEntityAPed(entity) or IsEntityAVehicle(entity)) then
                        if GetPedInVehicleSeat(entity, -1) ~= 0 then
                            TargetPed = GetPedInVehicleSeat(entity, -1)
                        else
                            TargetPed = entity
                        end
                        ClearPedTasks(SelectedPed)
                        TaskCombatPed(SelectedPed, TargetPed)
                    else
                        TaskShootAtCoord(SelectedPed, hitCoords[1], hitCoords[2], hitCoords[3], 5000, `FIRING_PATTERN_FULL_AUTO`)
                        MoveCoords = hitCoords
                    end
                elseif IsDisabledControlJustPressed(0, 24) and TaskingPed and SelectedPed ~= 'None' and hitCoords ~= NoLocation then
                    MoveCoords = nil
                    MoveCoords = hitCoords
                    local driver = GetPedInVehicleSeat(SelectedPed, -1)
                    if driver == 0 then
                        TaskGoToCoordAnyMeans(SelectedPed, hitCoords[1], hitCoords[2], hitCoords[3], tonumber(Selected_Ped_Speed..'.0'))
                    else
                        TaskVehicleDriveToCoord(driver, GetVehiclePedIsIn(driver), hitCoords[1], hitCoords[2], hitCoords[3], GetVehicleEstimatedMaxSpeed(GetVehiclePedIsIn(driver)), false, GetEntityModel(GetVehiclePedIsIn(driver)), 17301504, 6.0)
                    end
                elseif IsDisabledControlJustPressed(0, 145) and TaskingPed and SelectedPed ~= 'None' then -- F
                    TaskStayInCover(SelectedPed)
                elseif IsDisabledControlJustPressed(0, 202) then
                    if SelectedPed ~= 'None' then
                        ClearPedTasks(SelectedPed)
                        TaskSetBlockingOfNonTemporaryEvents(SelectedPed, false)
                        SetEntityAsMissionEntity(SelectedPed, false, false)
                        SetEntityAsNoLongerNeeded(SelectedPed)
                    end
                    MoveCoords = nil
                    TargetPed = nil
                    SelectedPed = 'None'
                    entity = nil
                end
                local BasePos = 0.50 -- Prob a bad way of doing this but its easier to understand for me lol
                Draw2DText('DEBUG: ~r~'..tostring(Config.Debug)..'~w~', 4, {255, 255, 255}, 0.4, 0.1, BasePos)
                BasePos = BasePos + 0.025
                Draw2DText('Ped: ~b~'..SelectedPed..'~w~ Health: ~r~'..GetEntityHealth(SelectedPed)..'~w~ Armor: ~b~'..GetPedArmour(SelectedPed), 4, {255, 255, 255}, 0.4, 0.1, BasePos)
                BasePos = BasePos + 0.025
                Draw2DText('Press ~g~ R ~w~ to select Entity', 4, {255, 255, 255}, 0.4, 0.1, BasePos)
                BasePos = BasePos + 0.025
                Draw2DText('Press ~g~ F ~w~ Force Ped to Cover', 4, {255, 255, 255}, 0.4, 0.1, BasePos)
                BasePos = BasePos + 0.025
                Draw2DText('Press ~g~ Left Click ~w~ to Move Ped', 4, {255, 255, 255}, 0.4, 0.1, BasePos)
                BasePos = BasePos + 0.025
                Draw2DText('Press ~g~ Right Click ~w~ to Make Ped Shoot', 4, {255, 255, 255}, 0.4, 0.1, BasePos)
                BasePos = BasePos + 0.025
                Draw2DText('Press ~g~ ESC ~w~ to deselect Ped', 4, {255, 255, 255}, 0.4, 0.1, BasePos)
            ------ Teleporting Player
            elseif hit and TeleportingPlayer then
                if not DoesEntityExist(ClonePedIG) then
                    ClonePedIG = ClonePed(PlayerPedId(), false, false, false)
                    SetEntityAlpha(ClonePedIG, 175)
                    SetEntityCollision(ClonePedIG, false, false)
                    SetEntityHeading(ClonePedIG, GetEntityHeading(PlayerPedId()))
                    local bool, weapon = GetCurrentPedWeapon(PlayerPedId())
                    GiveWeaponToPed(ClonePedIG, weapon, 1000, false, true)
                    SetPedAmmo(ClonePedIG, weapon, 1000)
                    SetCurrentPedWeapon(ClonePedIG, weapon, true)
                else
                    SetEntityCoords(ClonePedIG, hitCoords[1], hitCoords[2], hitCoords[3])
                end
                if IsDisabledControlJustPressed(0, 24) then
                    if hitCoords ~= NoLocation then
                        RequestCollisionAtCoord(hitCoords[1], hitCoords[2], hitCoords[3])
                        SetEntityCoords(PlayerPedId(), hitCoords[1], hitCoords[2], hitCoords[3])
                    end
                end
            elseif hit and Pfxing then
                DrawMarker(
                    28, -- Type
                    hitCoords,
                    0.0, 0.0, 0.0, -- Direction
                    0.0,
                    0.0,
                    0.0,
                    0.1, 0.1, 0.1,
                    255, 50, 50, 128,
                    false, -- bobs
                    false, -- face camera
                    1, -- Cargo Cult (Rotation order?)
                    false, -- rotates
                    0, 0, -- texture
                    false -- projects on entities
                )
                if IsDisabledControlJustPressed(0, 24) then
                    if (hitCoords ~= NoLocation) and PtfxCore and PtfxName then
                        if Config.Debug then print('Spawning PFX', hitCoords) end
                        TriggerServerEvent('tnj-editor:server:syncPfx', hitCoords, PtfxCore, PtfxName)
                    end
                end
            ------ Adding Synced Props client sided
            elseif hit and PlacingProps then
                if not DoesEntityExist(tempObj) then
                    RequestModel(GetHashKey(EntityHash))
                    local timer = GetGameTimer()
                    while not HasModelLoaded(GetHashKey(EntityHash)) and EntityHash ~= nil do
                        if GetGameTimer()-timer > 500 then
                            if Config.Debug then print('Could not load '..EntityHash..' in time, cancelling.') end
                            EntityHash = nil
                            return
                        end
                        Wait(1)
                    end
                    tempObj = CreateObject(GetHashKey(EntityHash), 0,0,0, false, false, false)
                    SetEntityAlpha(tempObj, 175)
                    SetEntityCollision(tempObj, false, false)
                    heading = GetEntityHeading(tempObj)
                else
                    Draw2DText('Hash: ~b~'..EntityHash..'~w~', 4, {255, 255, 255}, 0.4, 0.55, 0.888)
                    Draw2DText('Heading: ~b~'..heading..'~w~', 4, {255, 255, 255}, 0.4, 0.55, 0.888 + 0.025)
                    Draw2DText('Press ~g~ Left Click ~w~ to Place Object', 4, {255, 255, 255}, 0.4, 0.55, 0.888 + 0.050)
                    SetEntityCoords(tempObj, hitCoords[1], hitCoords[2], hitCoords[3])
                    if IsDisabledControlJustPressed(0, 24) then
                        PlaceObject(EntityHash, hitCoords, heading)
                    end
                    if IsDisabledControlJustPressed(0, 16) then -- Heading
                        heading = heading + 2.5
                        SetEntityHeading(tempObj, heading)
                    end
                    if IsDisabledControlJustPressed(0, 17) then  -- Heading
                        heading = heading - 2.5
                        SetEntityHeading(tempObj, heading)
                    end
                end
            elseif hit and MovingObject then
                if not DoesEntityExist(tempObj2) then
                    RequestModel(ObjectHash)
                    local timer = GetGameTimer()
                    while not HasModelLoaded(ObjectHash) and ObjectHash ~= nil do
                        if GetGameTimer()-timer > 500 then
                            if Config.Debug then print('Could not load '..ObjectHash..' in time, cancelling.') end
                            ObjectHash = nil
                            running = false
                            return
                        end
                        Wait(1)
                    end
                    tempObj2 = CreateObject(ObjectHash, 0,0,0, false, false, false)
                    SetEntityHeading(tempObj2, ObjectHeading)
                    SetEntityAlpha(tempObj2, 175)
                    SetEntityCollision(tempObj2, false, false)
                    heading = GetEntityHeading(tempObj2)
                else
                    SetEntityCoords(tempObj2, hitCoords[1], hitCoords[2], hitCoords[3])
                    if IsDisabledControlJustPressed(0, 24) then
                        PlaceObject(ObjectHash, hitCoords, heading)
                        DeleteEntity(tempObj2)
                        DeleteObject(tempObj2)
                        MovingObject = false
                        running = false
                    end
                    if IsDisabledControlJustPressed(0, 16) then
                        heading = heading + 2.5
                        SetEntityHeading(tempObj2, heading)
                        if Config.Debug then print('Heading: ',heading) end
                    end
                    
                    if IsDisabledControlJustPressed(0, 17) then
                        heading = heading - 2.5
                        SetEntityHeading(tempObj2, heading)
                        if Config.Debug then print('Heading: ',heading) end
                    end
                end
            ------ Adding Synced Ped client sided
            elseif hit and PlacingPeds then
                if not DoesEntityExist(tempObj) then
                    RequestModel(PedHash)
                    local timer = GetGameTimer()
                    while not HasModelLoaded(PedHash) and PedHash ~= nil do
                        if GetGameTimer()-timer > 500 then
                            if Config.Debug then print('Could not load '..PedHash..' in time, cancelling.') end
                            PedHash = nil
                            return
                        end
                        Wait(1)
                    end
                    tempObj = CreatePed(34, PedHash, 0.0, 0.0, 0.0, 0.0, false, false)
                    SetEntityAlpha(tempObj, 175, false)
                    SetEntityCollision(tempObj, false, false)
                    heading = GetEntityHeading(tempObj)
                else
                    SetEntityCoords(tempObj, hitCoords[1], hitCoords[2], hitCoords[3])
                    if IsDisabledControlJustPressed(0, 24) then
                        PlacePed(PedHash, hitCoords, heading)
                    end
                    if IsDisabledControlJustPressed(0, 16) then
                        heading = heading + 10
                        SetEntityHeading(tempObj, heading)
                        if Config.Debug then print('Heading: ',heading) end
                    end
                    
                    if IsDisabledControlJustPressed(0, 17) then
                        heading = heading - 10
                        SetEntityHeading(tempObj, heading)
                        if Config.Debug then print('Heading: ',heading) end
                    end
                end
            end
        end

        if CAM_ACTIVE then -- Failsafe check to make sure cam wasnt disabled
            SetFocusPosAndVel(location, NoLocation) -- Sets the games LOD to the cam pos
            -- NetworkApplyVoiceProximityOverride(location) -- Not too sure if this works tbh
        end

    end
end

function PlaceObject(object, coords, heading)
    if Config.Debug then print(coords) end
    if Config.Debug then print(heading) end
    local PlacedObject = CreateObject(object, coords.x, coords.y, coords.z, true, true)
    NetworkRegisterEntityAsNetworked(PlacedObject)
    if Config.Debug then print('Object: ',PlacedObject) end
    SetEntityAlpha(PlacedObject, 255)
    SetEntityHeading(PlacedObject, heading)
    FreezeEntityPosition(PlacedObject, true)
    SetEntityAsMissionEntity(PlacedObject, true, true)
    SetEntityVisible(PlacedObject, true, 0)
    local NetID = NetworkGetNetworkIdFromEntity(PlacedObject)
    if Config.Debug then print('NetID: ',NetID) end
    if NetworkDoesNetworkIdExist(NetID) then
        if Config.Debug then print('NetID Exists') end
        SetNetworkIdCanMigrate(NetID, false)
        SetNetworkIdExistsOnAllMachines(NetID, true)
    end
    SpawnedObjects[#SpawnedObjects+1] = {
        entity = PlacedObject,
        hash = object,
    }
end

function PlacePed(ped, coords, heading)
    if Config.Debug then print(coords) end
        if Config.Debug then print(heading) end
    local PlacedPed = CreatePed(34, ped, coords.x, coords.y, coords.z, heading, true, true)
    NetworkRegisterEntityAsNetworked(PlacedPed)
    if Config.Debug then print('Ped: ',PlacedPed) end
    SetEntityAlpha(PlacedPed, 255)
    SetEntityMaxHealth(PlacedPed, 500)
    SetEntityHealth(PlacedPed, 500)
    FreezeEntityPosition(PlacedPed, false)
    local NetID = NetworkGetNetworkIdFromEntity(PlacedPed)
    if Config.Debug then print('NetID: ',NetID) end
    if NetworkDoesNetworkIdExist(NetID) then
        if Config.Debug then print('NetID Exists') end
        SetNetworkIdCanMigrate(NetID, true)
        SetNetworkIdExistsOnAllMachines(NetID, true)
    end
    SpawnedPed[#SpawnedPed+1] = PlacedPed
end

-- WIP Not fully ready
RegisterNetEvent("tnj-editor:client:syncPfx", function(hitCoords, asset, name) -- weap_smoke_grenade | scr_powerplay_beast_appear |
    local ptfx

    RequestNamedPtfxAsset(asset)
    while not HasNamedPtfxAssetLoaded(asset) do
        Wait(1)
    end
    ptfx = vector3(hitCoords.x, hitCoords.y, hitCoords.z)
    SetPtfxAssetNextCall(asset)
    local effect = StartParticleFxLoopedAtCoord(name, ptfx.x, ptfx.y, ptfx.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    Wait(5000)
    StopParticleFxLooped(effect, 0)
end)

------------------------------------ Events

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        MenuV:CloseMenu(menu5)
        MenuV:CloseMenu(menu4)
        MenuV:CloseMenu(menu3)
        MenuV:CloseMenu(menu2)
        MenuV:CloseMenu(menu)
        stopCam(true)
        DeleteEntity(tempObj)
        SetEntityAsNoLongerNeeded(tempObj)
        DeleteEntity(ClonePedIG)
        SetEntityAsNoLongerNeeded(ClonePedIG)
        for k, v in pairs(SpawnedObjects) do
            DeleteEntity(v.entity)
            SetEntityAsNoLongerNeeded(v.entity)
        end
        for k, v in pairs(SpawnedPed) do
            SetEntityVisible(v, false)
            local NetID = NetworkGetNetworkIdFromEntity(v)
            if NetworkDoesNetworkIdExist(NetID) then
                SetNetworkIdCanMigrate(NetID, false)
                SetNetworkIdExistsOnAllMachines(NetID, false)
            end
            DeleteEntity(v)
            SetEntityAsMissionEntity(v, false, false)
            SetEntityAsNoLongerNeeded(v)
        end
    end
end)

local ready = false
RegisterNetEvent('aj:togglecam', function()
    ready = not ready

    CreateThread(function()
        while ready do
            Wait(5)
            if NetworkIsSessionStarted() and not IsPauseMenuActive() then
                doCamFrame()
            end
        end
    end)

    if CAM_ACTIVE then
        stopCam(false, 2000)
    else
        startCam()
    end
end)
