{ pkgs, ... }:
{
  environment = {
    shellAliases.x = "hx";
  };
  environment.systemPackages = [
    pkgs.nixfmt-rfc-style
    pkgs.nil
    pkgs.clang
    pkgs.clang-tools
  ];

  home-manager.sharedModules = [
    {

      programs.helix = {
        enable = true;
        defaultEditor = true;

        settings = {
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

        themes = {
          stylix-custom = {
            "ui.linenr" = "#ffb757";
            "ui.virtual.whitespace" = "#231f20";
          };
        };

      };

    }
  ];

}
