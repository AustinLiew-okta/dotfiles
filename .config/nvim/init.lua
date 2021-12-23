local api = vim.api
local cmd = vim.cmd  -- to execute vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options

-- general config
opt.number = true -- line numbers
opt.relativenumber = true -- relative line numbers
opt.mouse = 'a'   -- mouse mode
opt.expandtab = true -- spaces instead of tabs
opt.shiftwidth = 2 -- indent size
opt.tabstop = 2 -- tab size in spaces
opt.termguicolors = true -- true color support; make sure terminal supports this!
opt.clipboard = 'unnamedplus' -- share system clipboard
                              -- TODO: selection (middle click) keyboard currently disabled

-- Install paq-nvim if it doesn't exist (bootstrap)
local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
local paq_missing = fn.empty(fn.glob(install_path)) > 0
if paq_missing then
  print('Cloning Paq...')
  fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end
-- End install of paq-nvim

local paq = require "paq" {
  'savq/paq-nvim'; -- paq-nvim manages itself
  'vim-airline/vim-airline';
  'airblade/vim-gitgutter';
  'APZelos/blamer.nvim'; -- inline git blame
  'rktjmp/lush.nvim'; -- theme
  'npxbr/gruvbox.nvim'; -- theme
  'neovim/nvim-lspconfig';
  'simrat39/rust-tools.nvim';
  -- Optional fuzzy finder for rust-tools
  'nvim-lua/popup.nvim';
  'nvim-lua/plenary.nvim';
  'nvim-telescope/telescope.nvim';
  -- Completion framework nvim-cmp
  'hrsh7th/nvim-cmp';
  'hrsh7th/cmp-nvim-lsp'; -- LSP completion source for nvim-cmp
  'hrsh7th/cmp-buffer'; -- Other useful completion source for nvim-cmp
  'hrsh7th/cmp-path'; -- Other useful completion source for nvim-cmp
  'hrsh7th/cmp-cmdline'; -- vim cmdline completion source for nvim-cmp
  -- Snippet engine for nvim-cmp
  'hrsh7th/cmp-vsnip';
  'hrsh7th/vim-vsnip';
}

-- Automatically PaqInstall packages on bootstrap
if paq_missing then
  vim.cmd('autocmd User PaqDoneInstall source $MYVIMRC')
  paq.install()
  fn.confirm('Bootstrapping Paq and installing packages...')
  return
end
-- End PaqInstall packages

-- theme
opt.background = "dark" -- or "light" for light mode
cmd([[colorscheme gruvbox]])

-- git blamer
-- turn on by default
g.blamer_enabled = 1

-- lsp configuration

-- code navigation shortcuts
-- as found in :help lsp
api.nvim_set_keymap('n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, silent = true})
api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true})
api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true, silent = true})
api.nvim_set_keymap('n', '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', {noremap = true, silent = true})
api.nvim_set_keymap('n', '1gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', {noremap = true, silent = true})
api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', {noremap = true, silent = true})
api.nvim_set_keymap('n', 'g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', {noremap = true, silent = true})
api.nvim_set_keymap('n', 'gW', '<cmd>lua vim.lsp.buf.workplace_symbol()<CR>', {noremap = true, silent = true})

-- rust-analyzer does not yet support goto declaration
-- re-mapped `gd` to definition
api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, silent = true})
--api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', {noremap = true, silent = true})

-- quick-fix
api.nvim_set_keymap('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', {noremap = true, silent = true})

-- nvim-cmp config
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force user to select one from the menu
opt.completeopt = {'menuone', 'noinsert', 'noselect'} -- completion options

local cmp = require('cmp')

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Insert}),
    ['<C-p>'] = cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Insert}),
    ['<Tab>'] = cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Insert}),
    ['<S-Tab>'] = cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Insert}),
    ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    --['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confim explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = false,
    }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- rust-tools setup
local opts = {
  server = { -- configure opts sent to nvim-lspconfig for rust-analyzer
    capabilities = capabilities -- set up with nvim-cmp because setup
                                -- should only be called once per
                                -- lsp server in lspconfig
  }
}
require('rust-tools').setup(opts)

-- use <Tab> and <S-Tab> to navigate through nvim popup menu
api.nvim_set_keymap('i', '<Tab>', 'pumvisible() ? "<C-n>" : "<Tab>"', {noremap = true, expr = true})
api.nvim_set_keymap('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<Tab>"', {noremap = true, expr = true})
-- use <Tab> as trigger keys
-- api.nvim_set_keymap('i', '<tab>', '<plug>completion_smart_tab', true)
-- api.nvim_feedkeys('<plug>completion_smart_tab', 'i', v:true)
-- api.nvim_set_keymap('i', '<s-tab>', '<plug>completion_smart_s_tab', {})

-- use a fixed column for diagnostics to appear in
-- this removes jitter when warnings/errors flow in
opt.signcolumn = 'yes'

-- set updatetime for cursorhold
-- 300ms of no cursor movement to trigger cursorhold
opt.updatetime = 300
-- show diagnostic popup on cursor hover
-- cmd('autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()')

-- Goto previous/next diagnostic warning/error
api.nvim_set_keymap('n', 'g[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', {noremap = true, silent = true})
api.nvim_set_keymap('n', 'g]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', {noremap = true, silent = true})

-- autofmt on save for rust source files
cmd('autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync(nil, 200)')

-- telescope
require('telescope').setup({})
api.nvim_set_keymap('n', '<leader>ff', '<cmd>lua require(\'telescope.builtin\').find_files()<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>fg', '<cmd>lua require(\'telescope.builtin\').live_grep()<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>fb', '<cmd>lua require(\'telescope.builtin\').buffers()<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>fh', '<cmd>lua require(\'telescope.builtin\').help_tags()<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>flr', '<cmd>lua require(\'telescope.builtin\').lsp_references()<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>fld', '<cmd>lua require(\'telescope.builtin\').lsp_definitions()<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>flD', '<cmd>lua require(\'telescope.builtin\').lsp_document_diagnostics()<cr>', {noremap = true})
api.nvim_set_keymap('n', '<leader>fli', '<cmd>lua require(\'telescope.builtin\').lsp_implementations()<cr>', {noremap = true})

