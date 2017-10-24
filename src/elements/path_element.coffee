#
# Place Elements handle the organization of all place content.
# Place elements only need pointers to those elements that they will change.

class TSAG.Path_Element extends TSAG.Element

    constructor: (model, polyline, width, fill_color) ->

        super(model)

        # Representation stuff.
        @_polyline = null
        @_width = null

    # Returns a BDS.Point representing the location a given percentage of the way along the path.
    # Also returns a tangent direction to specify the orientation of the object along the path.
    # float -> [BDS.Point, BDS.Point]
    getLocation: (percentage) ->