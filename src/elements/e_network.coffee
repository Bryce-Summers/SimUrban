#
# Transportation Network.
#
# Written by Bryce Summers   on 12 - 18 - 2016.
# Rewritten by Bryce Summers on 1 - 26 - 2017.
#
# Purpose:
# This class represents a connected transportation network and provides gameplay functionality and rendering capabilities.
# Its functions are named according to gameplay uses, rather than mathematical imperatives.
# 
# This class represents all the urban systems linkages, rather than extraneous User Interfaces and such.
#
class TSAG.E_Network extends TSAG.E_Super

    # Takes in a SCRIB.Graph.
    constructor: (graph) ->
    
        super()

        # Use the graph as this network's topology object.
        @setTopology(graph)

        # We need a graph processor to make topology updates.
        @_network_processor = new SCRIB.PolylineGraphPostProcessor(graph)

        # FIXME: We shouldn't need these, since they will be associated with topological elements.
        #@_intersections = []
        #@_roads         = []

    # The network exposes an interface for the following kinds of actions:
    # From aa_e_super interface.
    # 1. addElement(e)         -> Adds the element's visual display and collision detection.
    # 2. removeElement(e)      -> Remove's the elements visual display and collision detection.
    #
    # 3. queryingElement(polygon()) -> Returns any element of the given type found inside the given world coordinate region.
    #
    # 4. linkElement(e)       -> Embeds the given element into the Network Topology.
    # 5. unlinkElement(e)     -> Removes the given element from the Network Topology.

    
    # Returns all elements that are found at the given point.
    query_elements_pt: (x, y) ->

        polylines = @_bvh.query_point_all(new BDS.Point(x, y))

        elements = []

        for polyline in polylines
            elements.push(polyline.getAssociatedData())

        return elements

    # BDS.Box -> TSAG.Element[]
    query_elements_box: (box) ->
    
        polylines = @_bvh.query_box_all(box)
        elements  = []

        for polyline in polylines
            elements.push(polyline.getAssociatedData())

        return elements


    # -- Topology Creation, modification, and destruction functions.

    newTopology_vertex: () ->

        graph = @getTopology()



        return 