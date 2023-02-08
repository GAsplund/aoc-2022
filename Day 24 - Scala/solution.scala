import scala.io.Source
import util.control.Breaks._


def gcd(a: Int, b: Int):Int=if (b==0) a.abs else gcd(b, a%b)
def lcm(a: Int, b: Int)=(a*b).abs/gcd(a,b)

def wrapIndex(i: Int, i_max: Int): Int = {
   return ((i % i_max) + i_max) % i_max;
}
def dirToVec(direction: Char): (Int, Int) =
   direction match {
      case '^' => (-1, 0) // up
      case '>' => (0, 1) // right
      case 'v' => (1, 0) // down
      case '<' => (0, -1) // left
      case _ => (0, 0) // invalid direction
   }

class Blizzard(position: (Int, Int), level: Int, direction: (Int, Int)) {

   def getNext(height: Int, width: Int, depth: Int): Blizzard = {
      
      return new Blizzard((
         wrapIndex(this.position._1 - 1 + this.direction._1, height) + 1,
         wrapIndex(this.position._2 - 1 + this.direction._2, width) + 1
         ),
         (this.level + 1) % depth,
         this.direction
      )
   }

   def getPos(): (Int, Int) = this.position;
}

var terrain: Array[String] = Array()
var blizzards: Array[Array[Blizzard]] = Array()
var blizzard_pos: Array[scala.collection.mutable.Set[(Int, Int)]] = Array()
var height = 0;
val source = Source.fromFile("input.txt")

// Parse first iteration for blizzards
var blizzards_first: Array[Blizzard] = Array();
var blizzards_pos_first = scala.collection.mutable.Set[(Int, Int)]();
for (line <- source.getLines()) {
   terrain = terrain :+ line

   var w = 0;
   for (char <- line) {
      if (!(char == '.') && !(char == '#'))  {
         val b_coord = (height, w);
         val new_blizzard = new Blizzard(b_coord, 0, dirToVec(char));
         blizzards_first = blizzards_first :+ new_blizzard;
         blizzards_pos_first += b_coord;
      }
      w = w + 1;
   }
   height = height + 1
}
blizzards = blizzards :+ blizzards_first;
blizzard_pos = blizzard_pos :+ blizzards_pos_first;
   
source.close()

val width = terrain(0).length - 2
height = height - 2

val depth = lcm(width, height)

// Calculate all possible blizzard states
var last_blizzard: Array[Blizzard] = blizzards_first;
var last_blizzard_pos: scala.collection.mutable.Set[(Int, Int)] = blizzards_pos_first;
for (d <- 1 to depth) {
   var blizzard_layer: Array[Blizzard] = Array();
   var blizzard_pos_layer = scala.collection.mutable.Set[(Int, Int)]();
   for (blizzard <- last_blizzard) {
      val next_blizzard = blizzard.getNext(height, width, depth);
      blizzard_layer = blizzard_layer :+ next_blizzard;
      blizzard_pos_layer += next_blizzard.getPos();
   }
   blizzards = blizzards :+ blizzard_layer;
   blizzard_pos = blizzard_pos :+ blizzard_pos_layer;
   last_blizzard = blizzard_layer;
   last_blizzard_pos = blizzard_pos_layer;
}

def getNext(node: (Int, Int), level: Int, dist: Int): Array[(Int, Int, Int, Int)] = {
   val moveDirections = Array((0, 0), (0, 1), (0, -1), (1, 0), (-1, 0));
   var possiblePositions: Array[(Int, Int, Int, Int)] = Array();
   val nextDepth = (level + 1) % depth;
   val nextDist = dist + 1;

   for (dir <- moveDirections) {
      val newPos = (node._1 + dir._1, node._2 + dir._2, nextDepth, nextDist);
      val newCoord = (newPos._1, newPos._2);
      if ((!blizzard_pos(nextDepth).contains(newCoord)  && newPos._1 <= height && newPos._1 > 0 && newPos._2 <= width && newPos._2 > 0) 
          || (newPos._1 == height + 1 && newPos._2 == width)
          || (newPos._1 == 0 && newPos._2 == 1)) {
         possiblePositions = possiblePositions :+ newPos;
      }
   }
   return possiblePositions;
}

def dijkstra(pos: (Int, Int), goal: (Int, Int), start_level: Int): (Int, Int, Int, Int) = {
   // y, x, level, length
   var pq = collection.mutable.PriorityQueue.empty[(Int, Int, Int, Int)](Ordering.by((_: (Int, Int, Int, Int))._4).reverse);
   pq.enqueue((pos._1, pos._2, start_level, 0));
   var visited = scala.collection.mutable.Set[(Int, Int, Int)]();

   while (!pq.isEmpty) {
      val node = pq.dequeue();
      breakable {
         val node_pos = (node._1, node._2);
         val node_pos_level = (node._1, node._2, node._3);
         if (visited contains node_pos_level) break;
         visited += node_pos_level;
         if (node_pos == goal) return node;
         for (nextNode <- getNext(node_pos, node._3, node._4)) {
            pq.enqueue(nextNode);
         }
      }

   }
   return (-1, -1, -1, -1);
}

// y, x coordinates
var pos = (0, 1)
val goal = (height + 1, width)

val to_end = dijkstra(pos, goal, 0);
val back_start = dijkstra(goal, pos, to_end._3);
val back_end = dijkstra(pos, goal, back_start._3);

print("Solution 1: ")
println(to_end._4);
print("Solution 2: ")
println(to_end._4 + back_start._4 + back_end._4);
