module GUI_Cpu (
    createCpuWindow
) where

-------------
--LIBRARIES--
-------------
import Map
import Block
import Solver
import Levels
import Data.Char
import Movement as Mv
import Graphics.UI.WX
import Control.Concurrent
import Graphics.UI.WXCore as Wx

-----------
--METHODS--
-----------
createCpuWindow :: IO()
createCpuWindow = do
    --Start music game
    playLoop (sound "sounds/game_music.wav")
    --Generate level
    varMoves <- varCreate []
    varGame <- varCreate (createLevel 0)
    game <- varGet varGame
    varPositions <- varCreate (createTheBoard (nRows game) (nColumns game) (calculateMarginX game) (calculateMarginY game))
    --Found solution
    varSet varMoves (find_best_solution (level game))
    --Define window objects
    f <- frameCreate objectNull idAny "Bloxorz 1.0" rectNull (wxMAXIMIZE)
    p <- panelCreate f idAny rectNull 0
    --Set window properties
    windowSetLayout f (column 1 [minsize (sz wxMAXIMIZE wxMAXIMIZE) (widget p)])
    --Draw level (map & block) on tick timer
    windowOnPaintRaw p (drawLevel varGame varPositions)
    --Get event key pressed
    windowOnKeyChar p (onKey p f varGame varPositions varMoves)
    --Define timer for next movement
    t <- windowTimerCreate f
    timerOnCommand t (nextMovement p varGame varPositions varMoves)
    timerStart t 500 False
    --Show window
    windowShow f
    windowRaise f
    return ()
    where
        --CREATE THE BOARD
        createTheBoard :: Int -> Int -> Int -> Int -> [[Rect]]
        createTheBoard rows columns x y = createAllRows rows columns x y
        --CREATE ALL ROWS
        createAllRows :: Int -> Int -> Int -> Int -> [[Rect]]
        createAllRows rows columns x y
            | rows == 0 = []
            | otherwise = createOneRow columns x y [] : createAllRows (rows-1) columns (x+cellSize+marginCell) y
        --CREATE ONE ROW
        createOneRow :: Int -> Int -> Int -> [Rect] -> [Rect]
        createOneRow columns x y list
            | columns == 0 = []
            | otherwise = (rect (pt x y) (sz cellSize cellSize)) : createOneRow (columns-1) x (y+cellSize+marginCell) list
        --GET KEYBOARD EVENTS FOR MOVE THE BLOCK AND CLOSE WINDOW
        onKey p f varGame varPositions varMoves keyboard =
            case keyKey keyboard of
                Wx.KeyChar 'r' -> restartCurrentLevel p varGame varMoves
                Wx.KeyReturn -> createNextLevel p varGame varPositions varMoves
                Wx.KeyEscape -> endGame f
                other -> skipCurrentEvent
        --CREATE NEXT LEVEL
        createNextLevel :: Window a -> Var Game -> Var [[Rect]] -> Var [Movement] -> IO()
        createNextLevel p varGame varPositions varMoves = do
            game <- varGet varGame
            --NEXT LEVEL
            if (state (piece game)) == Winning && (((nLevel game)+1) < (length maps))
                then do
                    varSet varGame (createLevel (1+(nLevel game)))
                    game <- varGet varGame
                    varSet varPositions (createTheBoard (nRows game) (nColumns game) (calculateMarginX game) (calculateMarginY game))
                    varSet varMoves (find_best_solution (level game))
                    refreshBoard p
                    nextLevel
            --WIN GAME
            else if (state (piece game)) == Winning && ((nLevel game) == ((length maps)-1))
                then do
                    winGame
            --RESTART LEVEL
            else do
                restartCurrentLevel p varGame varMoves
        --RESTART LEVEL
        restartCurrentLevel :: Window a -> Var Game -> Var [Movement] -> IO()
        restartCurrentLevel p varGame varMoves = do
            game <- varGet varGame
            varSet varGame (createLevel (nLevel game))
            newGame <- varGet varGame
            varSet varMoves (find_best_solution (level newGame))
            refreshBoard p
            restartLevel
        --SOLVER LEVEL
        nextMovement :: Window a -> Var Game -> Var [[Rect]] -> Var [Movement] -> IO()
        nextMovement p varGame varPositions varMoves = do
            moves <- varGet varMoves
            if moves /= []
                then do
                    moveBlock p varGame varPositions varMoves
                    varSet varMoves (tail moves)
            else
                skipCurrentEvent
        --MODIFY BLOCK POSITION AFTER PRESS KEY
        moveBlock :: Window a -> Var Game -> Var [[Rect]] -> Var [Movement] -> IO()
        moveBlock p varGame varPositions varMoves = do
            game <- varGet varGame
            moves <- varGet varMoves
            let newBlock = createNextPosition (level game) (piece game) (head moves)
            --FINISH GAME
            if (state newBlock) == Winning && ((nLevel game) >= (length maps))
                then do
                    winGame
            --PLAYING
            else do
                let initialGame = (createLevel (nLevel game))
                let newLevel = (paintBridges (bridgeButtons newBlock)(modifyMap (level initialGame) newBlock))
                varSet varGame (Game {level = newLevel, piece = newBlock, nColumns = (nColumns game), nRows = (nRows game), nLevel = (nLevel game)})
                refreshBoard p
        --REFRESH WINDOW FOR DRAW NEW MOVEMENT
        refreshBoard :: Window a -> IO()
        refreshBoard p = do
            windowRefresh p False
        --DRAW LEVEL (MAP & BLOCK)
        drawLevel :: Var Game -> Var [[Rect]] -> DC a -> Rect -> [Rect] -> IO()
        drawLevel varGame varPositions dc viewRect updateAreas = do
            dcClear dc
            Wx.dcWithBrushStyle dc (BrushStyle BrushSolid black) $ dcDrawRectangle dc viewRect
            game <- varGet varGame
            positions <- varGet varPositions
            drawBoard dc game 0 positions
        --DRAW BOARD
        drawBoard :: DC a -> Game -> Int -> [[Rect]] -> IO()
        drawBoard dc game currentPosY positions = do
            if currentPosY == (nRows game)
                then drawBlack dc
            else drawRow dc game 0 currentPosY positions (positions !! currentPosY)
        --DRAW ROW
        drawRow :: DC a -> Game -> Int -> Int -> [[Rect]] -> [Rect] -> IO()
        drawRow dc game currentPosX currentPosY positions rowPos = do
            if currentPosX == (nColumns game)
                then drawBoard dc game (currentPosY + 1) positions
            else
                drawCell dc color game currentPosX currentPosY positions rowPos 
            where
                color = getCellColor currentPosX currentPosY game
        --DRAW CELL
        drawCell :: DC a -> Color -> Game -> Int -> Int -> [[Rect]] -> [Rect] -> IO()
        drawCell dc color game currentPosX currentPosY positions rowPos = do
            Wx.dcWithBrushStyle dc (BrushStyle BrushSolid color) $ dcDrawRectangle dc (rowPos !! currentPosX)
            drawRow dc game (currentPosX + 1) currentPosY positions rowPos
        --DRAW BLACK CELL
        drawBlack :: DC a -> IO()
        drawBlack dc = do
            Wx.dcWithBrushStyle dc (BrushStyle BrushSolid black) $ dcDrawRectangle dc (Rect 0 0 0 0) 
        --RESET LEVEL
        restartLevel :: IO()
        restartLevel = do
            play (sound "sounds/reset_level.wav")
            threadDelay 3500000
            playLoop (sound "sounds/game_music.wav")
        --NEXT LEVEL
        nextLevel :: IO()
        nextLevel = do
            play (sound "sounds/next_level.wav")
            threadDelay 3500000
            playLoop (sound "sounds/game_music.wav")
        --WIN GAME
        winGame :: IO()
        winGame = do
            play (sound "sounds/win_game.wav")
            threadDelay 3500000
        --END GAME
        endGame f = do
            play (sound "sounds/end_game.wav")
            threadDelay 3500000
            (close f)
        --GET COLOR OF CELL
        getCellColor :: Int -> Int -> Game -> Color
        getCellColor x y game = 
            if (isLetter (typeCell) && isUpper(typeCell) && typeCell /= 'B' && typeCell /= 'S' && typeCell /= 'G')
                then
                    (rgb 75 72 250)
            else
                case typeCell of
                    '0' -> (rgb 0 0 0)
                    '1' -> (rgb 255 255 255)
                    '2' -> (rgb 255 140 0)
                    '3' -> (rgb 136 2 150)
                    '4' -> (rgb 240 2 150)
                    '5' -> (rgb 200 100 150)
                    '6' -> (rgb 200 2 220)
                    '7' -> (rgb 171 3 107)
                    '8' -> (rgb 242 179 218)
                    '9' -> (rgb 140 0 90)
                    'B' -> (rgb 0 255 0)
                    'G' -> (rgb 3 168 171)
                    'S' -> (rgb 230 255 0)
                    otherwise -> black
            where
                typeCell = (((lMap (level game)) !! x) !! y)
        --CALCULATE MARGIN X
        calculateMarginX :: Game -> Int
        calculateMarginX game = marginX
            where
                marginX = ((maxColumns - (nRows game)) `div` 2) * cellSize
        --CALCULATE MARGIN Y
        calculateMarginY :: Game -> Int
        calculateMarginY game = marginY
            where
                marginY = ((maxRows - (nColumns game)) `div` 2) * cellSize
        --DEFINITION OF VALUES
        maxColumns, maxRows, cellSize, marginCell :: Int
        maxColumns = 66
        maxRows = 35
        cellSize = 25
        marginCell = 3