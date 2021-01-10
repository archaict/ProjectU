{ config, pkgs, lib, ... }:

{
#  {{{ [I3WM] ────── A lightweight and easy to use window manager 

#  xsession.windowManager = {
#   i3 = {
#     enable = true;
#     config = {
#       modifier = mod;
#       fonts = ["Iosevka SemiBold, FontAwesome 10"];
#       bars = [];
#       gaps = {
#         inner = 14;
#         outer = 4;
#       };
#       window.border = 1;
#       startup = [
#         {
#           command = "exec i3-msg workspace ${ws1}";
#           always = true;
#           notification = false;
#         } {
#           command = "systemctl --user restart polybar.service";
#           always = true;
#           notification = false;
#         } {
#           command = "${pkgs.nitrogen}/bin/nitrogen --restore";
#           always  = true;
#           notification = false;
#         } {
#           command = "${pkgs.picom}/bin/picom -b";
#           always  = true;
#           notification = false;
#         }
#       ];

#       keybindings = lib.mkOptionDefault{

#         "${mod}+w"      = "kill";
#         "${mod}+c"      = "restart";
#         "${mod}+f"      = "fullscreen toggle";

#         "${mod}+i"      = "exec ${pkgs.firefox}/bin/firefox";
#         "${mod}+space"  = "exec ${pkgs.dmenu}/bin/dmenu_run";
#         "${mod}+Return" = "exec ${pkgs.kitty}/bin/kitty";

#         "${mod}+a" = "workspace ${ws1}";"${mod}+1" = "workspace ${ws1}";
#         "${mod}+s" = "workspace ${ws2}";"${mod}+2" = "workspace ${ws2}";
#         "${mod}+d" = "workspace ${ws3}";"${mod}+3" = "workspace ${ws3}";
#         "${mod}+p" = "workspace ${ws4}";"${mod}+4" = "workspace ${ws4}";

#         "${mod}+Shift+a" =
#           "move container to workspace ${ws1}";
#         "${mod}+Shift+s" =
#           "move container to workspace ${ws2}";
#         "${mod}+Shift+d" =
#           "move container to workspace ${ws3}";
#         "${mod}+Shift+p" =
#           "move container to workspace ${ws4}";

#         "${mod}+Shift+1" =
#           "move container to workspace ${ws1}";
#         "${mod}+Shift+2" =
#           "move container to workspace ${ws2}";
#         "${mod}+Shift+3" =
#           "move container to workspace ${ws3}";
#         "${mod}+Shift+4" =
#           "move container to workspace ${ws4}";

#         "${mod}+h" = "focus left";
#         "${mod}+j" = "focus down";
#         "${mod}+k" = "focus up";
#         "${mod}+l" = "focus right";

#         "${mod}+Shift+h" = "move left";
#         "${mod}+Shift+j" = "move down";
#         "${mod}+Shift+k" = "move up";
#         "${mod}+Shift+l" = "move right";

#         "XF86AudioMute"         = "exec pactl set-sink-mute 0 toggle";
#         "XF86AudioLowerVolume"  = "exec pactl -- set-sink-volume 0 -5%";
#         "XF86AudioRaiseVolume"  = "exec pactl -- set-sink-volume 0 +5%";
#         "XF86MonBrightnessDown" = "exec light -A 1";
#         "XF86MonBrightnessUp"   = "exec light -U 1";

#         "${mod}+Shift+e" =
#           "exec i3-nagbar -t warning -m 'exit i3?' -b 'Y' 'i3-msg exit'";
#         };
#       };
#     };

#                                                                  }}}  #
}