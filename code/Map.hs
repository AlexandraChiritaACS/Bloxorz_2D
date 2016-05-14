module Map (
    Level(..),
    createTheMap,
    modifyMap,
    paintBridges
) where

-------------
--LIBRARIES--
-------------
import Block
import Data.List

-------------------
--TYPE_DEFINITION--
-------------------
-- Parametres: - lMap:          Llista d'strings que determinen el format del mapa
--             - initialPos:    Objecte tipus "Position" que indica la posició d'inici del mapa
--             - endingPos:     Objecte tipus "Position" que indica la posició de fi del mapa
data Level = Level {
    lMap :: [String],
    initialPos :: Position,
    endingPos :: Position
} deriving Show



--             - lvl:        Objecte tipus "Level" conté la llista de Strings que representa el mapa i les posicions inicial i final.
--             - block:      Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-----------
--METHODS--
-----------
-- Parametres: - map:       Llista d'strings
--             - start:     Enter positiu
--             - end:       Enter positiu
--             - nColumns:  Enter positiu
-- Funció: Crea el mapa inicial segons la llista d'strings "map", les posicions d'inici "start" i final "end" i el numero de columne "nColumns"
createTheMap :: [String] -> Int -> Int -> Int -> Level
createTheMap map start end nColumns = level
    where 
        level = Level {lMap = map, initialPos = startPos, endingPos = endPos}
        startPos = Position {pos = ((div start nColumns),(mod start nColumns))}
        endPos = Position {pos = ((div end nColumns),(mod end nColumns))}

-- Parametres: - oldLvl:    Objecte tipus "Level" conté la llista de Strings que representa el mapa i les posicions inicial i final.
--             - block:     Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Modifica el mapa "lvl" actualitzant la nova posició de la Piece "block"
modifyMap :: Level -> Piece -> Level
modifyMap oldLvl block = newLvl
    where 
        newLvl = Level {lMap = map, initialPos = initialPos oldLvl, endingPos = endingPos oldLvl}
        map = modifyPosition (fst(pos(pos2 block))) (snd(pos(pos2 block))) 'B' (modifyPosition (fst(pos(pos1 block))) (snd(pos(pos1 block))) 'B' (lMap oldLvl))

-- Parametres: - x:       Enter positiu
--             - char:    Element que s'ha de insertar a la posicio indicada de la lissta
--             - zs:      Llista generica
-- Funció: Rep una llista de tipus generic la qual parteix en dos parts per la posicio incidaca per l'enter "x" i hi concatena entremig
--         l'element contingut al parametre "char"
changeStr2 x char zs = before ++ (char : tail after)
    where 
    (before, after) = splitAt (x) zs

-- Parametres: - n:       Enter positiu
--             - e:       Element que s'ha de insertar a la posicio indicada de la lissta
--             - xs:      Llista generica
-- Funció: Rep una llista de tipus generic, a la qual hi concatena l'element "e" del mateix tipus de la llista
--         a la posicio que indica l'enter "n"	
changeStr :: Int -> a -> [a] -> [a]
changeStr n e xs = changeStr2 n e xs

-- Parametres: - x:       Enter positiu
--             - y:       Enter positiu
--             - e:       Element que s'ha de insertar a la posicio indicada de la lissta de llistes
--             - xss:     Llista de llistes generica
-- Funció: Rep una llista de llistes de tipus generic, a la qual hi concatena l'element "e" del mateix tipus de la llista
--         a la posicio que indiquen els enters "x" i "y"
modifyPosition :: Int -> Int -> a -> [[a]] -> [[a]]
modifyPosition x y e xss = changeStr2 x (changeStr y e (xss !! x)) xss

-- Parametres: - xs:       Llista que conte els caracters que hem de pintar
--             - oldLvl:   Nivell actual sense modificar
-- Funció: Et pinta els ponts que hem trepitjat com '1' en el mapa (nomes si cal)
paintBridges :: String -> Level -> Level
paintBridges xs oldLvl
    | xs == [] = oldLvl
    | otherwise = paintBridges (tail xs) (paintCells (elemIndices (head xs) (concat(lMap oldLvl))) oldLvl)

-- Parametres: - xs:       Llista que conte els caracters que hem de pintar
--             - oldLvl:   Nivell actual sense modificar
-- Funció: Funcio recursiva que pinta tots els ponts que rebem a la llista com '1'
paintCells :: [Int] -> Level -> Level
paintCells xs oldLvl 
    | xs == [] = oldLvl
    | otherwise = paintCells (tail xs) newLvl
    where 
        columns = length ((lMap oldLvl) !! 0)
        newLvl = Level {lMap = newMap, initialPos = initialPos oldLvl, endingPos = endingPos oldLvl}
        newMap = modifyPosition (div (head xs) columns) (mod (head xs) columns) '1' (lMap oldLvl)