jets = read.delim("./input.txt", header = FALSE)
jetCnt = nchar(jets)
jetPos = 0

blocks <- new.env(hash=TRUE)
states <- new.env(hash=TRUE)

rock1 = list(1, 1, 1, 1)
rock2 = append(append(list(list(0, 1, 0)), list(list(1, 1, 1))), list(list(0, 1, 0)))
rock3 = append(append(list(list(1, 0, 0)), list(list(1, 0, 0))), list(list(1, 1, 1)))
rock4 = list(list(1, 1, 1, 1))
rock5 = append(list(list(1, 1)), list(list(1, 1)))

rocks <- append(append(append(append(list(rock1), list(rock2)), list(rock3)), list(rock4)), list(rock5))

rockNum = 5

movePossible <- function(position, direction, type) {
    for (i in 1:(length(rocks[[type]]))) {
        for (j in 1:(length(rocks[[type]][[i]]))) {
            if (rocks[[type]][[i]][[j]] == 1) {
                k = i + position[[1]] + direction[[1]]
                l = j + position[[2]] + direction[[2]]
                if (k < 1 || k > 7) {
                    return(FALSE)
                }
                if (l < 1) {
                    return(FALSE)
                }
                coords = paste(c(k, ',', l), collapse='')
                if (!is.null(blocks[[coords]])) {
                    return(FALSE)
                }
            }
        }
    }
    return(TRUE)
}

highestpoint <- 0
highestcolumns <- list(0, 0, 0, 0, 0, 0, 0)

placeRock <- function(position, type) {
    for (i in 1:(length(rocks[[type]]))) {
        for (j in 1:(length(rocks[[type]][[i]]))) {
            if (rocks[[type]][[i]][[j]] == 1) {
                blocks[[paste(c(i+position[1], ',', j+position[2]), collapse='')]] <- 1
                if (j+position[2] > highestpoint) {
                    highestpoint <- j+position[2]
                }
                if (j+position[2] > highestcolumns[i+position[1]]) {
                    highestcolumns[i+position[1]] <- j+position[2]
                }
            }
        }
    }
    minstate = min(unlist(highestcolumns))
    state = c()
    for (c in highestcolumns) {
        state = append(state, c-minstate)
    }
    return(c(blocks, highestpoint, list(highestcolumns), paste(state, collapse=',')))
}

cycleFound <- FALSE
totaldiff <- 0

iterations <- 1000000000000
highestpoint2022 <- 0

i <- 0
while (i < iterations) {
    rockPos = c(2, highestpoint+3)
    rockNum = (i %% 5)

    if (i == 2022) {
        highestpoint2022 <- highestpoint
    }

    settled = FALSE
    while (TRUE) {
        if (substr(jets, jetPos+1, jetPos+1) == "<") {
            if (movePossible(rockPos, c(-1, 0), rockNum+1)) {
                rockPos = c(rockPos[[1]]-1, rockPos[[2]])
            }
        } else if (movePossible(rockPos, c(1, 0), rockNum+1)) {
            rockPos = c(rockPos[[1]]+1, rockPos[[2]])
        }
        
        if (movePossible(rockPos, c(0, -1), rockNum+1)) {
            rockPos = c(rockPos[[1]], rockPos[[2]]-1)
        } else {
            result = placeRock(rockPos, rockNum+1)

            blocks <- result[[1]]
            highestpoint <- result[[2]]
            highestcolumns <- result[[3]]
            state = result[[4]]

            jetPos <- ((jetPos + 1) %% jetCnt)
            break
        }
        jetPos <- ((jetPos + 1) %% jetCnt)
    }

    i <- i + 1

    if (!cycleFound && i > 15000) {
        if (!is.null(states[[state]])) {
            if(states[[state]][[3]] == jetPos && states[[state]][[4]] == rockNum) {
                cycleheight = highestpoint - states[[state]][[2]]
                cyclestones = i - states[[state]][[1]]

                stonesleft = iterations - i
                cyclerepeats = stonesleft %/% cyclestones
                totaldiff <- cycleheight * cyclerepeats

                i <- i + cyclestones * cyclerepeats

                cycleFound <- TRUE
            }


        } else {
            states[[state]] <- c(i, list(highestpoint), jetPos, rockNum)
        }
    }

}

print(noquote(paste(c("Solution 1: ", highestpoint2022), collapse='')))
print(noquote(paste(c("Solution 2: ", format(highestpoint+totaldiff, scientific=FALSE)), collapse='')))
