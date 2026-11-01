return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      menu = { auto_show = false },
    },
    keymap = {
      preset = "default",
      ["<C-Space>"] = { "show", "show_documentation", "hide" },
    },
  },
}
