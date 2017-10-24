###
    Written by Bryce Summers on 10.23.2017
###

class TSAG.Operator_Model extends TSAG.Model

    constructor: () ->

        # (Object_model) -> enacts a mutation.
        @_mutation_function = null

    buildModel: () ->