addon.name = 'ninhud'
addon.author = 'Bee'
addon.version = '1.0.0.2'
addon.description = 'Heads up display for nuking NIN.'

local fonts = require('fonts');
local settings = require('settings');

local ninhud = T{};
local default_settings = T{
    font = T{
        visible = true,
        font_family = 'Consolas',
        font_height = 9,
        position_x = 400,
        position_y = 400,
        opacity = .75,
        background = {
            visible = true,
        }
    },
    look_and_feel = T{
        spell_sequence = {'Hyoton', 'Huton', 'Suiton', 'Doton', 'Raiton', 'Katon', 
            '<linebreak>', 'Hojo', 'Kurayami', 
            '<linebreak>', 'Utsusemi'},
        name_buffer_size = 8,
        tool_warning_threshold = 20,
        toolbag_warning_threshold = 3,
        yonin_warning = true,
        tool_name_hint = false,
        element_instead_of_spell = true,
    }
}

local ninhud = T{
    settings = settings.load(default_settings)
}

local tool_map = {
    Hyoton={id=1164, toolbag_id = 5309, name="Tsurara", name_short="Tsura", effect="Ice"},
    Huton={id=1167, toolbag_id = 5310, name="Kawahori-ogi", name_short="Kawa", effect="Wind"},
    Doton={id=1170, toolbag_id = 5311, name="Makibishi", name_short="Maki", effect="Earth"},
    Suiton={id=1176, toolbag_id = 5313, name="Mizu-Deppo", name_short="Mizu", effect="Water"},
    Raiton={id=1173, toolbag_id = 5312, name="Hiraishin", name_short="Hirai", effect="Thun"},
    Katon={id=1161, toolbag_id = 5308, name="Uchitake", name_short="Uchi", effect="Fire"},
    Utsusemi={id=1179, toolbag_id = 5314, name="Shihei", name_short="Shihe", effect="Utsu"},
    Jubaku={id=1182, toolbag_id = 5315, name="Jusatsu", name_short="Jusa", effect="Para"},
    Hojo={id=1185, toolbag_id = 5316, name="Kaginawa", name_short="Kagi", effect="Slow"},
    Kurayami={id=1188, toolbag_id = 5317, name="Sairui-Ran", name_short="Sai", effect="Blind"},
}

local function count_items_in_bag(bag_id, target_item_id)
    local inv = AshitaCore:GetMemoryManager():GetInventory()
    local item = nil
    local total = 0
    for bag_slot = 0, 80 do
        item = inv:GetContainerItem(bag_id, bag_slot)
        if (item ~= nil and item.Id == target_item_id) then
            total = total + item.Count;
        end
    end
    return total
end

local function get_recast(spell_name)
    local recasts = AshitaCore:GetMemoryManager():GetRecast()
    local spell_index = AshitaCore:GetResourceManager():GetSpellByName(spell_name, 0).Index
    return recasts:GetSpellTimer(spell_index)
end

local function is_yonin_up()
    local player = AshitaCore:GetMemoryManager():GetPlayer()
    if not player then return false end
    local buffs = player:GetBuffs()
    local yonin_id = 420
    for _, id in pairs(buffs) do
        if id == yonin_id then return true end
    end
    return false
end

ashita.events.register('d3d_present', 'ninhud_present_cb', function ()
    local outText = '';
    ninhud.font.color = tonumber(string.format('0x%xFFFFFF', 255*ninhud.settings.font.opacity))
    for _, spell in ipairs(ninhud.settings.look_and_feel.spell_sequence) do
        if(spell == '<linebreak>') then
            outText = outText .. '\n'
        else
            local ni_recast = get_recast(spell .. ': Ni')/60.0
            local ichi_recast = get_recast(spell .. ': Ichi')/60.0
            local tool_count = count_items_in_bag(0, tool_map[spell].id)
            local toolbag_count = count_items_in_bag(0, tool_map[spell].toolbag_id) 
                + count_items_in_bag(5, tool_map[spell].toolbag_id) --i think 5 is satchel

            local num_spaces = 0
            if(ninhud.settings.look_and_feel.element_instead_of_spell) then
                outText = outText .. tool_map[spell].effect
                num_spaces = 6 - #tool_map[spell].effect
            else
                outText = outText .. spell 
                num_spaces = ninhud.settings.look_and_feel.name_buffer_size - #spell
            end
            outText = outText .. string.rep(' ', num_spaces) .. '| '
            if(ni_recast < 10 and ni_recast > 0) then 
                outText = outText .. string.format('|c%xFF0000|0', 255*ninhud.settings.font.opacity) .. string.format('%.1f', ni_recast) .. '|r'
            elseif(ni_recast > 0) then
                outText = outText .. string.format('|c%xFF0000|', 255*ninhud.settings.font.opacity) .. string.format('%.1f', ni_recast) .. '|r'
            else
                outText = outText .. '0' .. string.format('%.1f', ni_recast)
            end

            outText = outText .. ' | '
            if(ichi_recast < 10 and ichi_recast > 0) then 
                outText = outText .. string.format('|c%xFF0000|0', 255*ninhud.settings.font.opacity) .. string.format('%.1f', ichi_recast) .. '|r'
            elseif(ichi_recast > 0) then
                outText = outText .. string.format('|c%xFF0000|', 255*ninhud.settings.font.opacity) .. string.format('%.1f', ichi_recast) .. '|r'
            else
                outText = outText .. '0' .. string.format('%.1f', ichi_recast)
            end

            outText = outText .. ' | '
            local tool_hint_spaces = 0
            if(ninhud.settings.look_and_feel.tool_name_hint) then
                tool_hint_spaces = 6 - #tool_map[spell].name_short
                outText = outText .. tool_map[spell].name_short .. ':' .. string.rep(' ', tool_hint_spaces)
            end
            if(tool_count == 0) then
                outText = outText .. string.format('|c%xFF0000|', 255*ninhud.settings.font.opacity) .. tool_count .. '|r'
            elseif(tool_count <= ninhud.settings.look_and_feel.tool_warning_threshold) then
                outText = outText .. string.format('|c%xFFFF00|', 255*ninhud.settings.font.opacity) .. tool_count .. '|r'
            else
                outText = outText .. tool_count
            end

            
            outText = outText .. '('
            if(toolbag_count == 0) then
                outText = outText .. string.format('|c%xFF0000|', 255*ninhud.settings.font.opacity) .. toolbag_count .. '|r'
            elseif(toolbag_count <= ninhud.settings.look_and_feel.toolbag_warning_threshold) then
                outText = outText .. string.format('|c%xFFFF00|', 255*ninhud.settings.font.opacity) .. toolbag_count .. '|r'
            else
                outText = outText .. toolbag_count
            end
            outText = outText .. ')\n'
        end
    end
    if ninhud.settings.look_and_feel.yonin_warning and not is_yonin_up() then
        ninhud.font.background.color = tonumber(string.format('0x%xBB0000', 150*ninhud.settings.font.opacity))
    else
        ninhud.font.background.color = tonumber(string.format('0x%x000000', 150*ninhud.settings.font.opacity))
    end
    outText = outText:sub(1, -2)
    ninhud.font.text = outText;
    ninhud.settings.font.position_x = ninhud.font.position_x;
    ninhud.settings.font.position_y = ninhud.font.position_y;

end);

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        ninhud.settings = s
    end

    -- Apply the font settings..
    if (ninhud.font ~= nil) then
        ninhud.font:apply(ninhud.settings.font);
    end

    settings.save()
end)

ashita.events.register('load', 'load_cb', function ()
    ninhud.font = fonts.new(ninhud.settings.font);
end);

ashita.events.register('unload', 'unload_cb', function()
    settings.save()
end);