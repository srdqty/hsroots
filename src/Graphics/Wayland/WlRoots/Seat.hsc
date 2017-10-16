module Graphics.Wayland.WlRoots.Seat
    ( WlrSeat
    , createSeat
    , destroySeat
    , handleForClient
    , setSeatCapabilities

    , pointerNotifyEnter
    , pointerNotifyMotion

    , keyboardNotifyEnter

    , pointerClearFocus

    , attachKeyboard
    )
where

#include <wlr/types/wlr_seat.h>

import Data.Word (Word32)
import Foreign.Ptr (Ptr)
import Foreign.C.String (CString, withCString)
import Foreign.C.Error (throwErrnoIfNull)
import Foreign.C.Types (CInt(..))
import Data.Bits ((.|.))
import Graphics.Wayland.Server (DisplayServer(..), Client (..), SeatCapability(..))
import Graphics.Wayland.WlRoots.Surface (WlrSurface)
import Graphics.Wayland.WlRoots.Input (InputDevice)

data WlrSeat

foreign import ccall "wlr_seat_create" c_create :: Ptr DisplayServer -> CString -> IO (Ptr WlrSeat)

createSeat :: DisplayServer -> String -> IO (Ptr WlrSeat)
createSeat (DisplayServer ptr) name = throwErrnoIfNull "createSeat" $ withCString name $ c_create ptr


foreign import ccall "wlr_seat_destroy" c_destroy :: Ptr WlrSeat -> IO ()

destroySeat :: Ptr WlrSeat -> IO ()
destroySeat = c_destroy


data WlrSeatHandle

foreign import ccall "wlr_seat_handle_for_client" c_handle_for_client :: Ptr WlrSeat -> Ptr Client -> IO (Ptr WlrSeatHandle)

handleForClient :: Ptr WlrSeat -> Client -> IO (Ptr WlrSeatHandle)
handleForClient seat (Client client) =
    throwErrnoIfNull "handleForClient" $ c_handle_for_client seat client


foreign import ccall "wlr_seat_set_capabilities" c_set_caps :: Ptr WlrSeat -> CInt -> IO ()

setSeatCapabilities :: Ptr WlrSeat -> [SeatCapability] -> IO ()
setSeatCapabilities seat xs =
    c_set_caps seat (fromIntegral $ foldr ((.|.) . unCap) 0 xs)
    where unCap :: SeatCapability -> Int
          unCap (SeatCapability x) = x


foreign import ccall "wlr_seat_pointer_notify_enter" c_pointer_enter :: Ptr WlrSeat -> Ptr WlrSurface -> Double -> Double -> IO ()

pointerNotifyEnter :: Ptr WlrSeat -> Ptr WlrSurface -> Double -> Double -> IO ()
pointerNotifyEnter = c_pointer_enter


foreign import ccall "wlr_seat_keyboard_notify_enter" c_keyboard_enter :: Ptr WlrSeat -> Ptr WlrSurface -> IO ()

keyboardNotifyEnter :: Ptr WlrSeat -> Ptr WlrSurface -> IO ()
keyboardNotifyEnter = c_keyboard_enter


foreign import ccall "wlr_seat_pointer_notify_motion" c_pointer_motion :: Ptr WlrSeat -> Word32 -> Double -> Double -> IO ()

pointerNotifyMotion :: Ptr WlrSeat -> Word32 -> Double -> Double -> IO ()
pointerNotifyMotion = c_pointer_motion


foreign import ccall "wlr_seat_pointer_clear_focus" c_pointer_clear_focus :: Ptr WlrSeat -> IO ()

pointerClearFocus :: Ptr WlrSeat -> IO ()
pointerClearFocus = c_pointer_clear_focus


foreign import ccall "wlr_seat_attach_keyboard" c_attach_keyboard :: Ptr WlrSeat -> Ptr InputDevice -> IO ()

attachKeyboard :: Ptr WlrSeat -> Ptr InputDevice -> IO ()
attachKeyboard = c_attach_keyboard