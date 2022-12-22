local NAME = ...

local ACR = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local db

local state

local f = CreateFrame("Frame")

local function UpdateNamePlates()
    for i, frame in ipairs(C_NamePlate.GetNamePlates()) do
        NamePlateDriverFrame:ApplyFrameOptions(frame, frame.namePlateUnitToken)
        CompactUnitFrame_UpdateAll(frame.UnitFrame)
    end
end

local function HandleAddUnitInputSaved(info, val)
    local groupName = info[1]

    for _, v in pairs(state.colorGroups[groupName].units) do
        if v == val then
            return
        end
    end

    table.insert(state.colorGroups[groupName].units, val)
    UpdateNamePlates()
end

local function HandleRemoveUnitNameClicked(info, i)
    local groupName = info[1]

    table.remove(state.colorGroups[groupName].units, i)

    UpdateNamePlates()
end

local function HandleAddCurrentTargetButtonClicked(info)
    local groupName = info[1]
    local targetName = GetUnitName("playertarget")

    for _, v in pairs(state.colorGroups[groupName].units) do
        if v == targetName then
            return
        end
    end

    table.insert(state.colorGroups[groupName].units, targetName)
    UpdateNamePlates()
end

local function HandleDeleteColorGroupButtonClicked(info)
    local groupName = info[1]

    state.colorGroups[groupName] = nil

    UpdateNamePlates()
end

local function HandleAddColorGroupButtonClicked()
    local groupName = string.format("Group %d", state.groupCount)

    state.groupCount = state.groupCount + 1

    state.colorGroups[groupName] = {
        groupName = groupName,
        color = {r = 1, g = 1, b = 1},
        units = {}
    }

    UpdateNamePlates()
end

local function HandleColorSelectorChanged(info, r, g, b, a)
    local groupName = info[1]
    state.colorGroups[groupName].color = {r = r, g = g, b = b, a = a}

    UpdateNamePlates()
end

local function HandleGetColorForSelector(info)
    local groupName = info[1]

    local c = state.colorGroups[groupName].color

    if c then
        return c.r, c.g, c.b, c.a
    end

    return 1, 1, 1, 1
end

local function GetConfig()
    local opts = {
        type = "group",
        name = format("%s |cffADFF2F%s|r", NAME, GetAddOnMetadata(NAME, "Version")),
        inline = false,
        args = {
            addbutton = {
                type = "execute",
                name = "Add Color Group",
                func = HandleAddColorGroupButtonClicked
            }
        }
    }

    for i, colorGroup in pairs(state.colorGroups) do
        opts.args[colorGroup.groupName] = {
            type = "group",
            name = colorGroup.groupName,
            args = {
                h1 = {
                    order = 10,
                    type = "header",
                    name = "Color"
                },
                colorPicker = {
                    order = 20,
                    type = "color",
                    name = "Color",
                    hasAlpha = true,
                    set = HandleColorSelectorChanged,
                    get = HandleGetColorForSelector
                },
                h2 = {
                    order = 30,
                    type = "header",
                    name = "Unit management"
                },
                unitInput = {
                    order = 40,
                    type = "input",
                    name = "Unit Name",
                    width = "full",
                    desc = "Enter unit name here to add it to the unit list",
                    set = HandleAddUnitInputSaved
                },
                textOr = {type = "description", name = "or", order = 50},
                addButton = {
                    order = 60,
                    type = "execute",
                    name = "Add Current Target",
                    func = HandleAddCurrentTargetButtonClicked
                },
                units = {
                    order = 70,
                    type = "multiselect",
                    name = "Units",
                    desc = "Click to remove",
                    set = HandleRemoveUnitNameClicked,
                    values = colorGroup.units
                },
                h3 = {
                    type = "header",
                    name = "Group options",
                    order = 80
                },
                deletebutton = {
                    order = 99,
                    type = "execute",
                    name = "Delete Color Group",
                    func = HandleDeleteColorGroupButtonClicked
                }
            }
        }
    end

    return opts
end

function f:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        if ... == NAME then
            if InarionNameplatesState then
                state = InarionNameplatesState
            else
                state = {
                    version = 1,
                    groupCount = 1,
                    colorGroups = {}
                }

                InarionNameplatesState = state
            end

            ACR:RegisterOptionsTable(NAME, GetConfig)
            ACD:AddToBlizOptions(NAME, NAME)
            ACD:SetDefaultSize(NAME, 400, 480)

            self:SetupNameplates()
            self:UnregisterEvent(event)
        end
    end
end

function f:SetupNameplates()
    local playerName = UnitName("player")

    -- names
    hooksecurefunc(
        "CompactUnitFrame_UpdateName",
        function(frame)
            if not strfind(frame.unit, "nameplate") or UnitName(frame.unit) == playerName then
                return
            end

            local name = GetUnitName(frame.unit)
            local nameParts = {strsplit(" ", name)}

            frame.name:SetText(nameParts[#nameParts])

            for _, colorGroup in pairs(state.colorGroups) do
                for _, unitName in pairs(colorGroup.units) do
                    if name == unitName then
                        local c = colorGroup.color
                        frame.name:SetVertexColor(c.r, c.g, c.b)
                    end
                end
            end
        end
    )

    -- nameplates
    hooksecurefunc(
        "CompactUnitFrame_UpdateHealthColor",
        function(frame)
            if not strfind(frame.unit, "nameplate") or UnitName(frame.unit) == playerName then
                return
            end

            local name = GetUnitName(frame.unit)
            local isFriendly = not UnitIsEnemy("player", frame.unit) or not ShouldShowName(frame)

            if isFriendly then
                color = {r = 1, g = 1, b = 0}
            else
                color = {r = 1, g = 0, b = 0}
            end

            for _, colorGroup in pairs(state.colorGroups) do
                for _, unitName in pairs(colorGroup.units) do
                    if name == unitName then
                        color = colorGroup.color
                    end
                end
            end

            frame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
        end
    )
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)
