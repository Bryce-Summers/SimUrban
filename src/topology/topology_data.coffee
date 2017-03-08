###
    Scribble.JS Halfedge Graph data classes.
    Data Classes that associated Sim Urban relevant information with Halfedge graph Topology members.

    Written by Bryce Summers on 3 - 7 - 2017.
###


class TSAG.Graph_Data
    
    # SCRIB.Graph
    constructor: (@graph) ->
        
    # Marks are very useful in various algorithms that
    # act upon global collections of topological elements.
    clearFaceMarks: () ->
        iter = @graph.facesBegin();
        while(iter.hasNext())
            iter.next().data.marked = false

    clearVertexMarks:   () ->
        iter = @graph.verticesBegin()
        while(iter.hasNext())
            iter.next().data.marked = false

    clearEdgeMarks:     () ->

        iter = @graph.edgesBegin()
        while(iter.hasNext())
            iter.next().data.marked = false

    clearHalfedgeMarks: () ->

        iter = @graph.halfedgesBegin()
        while(iter.hasNext())
            iter.next().data.marked = false

    clearMarks: () ->
        @clearFaceMarks()
        @clearVertexMarks()
        @clearEdgeMarks()
        @clearHalfedgeMarks()

class TSAG.Face_Data
    
    constructor: (@face) ->
        
        @marked = false

        # Area element...
        @element = null


class TSAG.Vertex_Data

    constructor: (@vertex) ->       
        @marked = false

        # BDS.Point
        @point  = null
        
        # e_intersection element...
        @element = null

class TSAG.Edge_Data

    constructor: (@edge) ->
        @marked = false

        # e_road element.
        # Note: a single e_road element may point to many Edge Data members.
        @element = null


class TSAG.Halfedge_Data

    constructor: (@halfedge) ->
    
        @marked = false
        @next_extraordinary = null

        # Road of driveways?
        @element = null

        ###
        @_curve
        @_time1
        @_time2
        ###

    ###

    I wonder if these will be useful in Sim Urban???

    # Halfedges may represent subsections of curves.
    setAssociatedCurve: (obj) ->
        @_curve = obj
        return

    getAssociatedCurve: () ->
        return @_curve

    # Associate parameter values with the beginning and end of this halfedge.
    setTimes: (time1, time2) ->
        @_time1 = time1
        @_time2 = time2

    getTimes: () ->
        return undefined if @_time1 is undefined
        return [@_time1, @_time2]
    ###
