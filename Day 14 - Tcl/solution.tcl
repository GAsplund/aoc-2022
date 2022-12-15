proc mcsplit "str splitStr {mc {\x00}}" {
    return [split [string map [list $splitStr $mc] $str] $mc]
}

set cave [dict create]
set lowestPoint 0

# Construct walls
set f [open "./input.txt"]
while {[gets $f line] >= 0} {
    set walls [mcsplit $line " -> "]
    for {set i 0} {$i < [llength $walls]-1} {incr i} {
        set fromCoords [split [lindex $walls $i] ","]
        set toCoords [split [lindex $walls $i+1] ","]

        if {[lindex $fromCoords 1] > $lowestPoint} {
            set lowestPoint [lindex $fromCoords 1]
        } elseif {[lindex $toCoords 1] > $lowestPoint} {
            set lowestPoint [lindex $toCoords 1]
        }

        if {[lindex $fromCoords 0] == [lindex $toCoords 0]} {
            if {[lindex $fromCoords 1] > [lindex $toCoords 1]} {
                set from [lindex $toCoords 1]
                set to [lindex $fromCoords 1]
            } else {
                set from [lindex $fromCoords 1]
                set to [lindex $toCoords 1]
            }
            for {set j $from} {$j <= $to} {incr j} {
                dict set cave "[lindex $fromCoords 0], $j" "#"
            }
        } else {
            if {[lindex $fromCoords 0] > [lindex $toCoords 0]} {
                set from [lindex $toCoords 0]
                set to [lindex $fromCoords 0]
            } else {
                set from [lindex $fromCoords 0]
                set to [lindex $toCoords 0]
            }
            for {set j $from} {$j <= $to} {incr j} {
                dict set cave "$j, [lindex $fromCoords 1]" "#"
            }
        }
    }
}
close $f

set lowerFloor [expr $lowestPoint+2]

foreach {k v} $cave {#puts $k=$v}

set spaceLeft 1
set totalGrains 0
set aboveGrains 0
set fallenBelow 0
while {$spaceLeft} {
    set running 1
    set grainX 500
    set grainY 0
    while {$running} {
        if {$grainY > $lowestPoint} {
            if {!$fallenBelow} {
                set aboveGrains [expr $totalGrains]
                set fallenBelow 1
            }
        }
        if {[dict exists $cave "$grainX, 0"]} {
            incr running [expr -$running]
            set spaceLeft 0
        } elseif {[dict exists $cave "$grainX, [expr $grainY+1]"] || [expr $grainY+1] >= $lowerFloor} {
            if {[expr $grainY+1] >= $lowerFloor} {
                dict set cave "$grainX, $grainY" "o"
                incr totalGrains
                incr running [expr -$running]
            } elseif {![dict exists $cave "[expr $grainX-1], [expr $grainY+1]"]} {
                incr grainX -1
                incr grainY
            } elseif {![dict exists $cave "[expr $grainX+1], [expr $grainY+1]"]} {
                incr grainX
                incr grainY
            } else {
                dict set cave "$grainX, $grainY" "o"
                incr totalGrains
                incr running [expr -$running]
            }
        } else {
            incr grainY 1
        }
    }
}

puts "Solution 1: $aboveGrains"
puts "Solution 2: [expr $totalGrains]"
