###
    Written by Bryce Summers on 10.23.2017
###

class TSAG.Path_Model extends TSAG.Model

    # Paths models use a polyline to determind locations and tangents over time
    # and a destination to represent where the path is going.
    # Note: This is decoupled from the path's representation, which could have ornamentation and width.
    constructor: (capacity, transversal_cost) ->

        # Number of objects that can travel along or be enqueued along this path.
        @_capacity = capacity

        # The number of objects currently on the path.
        @_occupancy = 0

        # Cost of using this path.
        @_cost = transversal_cost

        # The Model that this path points to.
        @destination = null

        # A Pointer to the Object model currently transversing the path, that has made the least progress.
        @last_object = null

    # Returns true if the path is clear of all objects.
    isClear: () ->
        return @_occupancy == 0