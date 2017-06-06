{-# LANGUAGE OverloadedStrings #-}

module DobadoBots.Graphics.Editor(
  drawEditor,
  renderCode
) where

import           Control.Monad.State(StateT(..), get,
                                     modify, liftIO)
import           Data.Text          (Text(..), unpack)
import qualified SDL                (Renderer(..), Point(..), 
                                     V2(..), Rectangle(..),
                                     V4(..), Texture(..),
                                     fillRect, rendererDrawColor,
                                     copy)
import           SDL                (($=))
import Foreign.C.Types              (CInt(..)) 
import qualified SDL.Raw as Raw     (Color(..))
import           Text.PrettyPrint   (Doc(..))

import DobadoBots.GameEngine.Data   (GameState(..))
import DobadoBots.Interpreter.Data  (Cond(..))
import DobadoBots.Interpreter.PrettyPrinter (prettyPrint)
import DobadoBots.Graphics.Data     (RendererState(..))
import DobadoBots.Graphics.Utils    (loadFont)

offset :: CInt
offset = 15

drawEditor :: SDL.Renderer -> GameState -> RendererState -> IO ()
drawEditor r st rst = do
  SDL.rendererDrawColor r $= SDL.V4 0 0 0 0
  SDL.fillRect r . Just $ SDL.Rectangle (SDL.P $ SDL.V2 540 0) (SDL.V2 300 480)
  displayCode r st rst

displayCode :: SDL.Renderer -> GameState -> RendererState -> IO ()
displayCode r st rst = do
                    runStateT (renderLines r $ codeTextures rst) 1 
                    return ()

renderCode :: SDL.Renderer -> Cond -> IO [(SDL.Texture, SDL.V2 CInt)]
renderCode r ast = mapM renderLine strs
  where renderLine str = do loadFont r
                                "data/fonts/Terminus.ttf"
                                15
                                (Raw.Color 255 255 255 0)
                                str
        strs = lines . unpack $ prettyPrint ast

renderLines :: SDL.Renderer -> [(SDL.Texture, SDL.V2 CInt)] -> StateT CInt IO ()
renderLines r strs = do
    mapM renderLine strs
    return ()
  where 
    renderLine :: (SDL.Texture, SDL.V2 CInt) -> StateT CInt IO ()
    renderLine (tex, size) = do
          lineNb <- get
          modify (+1)
          let pos = SDL.P $ SDL.V2 544 (lineNb * offset)
          liftIO $ SDL.copy r tex Nothing (Just $ SDL.Rectangle pos size)


