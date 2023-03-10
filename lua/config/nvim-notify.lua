vim.notify = require("notify")


-- Utility functions shared between progress reports for LSP and DAP

local client_notifs = {}

local function get_notif_data(client_id, token)
  if not client_notifs[client_id] then
    client_notifs[client_id] = {}
  end

  if not client_notifs[client_id][token] then
    client_notifs[client_id][token] = {}
  end

  return client_notifs[client_id][token]
end


local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local function update_spinner(client_id, token)
  local notif_data = get_notif_data(client_id, token)

  if notif_data.spinner then
    local new_spinner = (notif_data.spinner + 1) % #spinner_frames
    notif_data.spinner = new_spinner

    notif_data.notification = vim.notify(nil, nil, {
      hide_from_history = true,
      icon = spinner_frames[new_spinner],
      replace = notif_data.notification,
    })

    vim.defer_fn(function()
      update_spinner(client_id, token)
    end, 100)
  end
end

local function format_title(title, client_name)
  return client_name .. (#title > 0 and ": " .. title or "")
end

local function format_message(message, percentage)
  return (percentage and percentage .. "%\t" or "") .. (message or "")
end

-- LSP integration
-- Make sure to also have the snippet with the common helper functions in your config!

vim.lsp.handlers["$/progress"] = function(_, result, ctx)
 local client_id = ctx.client_id

 local val = result.value

 if not val.kind then
   return
 end

 local notif_data = get_notif_data(client_id, result.token)

 if val.kind == "begin" then
    local message = format_message(val.message, val.percentage)

    notif_data.notification = vim.notify(message, "info", {
      title = format_title(val.title, vim.lsp.get_client_by_id(client_id).name),
      icon = spinner_frames[1],
      timeout = 2000,
      hide_from_history = false,
    })

    notif_data.spinner = 1
    update_spinner(client_id, result.token)
  elseif val.kind == "report" and notif_data then
    notif_data.notification = vim.notify(format_message(val.message, val.percentage), "info", {
      replace = notif_data.notification,
      hide_from_history = false,
    })
  elseif val.kind == "end" and notif_data then
    notif_data.notification =
      vim.notify(val.message and format_message(val.message) or "Complete", "info", {
        icon = "",
        replace = notif_data.notification,
        timeout = 2000,
      })

    notif_data.spinner = nil
  end
end

-- table from lsp severity to vim severity.
local severity = {
  "error",
  "warn",
  "info",
  "info", -- map both hint and info to info?
}
vim.lsp.handlers["window/showMessage"] = function(err, method, params, client_id)
  vim.notify(method.message, severity[params.type])
end

local function qf_rename()
    local position_params = vim.lsp.util.make_position_params()
    position_params.oldName = vim.fn.expand("<cword>")
    position_params.newName = vim.fn.input("Rename To> ", position_params.oldName)

    vim.lsp.buf_request(0, "textDocument/rename", position_params, function(err, result, ...)
        if not result or not result.changes then
            require('notify')(string.format('could not perform rename'), 'error', {
                title = string.format('[lsp] rename: %s -> %s', position_params.oldName, position_params.newName),
                timeout = 2500
            })

            return
        end

        vim.lsp.handlers["textDocument/rename"](err, result, ...)

        local notification, entries = '', {}
        local num_files, num_updates = 0, 0
        for uri, edits in pairs(result.changes) do
            num_files = num_files + 1
            local bufnr = vim.uri_to_bufnr(uri)

            for _, edit in ipairs(edits) do
                local start_line = edit.range.start.line + 1
                local line = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]

                num_updates = num_updates + 1
                table.insert(entries, {
                    bufnr = bufnr,
                    lnum = start_line,
                    col = edit.range.start.character + 1,
                    text = line
                })
            end

            local short_uri = string.sub(vim.uri_to_fname(uri), #vim.fn.getcwd() + 2)
            notification = notification .. string.format('made %d change(s) in %s', #edits, short_uri)
        end

        require("notify")(notification, 'info', {
            title = string.format('[lsp] rename: %s -> %s', position_params.oldName, position_params.newName),
            timeout = 2500
        })

        if num_files > 1 then require("utils").qf_populate(entries, "r") end
        -- print(string.format("updated %d instance(s) in %d file(s)", num_updates, num_files))
    end)
end
vim.lsp.buf.rename = qf_rename
