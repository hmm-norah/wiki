addon.name      = 'Wiki';
addon.author    = 'Norah';
addon.version   = '1.0';
addon.desc      = 'Open current item or target on the HorizonXI Wiki';
addon.link      = ''; 

require('common');

local url = "https://horizonffxi.wiki/w/index.php?search="
local ptr = 0


ashita.events.register('command', 'command_callback1', function (e)

    local args = e.command:args();

    if (#args == 0 or args[1] ~= '/wiki') then
        return;
    end

    e.blocked = true;


    if (#args == 2 and args[2]:any('target')) then
        local entMgr = AshitaCore:GetMemoryManager():GetEntity();
        local targetMgr = AshitaCore:GetMemoryManager():GetTarget();
        local index = targetMgr:GetTargetIndex(targetMgr:GetIsSubTargetActive());
        local name = entMgr:GetName(index);
        ashita.misc.open_url(url..name)
        return;
    end

    if (#args == 2 and args[2]:any('item')) then

        if(ptr == 0) then
            ptr = ashita.memory.find('ffximain.dll', 0, '8b0d????????c681??????????5f', 2, 0)

            ptr = ashita.memory.read_uint32(ptr);
            -- offset
            ptr = ashita.memory.read_uint32(ptr) + 36

        end

        local itemID = ashita.memory.read_uint16(ptr) or 0
        -- print("Item ID: " .. ptr)

        -- local test = ashita.memory.get_base('ffximain.dll') + 5716072
        -- print ("precalc address of pointer: " .. string.format("%X", test))
        -- local pointer = ashita.memory.read_uint32(test) + 36
        -- local itemID = ashita.memory.read_uint16(pointer);
        -- print("Pointer:          " .. string.format("%X", pointer))
        -- print("Item ID: " .. itemID)
   
        -- TODO: Real exception handling, I don't think this covers everything
        if itemID == 0 then
            print("Something went wrong, itemID is 0")
            return
        end

        local itemName = AshitaCore:GetResourceManager():GetItemById(tonumber(itemID)).LogNameSingular[1]
        -- print("Item Name: " .. itemName)

        -- This messes up on some items and I need to track down what it was, I Forgot
        ashita.misc.open_url(url..itemName:gsub("%s+", "_"))
        return
    end

    if (#args > 1 and args[1] == '/wiki') then
        local search_term = args[2]

        for i = 3, #args do
            search_term = search_term + "+" + args[i]
        end

        ashita.misc.open_url(url..search_term)
        return;
    end

end);