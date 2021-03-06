   --  ┌──────────────────────────────────────────────────────────┐ --
   --  │                        ✖ import ✖                        │ --
   --  └──────────────────────────────────────────────────────────┘ --

-- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies,copyToAll)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

-- Data
import Data.Char (isSpace, toUpper)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.Place
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

-- Layouts
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Text
import Text.Printf

-- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

   --  ┌──────────────────────────────────────────────────────────┐ --
   --  │                        ✖ config ✖                        │ --
   --  └──────────────────────────────────────────────────────────┘ --

myFont        = "xft: Iosevka Bold:regular:size=11:antialias=true:hinting=true"

myTerminal    = "kitty"
myBrowser     = "firefox "
myEditor      = myTerminal ++ " -e vim "

myBorderWidth = 0         -- BORDER --
altMask       = mod1Mask
myModMask     = mod4Mask
myFocusColor  = "#2e2e2e"
myNormColor   = "#2e2e2e"

   --  ┌──────────────────────────────────────────────────────────┐ --
   --  │                         ✖ exes ✖                         │ --
   --  └──────────────────────────────────────────────────────────┘ --


windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
          spawnOnce "nitrogen --restore &"
       -- spawnOnce "polybar -r top &"
          spawnOnce "emacsclient -c -a ''"
          spawnOnce "pkill polybar"
          spawnOnce "pkill picom && pkill picom && picom -b"
          setWMName "LG3D"

main :: IO ()
main = do
    home <- getHomeDirectory
    xmonad $ ewmh def
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
        , handleEventHook    = serverModeEventHookCmd
                               <+> serverModeEventHook
                               <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
                               <+> docksEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        } `additionalKeysP` myKeys home

   --  ┌──────────────────────────────────────────────────────────┐ --
   --  │                        ✖ layout ✖                        │ --
   --  └──────────────────────────────────────────────────────────┘ --

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

tall     = renamed [Replace "tall"]
           $ windowNavigation
           $ limitWindows 12
           $ mySpacing 4
           $ ResizableTall 1 (1/8) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ limitWindows 20 Full

myTabTheme = def { fontName            = myFont
                 , activeColor         = "#fafafa"
                 , inactiveColor       = "#2e2e2e"
                 , activeBorderColor   = "#fafafa"
                 , inactiveBorderColor = "#2e2e2e"
                 , activeTextColor     = "#2e2e2e"
                 , inactiveTextColor   = "#fafafa"
                 }

myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Iosevka:bold:size=40"
    , swn_fade              = 0.4
    , swn_bgcolor           = "#1d2021"
    , swn_color             = "#fafafa"
    }

myLayoutHook = avoidStruts $ mouseResize $ windowArrange
               $ myDefaultLayout
             where
               myDefaultLayout =     tall
                                 ||| monocle

myWorkspaces = ["01", "02", "03", "04"]

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myClickableWorkspaces :: [String]
myClickableWorkspaces = clickable . (map xmobarEscape)
               $ ["01", "02", "03", "04"]
                where
        clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..4] l,
                      let n = i ]

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     [ className =? "Mozilla Firefox"                     --> doShift ( myWorkspaces !! 1 )
     , className =? "Chromium"                            --> doShift ( myWorkspaces !! 2 )
     , className =? "VirtualBox Manager"                  --> doShift ( myWorkspaces !! 3 )
     , className =? "pop-up"                              --> doFloat
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat
     , title=? "Picture-in-Picture"                       --> doFloat
     , title=? "Picture-in-Picture"                       --> doF copyToAll

     , className =? "mpv"                                 --> doF copyToAll
     , className =? "mpv"  --> placeHook (fixed ( 0.98,0.075 )) <+> doFloat

     , className =? "vlc"                                 --> doF copyToAll
     , className =? "vlc"  --> placeHook (fixed ( 0.98,0.075 )) <+> doFloat
     ]

myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 1.0

   --  ┌──────────────────────────────────────────────────────────┐ --
   --  │                       ✖ bindings ✖                       │ --
   --  └──────────────────────────────────────────────────────────┘ --

-- KeyBindings
myKeys :: String -> [([Char], X ())]
myKeys home =
    -- Xmonad
        [ ("M-C-r", spawn "xmonad --recompile")
        , ("M-S-r", spawn "xmonad --restart")
    --  , ("M-S-q", io exitSuccess)

    -- Run Prompt
        , ("M-<Space>" , spawn "rofi -show run")

    -- Programs
    --  , ("M-<Return>" , spawn "kitty --single-instance")
        , ("M-c"        , spawn "chromium --kiosk https://web.whatsapp.com")
        , ("M-i"        , spawn "firefox")
        , ("M-o"        , spawn "kitty --single-instance")
        , ("M-9"        , spawn "polybar -r top &")
        , ("M-0"        , spawn "pkill polybar")
    --  , ("M-S-8"      , spawn "scrot")
        , ("M-`"        , spawn "betterlockscreen -t 'BAKA BAKA BAKA!' -s blur")
        , ("M-e"        , spawn "emacs")
        , ("M-;"        , spawn "emacsclient -c")
        , ("M-<Return>" , spawn "emacsclient -c -a '' --eval '(vterm)'")
        , ("M-S-f"      , spawn "emacsclient -c -a '' --eval '(dired-jump)'")

    -- Kill windows
        , ("M-q" , kill1)       -- Kill the currently focused client

    -- Workspaces
        , ("M-a" , windows  (W.greedyView "01"))
        , ("M-s" , windows  (W.greedyView "02"))
        , ("M-d" , windows  (W.greedyView "03"))
        , ("M-p" , windows  (W.greedyView "04"))

        , ("M-S-a" , windows  (W.shift "01"))
        , ("M-S-s" , windows  (W.shift "02"))
        , ("M-S-d" , windows  (W.shift "03"))
        , ("M-S-p" , windows  (W.shift "04"))

    -- Floating windows
        , ("M-S-f" , sendMessage (T.Toggle "floats")) -- Toggles my 'floats' layout
        , ("M-t"   , withFocused $ windows . W.sink)  -- Push floating window back to tile
        , ("M-S-t" , sinkAll)                         -- Push ALL floating windows to tile

    -- Windows navigation
        , ("M-m"           , windows W.focusMaster)   -- Move focus to the master window

        , ("M-j"           , windows W.focusDown)     -- Move focus to the next window
        , ("M-k"           , windows W.focusUp)       -- Move focus to the prev window

        , ("M-C-w"         , windows W.focusDown)     -- Move focus to the next window
        , ("M-C-s"         , windows W.focusUp)       -- Move focus to the prev window

        , ("M-S-m"         , windows W.swapMaster)    -- Swap the focused window and the master window
        , ("M-S-j"         , windows W.swapDown)      -- Swap focused window with next window
        , ("M-S-k"         , windows W.swapUp)        -- Swap focused window with prev window
        , ("M-<Backspace>" , promote)                 -- Moves focused window to master
        , ("M-S-<Tab>"     , rotSlavesDown)           -- Rotate all windows except master
        , ("M-C-<Tab>"     , rotAllDown)              -- Rotate all the windows

    -- Layouts
        , ("M-f", sendMessage NextLayout)             -- Switch to next layout

    -- Window resizing
        , ("M-h"    , sendMessage Shrink)             -- Shrink horiz window width
        , ("M-l"    , sendMessage Expand)             -- Expand horiz window width

        , ("M-M1-h" , sendMessage Shrink)             -- Shrink horiz window width
        , ("M-M1-l" , sendMessage Expand)             -- Expand horiz window width
        , ("M-M1-j" , sendMessage MirrorShrink)       -- Shrink vert window width
        , ("M-M1-k" , sendMessage MirrorExpand)       -- Exoand vert window width

    -- Multimedia Keys
        , ("<XF86MonBrightnessUp>"   , spawn "light -A 1")
        , ("<XF86MonBrightnessDown>" , spawn "light -U 1")

        , ("M-<XF86AudioMute>"        , spawn (myTerminal ++ "mpc toggle"))
        , ("M-<XF86AudioLowerVolume>" , spawn (myTerminal ++ "mpc prev"))
        , ("M-<XF86AudioRaiseVolume>" , spawn (myTerminal ++ "mpc next"))

        , ("<XF86AudioMute>"          , spawn "pactl set-sink-mute 0 toggle")
        , ("<XF86AudioLowerVolume>"   , spawn "pactl set-sink-volume 0 -5%")
        , ("<XF86AudioRaiseVolume>"   , spawn "pactl set-sink-volume 0 +5%")

        , ("M-S-Up"                   , spawn (myTerminal ++ "mpc toggle"))
        , ("M-S-Left"                 , spawn (myTerminal ++ "mpc prev"))
        , ("M-S-Right"                , spawn (myTerminal ++ "mpc next"))

        , ("M-Up"                     , spawn "pactl set-sink-mute 0 toggle")
        , ("M-Left"                   , spawn "pactl set-sink-volume 0 -5%")
        , ("M-Right"                  , spawn "pactl set-sink-volume 0 +5%")

        , ("M-v"                      , spawn "$HOME/Archaict/Scripts/myth.sh")
        , ("<Print>"                  , spawn "scrotd 0")
        ]
