{ pkgs, ... }:

{
  home.file = {
    ".config/mpv/config".source = pkgs.writeText "mpv-config" ''
      alang=jpn
      slang=en

      vo=gpu
      gpu-context=x11egl
      hwdec=vaapi
      video-sync=display-resample

      vd-lavc-threads=2

      profile=gpu-hq
      scale=ewa_lanczossharp
      cscale=ewa_lanczossharp

      [smoothmotion]
      interpolation=yes
      tscale=oversample
       
      [sphinx]
      profile=smoothmotion
      tscale=box
      tscale-window=sphinx
      tscale-radius=0.8
      tscale-clamp=0.0
    '';

    ".config/mpv/input.conf".source = pkgs.writeText "mpv-input.conf" ''
      Alt+PGUP add sub-scale +0.1                       # increase subtitle font size
      Alt+PGDWN add sub-scale -0.1                      # decrease subtitle font size
       
      KP2 add sub-scale +0.1                       # increase subtitle font size
      KP1 add sub-scale -0.1                       # decrease subtitle font size
      F12 add sub-scale +0.1                       # increase subtitle font size
      F11 add sub-scale -0.1                       # decrease subtitle font size
       
      # The anime intro scrubbers
      Ctrl+RIGHT  seek  80
      Ctrl+LEFT  seek  -80
       
      PGUP seek +600
      PGDWN seek -600
       
      + add audio-delay 0.100
      = add audio-delay 0.100
      - add audio-delay -0.100
       
      s screenshot video
      S screenshot subtitles
      Alt+s screenshot window
      Alt+S screenshot each-frame
       
      Shift+RIGHT no-osd seek 1 - exact
      Shift+LEFT no-osd seek -1 - exact
      Shift+UP no-osd seek 5 - exact
      Shift+DOWN no-osd seek -5 - exact
       
      d cycle framedrop
      D cycle deinterlace
       
      P show-text "''${playlist}"
       
      alt+9 add ao-volume -1
      alt+0 add ao-volume 1
      alt+m cycle ao-mute
       
      alt+z add sub-delay -60.0
      alt+x add sub-delay 60.0
      Z add sub-delay -10.0
      X add sub-delay 10.0
       
      #ctrl+b script-binding Blackbox
      #0x2 script-binding Blackbox
    '';
  };
}
