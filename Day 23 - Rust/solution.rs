use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use std::collections::HashSet;
use std::collections::HashMap;

fn round_one(elves: &HashSet<(i32, i32)>, round: i32) -> HashMap<(i32, i32), (i32, i32)> {
    let mut proposals: HashMap<(i32, i32), (i32, i32)> = HashMap::new();
    for elf in elves {
        let mut offset = round % 4;
        let mut found_vacant = false;
        let n = !elves.contains(&(elf.0, elf.1 - 1));
        let s = !elves.contains(&(elf.0, elf.1 + 1));
        let w = !elves.contains(&(elf.0 - 1, elf.1));
        let e = !elves.contains(&(elf.0 + 1, elf.1));
        let ne = !elves.contains(&(elf.0 + 1, elf.1 - 1));
        let nw = !elves.contains(&(elf.0 - 1, elf.1 - 1));
        let se = !elves.contains(&(elf.0 + 1, elf.1 + 1));
        let sw = !elves.contains(&(elf.0 - 1, elf.1 + 1));
        if n && s && w && e && ne && nw && se && sw {
            proposals.insert(*elf, *elf);
            found_vacant = true;
        } else {
            for _ in 0..4 {
                if offset == 0 && n && ne && nw {
                    proposals.insert(*elf, (elf.0, elf.1 - 1));
                    found_vacant = true;
                    break;
                } else if offset == 1 && s && se && sw {
                    proposals.insert(*elf, (elf.0, elf.1 + 1));
                    found_vacant = true;
                    break;
                } else if offset == 2 && w && nw && sw {
                    proposals.insert(*elf, (elf.0 - 1, elf.1));
                    found_vacant = true;
                    break;
                } else if offset == 3 && e && ne && se {
                    proposals.insert(*elf, (elf.0 + 1, elf.1));
                    found_vacant = true;
                    break;
                }
                offset += 1;
                offset %= 4;
            }
        }
        if !found_vacant {
            proposals.insert(*elf, *elf);
        }
    }
    
    return proposals;
}

fn round_two(proposals: &HashMap<(i32, i32), (i32, i32)>) -> HashSet<(i32, i32)> {
    let mut filtered_pos: HashSet<(i32, i32)> = HashSet::new();
    for (old, new) in proposals {
        if proposals.values().filter(|&n| *n == *new).count() == 1 {
            filtered_pos.insert(*new);
        } else {
            filtered_pos.insert(*old);
        }
    }
    return filtered_pos;
}

fn find_dimensions(elves: &HashSet<(i32, i32)>) -> (i32, i32, i32, i32) {
    let mut xmin = i32::MAX;
    let mut xmax = 0;
    let mut ymin = i32::MAX;
    let mut ymax = 0;
    for elf in elves {
        if elf.0 > xmax { xmax = elf.0; }
        if elf.0 < xmin { xmin = elf.0; }
        if elf.1 > ymax { ymax = elf.1; }
        if elf.1 < ymin { ymin = elf.1; }
    }
    return (xmin, xmax, ymin, ymax);
}

fn find_empty(elves: &HashSet<(i32, i32)>, xmin: i32, xmax: i32, ymin: i32, ymax: i32) -> i32 {
    let mut total = 0;
    for y in ymin..(ymax+1) {
        for x in xmin..(xmax+1) {
            if !elves.contains(&(x, y)) { total += 1; }
        }
    }
    return total;
}

fn main() {
    let mut ylen: i32 = 0;
    let mut elves1: HashSet<(i32, i32)> = HashSet::new();
    if let Ok(lines) = read_lines("./input.txt") {
        for line in lines {
            if let Ok(ip) = line {
                let mut xlen: i32 = 0;
                for (_i, c) in ip.chars().enumerate() {
                    if c == '#' {
                        elves1.insert((xlen, ylen));
                    }
                    xlen += 1;
                }
                ylen += 1;
            }
        }

        let mut round = 0;
        let mut empty = 0;
        loop {
            let proposals = round_one(&elves1, round);
            let elves2 = round_two(&proposals);
            if elves1 == elves2 { round += 1; break;}
            elves1 = elves2;
            round += 1;
            if round == 10 {
                let dims = find_dimensions(&elves1);
                empty = find_empty(&elves1, dims.0, dims.1, dims.2, dims.3);
            }
        }
        println!("Solution 1: {}", empty);
        println!("Solution 2: {}", round);
    }
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where P: AsRef<Path>, {
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}
