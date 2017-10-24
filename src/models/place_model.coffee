###
    Place Class.
    Defines a place model.
    Written by Bryce Summers on 10.23.2017
        
    The User is always viewing a visual representation of a place model.
    There are also a set of active places currently in the model hiearchy handled by the scene object.
###

class TSAG.Place_Model extends TSAG.Model

    constructor: () ->

        @_object_spawners = null
