from strutils import formatFloat, TFloatformat
from unicode import toUTF8
import glfw/glfw

proc winPosCb(o: PWin, pos: tuple[x, y: int]) =
  echo "Window position: ", pos

proc mouseBtnCb(
    o: PWin, btn: TMouseBtn, pressed: bool, modKeys: TModifierKeySet) =
  echo($btn, ": ", if pressed: "down" else: "up")

proc winSizeCb(o: PWin not nil, res: tuple[w, h: int]) =
  echo "Window size: ", res

proc winFramebufSizeCb(o: PWin, res: tuple[w, h: int]) =
  echo "Window framebuffer size: ", res

proc winCloseCb(o: PWin) =
  echo "Window close event"

var nWinRefreshes = 0

proc winRefreshCb(o: PWin) =
  nWinRefreshes += 1

proc cursorPosCb(o: PWin, pos: tuple[x, y: float64]) =
  let xy = (x: formatFloat(pos.x, ffDecimal, 2),
            y: formatFloat(pos.y, ffDecimal, 2))
  echo "Cursor pos: ", xy

proc cursorEnterCb(o: PWin, entered: bool) =
  echo "The cursor ", if entered: "entered" else: "left", " the window area"

proc winFocusCb(o: PWin; focused: bool) =
  echo if focused: "Gained" else: "Lost", " window focus"

proc winIconifyCb(o: PWin; iconified: bool) =
  echo "Window ", if iconified: "iconified" else: "un-iconified"

proc scrollCb(o: PWin, offset: tuple[x, y: float64]) =
  let xy = (x: formatFloat(offset.x, ffDecimal, 2),
            y: formatFloat(offset.y, ffDecimal, 2))
  echo "Mouse scroll: ", xy

proc charCb(o: PWin, codePoint: TRune) =
  echo "Unicode char: ", codePoint.toUTF8()

proc keyCb(o: PWin, key: TKey, scanCode: int, action: TKeyAction,
    modKeys: TModifierKeySet) =
  echo("Key: ", key, " (scan code: ", scanCode, "): ", action)

  if action != kaUp:
    if key == keyEscape or key == keyF4 and mkAlt in modKeys:
      o.shouldClose = true

glfw.init()

var done = false

# All arguments are optional.
#initGL_API optionally takes parameters. for GL ES, use initGL_ES_API.
var win = newWin(
  dim = (w: 640, h: 480),
  title = "Event example",
  fullscreen = nilMonitor(), # No monitor specified; don't go fullscreen.
  shareResourcesWith = nilWin(), # Don't share resources.
  visible = true,
  decorated = true,
  resizable = false,
  stereo = false,
  SRGB_capableFramebuf = false,
  bits = (r: 8, g: 8, b: 8, a: 8, stencil: 8, depth: 24),
  accumBufBits = (r: 0, g: 0, b: 0, a: 0),
  nAuxBufs = 0,
  nMultiSamples = 0,
  refreshRate = 0, # Current refresh rate.
  GL_API = initGL_API()
)

setControlCHook do {.noconv.}:
  done = true

# Set up event handlers.
win.winPosCb = winPosCb
win.mouseBtnCb = mouseBtnCb
win.winSizeCb = winSizeCb
win.keyCb = keyCb
win.framebufSizeCb = winFramebufSizeCb
win.winCloseCb = winCloseCb
win.winRefreshCb = winRefreshCb
win.cursorPosCb = cursorPosCb
win.cursorEnterCb = cursorEnterCb
win.winFocusCb = winFocusCb
win.winIconifyCb = winIconifyCb
win.scrollCb = scrollCb
win.charCb = charCb
win.keyCb = keyCb

while not done and not win.shouldClose:
  win.update() # Buffer swap + event poll.

win.destroy()
glfw.terminate()
