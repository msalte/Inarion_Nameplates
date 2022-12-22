function GetDisplayName(groupName)
    if state.colorGroupNameMap[groupName] then
        return state.colorGroupNameMap[groupName]
    end

    return groupName
end

function GetGroupName(displayName)
    for k, v in pairs(state.colorGroupNameMap) do
        if v == displayName then
            return k
        end
    end

    return displayName
end

function UpdateNamePlates()
    for i, frame in ipairs(C_NamePlate.GetNamePlates()) do
        NamePlateDriverFrame:ApplyFrameOptions(frame, frame.namePlateUnitToken)
        CompactUnitFrame_UpdateAll(frame.UnitFrame)
    end
end
