###
    Written by Bryce Summers on 10.23.2017

    A model for the navigation of an object.

    This handles all of the logic for location and the creation of plans.
    Objects determine when to plan.
###

class TSAG.Navigation_Model extends TSAG.Model

    # TSAG.Model starting point, and desired destination point.
    constructor: (src, dest) ->

        # a Pointer to the model that this navigation is currently at.
        @current_location_model = src
        @destination = dest

        # The next parts of the plan come straight off the stack.
        @plan_stack = []

        # The transversed parts of the plan go onto this stack.
        @finished_plan_stack = []

        @buildModel()

    # Performs an A* search to update this navigation model
    # with an efficient path from its current location to its destination.
    # If this is a conditional path, then a path made not become apparent.
    # Returns True if a complete plan has been worked out, false otherwise.
    # Objects are responsible for only planning when sensible.
    updatePlan: () ->



    # Returns 
    get_current_location: () ->
        return @current_location_model
