# {
#   plugins.copilot-lua = {
#     enable = true;
#     # panel = {
#     #   enabled = false;
#     #   autoRefresh = true;
#     #   keymap = {
#     #     jumpPrev = "[[";
#     #     jumpNext = "]]";
#     #     accept = "<Tab>";
#     #     refresh = "gr";
#     #     open = "<M-CR>";
#     #   };
#     #   layout = {
#     #     position = "bottom"; # | top | left | right
#     #     ratio = 0.4;
#     #   };
#     # };
#     # suggestion = {
#     #   enabled = true;
#     #   autoTrigger = true;
#     #   debounce = 75;
#     #   keymap = {
#     #     accept = "<M-l>";
#     #     acceptWord = false;
#     #     acceptLine = false;
#     #     next = "<M-]>";
#     #     prev = "<M-[>";
#     #     dismiss = "<C-]>";
#     #   };
#     # };
#     panel = {
#       enabled = false;
#     };
#     suggestion = {
#       enabled = false;
#     };
    
#     filetypes = {
#       python = true;
#       nix = true;
#       lua = true;
#       yaml = false;
#       markdown = true;
#       help = false;
#       gitcommit = false;
#       gitrebase = false;
#       hgcommit = false;
#       svn = false;
#       cvs = false;
#       # "." = false;
#     };
#     copilotNodeCommand = "node"; # Node.js version must be > 18.x
#     serverOptsOverrides = {};
#   };
# }
