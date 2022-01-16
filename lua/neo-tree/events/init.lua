local vim = vim
local q = require("neo-tree.events.queue")
local log = require("neo-tree.log")

local M = {
  -- Well known event names, you can make up your own
  BEFORE_RENDER = "before_render",
  AFTER_RENDER = "after_render",
  FILE_ADDED = "file_added",
  FILE_DELETED = "file_deleted",
  FILE_MOVED = "file_moved",
  FILE_OPENED = "file_opened",
  FILE_RENAMED = "file_renamed",
  FS_EVENT = "fs_event",
  GIT_EVENT = "git_event",
  VIM_BUFFER_CHANGED = "vim_buffer_changed",
  VIM_BUFFER_ENTER = "vim_buffer_enter",
  VIM_DIAGNOSTIC_CHANGED = "vim_diagnostic_changed",
  VIM_DIR_CHANGED = "vim_dir_changed",
  VIM_WIN_ENTER = "vim_win_enter",
}

M.define_autocmd_event = function(event_name, autocmds, debounce_frequency, seed_fn)
  local opts = {
    setup = function()
      local tpl = ":lua require('neo-tree.events').fire_event('%s')"
      local callback = string.format(tpl, event_name)
      local cmds = {
        "augroup NeoTreeEvent_" .. event_name,
        "autocmd " .. table.concat(autocmds, ",") .. " * " .. callback,
        "augroup END",
      }
      log.trace("Registering autocmds: %s", table.concat(cmds, "\n"))
      vim.cmd(table.concat(cmds, "\n"))
    end,
    seed = seed_fn,
    teardown = function()
      log.trace("Teardown autocmds for ", event_name)
      vim.cmd(string.format("autocmd! NeoTreeEvent_%s", event_name))
    end,
    debounce_frequency = debounce_frequency,
  }
  log.debug("Defining autocmd event: %s", event_name)
  q.define_event(event_name, opts)
end

M.clear_all_events = q.clear_all_events
M.define_event = q.define_event
M.destroy_event = q.destroy_event
M.fire_event = q.fire_event

M.subscribe = q.subscribe
M.unsubscribe = q.unsubscribe

return M