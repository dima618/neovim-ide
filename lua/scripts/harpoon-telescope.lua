local M = {}
local harpoon = require("harpoon")
local conf = require("telescope.config").values

local function harpoon_items(list)
    local results = {}
    for i = 1, list:length() do
        local item = list.items[i]
        if item then
            table.insert(results, { value = item.value, harpoon_index = i })
        end
    end
    return results
end

local function make_finder(harpoon_files)
    return require("telescope.finders").new_table {
        results = harpoon_items(harpoon_files),
        entry_maker = function(entry)
            return {
                value = entry.value,
                display = entry.value,
                ordinal = entry.value,
                harpoon_index = entry.harpoon_index,
            }
        end,
    }
end

function M.toggle_telescope()
    local list = harpoon:list()
    require("telescope.pickers")
        .new({}, {
            prompt_title = "Harpoon  (dd to remove)",
            finder = make_finder(list),
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
            attach_mappings = function(prompt_buffer_number, map)
                map("n", "dd", function()
                    local state = require("telescope.actions.state")
                    local selected_entry = state.get_selected_entry()
                    local current_picker = state.get_current_picker(prompt_buffer_number)

                    harpoon:list():remove_at(selected_entry.harpoon_index)
                    current_picker:refresh(make_finder(harpoon:list()))
                end)
                return true
            end,
        })
        :find()
end

return M
