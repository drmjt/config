return {
  -- Add gruvbox colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      contrast = "hard",
    },
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },

  -- More sensible autocompletion options
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.completion = { completeopt = "menu,menuone,noinsert,noselect" }
      opts.preselect = cmp.PreselectMode.None
      opts.mapping = cmp.mapping.preset.insert({
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      })
      opts.experimental = {
        ghost_text = false,
      }
    end,
  },

  -- { -- To disable only the animation of the scope highlighting
  --   "echasnovski/mini.indentscope",
  --   opts = {
  --     draw = {
  --       animation = require("mini.indentscope").gen_animation.none(),
  --     },
  --   },
  -- },

  -- Disable insersion of matching quotes/parentheses
  { "echasnovski/mini.pairs", enabled = false },
}
