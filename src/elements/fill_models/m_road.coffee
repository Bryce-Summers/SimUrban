#
# Road Filled Triangle Model.
#
# Written by Bryce Summers on 12 - 19 - 2016.
#
# Specifies the information class attached to the fill mesh for roads.

class TSAG.M_Road

    constructor: (@t0, @t1, @road) ->

    getPosition: () ->
        return @road.getPosition((@t0 + t1)/2)