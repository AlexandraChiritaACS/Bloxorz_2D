module Solver (
    find_best_solution
) where

-------------
--LIBRARIES--
-------------
import qualified Data.Set as Set
import Data.List (findIndex, nubBy)
import Data.Function (on)
import Block
import Movement
import Map

-------------------
--TYPE DEFINITION--
-------------------
-- Parametres: - Piece:       Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
--             - [Movement]   Lista de objectes de tipus Movement
type Path = (Piece, [Movement])

-----------
--METHODS--
-----------
-- Parametres: - lvl:         Objecte tipus "Level" conté la llista de Strings que representa el mapa i les posicions inicial i final.
-- Funció: Rep el mapa introduit per l'usuari. I calculará tots els camins possibles del mapa fins que trobi una solució. 
--         Al retornar la primera que ha trobat ens assegurem que sera la més curta
find_best_solution :: Level -> [Movement]
find_best_solution lvl = 
    case dropWhile (\(b,_)->finish/=b) (find_all_paths lvl start) of
        []         -> []
        ((b,ms):_) -> reverse ms
    where
        finish = Piece {pos1 = (endingPos lvl), pos2 = (endingPos lvl), state = Winning, orientation = Standing, bridgeButtons = []}
        start = Piece {pos1 = (initialPos lvl), pos2 = (initialPos lvl), state = Starting, orientation = Standing, bridgeButtons = []}


-- Parametres: - lvl:         Objecte tipus "Level" conté la llista de Strings que representa el mapa i les posicions inicial i final.
--             - b:           Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
-- Funció: Executa la recursió a traves del mapa per tal de generar tots els camins possibles. 
find_all_paths :: Level -> Piece -> [Path]
find_all_paths lvl b = from [(b, [])] (Set.fromList [b])
    where
        from :: [Path] -> Set.Set Piece -> [Path]
        from []    _       = []
        from paths visited = paths ++ from best_paths nowVisited
            where
                -- És una llista de tipus "Path" : [Path] sense repetits; Es generen tots els moviments legals des de totes les posicions contingudes per totes les peces
                -- de tots els Path de la llista de Path que ens entra per parametre "paths"; Contindra tots els Path amb peces que es trobin a posicions no visitades anteriorment;
                best_paths = nubBy ((==) `on` fst) $ [neigOfB | (b, ms) <- paths , neigOfB <- possible_paths lvl b ms, dontVisited neigOfB]
                
                -- Et retorna True si la peça "b" continguda en el Path d'entrada no és membre del Set "visited" és a dir, si la posició de la peça 
                -- encara no ha sigut visitada. Altrament retorna False
                dontVisited :: Path -> Bool
                dontVisited (b,_) = not $ b `Set.member` visited
                
                -- Inserta al Set "visited" totes les noves peces contingudes a la llista de Path que retorna "best_paths"
                nowVisited = foldr Set.insert visited (map fst best_paths)

-- Parametres: - lvl:         Objecte tipus "Level" conté la llista de Strings que representa el mapa i les posicions inicial i final.
--             - b:           Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
--             - ms:          Llista de tipus "Movement"
-- Funció: Executa tots els moviments (4) possibles sobre la peça "b" generant aixi una llista de tips Path; Un cop aquesta llista ha sigut generada 
--         es filtra comprovant si la posicio a la que ha anat a parar la peça es legal (filter legalPosition). Si es legal es mante dins la llista
--         altrament s'extreu de la llista. La llista filtrada es la que es retorna.
possible_paths :: Level -> Piece -> [Movement] -> [Path]
possible_paths lvl b ms = filter legalPosition $ map moves [KeyLeft, KeyRight, KeyUp, KeyDown]
    where 
        legalPosition (b, _) = isLegal lvl b
        
        moves m = (move lvl b m, m:ms)

        isLegal :: Level -> Piece -> Bool
        isLegal lvl block = Falling /= state block && OutOfBorders /= state block

-- Parametres: - lvl:         Objecte tipus "Level" conté la llista de Strings que representa el mapa i les posicions inicial i final.
--             - b:           Objecte tipus "Piece" conté les posicions de les dues parts de la peça, l'estat d'aquesta i la seva orientació.
--             - m:           Objecte tipus "Movement" conté un dels quatre moviments possibles
-- Funció: Executa el moviment indicat per el parametre "m" sobre la peça "b" canviant la seva posició i estats
move :: Level  -> Piece ->  Movement -> Piece
move lvl b m = createNextPosition lvl b m 