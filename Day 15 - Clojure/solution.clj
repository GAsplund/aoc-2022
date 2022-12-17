(require '[clojure.string :as str])
(require '[clojure.edn :as edn])
(require '[clojure.set :as set])

(defn coordint [p] (vec [(edn/read-string (get p 0)), (edn/read-string (get p 1))]))
(defn lineCoords  [p dist level]
(for [i (range (- (max 0, (- dist (Math/abs (- level (get p 1)))))) (+ (max -1, (- dist (Math/abs (- level (get p 1))))) 1))] 
(vec [(+ (get p 0) i), level])
))

(defn manhattan  [p1 p2]  (+ (Math/abs (- (get p1 0) (get p2 0))) (Math/abs (- (get p1 1) (get p2 1)))) )

(defn taxicab [p r] (for [level (range (- (get p 1) (+ r 1)) (+ (get p 1) (+ r 1)))] (for [i [(- (max 0, (- (+ r 1) (Math/abs (- level (get p 1)))))), (+ (max -1, (- (+ r 1) (Math/abs (- level (get p 1))))) 1)]] 
(vec [(+ (get p 0) i), level])
)))

(def sensorpairs (for [q (str/split-lines (slurp "./test.txt"))] (for [p (str/split (subs q 12) #": closest beacon is at x=")] (coordint (str/split p #", y=")))))
(def sensorranges (for [pair sensorpairs] [(nth pair 0), (manhattan (nth pair 0) (nth pair 1))]))
(def knownbeacons (set (for [pair sensorpairs] [(get (nth pair 1) 0), (get (nth pair 1) 1)])))

; Hardcoded numbers... not very fun lol (desired y level at last numberic argument)
(def sensorcoverage (set (apply concat (for [sensor sensorranges] (lineCoords (nth sensor 0)  (nth sensor 1) 2000000 )))))

(def nobeacons (set/difference sensorcoverage knownbeacons))
(def nobeaconscnt (count nobeacons))

; Part 2
(def taxicabs (set (apply concat (apply concat (for [pair sensorpairs] (taxicab (nth pair 0)  (manhattan (nth pair 0) (nth pair 1)) ))))))
(defn insiderange [p] (some true? (for [sensor sensorranges] (>= (nth sensor 1) (manhattan (nth sensor 0) p)) )))

; (+ (get p 0) (get ofs 0))
(defn validspot [p maxLoc]
    (and 
        (and (> (get p 0) 0) (< (get p 0) maxLoc)) 
        (and (> (get p 1) 0) (< (get p 1) maxLoc))
    ))

(defn emptyspot [maxLoc] (for [loc taxicabs] 
    (for [loc taxicabs] 
    (if (and (validspot loc maxLoc) (not (insiderange loc))) loc)
    )))

(def result2 (nth (remove nil? (set (apply concat(emptyspot 4000000)))) 0))

(println "Solution 1:")
(println nobeaconscnt)
(println "Solution 2:")
(println (+(* (get result2 0) 4000000) (get result2 1) ))
