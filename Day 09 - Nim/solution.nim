import std/sets
import std/sequtils
import strutils

proc minusOne(num: int): int =
    if num < 0:
        return num + 1
    else:
        return num - 1

proc moveTail(nextPos: (int, int), tailPos: (int, int)): (int, int) =
    var difference = (nextPos[0]-tailPos[0], nextPos[1]-tailPos[1])
    if difference == (0, 0) or difference == (1, 0) or difference == (0, 1) or difference == (1, 1):
        # Touching
        return tailPos
    elif abs(difference[0]) > 1 and abs(difference[1]) > 1:
        # Off by both row and column
        return (tailPos[0]+minusOne(difference[0]), tailPos[1]+minusOne(difference[1]))
    elif abs(difference[0]) > 1:
        # Off by row (x)
        return (tailPos[0]+minusOne(difference[0]), nextPos[1])
    elif abs(difference[1]) > 1:
        # Off by column (y)
        return (nextPos[0], tailPos[1]+minusOne(difference[1]))
    else:
        return tailPos
        

proc moveHeadAndTail(xDir: int, yDir: int, steps: int, headPos: (int, int), tails: seq[(int, int)]): ((int, int), seq[(int, int)], HashSet[(int, int)]) =
    # Move stepwise, and move tail with it
    var currentHead = headPos
    var currentVisited = initHashSet[(int, int)]()
    var knots = tails
    for _ in 1..steps:
        # Move the head one step
        var nextKnot = (currentHead[0]+xDir, currentHead[1]+yDir)
        currentHead = nextKnot
        # And all the tails with it
        for knot in countdown(tails.len-1, 0):
            nextKnot = moveTail(nextKnot, knots[knot])
            knots[knot] = nextKnot
        
        currentVisited.incl(knots[0])
    return (currentHead, knots, currentVisited)

var oneVisitedCoords = toHashSet([(0, 0)])
var nineVisitedCoords = toHashSet([(0, 0)])

var nineHeadPos = (0, 0)
var oneHeadPos = (0, 0)

var oneTail = [(0, 0)].toSeq
var nineTails = [(0, 0),(0, 0),(0, 0),(0, 0),(0, 0),(0, 0),(0, 0),(0, 0),(0, 0)].toSeq

for line in lines("./test.txt"):
    let direction = line[0]
    let dirLength = parseInt(line[2 .. line.len-1])
    var nineVisited = initHashSet[(int, int)]()
    var oneVisisted = initHashSet[(int, int)]()
    case direction
    of 'U': 
        (nineHeadPos, nineTails, nineVisited) = moveHeadAndTail(0, 1, dirLength, nineHeadPos, nineTails)
        (oneHeadPos, oneTail, oneVisisted) = moveHeadAndTail(0, 1, dirLength, oneHeadPos, oneTail)
    of 'D': 
        (nineHeadPos, nineTails, nineVisited) = moveHeadAndTail(0, -1, dirLength, nineHeadPos, nineTails)
        (oneHeadPos, oneTail, oneVisisted) = moveHeadAndTail(0, -1, dirLength, oneHeadPos, oneTail)
    of 'L': 
        (nineHeadPos, nineTails, nineVisited) = moveHeadAndTail(-1, 0, dirLength, nineHeadPos, nineTails)
        (oneHeadPos, oneTail, oneVisisted) = moveHeadAndTail(-1, 0, dirLength, oneHeadPos, oneTail)
    of 'R': 
        (nineHeadPos, nineTails, nineVisited) = moveHeadAndTail(1, 0, dirLength, nineHeadPos, nineTails)
        (oneHeadPos, oneTail, oneVisisted) = moveHeadAndTail(1, 0, dirLength, oneHeadPos, oneTail)
    else:   
        (nineHeadPos, nineTails, nineVisited) = moveHeadAndTail(0, 0, dirLength, nineHeadPos, nineTails)
        (oneHeadPos, oneTail, oneVisisted) = moveHeadAndTail(0, 0, dirLength, oneHeadPos, oneTail)
    oneVisitedCoords.incl(oneVisisted)
    nineVisitedCoords.incl(nineVisited)

echo "Solution 1: "
echo len(oneVisitedCoords)
echo "Solution 2: "
echo len(nineVisitedCoords)
