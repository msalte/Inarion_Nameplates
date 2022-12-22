local NAME = ...

local function HandleAddUnitInputSaved(info, val)
    local displayName = info[1]
    local groupName = GetGroupName(displayName)

    for _, v in pairs(state.colorGroups[groupName].units) do
        if v == val then
            return
        end
    end

    table.insert(state.colorGroups[groupName].units, val)
    UpdateNamePlates()
end

local function HandleRemoveUnitNameClicked(info, i)
    local displayName = info[1]
    local groupName = GetGroupName(displayName)

    table.remove(state.colorGroups[groupName].units, i)

    UpdateNamePlates()
end

local function HandleAddCurrentTargetButtonClicked(info)
    local displayName = info[1]
    local groupName = GetGroupName(displayName)
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
    local displayName = info[1]
    local groupName = GetGroupName(displayName)

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
    local displayName = info[1]
    local groupName = GetGroupName(displayName)

    state.colorGroups[groupName].color = {r = r, g = g, b = b, a = a}

    UpdateNamePlates()
end

local function HandleGetColorForSelector(info)
    local displayName = info[1]
    local groupName = GetGroupName(displayName)

    local c = state.colorGroups[groupName].color

    if c then
        return c.r, c.g, c.b, c.a
    end

    return 1, 1, 1, 1
end

local function HandleToggleSimpleNames()
    if state.isSimpleNames then
        state.isSimpleNames = false
    else
        state.isSimpleNames = true
    end

    UpdateNamePlates()
end

local function HandleGroupNameInputSaved(info, val)
    local displayName = info[1]
    local groupName = GetGroupName(displayName)

    state.colorGroupNameMap[groupName] = val
end

local function HandleGetGroupName(info)
    local groupName = info[1]
    return GetDisplayName(groupName)
end

function GetConfig()
    local config = {
        type = "group",
        name = format("%s |cffADFF2F%s|r", NAME, GetAddOnMetadata(NAME, "Version")),
        inline = false,
        args = {
            h1 = {
                order = 1,
                type = "header",
                name = "General"
            },
            toggleSimpleNames = {
                order = 2,
                type = "toggle",
                name = "Short Names",
                desc = "Toggle to render short nameplate texts. Will show only last part of NPC names and hide server names from players.",
                set = HandleToggleSimpleNames,
                get = function()
                    return state.isSimpleNames
                end
            },
            h2 = {
                order = 10,
                type = "header",
                name = "Color Groups"
            },
            addbutton = {
                order = 11,
                type = "execute",
                name = "Add Color Group",
                func = HandleAddColorGroupButtonClicked
            }
        }
    }

    for i, colorGroup in pairs(state.colorGroups) do
        config.args[colorGroup.groupName] = {
            type = "group",
            name = GetDisplayName(colorGroup.groupName),
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
                groupNameInput = {
                    order = 98,
                    width = "full",
                    type = "input",
                    name = "Group Name",
                    get = HandleGetGroupName,
                    set = HandleGroupNameInputSaved
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

    return config
end
