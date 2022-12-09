#!/usr/local/bin/julia

forest = [[parse(Int8, tree) for tree in line] for line in eachline("./input.txt")]
forest = reduce(vcat,transpose.(forest))

height = length(forest[:,1])
width = length(forest[1,:])

function findVisibleTrees(width, height)
    global forest
    visibleTrees = zeros(Int8, height, width)
    for h in 1:height
        visible = findVisibleLine(forest[h,:])
        for i in 1:length(visible)
            if visibleTrees[h,i] == 0
                visibleTrees[h,i] = visible[i]
            end
        end
    end
    for v in 1:width
        visible = findVisibleLine(forest[:,v])
        for i in 1:length(visible)
            if visibleTrees[i,v] == 0
                visibleTrees[i,v] = visible[i]
            end
        end

    end
    return visibleTrees
end

function findVisibleLine(line)
    tallestTree = -1
    trees = zeros(Int8, length(line))
    for tree in 1:length(line)
        if line[tree] > tallestTree
            tallestTree = line[tree]
            trees[tree] = 1
        end
    end
    tallestTree = -1
    for tree in length(line):-1:1
        if line[tree] > tallestTree
            tallestTree = line[tree]
            trees[tree] = 1
        end
    end
    return trees
end

function getScenicScore(coordinates)
    global forest
    tallestTree = forest[coordinates[1], coordinates[2]]
    vertical = forest[:,coordinates[2]]
    horizontal = forest[coordinates[1],:]

    # North
    scNorth = 0
    for tree in coordinates[1]-1:-1:1
        scNorth += 1
        if vertical[tree] >= tallestTree
            break
        end
    end

    # South
    scSouth = 0
    for tree in coordinates[1]+1:length(vertical)
        scSouth += 1
        if vertical[tree] >= tallestTree
            break
        end
    end

    # West
    scWest = 0
    for tree in coordinates[2]-1:-1:1
        scWest += 1
        if horizontal[tree] >= tallestTree
            break
        end
    end

    # East
    scEast = 0
    for tree in coordinates[2]+1:length(horizontal)
        scEast += 1
        if horizontal[tree] >= tallestTree
            break
        end
    end
    return scNorth * scSouth * scWest * scEast
end

function getBestScenicScore()
    global width
    global height
    maxScenic = -1
    for v in 1:width
        for w in 1:height
            scenic = getScenicScore((w, v))
            if scenic > maxScenic
                maxScenic = scenic
            end
        end
    end
    return maxScenic
end

visibleTrees = findVisibleTrees(width, height)
print("Solution 1: ")
println(count(i->(i>=1), visibleTrees))

print("Solution 2: ")
println(getBestScenicScore())
