# Bloxorz_2D :space_invader:
#### 1.- INTRODUCCIÓN

Este proyecto corresponde a la materia de **Paradigmas y lenguajes de programación** de la **Universidad de Girona**.

El juego del [Bloxorz] (http://web.eecs.umich.edu/~gameprof/gamewiki/index.php/Bloxorz) es el típico juego rompecabezas que se puede enmarcar en los clásicos problemas de la inteligencia artificial de planificación: dado un mundo con unas reglas que definen unas acciones que cambian el estado del mundo, decidir si existe una secuencia de acciones que nos lleven del estado inicial al estado final.

#### 2.- OBJETIVOS

- Desarrollar el juego del Bloxorz en Haskell.
- La entrada/salida del juego debería ser en modo texto, pero la adaptamos creando un modulo gráfico en 2D. Los '1' representaran las casillas por las que el bloque se puede mover, mientras que los '0' representaran las casillas “vaciás” por las que el bloque no se puede mover. En los próximos apartados detallamos el estilo del tablero y los tipos de casilla.
- Crear dos métodos de juego, interactivo (player) y automático (cpu). El automático debe solucionar el mapa con el menor numero de movimientos y mostrar la solución.
- Desarrollar un modulo gráfico que permita cargar los mapas definidos anteriormente.

#### 3.- REQUISITOS PREVIOS

- [Glasgow Haskell Compiler (GHC) v7.10.3](https://www.haskell.org/platform/): Para la compilación del proyecto hemos hecho servir el compilador GHC. Nuestra recomendación es instalar “Haskell Platform”, una conjunto de herramientas que contiene el compilador requerido y otras herramientas necesarias como “cabal”, entre otras.

- [WxHaskell v0.92](https://wiki.haskell.org/WxHaskell/Windows): Librería basada en wxWidgets v3.0 que hemos hecho servir para el modulo gráfico. Tuvimos diversos problemas para instalarla en diversas plataformas. Al final solo lo conseguimos en Windows 10. Siguiendo los consejos del siguiente enlace, algunas horas de esfuerzo y algo de ingenio conseguimos instalarla satisfactoriamente.

#### 4.- ELEMENTOS DEL JUEGO

El juego esta formado por un tablero compuesto de casillas y un bloque. Supongamos que cada casilla es de 1x1, sin altura. El bloque esta formado por 1x1x2, en este caso si tenemos altura, no obstante solo la apreciaremos cuando el bloque este “tumbado” en el tablero.

| Carácter | Color | Código RGB | Tipo |
| --- | --- | --- | --- |
| S | Amarillo | 230 255 0 | Inicio |
| B | Verde | 0 255 0 | Bloque |
| G | Turquesa | 3 168 171 | Fin |
| {A..Z} ∉ {S,B,G} | Azul | 75 72 250 | Botón puente |
| 0 | Negro | 0 0 0 | Vacío |
| 1 | Blanco | 255 255 255 | Normal |
| 2 | Naranja | 255 140 0 | Sensible |
| {3..9} | Gama de rosas/lilas | none | Teleport |


#### 5.- COMO UTILIZARLO

A continuación presentamos los 3 modos de ejecución:
> ATENCIÓN:
> - Estamos trabajando para mostrar los 3 metodos de ejecucion (gif & video)
> - Bloxorz_2D solo sera ejecutable en los sistemas que cumplan los requisitos previos. Actualmente estamos trabajando en una versión compilada estaticamente para que los usuarios puedan disfrutar del juego sin tener que cumplir los requisitos del sistema.

#### 6.- DESARROLLADORES

@Miquel Isern Roca

@Sergi Bernad Santiago

[@Thyplock](https://github.com/BrunoAltadill)
