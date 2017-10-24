###
    Written by Bryce Summers on 10.23.2017

    Conditional models allow either accept or reject a given object model depending
    this conditional model's prediated test configuration.
###

class TSAG.Condition_Model extends TSAG.Model

    @EQ = "="
    @LE = "<="
    @GE = ">="
    @LT = "<"
    @GT = ">"
    @NE = "!="

    @VAR = 0 # Key is a name of variable to be looked up in the object.
    @CONSTANT = 1 # key is a constant used for being compared to.

    # String or primitive, variable/constant, comparison operator, key, variable/constant.
    constructor: (@key1, @type1, @operator, @key2, @type2) ->

    buildModel: () ->

    evaluateObject: (obj) ->

        if @type1 == TSAG.Condition_Model.VAR
            val1 = obj.lookup(@key1)
        else # Constant.
            val1 = @key1

        if @type2 == TSAG.Condition_Model.VAR
            val2 = obj.lookupKey(@key2)
        else # Constant.
            val2 = @key2

        switch @operator
            when TSAG.Condition_Model.EQ then return val1 == val2
            when TSAG.Condition_Model.LE then return val1 <= val2
            when TSAG.Condition_Model.GE then return val1 >= val2
            when TSAG.Condition_Model.LT then return val1 <  val2
            when TSAG.Condition_Model.GT then return val1 >  val2
            when TSAG.Condition_Model.NE then return val1 != val2
            else console.log("Conditional: " + @operator + " is not defined.")
