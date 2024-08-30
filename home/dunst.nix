{ pkgs, ... }:

{
  services.dunst.enable = true;
  services.dunst.settings = {
    global = {
      # font = "";

      # Allow a small subset of html markup
      markup = "yes";
      plain_text = "no";

      # The format of the message
      format = "<b>%s</b>\\n%b";

      # Alignment of message text
      alignment = "center";

      # Split notifications into multiple lines
      word_wrap = "yes";

      # Ignore newlines '\n' in notifications.
      ignore_newline = "no";

      # Hide duplicate's count and stack them
      stack_duplicates = "yes";
      hide_duplicates_count = "yes";

      # The geometry of the window
      geometry = "420x50-15+49";

      # Shrink window if it's smaller than the width
      shrink = "no";

      # Don't remove messages, if the user is idle
      idle_threshold = 0;

      # Which monitor should the notifications be displayed on.
      monitor = 0;

      # The height of a single line. If the notification is one line it will be
      # filled out to be three lines.
      line_height = 3;

      # Draw a line of "separatpr_height" pixel height between two notifications
      separator_height = 2;

      # Padding between text and separator
      padding = 6;
      horizontal_padding = 6;

      # Define a color for the separator
      separator_color = "frame";

      # dmenu path
      dmenu = "${pkgs.dmenu}/bin/dmenu -l 40";

      # Browser for opening urls in context menu.
      browser = "/run/current-system/sw/bin/librewolf -new-tab";

      # Align icons left/right/off
      icon_position = "left";
      max_icon_size = 80;

      # Define frame size and color
      frame_width = 3;
      frame_color = "#8EC07C";
    };

    shortcuts = {
      close = "mod4+semicolon";
      close_all = "mod4+colon";
      history = "mod4+grave";
      context = "mod4+apostrophe";
    };

    urgency_low = {
      frame_color = "#3B7C87";
      foreground = "#3B7C87";
      background = "#191311";
      timeout = 4;
    };
    urgency_normal = {
      frame_color = "#5B8234";
      foreground = "#5B8234";
      background = "#191311";
      timeout = 6;
    };

    urgency_critical = {
      frame_color = "#B7472A";
      foreground = "#B7472A";
      background = "#191311";
      timeout = 8;
    };
  };
}
