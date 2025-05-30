{ config, lib, pkgs, ... }:
let
  # Config extraction
  cfg = config.customHomeProfile.GUI;
  hardwareCfg = config.systemHardwareInfo;
  linuxCfg = config.linuxInfo;

  fontStrFn = fontName: fontStyle: fontSize: ''${fontName}:${fontStyle}:size=${builtins.toString fontSize}'';
  mesloNF = fontStrFn "MesloLGS NF";
  # Font settings
  font_header1 = mesloNF "bold" 12;
  font_header3 = mesloNF "bold" 9;
  font_header3_unbold = mesloNF "bold" 9;
  font_para = mesloNF "normal" 9;

  # TODO: make this whole config more generalised (i.e. make hardware configuration a setting to be done *BEFORE* applying your first home manager generation)

  # Colour settings
  colour_pinkred = "c6396b";
  colour_orange = "fc8c3b";
  colour_yellow = "f9e30f";
  colour_blue = "4291e2";
  colour_dark_blue = "161925";
  colour_teal = "3bf4bb";

  short_interval_secs = "5";
  medium_interval_secs = "180";
  long_interval_secs = "300";

  # Conky templated strings

  # TODO: only support arch for now
  conky_package_update_section = if (!pkgs.stdenv.isLinux || linuxCfg.distro == null || linuxCfg.distro != "arch") then "#" else
  ''
    #Package Section
    ''${color4}''${hr}''${color}
    ''${alignc}''${font ${font_header3_unbold}}''${color6}Packages To Update''${font}''${color}
    ''${goto 10}''${font ${font_header3_unbold}}Packages:''${color2}''${alignr 10}''${execi ${medium_interval_secs} checkupdates | wc -l}''${font}''${color}
    ''${goto 10}''${font ${font_header3_unbold}}AUR Packages:''${color2}''${alignr 10}''${execi ${medium_interval_secs} yay -Qua | wc -l}''${color}'';

  conky_text_battery_power_section =
    let
      conky_power_texts = lib.imap0
        (
          idx: batteryName:
            let
              idxStr = builtins.toString idx;
              powerSupply = metricName:
                ''cat /sys/class/power_supply/${batteryName}/${metricName}'';

              powerSupplyUeventRatio = metric1: metric2: units: reason:
                ''${powerSupply "uevent"} | awk -F= 'BEGIN { one=0; two=0; } $1 == "${metric1}" { one=$2 } $1 == "${metric2}" { two=$2 } END { if (two > 0) { printf "%.2f${units}", one / two } else { print "${reason}" } }' '';
            in
            ''
              ##------------Battery${idxStr}-------------##
              ''${alignc}''${color6}''${font ${font_header3_unbold}}''${exec ${powerSupply "model_name"}} ''${exec ${powerSupply "technology"}} ''${exec ${powerSupply "type"}}''${font}''${color}
              ''${goto 10}''${color}Capacity: ''${color6}''${execi ${short_interval_secs} ${powerSupply "capacity"}}%''${color}''${goto 170}''${color}Cap. Lvl: ''${alignr 10}''${color6}''${execi ${short_interval_secs} ${powerSupply "capacity_level"}}''${color}
              ''${goto 10}''${color}Battery Life: ''${color6}''${execi ${short_interval_secs} ${powerSupplyUeventRatio "POWER_SUPPLY_ENERGY_NOW" "POWER_SUPPLY_POWER_NOW" " Hrs" "N/A"}}''${color}''${goto 170}''${color}Usage: ''${alignr 10}''${color6}''${execi ${short_interval_secs} ${powerSupply "power_now"} | awk '{printf "%.2f", $1 / 1000000}'}W''${color}
              ''${goto 10}''${color}Status: ''${color6}''${execi ${short_interval_secs} ${powerSupply "status"}}''${color}''${color}''${goto 170}''${color}Cycle Counts: ''${alignr 10}''${color6}''${execi ${long_interval_secs} ${powerSupply "cycle_count"}}''${color}''
        )
        hardwareCfg.batteries;

      resultStr = if (builtins.length conky_power_texts) == 0 then "#" else ''
        #
        # Power Section
        ''${color4}''${hr}''${color}
        ${builtins.concatStringsSep "\n" conky_power_texts}'';
    in
    resultStr;

  # Left and right column of CPU core details
  conky_each_cpu_core_str = { cNum1, cNum2 ? null }:
    let
      # The CPU Header and bar footer take up one half of the column, this is why we need two 
      cpu_header = cNum:
        let
          cNumStr = builtins.toString cNum;
          # If its an intel core, it should have the individual coretemps listed under the coretemps kernel module
          # Ryzen doesnt and only has the average temperature
          gotoJump = if (cNum == cNum1) then "100" else "250";
          individualCoreTemp =
            if
              (hardwareCfg.cpuMake == "ryzen" || hardwareCfg.cpuMake == null)
            then "" else "\${goto ${gotoJump}}\${color1}\${execi ${short_interval_secs} ${pkgs.lm_sensors}/bin/sensors |grep 'Core ${builtins.toString (cNum - 1)}:'|awk '{print $3}'}";
        in
        "\${color}C${cNumStr}: \${color2}\${cpu cpu${cNumStr}}%${individualCoreTemp}\${color}";

      cpu_bar_footer = cNum:
        let
          cNumStr = builtins.toString cNum;
        in
        "\${color5}\${cpugraph cpu${cNumStr} 20,140 ${colour_orange} ${colour_pinkred} -t}\${color}";

      line_one_parts = [ "\${goto 10}" (cpu_header cNum1) ] ++ (pkgs.lib.optionals (cNum2 != null) [ "\${goto 170}" (cpu_header cNum2) ]);
      line_two_parts = [ "\${goto 10}" (cpu_bar_footer cNum1) ] ++ (pkgs.lib.optionals (cNum2 != null) [ "\${alignr 10}" (cpu_bar_footer cNum2) ]);
    in
    ''
      ${builtins.concatStringsSep "" line_one_parts}
      ${builtins.concatStringsSep "" line_two_parts}'';

  conky_avg_cpu_temp_str = if hardwareCfg.cpuMake == null then "#" else
  let
    after_pipe_cmd = if hardwareCfg.cpuMake == "ryzen" then "grep 'Tctl:' | sed -e 's/  :\s*//'" else "grep 'Package id' | awk '{print $4}'";
  in
  "\${goto 10}\${color}Average Temperature: \${alignr 10}\${color6}\${execi ${short_interval_secs} ${pkgs.lm_sensors}/bin/sensors | ${after_pipe_cmd}}\${color}";

  conky_text_gpu_section =
    let
      conky_gpu_texts = lib.imap0
        (
          idx: gpu:
            let
              idxStr = builtins.toString idx;
              amdgpuRadeontopExtract = metricName: units: selectedUnitIndex:
                let
                  # i.e. if units passed into it is ["%" "ghz"], then the resultant string will be `[.0-9]\{1,6\}% [.0-9]\{1,6\}ghz`
                  unitsToGrep = builtins.concatStringsSep " " (builtins.map (x: ''[.0-9]\{1,6\}'' + x) units);
                  # radeontop -b 0b -l1 -d - | grep -o "mclk [.0-9]\{1,6\}% [.0-9]\{1,6\}ghz" | sed -e 's/mclk //'  | 
                in
                ''${pkgs.radeontop}/bin/radeontop -b ${gpu.pcie_bus_id} -l1 -d - | grep -o "${metricName} ${unitsToGrep}" | sed -e 's/${metricName} //' | cut -d " " -f ${builtins.toString(selectedUnitIndex + 1)} | sed -e 's/${builtins.elemAt units selectedUnitIndex}$//' '';

              nvidiaSmiExtract = metricName:
                ''nvidia-smi --query-gpu=pci.bus_id,${metricName} --format=csv,noheader | grep ':${gpu.pcie_bus_id}:${gpu.pcie_device_id}.0' | awk -F', ' '{print $2}' '';

              sedRemoveUnitSuffix = units: "| sed -e 's/\s*${units}$//' | xargs";

              gpuName =
                if gpu.name != null then gpu.name
                else if gpu.driver == "nvidia" then ''''${exec ${nvidiaSmiExtract "gpu_name"}}''
                else "";

              currentPowerCMD =
                if gpu.driver == "amdgpu" then "${pkgs.lm_sensors}/bin/sensors ${gpu.driver}-pci-${gpu.pcie_bus_id}${gpu.pcie_device_id} | grep 'PPT:' | awk '{print $2}'"
                else if gpu.driver == "nvidia" then ''${nvidiaSmiExtract "power.draw"} ${sedRemoveUnitSuffix "W"}''
                else "";
              maxPowerCMD =
                if gpu.driver == "amdgpu" then "${pkgs.lm_sensors}/bin/sensors ${gpu.driver}-pci-${gpu.pcie_bus_id}${gpu.pcie_device_id} | grep 'PPT:' | sed -e 's/.*(cap = //' -e  's/ W)$//'"
                else if gpu.driver == "nvidia" then ''${nvidiaSmiExtract "power.max_limit"}${sedRemoveUnitSuffix "W"}''
                else "";
              loadCMD =
                if gpu.driver == "amdgpu" then "${amdgpuRadeontopExtract "gpu" ["%"] 0}"
                else if gpu.driver == "nvidia" then ''${nvidiaSmiExtract "utilization.gpu"}${sedRemoveUnitSuffix "%"}''
                else "";
              vRAMCMD =
                if gpu.driver == "amdgpu" then "${amdgpuRadeontopExtract "gpu" ["%"] 0}"
                else if gpu.driver == "nvidia" then ''${nvidiaSmiExtract "utilization.memory"}${sedRemoveUnitSuffix "%"}''
                else "";
              graphicsSpeedCMD =
                if gpu.driver == "amdgpu" then "${amdgpuRadeontopExtract "sclk" ["%" "ghz"] 1}"
                else if gpu.driver == "nvidia" then ''${nvidiaSmiExtract "clocks.current.graphics"}${sedRemoveUnitSuffix "MHz"} | awk '{print $1 / 1000}' ''
                else "";
              memSpeedCMD =
                if gpu.driver == "amdgpu" then "${amdgpuRadeontopExtract "mclk" ["%" "ghz"] 1}"
                else if gpu.driver == "nvidia" then ''${nvidiaSmiExtract "clocks.current.memory"}${sedRemoveUnitSuffix "MHz"} | awk '{print $1 / 1000}' ''
                else "";
              currTempCMD =
                if gpu.driver == "amdgpu" then "${pkgs.lm_sensors}/bin/sensors ${gpu.driver}-pci-${gpu.pcie_bus_id}${gpu.pcie_device_id} | grep 'edge' | awk '{print $2}'"
                else if gpu.driver == "nvidia" then ''${nvidiaSmiExtract "temperature.gpu"} | awk '{print $1"C"}' ''
                else "";
              fanspeedCMD =
                if gpu.driver == "amdgpu" then "${pkgs.lm_sensors}/bin/sensors ${gpu.driver}-pci-${gpu.pcie_bus_id}${gpu.pcie_device_id} | grep 'fan1' | awk '{print $2 \" \" $3}'"
                else if gpu.driver == "nvidia" then ''${nvidiaSmiExtract "fan.speed"}''
                else "";
            in
            ''
              ##------------Card${idxStr}-------------##
              ''${alignc}''${font ${font_header3_unbold}}GPU${idxStr}: ''${color6}${gpuName}''${font}''${color}
              ''${goto 10}Power: ''${color6}''${execi ${short_interval_secs} ${currentPowerCMD}} W''${color}''${goto 170}Max Power: ''${color1}''${alignr 10}''${execi ${short_interval_secs} ${maxPowerCMD}} W''${color}
              ''${goto 10}GPU Load: ''${color2}''${execi ${short_interval_secs} ${loadCMD}}%''${color}''${goto 170}GPU VRAM: ''${color2}''${alignr 10}''${execi ${short_interval_secs} ${vRAMCMD}}%''${color}
              ''${goto 10}''${color5}''${execigraph ${short_interval_secs} "${loadCMD}"  20,140 ${colour_orange} ${colour_pinkred} -t}''${alignr 10}''${execigraph ${short_interval_secs} "${vRAMCMD}"  20,140 ${colour_orange} ${colour_pinkred} -t}''${color}
              ''${goto 10}GPU Spd: ''${color2}''${execi ${short_interval_secs} ${graphicsSpeedCMD}}GHz ''${color}''${goto 170}VRAM Spd: ''${alignr 10}''${color2}''${execi ${short_interval_secs} ${memSpeedCMD}}GHz''${color}
              ''${goto 10}Current Temp: ''${color1}''${execi ${short_interval_secs} ${currTempCMD}} ''${color}''${goto 170}Fan Spd: ''${alignr 10}''${color2}''${execi ${short_interval_secs} ${fanspeedCMD}}''
        )
        hardwareCfg.gpus;

      resultStr = if (builtins.length conky_gpu_texts) == 0 then "#" else ''
        #
        # GPU Section
        ''${color4}''${hr}''${color}
        ${builtins.concatStringsSep "\n" conky_gpu_texts}'';
    in
    resultStr;

  conky_text_network_section = if hardwareCfg.networkInterface == null then "#" else ''
    #
    #network
    ''${color4}''${hr}''${color}
    ''${goto 10}''${font}Internal IP: ''${color6}''${alignr 10}''${addr ${hardwareCfg.networkInterface}}''${color}
    #''${goto 10}Network''${alignr 10 10}SSID: ''${wireless_essid ${hardwareCfg.networkInterface}}''${color}
    #''${goto 10}Signal:''${goto 70}''${color}''${wireless_link_bar wlan0}''${color}''${alignr 10 10}''${wireless_link_qual_perc ${hardwareCfg.networkInterface}}%''${color}
    #''${goto 10}''${font}External: ''${font ${font_header3}}''${alignr 10 10}''${execi ${long_interval_secs} curl ipinfo.io/ip}''${color}
    ''${goto 10}''${font}Up Spd:   ''${color2}''${upspeed ${hardwareCfg.networkInterface}}''${goto 170}''${color}Down Spd: ''${alignr 10}''${color2}''${downspeed ${hardwareCfg.networkInterface}}''${color}
    ''${goto 10}Total Up: ''${color2}''${totalup ${hardwareCfg.networkInterface}}''${goto 170}''${color}Total Dn: ''${alignr 10}''${color2}''${totaldown ${hardwareCfg.networkInterface}}''${color}
    ''${goto 15}''${color5}''${upspeedgraph ${hardwareCfg.networkInterface} 20,140 ${colour_orange} ${colour_pinkred} -t}  ''${alignr 10} ''${color5}''${downspeedgraph ${hardwareCfg.networkInterface} 20,140 ${colour_orange} ${colour_pinkred} -t}'';

  conky_text_disks_section =
    let
      conky_disk_texts = lib.imap0
        (
          idx: disk:
            let
              idxStr = builtins.toString idx;
            in
            ''
              ##------------Disk${idxStr}-------------##
              ''${goto 10}''${color}${disk.name}: ''${color6}''${fs_used ${disk.mountedPath}}''${color} / ''${color2}''${fs_size ${disk.mountedPath}}''${color}''${alignr 10}Available: ''${color6}''${fs_free_perc ${disk.mountedPath}}%''${color}''
        )
        hardwareCfg.disks;

      resultStr = if (builtins.length conky_disk_texts) == 0 then "#" else ''
        #
        #Storage
        ''${color4}''${hr}''${color}
        ${builtins.concatStringsSep "\n" conky_disk_texts}'';
    in
    resultStr;
in
{
  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) (lib.mkMerge [
    {
      home.shellAliases = {
        conky_reload = "pkill -USR1 conky";
      };
      # NOTE: lohvht@27aug2022: autostart may create multiple entries of the same conky instance on auto startup if
      #       we choose to restore session on your DE.
      #       One way to circumvent this is to not allow `conky` to be restored under the desktop Autostart settings
      #       (On KDE as: Don't restore these applications)
      xdg.configFile."autostart/conky.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=conky
        Exec=${pkgs.conky}/bin/conky --daemonize --pause=30
        StartupNotify=false
        Terminal=false
      '';
      xdg.configFile."conky/conky.conf".text = ''
        conky.config = {
          alignment = 'top_right',
          use_xft = true,
          xftalpha = 0.8,
          font = '${font_para}',
          text_buffer_size = 2048,
          update_interval = 1.0,
          total_run_times = 0,
          double_buffer = true,
          no_buffers = true,
          imlib_cache_size = 0,
          cpu_avg_samples = 2,
          own_window = true,
          own_window_class = 'Conky',
          own_window_argb_visual = true,
          own_window_argb_value = 192,
          own_window_transparent = no,
          own_window_type = 'normal',
          own_window_hints = 'undecorated,below,skip_taskbar,sticky,skip_pager',
          own_window_colour = '000000',
          draw_shades = no,
          default_shade_color = '000000',
          draw_outline = no,
          default_outline_color = '000000',
          draw_borders = no,
          gap_x = 10,
          gap_y = 10,
          minimum_height = 5,
          minimum_width = 205,
          draw_graph_borders = true,
          show_graph_scale = no,
          show_graph_range = no,
          short_units = yes,
          override_utf8_locale = yes,
          uppercase = no,
          default_color = 'ffffff',
          color1 = '${colour_pinkred}',
          color2 = '${colour_orange}',
          color3 = '${colour_yellow}',
          color4 = '${colour_blue}',
          color5 = '${colour_dark_blue}',
          color6 = '${colour_teal}',
          use_spacer = none,
          hddtemp_host = "127.0.0.1",
          hddtemp_port = "7634",
        }
        conky.text = [[
        #
        #Title Section
        ''${goto 10}''${font ${font_header1}}${config.home.username}'s Desktop ''${alignr 10}''${color2}''${time %r}
        ''${font ${font_header3}}''${color4}''${hr}''${color}
        # day/time
        ''${font ${font_header3_unbold}}''${goto 10}Date:''${color2}''${alignr 10}''${time %d %B %Y}''${color}
        ''${goto 10}Host:''${color2}''${alignr 10}''${exec hostname}''${color}
        ''${goto 10}Kernel:''${color2}''${alignr 10}''${kernel}''${color}
        ''${goto 10}Uptime:''${color2}''${alignr 10}$uptime''${font}
        ${conky_package_update_section}
        ${conky_text_battery_power_section}
        #
        #Processor section
        ''${color4}''${hr}''${color}
        ''${alignc}''${color6}''${font ${font_header3_unbold}}''${exec cat /proc/cpuinfo|grep 'model name'|sed -e 's/model name.*: //' -e 's/ @ .*//' | uniq }''${color} @ ''${color6}''${freq_g 1}GHz''${font}
        ${conky_avg_cpu_temp_str}
        ''${goto 10}''${color}Threads/Cores: ''${alignr 10}''${color6}''${exec cat /proc/cpuinfo | grep 'core id' | wc -l}''${color}''${font}
        ''${goto 10}''${color}Active Governor: ''${alignr 10}''${color6}''${execi ${short_interval_secs} cut -b 1-20 /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor}''${color}''${font}
        # top processes
        ''${goto 10}''${color}Current Average CPU Load: ''${alignr 10}''${color6}''${cpu cpu0}%
        ''${goto 15}''${color5}''${cpugraph 20,280 ${colour_orange} ${colour_pinkred} -t}
        ''${goto 10}''${color1}''${top name 1}''${alignc}''${color2}''${top pid 1}''${alignr 10}''${color}''${top cpu 1}%
        ''${goto 10}''${color1}''${top name 2}''${alignc}''${color2}''${top pid 2}''${alignr 10}''${color}''${top cpu 2}%
        ''${goto 10}''${color1}''${top name 3}''${alignc}''${color2}''${top pid 3}''${alignr 10}''${color}''${top cpu 3}%
        ''${goto 10}''${color1}''${top name 4}''${alignc}''${color2}''${top pid 4}''${alignr 10}''${color}''${top cpu 4}%
        ''${goto 10}''${color1}''${top name 5}''${alignc}''${color2}''${top pid 5}''${alignr 10}''${color}''${top cpu 5}%
        #
        ${conky_text_gpu_section}
        #
        #
        # top memory
        ''${color4}''${hr}''${color}
        ''${goto 10}''${color}Current RAM Usage: ''${alignr 10}''${color6}''${memperc}%
        ''${goto 15}''${color5}''${memgraph 20,280 ${colour_orange} ${colour_pinkred} -t}
        ''${goto 10}''${color1}''${top_mem name 1}''${alignc}''${color2}''${top_mem pid 1}''${alignr 10}''${color}''${top_mem mem 1}%
        ''${goto 10}''${color1}''${top_mem name 2}''${alignc}''${color2}''${top_mem pid 2}''${alignr 10}''${color}''${top_mem mem 2}%
        ''${goto 10}''${color1}''${top_mem name 3}''${alignc}''${color2}''${top_mem pid 3}''${alignr 10}''${color}''${top_mem mem 3}%
        ''${goto 10}''${color1}''${top_mem name 4}''${alignc}''${color2}''${top_mem pid 4}''${alignr 10}''${color}''${top_mem mem 4}%
        ''${goto 10}''${color1}''${top_mem name 5}''${alignc}''${color2}''${top_mem pid 5}''${alignr 10}''${color}''${top_mem mem 5}%
        ${conky_text_network_section}
        ${conky_text_disks_section}
        ]]
      '';
    }
  ]);
}
