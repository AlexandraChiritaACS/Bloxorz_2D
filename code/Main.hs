-------------
--LIBRARIES--
-------------
import Graphics.UI.WXCore
import GUI_Player
import GUI_Cpu

-----------
--METHODS--
-----------
main :: IO()
main = do
    putStrLn "Enter game mode (player or cpu): "
    gameMode <- getLine
    case gameMode of
        "player" -> run createPlayerWindow
        "cpu" -> run createCpuWindow
        otherwise -> skipCurrentEvent