#
# Useful Mathematics.
#

TSAG.Math = {}

TSAG.Math.distance = (x1, y1, x2, y2) ->
    return Math.sqrt(TSAG.Math.distance_sqr(x1, y1, x2, y2))
    
TSAG.Math.distance_sqr = (x1, y1, x2, y2) ->
    dx = x1 - x2
    dy = y1 - y2
    return dx*dx + dy*dy