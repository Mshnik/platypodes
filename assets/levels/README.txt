This asset folder stores the templates for our different levels.

Template schema:

rows: <NUMBER OF ROWS>
cols: <NUMBER OF COLUMNS>

Regular tile: .
Mirrors: N, E, S, W for each rotation configuration
Walls: w
Holes: h
*Light source: 1, 2, 3, 4 for each rotation configuration (aka which way the light shoots out)  * = required
*Light switch: l
*Exit: e
*Character start tile: c

***The rotation configurations 1,2,3,4 and N,E,S,W start from NORTH and go clockwise.
For mirrors: (N : North, E : East, S : South, W : West)
For light source: (1 : North, 2 :East , 3: South, 4 :West)



Example of a .txt file describing a 4 rows by 6 columns level:

4
6
..3...
.N..w.
.l..h.
c....e

***Please do not add extra \newlines between any of those lines**






