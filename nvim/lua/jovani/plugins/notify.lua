-- Configures nvim-notify with a proper background colour to silence the
-- "NotifyBackground has no background highlight" warning.
return {
  "rcarriga/nvim-notify",
  opts = {
    background_colour = "#30363d",
  },
}
