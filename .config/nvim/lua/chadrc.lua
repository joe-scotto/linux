-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "chadracula",
}

-- Copy to clipboard

-- Disable line wrapping
local opt = vim.opt
opt.wrap = false

-- Conform auto formatting
require("conform").setup {
  formatters_by_ft = {
    angular = { "prettier" },
    css = { "prettier" },
    flow = { "prettier" },
    graphql = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    jsx = { "prettier" },
    javascript = { "prettier" },
    less = { "prettier" },
    markdown = { "prettier" },
    scss = { "prettier" },
    typescript = { "prettier" },
    vue = { "prettier" },
    yaml = { "prettier" },
  },
  format_on_save = {
    lsp_format = "fallback",
  },
}

-- Render markdown
require("render-markdown").setup {}

return M
