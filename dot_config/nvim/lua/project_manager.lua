-- Project Management System
-- Provides two main functionalities:
-- 1. Switch project: Close everything and restart Neovim in the target project
-- 2. Open file from another project: First select project, then select file

local M = {}

-- Helper to get projects from ~/checkout (all directories with .git)
local function get_projects()
  local checkout_dir = vim.fn.expand("~/checkout")
  local handle = io.popen("find " .. checkout_dir .. " -maxdepth 5 -name '.git' -type d 2>/dev/null")
  if not handle then
    return {}
  end

  local projects = {}
  for line in handle:lines() do
    -- Extract project directory from .git path
    local project_dir = line:gsub("/.git$", "")
    table.insert(projects, project_dir)
  end
  handle:close()

  -- Sort projects alphabetically
  table.sort(projects)
  return projects
end

-- Switch to a different project (change cwd and close all buffers)
function M.switch_project()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local projects = get_projects()
  if #projects == 0 then
    vim.notify("No projects found in ~/checkout", vim.log.levels.WARN)
    return
  end

  pickers
    .new({}, {
      prompt_title = "Switch Project",
      finder = finders.new_table({
        results = projects,
      }),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local project_path = selection.value

          -- Close all toggleterm terminals
          local ok, toggleterm = pcall(require, "toggleterm.terminal")
          if ok then
            local terminals = toggleterm.get_all()
            for _, term in ipairs(terminals) do
              term:shutdown()
            end
          end

          -- Close all buffers
          vim.cmd("%bdelete!")

          -- Change working directory
          vim.cmd("cd " .. vim.fn.fnameescape(project_path))

          vim.notify("Switched to " .. project_path, vim.log.levels.INFO)
        end)
        return true
      end,
    })
    :find()
end

-- Open a file from any project - two step process: 1) select project 2) select file
function M.open_project_file()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local projects = get_projects()
  if #projects == 0 then
    vim.notify("No projects found in ~/checkout", vim.log.levels.WARN)
    return
  end

  -- Step 1: Select project
  pickers
    .new({}, {
      prompt_title = "Select Project",
      finder = finders.new_table({
        results = projects,
      }),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local project_path = selection.value

          -- Step 2: Open file picker in selected project
          vim.schedule(function()
            pickers
              .new({}, {
                prompt_title = "Open File from " .. vim.fn.fnamemodify(project_path, ":t"),
                finder = finders.new_async_job({
                  command_generator = function(prompt)
                    return {
                      "bash",
                      "-c",
                      string.format(
                        "find '%s' -type f \\( -path '*/.*' ! -path '*/.teamcity/*' -prune \\) -o -type f -print 2>/dev/null | grep -v '/\\.' | head -5000",
                        project_path
                      ),
                    }
                  end,
                  entry_maker = function(line)
                    local display = line
                    if line:sub(1, #project_path) == project_path then
                      display = line:sub(#project_path + 2)  -- +2 to skip the trailing /
                    end
                    return {
                      value = line,
                      display = display,
                      ordinal = line,
                    }
                  end,
                }),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr2, map2)
                  actions.select_default:replace(function()
                    actions.close(prompt_bufnr2)
                    local file_selection = action_state.get_selected_entry()
                    if file_selection then
                      local file_path = file_selection.value
                      -- Open file without changing cwd
                      vim.cmd("edit " .. vim.fn.fnameescape(file_path))
                      vim.notify("Opened: " .. file_path, vim.log.levels.INFO)
                    end
                  end)
                  return true
                end,
              })
              :find()
          end)
        end)
        return true
      end,
    })
    :find()
end

return M


