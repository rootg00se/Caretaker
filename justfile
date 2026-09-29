cwd := `pwd`
theme := "MyTheme"

init:
    #!/usr/bin/env bash
    mkdir -p "Configs/.config/hyde/themes/{{theme}}/wallpapers"
    mkdir -p "Source/arcs"
    mkdir -p "screenshots"
    mkdir -p "refs"
install:
    #!/usr/bin/env bash
    rm -rf ~/.config/hyde/themes/{{theme}}
    env FORCE_THEME_UPDATE=true Hyde theme import "{{theme}}" "{{cwd}}" || hydectl theme import --name "{{theme}}" --url "{{cwd}}" || ~/HyDE/Scripts/themepatcher.sh "{{theme}}" "{{cwd}}"
    # BUG: sometimes when imported locally, Configs folder is not copied over
    mkdir -p ~/.config/hyde/themes/{{theme}}
    cp -r Configs/.config/hyde/themes/{{theme}}/. ~/.config/hyde/themes/{{theme}}/.
copy-theme:
    #!/usr/bin/env bash
    just reset
    just init
    selected_theme=$(ls ~/.config/hyde/themes | fzf)
    if [ -z "$selected_theme" ]; then
        echo "No theme selected"
        exit 1
    fi
    cp -r ~/.config/hyde/themes/"$selected_theme"/. {{cwd}}/Configs/.config/hyde/themes/{{theme}}/.
    echo "Note this did not copy Source/arcs, this will have to be done manually"
gen-dcol:
    #!/usr/bin/env bash
    mkdir -p {{cwd}}/refs
    cp $HOME/.cache/hyde/wall.dcol {{cwd}}/refs/theme.dcol
gen-hypr:
    #!/usr/bin/env bash
    mkdir -p {{cwd}}/refs
    cp $HOME/.config/hypr/themes/theme.conf {{cwd}}/refs/hypr.theme
    echo '$HOME/.config/hypr/themes/theme.conf|> $HOME/.config/hypr/themes/colors.conf' | cat - {{cwd}}/refs/hypr.theme > temp && mv temp {{cwd}}/refs/hypr.theme
gen-waybar:
    #!/usr/bin/env bash
    mkdir -p {{cwd}}/refs
    cp $HOME/.config/waybar/theme.css {{cwd}}/refs/waybar.theme
    echo '$HOME/.config/waybar/theme.css|${scrDir}/wbarconfgen.sh' | cat - {{cwd}}/refs/waybar.theme > temp && mv temp {{cwd}}/refs/waybar.theme
gen-rofi:
    #!/usr/bin/env bash
    mkdir -p {{cwd}}/refs
    cp $HOME/.config/rofi/theme.rasi {{cwd}}/refs/rofi.theme
    echo '$HOME/.config/rofi/theme.rasi' | cat - {{cwd}}/refs/rofi.theme > temp && mv temp {{cwd}}/refs/rofi.theme
gen-kvantum:
    #!/usr/bin/env bash
    mkdir -p {{cwd}}/refs/kvantum
    cp $HOME/.config/Kvantum/wallbash/wallbash.svg {{cwd}}/refs/kvantum/kvantum.theme
    cp $HOME/.config/Kvantum/wallbash/wallbash.kvconfig {{cwd}}/refs/kvantum/kvconfig.theme
    echo '$HOME/.config/Kvantum/wallbash/wallbash.svg' | cat - {{cwd}}/refs/kvantum/kvantum.theme > temp && mv temp {{cwd}}/refs/kvantum/kvantum.theme
    echo '$HOME/.config/Kvantum/wallbash/wallbash.kvconfig' | cat - {{cwd}}/refs/kvantum/kvconfig.theme > temp && mv temp {{cwd}}/refs/kvantum/kvconfig.theme
gen-kitty:
    #!/usr/bin/env bash
    mkdir -p {{cwd}}/refs
    cp $HOME/.config/kitty/theme.conf {{cwd}}/refs/kitty.theme
    echo '$HOME/.config/kitty/theme.conf|killall -SIGUSR1 kitty' | cat - {{cwd}}/refs/kitty.theme > temp && mv temp {{cwd}}/refs/kitty.theme
gen-gtk4:
    #!/usr/bin/env bash
    mkdir -p {{cwd}}/refs/gtk-4.0
    cp $HOME/.themes/Wallbash-Gtk/gtk-4.0/*.css {{cwd}}/refs/gtk-4.0/
gen-all:
    just gen-dcol
    just gen-hypr
    just gen-waybar
    just gen-rofi
    just gen-kvantum
    just gen-kitty
set-wall:
    #!/usr/bin/env bash
    selected_wallpaper=$(ls {{cwd}}/Configs/.config/hyde/themes/{{theme}}/wallpapers | fzf)
    if [ -z "$selected_wallpaper" ]; then
        echo "No wallpaper selected"
        exit 1
    fi
    rm -f {{cwd}}/Configs/.config/hyde/themes/{{theme}}/wall.set
    ln -s {{cwd}}/Configs/.config/hyde/themes/{{theme}}/wallpapers/"$selected_wallpaper" {{cwd}}/Configs/.config/hyde/themes/{{theme}}/wall.set
reset:
    #!/usr/bin/env bash
    read -p "Are you sure you want to reset the theme structure? This will delete all your current theme files. (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo "Reset cancelled"
        exit 1
    fi

    rm -rf ./Configs
    rm -rf ./Source
    rm -rf ./screenshots
    rm -rf ./refs
