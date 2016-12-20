###
#
# Element Interface Class.
# This specifies properties of all element objects.
#
# Written by Bryce Summers on 12 - 19 - 2016.
#
###

class TSAG.E_Super

    # Input something like a THREE.Scene object if desired.
    constructor: (@_view) ->

        # Define @_view if it is not given.
        if not @_view
            @_view = new THREE.Object3D()

        @_BVH = null

    # Returns the current visual.
    getVisual: () ->

        return @_view

    # Returns a new visual that is freshly constructed based on the given viewport.
    # some classes, such as road networks will provide a function to reconstruct the visual, optimized for a particular viewport.
    #toVisual: (viewport) ->