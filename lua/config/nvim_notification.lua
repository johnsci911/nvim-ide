require('notify').setup {
  background_colour = "#000000",
  render = "default",
  stages = "fade_in_slide_out",
  time_formats = {
    notification = " %a %b %d, %Y -  %H:%M",
    notification_history = " %a %b %d, %Y -  %H:%M"
  },
  max_height = 3,
  timeout = 800,
}

-- Wrap vim.notify to filter out CodeCompanion Prompt Library warnings
local notify = require("notify")
vim.notify = function(msg, level, opts)
  -- Filter out Prompt Library warnings
  if type(msg) == "string" and msg:match("%[Prompt Library%]") then
    return
  end
  notify(msg, level, opts)
end
