-- Performant indent guides with scope highlighting. ~10x faster than
-- indent-blankline — renders in 0.1-1ms even on large files.
return {
  "saghen/blink.indent",
  event = "VeryLazy",
  opts = {
    dedent_scoped_filetypes = { include_defaults = true },
  },
}
