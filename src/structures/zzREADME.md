# Structure Development Design Document

Written by Bryce Summers starting on 12 - 18 - 2016.


Structural classes implement rigourously specified algorithms. These structural classes are then used to facillitate gameplay needs.


S stands for structure.

# Purpose
This document explains the design descisions for the structures classes in the Sim Urban Game. The structures classes provide the algorithmic functionality for the game, such as Spatial subdivision schemes to optimize collission detection queries,
and networks that are used to connect curves and provide paths for agents.

'Structures' are used to organize 'elements' which are objects that have visual and thematic meaning to the player, such as roads in the Sim Urban game.
Elements contains links back to structural elements.