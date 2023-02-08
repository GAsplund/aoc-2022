let cubes = new Set();
let adjacents = new Set();

var xmin = 0
var xmax = 0
var ymin = 0
var ymax = 0
var zmin = 0
var zmax = 0

fetch('./input.txt')
  .then(response => response.text())
  .then(text => text.split("\r\n").forEach(position => addCube(position)))
  .then(_ => {
    let outer = floodFill();
    console.log(getSurface());
    console.log(getOuterSurface(outer));
  });

function getSurface() {
  var surfaceArea = 0
  cubes.forEach(cube => {surfaceArea += (6 - findAdjacent(cube, adjacents).length)})
  return surfaceArea
}

function getOuterSurface(outer) {
  var surfaceArea = 0
  cubes.forEach(cube => {surfaceArea += findAdjacent(cube, outer).length})
  return surfaceArea
}

function setMinMax(cube: [number, number, number] | number[]) {
  if(cube[0] < xmin) xmin = cube[0];
  if(cube[0] > xmax) xmax = cube[0];
  if(cube[1] < ymin) ymin = cube[1];
  if(cube[1] > ymax) ymax = cube[1];
  if(cube[2] < zmin) zmin = cube[2];
  if(cube[2] > zmax) zmax = cube[2];
}

function insideRange(cube) {
  return (cube[0] >= xmin-1 && cube[0] <= xmax+1 
       && cube[1] >= ymin-1 && cube[1] <= ymax+1 
       && cube[2] >= zmin-1 && cube[2] <= zmax+1);
}

function addCube (cube: string) {
  adjacents.add(cube)
  let coords: string[] = cube.split(",");
  var coordsNum: [number, number, number] | number[] = [];
  coords.forEach(coord => {
    coordsNum.push(parseInt(coord))
  });
  cubes.add(coordsNum);
  setMinMax(coordsNum);
}

function sumArray(a: number[], b: number[]) {
  var c = [];
  for (var i = 0; i < Math.max(a.length, b.length); i++) {
    c.push((a[i] || 0) + (b[i] || 0));
  }
  return c;
}

function findAdjacent(cube, adj) {
  let offsets: number[][] = [[0, 0, 1], [0, 1, 0], [1, 0, 0]];
  var adjacent = [];
  offsets.forEach(offset => {
    if (adj.has(sumArray(cube, offset).join(","))) adjacent.push(sumArray(cube, offset));
    if (adj.has(sumArray(cube, offset.map(o => -o)).join(","))) adjacent.push(sumArray(cube, offset.map(o => -o)));
  })
  return adjacent
}

function findEmpty(cube) {
  let offsets: number[][] = [[0, 0, 1], [0, 1, 0], [1, 0, 0]];
  var empty = [];
  offsets.forEach(offset => {
    let next = sumArray(cube, offset)
    if (!adjacents.has(next.join(",")) && insideRange(next)) empty.push(next);
    let prev = sumArray(cube, offset.map(o => -o))
    if (!adjacents.has(prev.join(",")) && insideRange(prev)) empty.push(prev);
  })
  return empty
}

function floodFill() {
  let origin = [xmin, ymin, zmin];
  var queue = [origin];
  var visited = new Set();
  while (queue.length > 0) {
    let pos = queue.pop();
    if (visited.has(pos.join(","))) continue;
    visited.add(pos.join(","));

    findEmpty(pos).forEach(otherPos => {
      queue.push(otherPos);
    });
  }
  return visited;
}
