#
# Bryce Summer's Spline Class.
#
# Written on 11/29/2016.
#
# Purpose: Extends the THREE.js spline classes with better features.
#
# Planned:
# 1. Offset Curves.
# 2. Inset Curves.
# 3. Maximum-length interval discretizations for producing renderable line segments.
#
# Currently we are implementing this as a reduction to THREE.CatmullRomCurve3, but we may remove the dependancy if we have time and go sufficiently beyond it.
# FIXME: Standardize the curve class and instantiate it from interfacial curves.
class TSAG.Curve

    constructor: () ->

        # A spline that dynamically parameterizes itself to between 0 and 1.
        @_spline = new THREE THREE.CatmullRomCurve3()

    # p : THREE.Vector3.
    addPoint: (p) ->
        @_spline.points.push(p);

    # Returns a list of points representing this spline.
    # They will be no more than max_length apart.
    # They will be as sparse as is practical. # FIXME: Do some studying of this.
    # See: https://github.com/Bryce-Summers/Bryce-Summers.github.io/blob/master/p5/Physics/Visuals/visual_conservation_of_energy.js
    # This is more efficient than the built in THREE.js version, because it does the binary searches for all of the points at the same time.
    # It may produce up to 2 times as many points though...
    # FIXME: Do an analysis of differnt spline discretization techniques.
    #
    getPoints: (max_length) ->

        output = []
        p0 = @_spline.getPoint(0)
        output.push(p0)

        S = [] # Stack.
        S.push(1.0)
        
        low   = 0
        p_low = @_spline.getPoint(low)

        # The stack stores the right next upper interval.
        # The lower interval starts at 0 and is set to the upper interval
        # every time an interval is less than the max_length, subdivision is terminated.

        # Left to right subdivision loop. Performs a binary search across all intervals.
        while S.length != 0
        
            high   = S.pop()
            p_high = @_spline.getPoint(high)
        
            # Subdivision is sufficient, move on to the next point.
            while p_low.distanceTo(p_high) > max_length
                # Otherwise subdivide the interval and keep going.
                S.push(high)
                high   = (low + high)/2.0
                p_high = @_spline.getPoint(high)
        
            output.push(p_high)
            low   = high
            p_low = p_high
            continue