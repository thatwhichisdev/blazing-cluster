{ pkgs, ... }:
{
  environment = {
    shellAliases.x = "hx";
  };

  environment.systemPackages = with pkgs; [
    clang
    clang-tools
    helix
    nil
    nixfmt
    nixfmt-tree
    taplo
    yaml-language-server
  ];

  home-manager.sharedModules = [
    {
      programs.helix = {
        enable = true;
        defaultEditor = true;

        settings = {
          theme = "github_dark_high_contrast";

          editor = {
            auto-format = true;
            auto-completion = true;
            bufferline = "never";
            color-modes = false;
            cursorline = true;
            file-picker.hidden = false;
            idle-timeout = 0;
            line-number = "relative";
            text-width = 140;

            lsp = {
              display-progress-messages = true;
              display-color-swatches = true;
              display-inlay-hints = true;
            };

            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };

            statusline.mode = {
              insert = "INSERT";
              normal = "NORMAL";
              select = "SELECT";
            };

            indent-guides = {
              character = "▏";
              render = false;
            };

            whitespace.render = {
              tab = "all";
              space = "all";
            };

            whitespace.characters = {
              tab = "·";
              space = "·";
            };
          };

          keys.normal = {
            C-c = ":clipboard-yank";
            C-v = ":clipboard-paste-after";
            "C-/" = "toggle_comments";
          };
        };
      };
    }
  ];

}
