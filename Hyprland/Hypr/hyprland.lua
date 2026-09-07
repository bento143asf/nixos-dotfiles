-- VARIAVEIS VISUAIS (MATUGEN / BASE16)
local GAPS_INNER = 10
local GAPS_OUTER = 25
local BORDERS = 2
local CORNERS = 5

local BASE00 = "111216"
local BASE01 = "1c1d24"
local BASE03 = "595959"
local BASE0A = "7fbae4"
local BASE0B = "5074be" -- Substitui o ciano antigo pelo Azul Royal (#5074be)
local BASE0C = "7eb7e2" -- Substitui o verde neon pelo Azul Claro NixOS (#7eb7e2)
local BASE0E = "5271ff"
local BASE07 = "ffffff"
local BASE08 = "ff5555"
local BASE09 = "ffb86c"

-- MONITORES
hl.monitor({
    output   = "",
    mode     = "highrr",
    position = "auto",
    scale    = "1",
})

-- PROGRAMAS PADRÃO
local terminal    = "kitty"
local fileManager = "dolphin"

-- INICIALIZAÇÃO AUTOMÁTICA (AUTOSTART DEFINITIVO)
hl.on("hyprland.start", function () 
    hl.exec_cmd("hyprctl setcursor WhiteSur-cursors 24") 
    
    hl.exec_cmd("wal -i ~/Pictures/Wallpapers/nord.jpg")
    hl.exec_cmd("brightnessctl set 100%")
    hl.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.50")
    
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("hyprctl keyword windowrulev2 'blur, class:^(kitty)$'")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waypaper --restore")
end)

-- VARIÁVEIS DE AMBIENTE (TEMA ESCURO)
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- APARÊNCIA E COMPORTAMENTO
hl.config({
    general = {
        gaps_in     = GAPS_INNER,
        gaps_out    = GAPS_OUTER,
        border_size = BORDERS,

        col = {
            active_border = {
                colors = {
                    "rgba(00000000)",
                    "rgba(00000000)",
                },
                angle = 45,
            },
            inactive_border = {
                colors = {
                    "rgba(00000000)",
                    "rgba(00000000)",
                },
                angle = 90,
            },
            nogroup_border_active = {
                colors = {
                    "rgba(00000000)",
                    "rgba(00000000)",
                },
                angle = 45,
            },
            nogroup_border = {
                colors = {
                    "rgba(00000000)",
                    "rgba(00000000)",
                },
                angle = 45,
            },
        },

        no_focus_fallback = true,
        resize_on_border  = true,
    },

    decoration = {
        rounding = CORNERS,
  
        active_opacity     = 1.0,
        inactive_opacity   = 0.8,
        fullscreen_opacity = 1.0,

        dim_inactive = false,
        dim_strength = 0.25,
        dim_special  = 0.2,
        dim_around   = 0.4,

        blur = {
            enabled            = true,
            size               = 10,
            passes             = 3,
            ignore_opacity     = true,
            new_optimizations  = true,
            xray               = false,
            noise              = 0.03,
            special            = false,
            popups             = true,
            popups_ignorealpha = 0.2,
        },

        shadow = { 
            enabled        = true,
            range          = 20,   
            render_power   = 4,
            sharp          = false,
            color          = "rgba(00000077)", 
            color_inactive = "rgba(00000044)", 
            scale          = 1.0,
        },

        glow = {
            enabled        = false,
            range          = 10,
            render_power   = 3,
            color          = "rgba(" .. BASE07 .. "ee)",
            color_inactive = "rgba(00000000)",
        },
    },

    animations = {
        enabled = true,
        workspace_wraparound = false,
    },
})

-- CURVAS DE ANIMAÇÃO
hl.curve("overshot"    , { type = "bezier" , points = { {0.05 , 0.9} , {0.1  , 1.1  } } })
hl.curve("softSnap"    , { type = "bezier" , points = { {0.4  , 0  } , {0.2  , 1    } } })
hl.curve("fluent"      , { type = "bezier" , points = { {0.0  , 0.0} , {0.2  , 1.0  } } })
hl.curve("linear"      , { type = "bezier" , points = { {0    , 0  } , {1    , 1    } } })
hl.curve("almostLinear", { type = "bezier" , points = { {0.5  , 0.5} , {0.75 , 1    } } })
hl.curve("quick"       , { type = "bezier" , points = { {0.15 , 0  } , {0.1  , 1    } } })
hl.curve("smoothIn"    , { type = "bezier" , points = { {0.25 , 1  } , {0.5  , 1    } } })
hl.curve("smoothOut"   , { type = "bezier" , points = { {0.36 , 0  } , {0.66 , -0.56} } })

-- ease in
hl.curve("easeInSine"  , { type = "bezier", points = { {0.12 , 0}, {0.39 , 0    } } })
hl.curve("easeInQuad"  , { type = "bezier", points = { {0.11 , 0}, {0.5  , 0    } } })
hl.curve("easeInCubic" , { type = "bezier", points = { {0.32 , 0}, {0.67 , 0    } } })
hl.curve("easeInQuart" , { type = "bezier", points = { {0.5  , 0}, {0.75 , 0    } } })
hl.curve("easeInQuint" , { type = "bezier", points = { {0.64 , 0}, {0.78 , 0    } } })
hl.curve("easeInExpo"  , { type = "bezier", points = { {0.7  , 0}, {0.84 , 0    } } })
hl.curve("easeInCirc"  , { type = "bezier", points = { {0.55 , 0}, {1    , 0.45 } } })
hl.curve("easeInBack"  , { type = "bezier", points = { {0.36 , 0}, {0.66 , -0.56} } })

-- ease out
hl.curve("easeOutSine" , { type = "bezier", points = { {0.61 , 1   } , {0.88 , 1} } })
hl.curve("easeOutQuad" , { type = "bezier", points = { {0.5  , 1   } , {0.89 , 1} } })
hl.curve("easeOutCubic", { type = "bezier", points = { {0.33 , 1   } , {0.68 , 1} } })
hl.curve("easeOutQuart", { type = "bezier", points = { {0.25 , 1   } , {0.5  , 1} } })
hl.curve("easeOutQuint", { type = "bezier", points = { {0.22 , 1   } , {0.36 , 1} } })
hl.curve("easeOutExpo" , { type = "bezier", points = { {0.16 , 1   } , {0.3  , 1} } })
hl.curve("easeOutCirc" , { type = "bezier", points = { {0    , 0.55} , {0.45 , 1} } })
hl.curve("easeOutBack" , { type = "bezier", points = { {0.34 , 1.56} , {0.64 , 1} } })

-- ease in-out
hl.curve("easeInOutSine"  , { type = "bezier", points = { {0.37 , 0   } , {0.63 , 1   } } })
hl.curve("easeInOutQuad"  , { type = "bezier", points = { {0.45 , 0   } , {0.55 , 1   } } })
hl.curve("easeInOutCubic" , { type = "bezier", points = { {0.65 , 0   } , {0.35 , 1   } } })
hl.curve("easeInOutQuart" , { type = "bezier", points = { {0.76 , 0   } , {0.24 , 1   } } })
hl.curve("easeInOutQuint" , { type = "bezier", points = { {0.83 , 0   } , {0.17 , 1   } } })
hl.curve("easeInOutExpo"  , { type = "bezier", points = { {0.87 , 0   } , {0.13 , 1   } } })
hl.curve("easeInOutCirc"  , { type = "bezier", points = { {0.85 , 0   } , {0.15 , 1   } } })
hl.curve("easeInOutBack"  , { type = "bezier", points = { {0.68 , -0.6} , {0.32 , 1.6 } } })

-- CONFIGURAÇÃO DAS ANIMAÇÕES
hl.animation({ leaf = "windows"             , enabled = true , speed = 7 , bezier = "easeInOutQuint" })
hl.animation({ leaf = "windowsIn"           , enabled = true , speed = 7 , bezier = "easeInOutQuint" , style = "popin 95%" })
hl.animation({ leaf = "windowsOut"          , enabled = true , speed = 5 , bezier = "easeInOutQuint" })
hl.animation({ leaf = "windowsMove"         , enabled = true , speed = 4 , bezier = "softSnap" })

hl.animation({ leaf = "layers"              , enabled = true , speed = 5 , bezier = "easeInOutQuint" , style = "popin 95%" })
hl.animation({ leaf = "layersIn"            , enabled = true , speed = 4 , bezier = "easeInOutQuint" , style = "popin 95%" })
hl.animation({ leaf = "layersOut"           , enabled = true , speed = 7 , bezier = "easeInOutQuint" , style = "popin 95%" })

hl.animation({ leaf = "fade"                , enabled = true , speed = 5 , bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeIn"              , enabled = true , speed = 5 , bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeOut"             , enabled = true , speed = 7 , bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeSwitch"          , enabled = true , speed = 5 , bezier = "easeInOutQuint" })
hl.animation({ leaf = "fadeShadow"          , enabled = true , speed = 5 , bezier = "easeInOutQuint" })
hl.animation({ leaf = "fadeDim"             , enabled = true , speed = 7 , bezier = "easeInOutQuint" })
hl.animation({ leaf = "fadeLayers"          , enabled = true , speed = 5 , bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeLayersIn"        , enabled = true , speed = 5 , bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeLayersOut"       , enabled = true , speed = 7 , bezier = "easeOutQuint" })

hl.animation({ leaf = "border"              , enabled = true , speed = 7  , bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle"         , enabled = true , speed = 15 , bezier = "easeOutBack" })

hl.animation({ leaf = "workspaces"          , enabled = true , speed = 7 , bezier = "easeOutQuint" , style = "slidefade 10%" })
hl.animation({ leaf = "workspacesIn"        , enabled = true , speed = 7 , bezier = "easeOutQuint" , style = "slidefade 10%" })
hl.animation({ leaf = "workspacesOut"       , enabled = true , speed = 5 , bezier = "easeOutQuint" , style = "slidefade 10%" })
hl.animation({ leaf = "specialWorkspace"    , enabled = true , speed = 7 , bezier = "easeOutQuint" , style = "slidefadevert -10%" })
hl.animation({ leaf = "specialWorkspaceIn"  , enabled = true , speed = 7 , bezier = "easeOutQuint" , style = "slidefadevert -10%" })
hl.animation({ leaf = "specialWorkspaceOut" , enabled = true , speed = 7 , bezier = "easeOutQuint" , style = "slidefadevert -10%" })

-- LAYOUTS DO GERENCIADOR DE JANELAS
hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

-- PREFERÊNCIAS DO SISTEMA (MISC)
hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
        disable_splash_rendering = true,
    },
})

disable_splash_rendering = true;

-- CONFIGURAÇÃO DE TECLADO (ABNT2 BRASIL)
hl.config({
    input = {
        kb_layout  = "br",
        kb_model   = "abnt2",
        kb_variant = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- GESTOS DO TOUCHPAD
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- CONFIGURAÇÃO DE ATALHOS (KEYBINDINGS)
local mainMod = "SUPER"

-- Aplicativos e Menu
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("quickshell -c launcher"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("waypaper"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind("F11", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + V", function()
    local window = hl.get_active_window()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    if window and not window.floating then
        hl.dispatch(hl.dsp.exec_raw("resizeactive exact 1000 700"))
        hl.dispatch(hl.dsp.window.center())
    end
end)

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))

-- Fn + F1 (Mutar Volume)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
-- Fn + F2 (Diminuir volume de 2% em 2%)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { e = true })
-- Fn + F3 (Aumentar volume de 2% em 2%)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { e = true })
-- Fn + F6 (Diminuir brilho da tela)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { e = true })
-- Fn + F7 (Aumentar brilho da tela)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"), { e = true })
-- Fn + F10 (Print por região para recortar/redimensionar por padrão)
hl.bind("XF86Search", hl.dsp.exec_cmd("grimblast copysave area ~/Imagens/$(date +'%Y-%m-%d_%H-%M-%S').png"))

-- Controles do Mouse para janelas destacadas (Segurando a tecla Windows)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Win + Shift + Setinhas: Mover posições das janelas entre si
hl.bind(mainMod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "down" }))

-- Win + Setinhas normais: Mudar o foco visual entre as janelas
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "down" }))

-- GERENCIAMENTO DE WORKSPACES (ÁREAS DE TRABALHO)
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
