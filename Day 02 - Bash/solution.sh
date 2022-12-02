#!/bin/bash

points=0
points_strat=0
while IFS= read -r line
do
    round=($line)
    if [ ${round[1]} == 'X' ]
    then
        # Star 1: Human picks rock
        # Star 2: Human loses round
        ((points = points + 1))
        # (No points added to strat method due to loss)
        if [ ${round[0]} == 'A' ] # Elf picks rock
        then
            # Star 1: Draw
            # Star 2: Human picks scissors - loss
            ((points = points + 3))
            ((points_strat = points_strat + 3))
        elif [ ${round[0]} == 'B' ] # Elf picks paper
        then
            # Star 1: Loss
            # Star 2: Human picks rock
            ((points_strat = points_strat + 1))
        elif [ ${round[0]} == 'C' ] # Elf picks scissors
        then
            # Star 1: Human wins
            # Star 2: Human picks paper
            ((points = points + 6))
            ((points_strat = points_strat + 2))
        fi
    elif [ ${round[1]} == 'Y' ]
    then
        # Star 1: Human picks paper
        # Star 2: Round ends in a draw
        ((points = points + 2))
        ((points_strat = points_strat + 3))
        if [ ${round[0]} == 'A' ] # Elf picks rock
        then
            # Star 1: Human wins
            # Star 2: Human picks rock
            ((points = points + 6))
            ((points_strat = points_strat + 1))
        elif [ ${round[0]} == 'B' ] # Elf picks paper
        then
            # Star 1: Draw
            # Star 2: Human picks paper
            ((points = points + 3))
            ((points_strat = points_strat + 2))
        elif [ ${round[0]} == 'C' ] # Elf picks scissors
        then
            # Star 1: Human loses
            # Star 2: Human picks scissors
            ((points_strat = points_strat + 3))
        fi
    elif [ ${round[1]} == 'Z' ]
    then
        # Star 1: Human picks scissors 
        # Star 2: Human wins
        ((points = points + 3))
        ((points_strat = points_strat + 6))
        if [ ${round[0]} == 'A' ] # Elf picks rock
        then
            # Star 1: Human loses
            # Star 2: Human picks paper
            ((points_strat = points_strat + 2))
        elif [ ${round[0]} == 'B' ] # Elf picks paper
        then
            # Star 1: Human wins
            # Star 2: Human picks scissors
            ((points = points + 6))
            ((points_strat = points_strat + 3))
        elif [ ${round[0]} == 'C' ] # Elf picks scissors
        then
            # Star 1: Draw
            # Star 2: Human picks rock
            ((points = points + 3))
            ((points_strat = points_strat + 1))
        fi
    fi
done < "./input.txt"

echo "Solution 1: $points"
echo "Solution 2: $points_strat"
