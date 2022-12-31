local NAME = ...

local ACR = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local f = CreateFrame("Frame")

local defaults = {
    version = 3,
    groupCount = 1,
    isSimpleNames = false,
    colorGroupNameMap = {}, -- map of [groupName, displayName]
    colorGroups = {}
}

function f:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        if ... == NAME then
            if InarionNameplatesState and InarionNameplatesState.version == defaults.version then
                state = InarionNameplatesState
            else
                state = CopyTable(defaults)
                InarionNameplatesState = state
            end

            ACR:RegisterOptionsTable(NAME, GetConfig)
            ACD:AddToBlizOptions(NAME, NAME)
            ACD:SetDefaultSize(NAME, 700, 600)

            self:SetupNameplates()
            self:UnregisterEvent(event)
        end
    end
end

function f:SetupNameplates()
    local playerName = UnitName("player")

    hooksecurefunc(
        "CompactUnitFrame_UpdateName",
        function(frame)
            if not strfind(frame.unit, "nameplate") or UnitName(frame.unit) == playerName then
                return
            end

            local name = GetUnitName(frame.unit)

            if state.isSimpleNames then
                local nameParts = {strsplit(" ", name)}
                local simpleName

                if UnitIsPlayer(frame.unit) then
                    -- for players, simple name removes server name suffix
                    simpleName = nameParts[1]
                else
                    -- for npcs, simple name removes everything except last part
                    simpleName = nameParts[#nameParts]
                end

                frame.name:SetText(simpleName)
            end

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

    hooksecurefunc(
        "CompactUnitFrame_UpdateHealthColor",
        function(frame)
            if not strfind(frame.unit, "nameplate") or UnitIsPlayer(frame.unit) then
                -- don't change health color for players (use default class colors)
                return
            end

            local name = GetUnitName(frame.unit)
            local react = UnitReaction(frame.unit, "player") or 4

            if UnitIsTapDenied(frame.unit) then
                color = {r = 1, g = 1, b = 1}
            elseif react >= 4 then
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

_G["SLASH_INARIONNAMEPLATES1"] = "/inp"

function SlashCmdList.INARIONNAMEPLATES()
    if not ACD.OpenFrames.NAME then
        ACD:Open(NAME)
    end
end
