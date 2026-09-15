local M = {}

local function escape_statusline(text)
  return text:gsub("%%", "%%%%")
end

function M.render()
  local current_tab = vim.fn.tabpagenr()
  local parts = {}

  for _, tab in ipairs(vim.fn.gettabinfo()) do
    local name = tab.variables.project_name
    if name and name ~= "" then
      local highlight = tab.tabnr == current_tab and "BufferLineTabSelected" or "BufferLineTab"
      parts[#parts + 1] = string.format(
        "%%%d@v:lua.ProjectTabClick@%%#%s# %s %%X",
        tab.tabnr,
        highlight,
        escape_statusline(name)
      )
    end
  end

  return table.concat(parts)
end

function M.setup()
  if not vim.t.project_name or vim.t.project_name == "" then
    local cwd = vim.fn.getcwd()
    local project_root = vim.fs.root(cwd, ".git") or cwd
    vim.t.project_name = vim.fs.basename(project_root)
  end

  _G.ProjectTabs = M.render
  vim.o.showtabline = 2
  vim.o.tabline = "%!v:lua.ProjectTabs()"
  vim.o.winbar = "%{%v:lua.nvim_bufferline()%}"
end

_G.ProjectTabClick = function(tabnr)
  vim.api.nvim_set_current_tabpage(vim.api.nvim_list_tabpages()[tabnr])
end

return M
