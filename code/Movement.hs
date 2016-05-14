module Movement (
    Movement(..),
    createNextPosition
) where 

-------------
--LIBRARIES--
-------------
import Data.Char
import Map
import Block

-------------------
--TYPE_DEFINITION--
-------------------
-- Respresenta els 5 moviments possibles que pot executar la peça
data Movement = KeyUp | KeyDown | KeyRight | KeyLeft | KeyRestart deriving (Eq, Show)

-----------
--METHODS--
-----------
-- Parametres: - lvl:        Objecte tipus "Level" conté la llista de Strings que representa el mapa i les posicions inicial i final.
--             - block:      Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
--             - movement:   Objecte tipus "Movement" conté un dels quatre moviments 
-- Funció: Recorre la llista [Movement] i executa cadascun dels "Movement" que conté
--         Imprimeix el mapa resultant de cada moviment
createNextPosition :: Level -> Piece -> Movement -> Piece
createNextPosition lvl block movement
    | movement == KeyUp = (update_state lvl (upPosition block))
    | movement == KeyDown = (update_state lvl (downPosition block))
    | movement == KeyRight = (update_state lvl (rightPosition block))
    | movement == KeyLeft = (update_state lvl (leftPosition block))
    | movement == KeyRestart = (restartPosition block)
    | otherwise = Piece {pos1 = Position {pos = (-1, -1)}, pos2 = Position {pos = (-1, -1)}, state = Falling, orientation = Standing, bridgeButtons = []}

-- Parametres: - block:      Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Executa el moviment cap amunt sobre la peça que entre per parametre "block"
upPosition :: Piece -> Piece
upPosition block
    |currentOrientation == Standing = Piece {pos1 = (sumaX (pos1 block) (-2)), pos2 = (sumaX (pos2 block) (-1)), state = (state block), orientation = Vertical, bridgeButtons = (bridgeButtons block)}
    |currentOrientation == Vertical = Piece {pos1 = (sumaX (pos1 block) (-1)), pos2 = (sumaX (pos2 block) (-2)), state = (state block), orientation = Standing, bridgeButtons = (bridgeButtons block)}
    |otherwise = Piece {pos1 = (sumaX (pos1 block) (-1)), pos2 = (sumaX (pos2 block) (-1)), state = (state block), orientation = Horizontal, bridgeButtons = (bridgeButtons block)}
    where
        currentOrientation = orientation block

-- Parametres: - block:      Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Executa el moviment cap avall sobre la peça que entre per parametre "block"
downPosition :: Piece -> Piece
downPosition block
    |currentOrientation == Standing = Piece {pos1 = (sumaX (pos1 block) (1)), pos2 = (sumaX (pos2 block) (2)), state = (state block), orientation = Vertical, bridgeButtons = (bridgeButtons block)}
    |currentOrientation == Vertical = Piece {pos1 = (sumaX (pos1 block) (2)), pos2 = (sumaX (pos2 block) (1)), state = (state block), orientation = Standing, bridgeButtons = (bridgeButtons block)}
    |otherwise = Piece {pos1 = (sumaX (pos1 block) (1)), pos2 = (sumaX (pos2 block) (1)), state = (state block), orientation = Horizontal, bridgeButtons = (bridgeButtons block)}
    where
        currentOrientation = orientation block

-- Parametres: - block:      Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Executa el moviment cap a la dreta sobre la peça que entre per parametre "block"
rightPosition :: Piece -> Piece
rightPosition block
    |currentOrientation == Standing = Piece {pos1 = (sumaY (pos1 block) (1)), pos2 = (sumaY (pos2 block) (2)), state = (state block), orientation = Horizontal, bridgeButtons = (bridgeButtons block)}
    |currentOrientation == Vertical = Piece {pos1 = (sumaY (pos1 block) (1)), pos2 = (sumaY (pos2 block) (1)), state = (state block), orientation = Vertical, bridgeButtons = (bridgeButtons block)}
    |otherwise = Piece {pos1 = (sumaY (pos1 block) (2)), pos2 = (sumaY (pos2 block) (1)), state = (state block), orientation = Standing, bridgeButtons = (bridgeButtons block)}
    where 
        currentOrientation = orientation block

-- Parametres: - block:      Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Executa el moviment cap a esquerra sobre la peça que entre per parametre "block"
leftPosition :: Piece -> Piece
leftPosition block
    |currentOrientation == Standing = Piece {pos1 = (sumaY (pos1 block) (-2)), pos2 = (sumaY (pos2 block) (-1)), state = (state block), orientation = Horizontal, bridgeButtons = (bridgeButtons block)}
    |currentOrientation == Vertical = Piece {pos1 = (sumaY (pos1 block) (-1)), pos2 = (sumaY (pos2 block) (-1)), state = (state block), orientation = Vertical, bridgeButtons = (bridgeButtons block)}
    |otherwise = Piece {pos1 = (sumaY (pos1 block) (-1)), pos2 = (sumaY (pos2 block) (-2)), state = (state block), orientation = Standing, bridgeButtons = (bridgeButtons block)}
    where 
        currentOrientation = orientation block

-- Parametres: - block:      Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Crea una peça igual que la que rep, pero modifica l'estat a "OutOfBorders" per fer un restart del nivell
restartPosition :: Piece -> Piece
restartPosition block = Piece {pos1 = (pos1 block), pos2 = (pos2 block), state = OutOfBorders, orientation = (orientation block), bridgeButtons = (bridgeButtons block)}

-- Parametres: - lvl:        Objecte tipus "Level" conté la llista de Strings que representa el mapa i les posicions inicial i final.
--             - block:      Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Avalua si les posicions de la peça "block" es troben dintre dels marges reals del mapa
update_state :: Level -> Piece -> Piece
update_state lvl block = checkedPiece
    where
        checkedPiece =
            if (fst (pos (pos2 block))) < rows && (snd (pos (pos2 block))) < columns && (fst (pos (pos1 block))) >= 0 && (snd (pos (pos1 block))) >= 0
                then
                    updete_legal_state columns mapString position1 position2 block
            else
                modify_block_state block OutOfBorders
            where
                columns = length ((lMap lvl) !! 0)
                rows = length (lMap lvl)
                position1 = (fst (pos (pos1 block))) * columns + (snd (pos (pos1 block)))
                position2 = (fst (pos (pos2 block))) * columns + (snd (pos (pos2 block)))
                mapString = concat (lMap lvl)

-- Parametres: - lvl:        Objecte tipus "Level" conté la llista de Strings que representa el mapa i les posicions inicial i final.
--             - block:      Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Avalua si les posicions de la peça "block" es troben en el terreny valid del mapa o trepitjen una zona no legal o especial.
--         Si trepitja terreny valid seguira jugant, altrament pot ser que caigui o que hagi guanyat la partida.
updete_legal_state :: Int -> String -> Int -> Int -> Piece -> Piece
updete_legal_state columns mapString position1 position2 block = newBlock
    where
         newBlock = 
            if (cell1 == '0' || cell2 == '0') || ((cell1 == '2' && cell2 == '2') && (position1 == position2))--CANVIIIIIIIIIIIIIIII--
                then modify_block_state block Falling
            else if cell1 == 'G' && cell2 == 'G'
                then modify_block_state block Winning
            else if cell1 == cell2 && (fromEnum cell1 > 50 && fromEnum cell1 < 58)
                then teleport cell1 columns mapString (modify_block_state block Playing)
            else if (isValidLetterBridge cell1)
                then addButton(modify_block_state block Playing) (toLower cell1)
            else if (isValidLetterBridge cell2)
                then addButton(modify_block_state block Playing) (toLower cell2)
            else if cell1 `elem` (bridgeButtons block) || cell2 `elem` (bridgeButtons block)
                then modify_block_state block Playing
            else if isLower cell1 && not (cell1 `elem` (bridgeButtons block)) || isLower cell2 && not (cell2 `elem` (bridgeButtons block))
                then modify_block_state block Falling
            else modify_block_state block Playing
            where
                cell1 = (mapString !! position1)
                cell2 = (mapString !! position2)

-- Parametres: - c:        Objecte tipus "Char" 
-- Funció: Retorna cert si el caracter entrat es una lletra majuscula i no es G ni S. S'utilitza per trobar botons de ponts.
isValidLetterBridge :: Char -> Bool
isValidLetterBridge c = (c /= 'S' && c /= 'G' && isUpper c)