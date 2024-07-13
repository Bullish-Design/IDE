{
  programs.nixvim.plugins.mini.modules.clue = {
    triggers = [
      # leader triggers
      {
        mode = "n";
        keys = "<leader>";
      }
      {
        mode = "x";
        keys = "<leader>";
      }

      # built-in completion
      {
        mode = "i";
        keys = "<C-x>";
      }

      # `g` key
      {
        mode = "n";
        keys = "g";
      }
      {
        mode = "x";
        keys = "g";
      }

      # marks
      {
        mode = "n";
        keys = "\"";
      }
      {
        mode = "n";
        keys = "`";
      }
      {
        mode = "x";
        keys = "\"";
      }
      {
        mode = "x";
        keys = "`";
      }

      # registers
      {
        mode = "n";
        keys = "\"";
      }
      {
        mode = "x";
        keys = "\"";
      }
      {
        mode = "i";
        keys = "<C-r>";
      }
      {
        mode = "c";
        keys = "<C-r>";
      }

      # window commands
      {
        mode = "n";
        keys = "<C-w>";
      }

      # `z` key
      {
        mode = "n";
        keys = "z";
      }
      {
        mode = "x";
        keys = "z";
      }
    ];

    clues = [
      # Enhance this by adding descriptions for <leader> mapping groups
      {__raw = "require('mini.clue').gen_clues.builtin_completion()";}
      {__raw = "require('mini.clue').gen_clues.g()";}
      {__raw = "require('mini.clue').gen_clues.marks()";}
      {__raw = "require('mini.clue').gen_clues.registers()";}
      {__raw = "require('mini.clue').gen_clues.windows()";}
      {__raw = "require('mini.clue').gen_clues.z()";}
    ];

    window = {
      config = {
        border = "rounded";
        width = "auto";
      };
      delay = 0;
    };
  };
}
