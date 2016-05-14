module Block (
    BlockOrientation(..),
    BlockState(..),
    Position(..),
    Piece(..),
    createThePiece,
    modify_block_state,
    sumaX,
    sumaY,
    addButton,
    teleport
) where

-------------
--LIBRARIES--
-------------
import Data.List
import Data.Char

-------------------
--TYPE_DEFINITION--
-------------------
--Orientació del bloc dins del tauler
data BlockOrientation = Horizontal | Vertical | Standing deriving (Show, Eq, Ord)
--Estat del bloc segons la jugabilitat
data BlockState = Starting | Playing | Falling | Winning | OutOfBorders deriving (Show, Eq, Ord) 

-- Marca la posició dins del mapa de cada part del bloc, mitjançant dues cordenades(x,y) que senyalen la posició a la matriu mapa
data Position = Position {
    pos :: (Int, Int)
} deriving (Show, Eq, Ord)

-- Parametres: - pos1:        és un data position que marca la posició d'una de les meitats del bloc
--             - pos2:        és un data position que marca la posició d'una de les meitats del bloc
--             - state:       és un data BlockState, indica l'estat del block segons jugabilitat
--             - orientation: és un data BlockOrientation, indica l'orientació del bloc dins el tauler
data Piece = Piece {
    pos1 :: Position,
    pos2 :: Position,
    state :: BlockState,
    orientation :: BlockOrientation,
    bridgeButtons :: [Char]
} deriving (Show, Ord)

--Instància Eq per el tipus Piece
instance Eq Piece where
    (Piece pos1a pos2a statea orientationa bridgeButtonsa)  == (Piece pos1b pos2b stateb orientationb bridgeButtonsb) = (pos1a == pos1b) && (pos2a == pos2b) && (statea == stateb) && (orientationa == orientationb)

-----------
--METHODS--
-----------
-- Parametres: - nPosition: Enter positiu
--             - nColumns:  Enter positiu
-- Funció: Crea la peça a la posició d'inici i la retorna.
createThePiece :: Int -> Int -> Piece
createThePiece nPosition nColumns = piece
    where 
        start = Position {pos = ((div nPosition nColumns), (mod nPosition nColumns))}
        piece = Piece {pos1 = start, pos2 = start, state = Starting, orientation = Standing, bridgeButtons = []}

-- Parametres: - block:      Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
--             - newState:   Objecte tipus "BlockState" indica l'estat de la peça segons la jugabilitat
-- Funció: A partir de la peça ("block") que hi passem retorna una peça nova amb l'state substituït per la variable "newState"
modify_block_state :: Piece -> BlockState -> Piece
modify_block_state block newState = newBlock
    where
        newPos1 = pos1 block
        newPos2 = pos2 block
        newOrientation = orientation block
        newBridgeButtons = bridgeButtons block
        newBlock = Piece {pos1 = newPos1, pos2 = newPos2, state = newState, orientation = newOrientation, bridgeButtons = newBridgeButtons}

-- Parametres: - position: Objecte tipus "Position" conté dos enters que representen les cordenades x i y dins del mapa
--             - n:        Enter positiu o negatiu
-- Funció: Retorna una nova Postition resultant de sumar "n" a la cordenada x de la "position"
sumaX :: Position -> Int -> Position
sumaX position n = Position {pos = ((fst (pos position)) + (n), snd (pos position))}

-- Parametres: - position: Objecte tipus "Position", conté dos enters que representen les xcordenades x i y dins del mapa
--             - n:        Enter positiu o negatiu
-- Funció: Retorna una nova Postition resultant de sumar "n" a la cordenada Y de la "position"
sumaY :: Position -> Int -> Position
sumaY position n = Position {pos = (fst (pos position) , (snd (pos position)) + (n))}

-- Parametres: - position: Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
--             - c:        Objecte tipus "Char" 
-- Funció: Afegeix el char "c" a la llista de chars de btidgeButtons dins de la Piece "p"
addButton :: Piece -> Char -> Piece
addButton p c = Piece {pos1 = (pos1 p), pos2 = (pos2 p), state = (state p), orientation = (orientation p), bridgeButtons = nub(c:(bridgeButtons p)) }

-- Parametres: - num:     Indica el Char que correspon al teleport (3..9)
--             - columns: Numero de columnes que te el mapa
--             - map:     Mapa concatenat en un unic String
--             - block:   Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Modifica la posicio del block al desti del teleport
teleport :: Char -> Int -> String -> Piece -> Piece
teleport num columns map block = Piece {pos1 = newPos, pos2 = newPos, state = (state block), orientation = (orientation block), bridgeButtons = (bridgeButtons block)}
    where
        newPos = (searchPosition columns (elemIndices num map) block)

-- Parametres: - columns: Numero de columnes que te el mapa
--             - xs:      Llista d'enters que conte les destinacions dels teleports
--             - p:       Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Retorna la posicio de desti del teleport
searchPosition :: Int -> [Int] -> Piece -> Position
searchPosition columns xs p
    | (Position {pos = ((div (head xs) columns),(mod (head xs) columns))}) == (pos1 p) = (Position {pos = ((div (last xs) columns),(mod (last xs) columns))})
    | otherwise = (Position {pos = ((div (head xs) columns),(mod (head xs) columns))})
