package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
)

type coord struct {
	x int
	y int
}

const (
	right int = 0
	down      = 1
	left      = 2
	up        = 3
)

func replaceAtIndex(in string, r rune, i int) string {
	out := []rune(in)
	out[i] = r
	return string(out)
}

func main() {

	readFile, err := os.Open("./input.txt")

	if err != nil {
		fmt.Println(err)
	}
	fileScanner := bufio.NewScanner(readFile)

	fileScanner.Split(bufio.ScanLines)

	r, _ := regexp.Compile("[A-Z]|\\d+")

	var forcefields []string
	var instructions []string
	for fileScanner.Scan() {
		if fileScanner.Text() == "" {
			fileScanner.Scan()
			instructions = r.FindAllString(fileScanner.Text(), -1)
			break
		}
		forcefields = append(forcefields, fileScanner.Text())
	}
	forcefieldsCube := forcefields

	direction := right
	position := getStart(forcefields)

	for _, instruction := range instructions {
		position, direction = executeInstruction(forcefields, instruction, direction, position, false)
		forcefields[position.y] = replaceAtIndex(forcefields[position.y], rune('0'), position.x)
	}

	finalSum := 1000*(position.y+1) + 4*(position.x+1) + direction
	fmt.Printf("Solution 1: %d\n", finalSum)

	direction = right
	position = getStart(forcefieldsCube)

	for _, instruction := range instructions {
		position, direction = executeInstruction(forcefieldsCube, instruction, direction, position, true)
		forcefieldsCube[position.y] = replaceAtIndex(forcefieldsCube[position.y], rune('0'), position.x)
	}

	finalSumCube := 1000*(position.y+1) + 4*(position.x+1) + direction
	fmt.Printf("Solution 2: %d\n", finalSumCube)
}

func executeInstruction(terrain []string, instruction string, direction int, position coord, isCube bool) (newPos coord, newDir int) {
	if num, err := strconv.Atoi(instruction); err == nil {
		for i := 1; i <= num; i++ {
			nextPosition := move(direction, position)
			nextDirection := direction
			if checkOOB(terrain, nextPosition) {
				if isCube {
					nextPosition, nextDirection = wrapAroundCube(terrain, direction, nextPosition)
				} else {
					nextPosition = wrapAround(terrain, direction, nextPosition)
				}

			}
			if !checkCollision(terrain, nextPosition) {
				position = nextPosition
				direction = nextDirection
			}
		}
	} else if instruction == "L" {
		direction -= 1
		if direction == -1 {
			direction = 3
		}
	} else if instruction == "R" {
		direction += 1
		direction %= 4
	}
	return position, direction
}

func checkCollision(terrain []string, pos coord) (collide bool) {
	return terrain[pos.y][pos.x] == '#'
}

func checkOOB(terrain []string, pos coord) (oob bool) {
	return pos.x < 0 || pos.y < 0 || pos.y >= len(terrain) || pos.x >= len(terrain[pos.y]) || terrain[pos.y][pos.x] == ' '
}

func getStart(top []string) (pos coord) {
	// The leftmost open tile of the top row of tiles.
	// Initially facing to the right
	xpos := 0
	for top[0][xpos] == ' ' {
		xpos++
	}
	return coord{x: xpos, y: 0}
}

func move(direction int, position coord) (newPos coord) {
	// Moves 1 steps in the current direction
	switch direction {
	case up:
		return coord{x: position.x, y: position.y - 1}
	case down:
		return coord{x: position.x, y: position.y + 1}
	case left:
		return coord{x: position.x - 1, y: position.y}
	case right:
		return coord{x: position.x + 1, y: position.y}
	default:
		return position
	}
}

func wrapAround(terrain []string, direction int, position coord) (newPosition coord) {
	// Reverses until edge has been reached
	newDirection := (direction + 2) % 4
	newPos := move(newDirection, position)
	for newPos.x >= 0 && newPos.y >= 0 && !checkOOB(terrain, newPos) {
		position = newPos
		newPos = move(newDirection, newPos)
	}
	return position
}

func wrapAroundCube(terrain []string, direction int, position coord) (newPosition coord, newDirection int) {
	// Wraps to another side of the cube
	// Do this instead of wrapAround for solution 2
	switch direction {
	case up:
		if position.y == -1 {
			if position.x < 100 {
				// 1 to 6
				direction = right
				position.y = 100 + position.x
				position.x = 0
			} else {
				// 2 to 6
				direction = up
				position.x -= 100
				position.y = 199
			}
		} else if position.y == 99 {
			// 5 to 3
			direction = right
			position.y = 50 + position.x
			position.x = 50
		}
	case down:
		if position.y == 50 {
			// 2 to 3
			direction = left
			position.y = position.x - 50
			position.x = 99
		} else if position.y == 150 {
			// 4 to 6
			direction = left
			position.y = position.x + 100
			position.x = 49
		} else if position.y == 200 {
			// 6 to 2
			direction = down
			position.x += 100
			position.y = 0
		}
	case right:
		if position.x == 150 {
			// 2 to 4
			direction = left
			position.y = 149 - position.y
			position.x = 99
		} else if position.x == 100 {
			if position.y < 100 {
				// 3 to 2
				direction = up
				position.x = position.y + 50
				position.y = 49
			} else {
				// 4 to 2
				direction = left
				position.y = 149 - position.y
				position.x = 149
			}
		} else if position.x == 50 {
			// 6 to 4
			direction = up
			position.x = position.y - 100
			position.y = 149
		}
	case left:
		if position.x == 49 {
			if position.y < 50 {
				// 1 to 5
				direction = right
				position.y = 149 - position.y
				position.x = 0
			} else {
				// 3 to 5
				direction = down
				position.x = position.y - 50
				position.y = 100
			}
		} else if position.x == -1 {
			if position.y < 150 {
				// 5 to 1
				direction = right
				position.y = 149 - position.y
				position.x = 50
			} else {
				// 6 to 1
				direction = down
				position.x = position.y - 100
				position.y = 0
			}
		}
	default:
		return position, direction
	}
	return position, direction
}
