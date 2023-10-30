_: {
  config = {
    globals = {
      # disable support for plugins written in
      loaded_ruby_provider = 0;
      loaded_perl_provider = 0;
      loaded_python_provider = 0;
      loaded_python3_provider = 0;
    };

    options = {
      autoindent = true;
      linebreak = true;
      backup = false;
      writebackup = false;
      swapfile = false;
      undofile = true;

      fileencoding = "utf-8";
      clipboard = "unnamedplus";

      # mouse = "a";
      # mouse = "";

      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      smartindent = false;

      signcolumn = "yes";

      number = true;
      numberwidth = 4;
      relativenumber = false;
      cursorline = true;

      hlsearch = true;
      ignorecase = true;
      smartcase = true;

      wrap = false;
      scrolloff = 8;
      sidescrolloff = 8;

      conceallevel = 0;

      splitbelow = true;
      splitright = true;

      spell = true;
      spelllang = "en_us,en";

      termguicolors = true;

      timeout = true;
      timeoutlen = 300;
      updatetime = 300;

      showtabline = 0;
      showmode = false;
      showcmd = false;
      ruler = false;
      cmdheight = 1;
      laststatus = 3;

      pumheight = 10;
      completeopt = ["menuone" "noselect"];
      # shortmess:append "c"
      # iskeyword:append "-"

      # markdown_folding = true;
    };
  };
}