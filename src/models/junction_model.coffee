###
    Written by Bryce Summers on 10.23.2017
###

class TSAG.Junction_Model extends TSAG.Model

    constructor: () ->

        # An array of sets of potential paths.
        # potential path = path, {paths that must be empty}, Condition for taking path.
        @_configurations = null

    buildModel: () ->