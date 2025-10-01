" Bootstrap the copilot-cli plugin
if !exists('g:copilot_loaded')
  lua require('copilot').setup()
  let g:copilot_loaded = 1
endif
