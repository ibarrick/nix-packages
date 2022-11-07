{
  description = "ibarrick Nix Packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; 

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = 
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      hello = nixpkgs.legacyPackages.x86_64-linux.hello;

      neovim = (pkgs.neovim.override {
      configure = {
        customRC = ''
syntax on
set tabstop=4
set shiftwidth=4
set encoding=UTF-8
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

autocmd BufWritePre *.clj %s/\s\+$//e
autocmd BufWritePre *.tsx %s/\s\+$//e
autocmd BufWritePre *.ts %s/\s\+$//e
autocmd BufWritePre *.js %s/\s\+$//e

set clipboard^=unnamed,unnamedplus
let mapleader = "\<Space>"
let maplocalleader = ","
nnoremap <silent> <Leader>s :split<CR>
nnoremap <silent> <Leader>v :vsplit<CR>
nnoremap <silent> <Leader><Tab> :wincmd w<CR>
nnoremap <silent> <C-p> :FZF<CR>
nnoremap <silent> <C-f> :Rg<CR>
nnoremap <silent> <C-b> :Buffers<CR>
nnoremap <silent> <Leader>gg :LazyGit<CR>
nnoremap <silent> <C-y> :FloatermToggle build<CR>
tnoremap <C-y> <C-\><C-n>:FloatermToggle build<CR>
set nocompatible
filetype plugin on
let g:pencil#map#suspend_af = 'K'
let g:goyo_width = 110
let g:pencil#textwidth = 100    
let g:vimwiki_list = [{'path': '~/vimwiki/',
                          \ 'syntax': 'markdown', 'ext': '.md'}]
let g:GPGFilePattern = '*.\(gpg\|asc\|pgp\)\(.wiki\)\='
set backspace=indent,eol,start 
set redrawtime=10000
set splitright
let g:deoplete#enable_at_startup = 1
colorscheme codedark
let g:conjure#extract#tree_sitter#enabled = v:true
let g:sexp_mappings = {
          \ 'sexp_capture_next_element': '<Leader>>',
          \ 'sexp_emit_tail_element': '<Leader><',
        \ }
nnoremap <silent> <Leader>a :A<CR>
let g:coc_root_patterns = ['.']
nnoremap <C-n> :NERDTreeToggle<CR>

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:VM_maps = {}
let g:VM_maps['Find Under']         = '<Leader>n'           " replace C-n
let g:VM_maps['Find Subword Under'] = '<Leader>n'           " replace visual C-n
let g:VM_maps["Add Cursor Down"] = '<Leader>j'      " start selecting down
let g:VM_maps["Add Cursor Up"] = '<Leader>k'      " start selecting down
let g:airline_powerline_fonts = 1
nmap <silent> <Leader>gd <Plug>(coc-definition)
nmap <silent> <Leader>gy <Plug>(coc-type-definition)
nmap <silent> <Leader>gi <Plug>(coc-implementation)
nmap <silent> <Leader>gr <Plug>(coc-references)
nmap <silent> <Leader>ca <Plug>(coc-codeaction)
nmap <silent> <Leader>cn <Plug>(coc-diagnostic-next)

nnoremap <silent> <Leader><Leader>p :CocCommand<CR>

nnoremap <silent> <C-d> :Clap coc_diagnostics<CR>
nnoremap <silent> <C-]> :Clap coc_symbols<CR>
nnoremap <silent> <C-u> :Clap coc_outline<CR>

nmap <silent> <Leader><Leader>jd <Plug>(jsdoc)


nnoremap <silent> <Leader>r :ConjureEval (reloaded.repl/reset)<CR>

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nnoremap <silent> <C-l> :nohl<CR><C-l>
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
set termguicolors
lua <<EOF
require("bufferline").setup{
  options = {
    separator_style = "slant"
  }
}
require("hop").setup{

}
EOF
nnoremap <silent><Leader><Leader>l :BufferLineCycleNext<CR>
nnoremap <silent><Leader><Leader>h :BufferLineCyclePrev<CR>
nnoremap <silent><Leader><Leader>d :bd<CR>
nnoremap <silent><Leader><Leader>w :HopWord<CR>
'';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ vim-nix hop-nvim fzf-vim vim-pencil goyo vim-markdown vimwiki vim-gnupg conjure coc-nvim vim-airline vim-fugitive vim-sexp 
        vim-clojure-static vim-visual-multi vim-floaterm
        vim-jsx-pretty coc-snippets vim-gitgutter nerdtree lazygit-nvim vim-code-dark coc-clap coc-tsserver coc-go
        vim-devicons bufferline-nvim vim-jsdoc vim-clap coc-flutter vim-surround vim-commentary
        (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
#        (pkgs.vimUtils.buildVimPlugin {
#          name = "coc-snippets";
#          src = pkgs.fetchFromGitHub {
#            repo = "coc-snippets";
#            owner = "neoclide";
#            rev = "e92633e0e83c46dca02583a7bb5553989bcede80";
#            sha256 = "1vgrm39avy94b9699cpks5sbxsmcdbkzqri99jrl384b88dql7ha";
#          };
#        })
        (pkgs.vimUtils.buildVimPlugin {
          name = "portkey";
          src = pkgs.fetchFromGitHub {
            repo = "portkey";
            owner = "dsawardekar";
            rev = "2afd378b3fdec04138e9bda17840c60d0d9cca7d";
            sha256 = "02ga889h16kfz5cmbxy1hj788zdf7sk03h8x1xzlpdnp23jhbcf0";
          };
        })
        (pkgs.vimUtils.buildVimPlugin {
          name = "vim-ember-hbs";
          src = pkgs.fetchFromGitHub {
            repo = "vim-ember-hbs";
            owner = "joukevandermaas";
            rev = "c47e1958a6c190c9d79ac66cb812f1a1d3b4e968";
            sha256 = "0asxn18j65fihzwdpjbpcnqr6klwk5dr5v9lzw9imjj50ia40ah3";
          };
        })
#        (pkgs.vimUtils.buildVimPlugin {
#          name = "paredit-vim";
#          src = pkgs.fetchFromGitHub {
#            repo = "paredit.vim";
#            owner = "vim-scripts";
#            rev = "791c3a0cc3155f424fba9409a9520eec241c189c";
#            sha256 = "15lg33bgv7afjikn1qanriaxmqg4bp3pm7qqhch6105r1sji9gz9";
#          };
#        })
           ];
      };
    };
    });

      ghostpdl = import ./ghostpdl { stdenv = pkgs.stdenv; };
      
      cdk8s = import ./cdk8s { inherit pkgs; stdenv = pkgs.stdenv; };
    };

  };
}
