-- Animates cursor movement with a Neovide-style smear/trail effect in
-- any terminal. Uses the author-recommended "faster" dynamics so jumps
-- feel snappy instead of floaty, and draws in buffer space so it plays
-- well with neoscroll's smooth scrolling. Disabled in :terminal buffers,
-- where the animation is just noise. Toggle with <leader>uS.
return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  opts = {
    -- Smear color defaults to the Cursor highlight. If your terminal
    -- forces its own cursor color, set e.g. cursor_color = "#d3cdc3".

    -- "Faster" dynamics: short, responsive trails (plugin defaults are 0.6/0.45)
    stiffness = 0.8,
    trailing_stiffness = 0.6,
    damping = 0.95,
    distance_stop_animating = 0.5, -- stop early; no lingering trail

    -- Keep the insert-mode (vertical bar) smear subtle and quick
    stiffness_insert_mode = 0.7,
    trailing_stiffness_insert_mode = 0.7,
    damping_insert_mode = 0.95,

    filetypes_disabled = { "terminal" },
  },
  keys = {
    {
      "<leader>uS",
      function()
        require("smear_cursor").toggle()
      end,
      desc = "Toggle Smear Cursor",
    },
  },
}
