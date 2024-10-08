# Thanks for the keybinds primeagen and folke!
{
  globals.mapleader = " ";

  # TODO: Move general mappings to which-key?
  keymaps = [
    ## Disable arrow keys
    #{
    #  mode = ["n" "i"];
    #  key = "<Up>";
    #  action = "<Nop>";
    #  options = {
    #    silent = true;
    #    noremap = true;
    #    desc = "Disable Up arrow key";
    #  };
    #}
    #{
    #  mode = ["n" "i"];
    #  key = "<Down>";
    #  action = "<Nop>";
    #  options = {
    #    silent = true;
    #    noremap = true;
    #    desc = "Disable Down arrow key";
    #  };
    #}
    #{
    #  mode = ["n" "i"];
    #  key = "<Right>";
    #  action = "<Nop>";
    #  options = {
    #    silent = true;
    #    noremap = true;
    #    desc = "Disable Right arrow key";
    #  };
    #}
    #{
    #  mode = ["n" "i"];
    #  key = "<Left>";
    #  action = "<Nop>";
    #  options = {
    #    silent = true;
    #    noremap = true;
    #    desc = "Disable Left arrow key";
    #  };
    #}

    # ----- General maps -----
    {
      mode = "n";
      key = "<leader>f";
      action = "+find/file";
      options.desc = "Find";
    }

    {
      mode = "n";
      key = "<leader>s";
      action = "+search";
      options.desc = "Search";
    }

    {
      mode = "n";
      key = "<leader>q";
      action = "+quit/session";
      options.desc = "Quit/Session";
    }

    {
      mode = ["n" "v"];
      key = "<leader>g";
      action = "+git";
      options.desc = "Git";
    }

    {
      mode = "n";
      key = "<leader>u";
      action = "+ui";
      options.desc = "UI";
    }

    {
      mode = "n";
      key = "<leader>w";
      action = "+windows";
      options.desc = "Windows";
    }

    {
      mode = "n";
      key = "<leader><Tab>";
      action = "+navigation";
      options.desc = "Navigation";
    }

    {
      mode = "n";
      key = "<leader><Tab><Space>";
      action = "+buffers";
      options.desc = "Buffers";
    }

    {
      mode = "n";
      key = "<leader><Tab><Tab>";
      action = "+tmux";
      options.desc = "Tmux";
    }

    {
      mode = ["n" "v"];
      key = "<leader>d";
      action = "+debug";
      options.desc = "Debug";
    }

    {
      mode = ["n" "v"];
      key = "<leader>c";
      action = "+code";
      options.desc = "Code";
    }

    {
      mode = ["n" "v"];
      key = "<leader>t";
      action = "+test";
      options.desc = "Test";
    }

    {
      mode = "n";
      key = "<leader>o";
      action = "+obsidian";
      options.desc = "Obsidian";
    }

    # ----- Obsidian -----

    {
      mode = "n";
      key = "<leader>ot";
      action = "<cmd>lua require('obsidian').util.toggle_checkbox()<cr>";
      options.desc = "Toggle Checkbox";
    }

    {
      mode = "n";
      key = "<leader>oo";
      action = "<cmd>ObsidianQuickSwitch<cr>";
      options.desc = "Quick Switch";
    }

    {
      mode = "n";
      key = "<leader>on";
      action = "<cmd>ObsidianNew<cr>";
      options.desc = "New Blank Note";
    }

    {
      mode = "n";
      key = "<leader>of";
      action = "<cmd>ObsidianSearch<cr>";
      options.desc = "Search";
    }

    {
      mode = "n";
      key = "<leader>oi";
      action = "<cmd>ObsidianPasteImg<cr>";
      options.desc = "Paste Image";
    }



    # ----- Tmux -----

    {
      mode = "n";
      key = "<leader><Tab><Tab><Tab>";
      # action = "<M-L>";
      # action = "<cmd>lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<M-L>', true, false, true), 'n', false)<cr>";

      action = "<cmd>! tmux next-window<cr>";
      options.desc = "Next Window";
    }

    {
      mode = "n";
      key = "<leader><Tab><Tab>`";
      # action = "<M-H>";
      # action.__raw = "(function () return (vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<M-H>', true, false, true), 'n', false)) end)";
      # action = ":call nvim_feedkeys(nvim_replace_termcodes("<M-H>", true, false, true), 'n', false)<cr>";
      action = "<cmd>! tmux previous-window<cr>";
      options.desc = "Previous Window";
    }

    {
      mode = "n";
      key = "<leader><Tab><Tab>h";
      action = "<cmd>! tmux select-pane -L<cr>";
      options = {
        silent = true;
        desc = " Pane Left";
      };
    }

    {
      mode = "n";
      key = "<leader><Tab><Tab>l";
      action = "<cmd>! tmux select-pane -R<cr>";
      options = {
        silent = true;
        desc = " Pane Right";
      };
    }

    {
      mode = "n";
      key = "<leader><Tab><Tab>j";
      action = "<cmd>! tmux select-pane -D<cr>";
      options = {
        silent = true;
        desc = " Pane Down";
      };
    }

    {
      mode = "n";
      key = "<leader><Tab><Tab>k";
      action = "<cmd>! tmux select-pane -U<cr>";
      # options.desc = " Pane Up";
      options = {
        silent = true;
        desc = " Pane Up";
      };
    }

    # # ----- Tabs -----
    # {
    #   mode = "n";
    #   key = "<leader><tab>l";
    #   action = "<cmd>tablast<cr>";
    #   options = {
    #     silent = true;
    #     desc = "Last tab";
    #   };
    # }

    # {
    #   mode = "n";
    #   key = "<leader><tab>f";
    #   action = "<cmd>tabfirst<cr>";
    #   options = {
    #     silent = true;
    #     desc = "First Tab";
    #   };
    # }

    # {
    #   mode = "n";
    #   key = "<leader><tab><tab>";
    #   action = "<cmd>tabnew<cr>";
    #   options = {
    #     silent = true;
    #     desc = "New Tab";
    #   };
    # }

    # {
    #   mode = "n";
    #   key = "<leader><tab>]";
    #   action = "<cmd>tabnext<cr>";
    #   options = {
    #     silent = true;
    #     desc = "Next Tab";
    #   };
    # }

    # {
    #   mode = "n";
    #   key = "<leader><tab>d";
    #   action = "<cmd>tabclose<cr>";
    #   options = {
    #     silent = true;
    #     desc = "Close tab";
    #   };
    # }

    # {
    #   mode = "n";
    #   key = "<leader><tab>[";
    #   action = "<cmd>tabprevious<cr>";
    #   options = {
    #     silent = true;
    #     desc = "Previous Tab";
    #   };
    # }

    # ----- Windows -----
    {
      mode = "n";
      key = "<leader>ww";
      action = "<C-W>p";
      options = {
        silent = true;
        desc = "Other window";
      };
    }

    {
      mode = "n";
      key = "<leader>wd";
      action = "<C-W>c";
      options = {
        silent = true;
        desc = "Delete window";
      };
    }

    {
      mode = "n";
      key = "<leader>w-";
      action = "<C-W>s";
      options = {
        silent = true;
        desc = "Split window below";
      };
    }

    {
      mode = "n";
      key = "<leader>w|";
      action = "<C-W>v";
      options = {
        silent = true;
        desc = "Split window right";
      };
    }

    # {
    #   mode = "n";
    #   key = "<leader>-";
    #   action = "<C-W>s";
    #   options = {
    #     silent = true;
    #     desc = "Split window below";
    #   };
    # }

    # {
    #   mode = "n";
    #   key = "<leader>|";
    #   action = "<C-W>v";
    #   options = {
    #     silent = true;
    #     desc = "Split window right";
    #   };
    # }

    {
      mode = "n";
      key = "<C-s>";
      action = "<cmd>w<cr><esc>";
      options = {
        silent = true;
        desc = "Save file";
      };
    }

    # ----- Quit/Session -----
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>quitall<cr><esc>";
      options = {
        silent = true;
        desc = "Quit all";
      };
    }

    {
      mode = "n";
      key = "<leader>qs";
      action = ":lua require('persistence').load()<cr>";
      options = {
        silent = true;
        desc = "Restore session";
      };
    }

    {
      mode = "n";
      key = "<leader>ql";
      action = "<cmd>lua require('persistence').load({ last = true })<cr>";
      options = {
        silent = true;
        desc = "Restore last session";
      };
    }

    {
      mode = "n";
      key = "<leader>qd";
      action = "<cmd>lua require('persistence').stop()<cr>";
      options = {
        silent = true;
        desc = "Don't save current session";
      };
    }

    # ----- Line Numbers/Wrap/Highlight -----
    {
      mode = "n";
      key = "<leader>ul";
      action = ":lua ToggleLineNumber()<cr>";
      options = {
        silent = true;
        desc = "Toggle Line Numbers";
      };
    }

    {
      mode = "n";
      key = "<leader>uL";
      action = ":lua ToggleRelativeLineNumber()<cr>";
      options = {
        silent = true;
        desc = "Toggle Relative Line Numbers";
      };
    }

    {
      mode = "n";
      key = "<leader>uw";
      action = ":lua ToggleWrap()<cr>";
      options = {
        silent = true;
        desc = "Toggle Line Wrap";
      };
    }

    {
      mode = "v";
      key = "J";
      action = ":m '>+1<CR>gv=gv";
      options = {
        silent = true;
        desc = "Move up when line is highlighted";
      };
    }

    {
      mode = "v";
      key = "K";
      action = ":m '<-2<CR>gv=gv";
      options = {
        silent = true;
        desc = "Move down when line is highlighted";
      };
    }

    {
      mode = "n";
      key = "J";
      action = "mzJ`z";
      options = {
        silent = true;
        desc = "Allow cursor to stay in the same place after appeding to current line";
      };
    }

    {
      mode = "v";
      key = "<";
      action = "<gv";
      options = {
        silent = true;
        desc = "Indent while remaining in visual mode.";
      };
    }

    {
      mode = "v";
      key = ">";
      action = ">gv";
      options = {
        silent = true;
        desc = "Indent while remaining in visual mode.";
      };
    }

    {
      mode = "n";
      key = "<C-d>";
      action = "<C-d>zz";
      options = {
        silent = true;
        desc = "Allow <C-d> and <C-u> to keep the cursor in the middle";
      };
    }

    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
      options = {
        desc = "Allow C-d and C-u to keep the cursor in the middle";
      };
    }

    # ----- Remap for dealing with word wrap and adding jumps to the jumplist. -----
    {
      mode = "n";
      key = "j";
      action.__raw = "
        [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']]
      ";
      options = {
        expr = true;
        desc = "Remap for dealing with word wrap and adding jumps to the jumplist.";
      };
    }

    {
      mode = "n";
      key = "k";
      action.__raw = "
        [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']]
      ";
      options = {
        expr = true;
        desc = "Remap for dealing with word wrap and adding jumps to the jumplist.";
      };
    }

    {
      mode = "n";
      key = "n";
      action = "nzzzv";
      options = {
        desc = "Allow search terms to stay in the middle";
      };
    }

    {
      mode = "n";
      key = "N";
      action = "Nzzzv";
      options = {
        desc = "Allow search terms to stay in the middle";
      };
    }

    # ----- Paste stuff without saving the deleted word into the buffer -----
    {
      mode = "x";
      key = "<leader>p";
      action = "\"_dP";
      options = {
        desc = "Deletes to void register and paste over";
      };
    }

    # ----- Copy stuff to system clipboard with <leader> + y or just y to have it just in vim -----
    {
      mode = ["n" "v" "i"];
      key = "<C-c>";
      action = "\"+y";
      options = {
        # desc = "Copy to system clipboard";
      };
    }

    {
      mode = ["n" "v" "i"];
      key = "<C-C>";
      action = "\"+Y";
      options = {
        # desc = "Copy to system clipboard";
      };
    }

    # ----- Delete to void register -----
    # {
    #   mode = ["n" "v"];
    #   key = "<leader>D";
    #   action = "\"_d";
    #   options = {
    #     desc = "Delete to void register";
    #   };
    # }

    # # <C-c> instead of pressing esc just because
    # {
    #   mode = "i";
    #   key = "<C-c>";
    #   action = "<Esc>";
    # }

    # {
    #   mode = "n";
    #   key = "<C-f>";
    #   action = "!tmux new tmux-sessionizer<CR>";
    #   options = {
    #     desc = "Switch between projects";
    #   };
    # }
  ];
  extraConfigLua = ''
    local notify = require("notify")

    local function show_notification(message, level)
      notify(message, level, { title = "conform.nvim" })
    end

    function ToggleLineNumber()
    if vim.wo.number then
      vim.wo.number = false
      show_notification("Line numbers disabled", "info")
    else
      vim.wo.number = true
        vim.wo.relativenumber = false
        show_notification("Line numbers enabled", "info")
        end
        end

        function ToggleRelativeLineNumber()
        if vim.wo.relativenumber then
          vim.wo.relativenumber = false
          show_notification("Relative line numbers disabled", "info")
        else
          vim.wo.relativenumber = true
            vim.wo.number = false
            show_notification("Relative line numbers enabled", "info")
          end
        end

        function ToggleWrap()
          if vim.wo.wrap then
            vim.wo.wrap = false
            show_notification("Wrap disabled", "info")
          else
            vim.wo.wrap = true
              vim.wo.number = false
              show_notification("Wrap enabled", "info")
          end
        end

       if vim.lsp.inlay_hint then
         vim.keymap.set('n', '<leader>uh', function()
           vim.lsp.inlay_hint(0, nil)
         end, { desc = 'Toggle Inlay Hints' })
       end
  '';
}
