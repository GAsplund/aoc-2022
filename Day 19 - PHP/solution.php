<?php
    ini_set('memory_limit', '-1');
    gc_enable();

    class State {
        public $oreRobot;
        public $clayRobot;
        public $obsidianRobot;
        public $geodeRobot;

        public $ores;
        public $clay;
        public $obsidian;
        public $geodes;

        public $minutes;

        function __construct($or, $cr, $obr, $gr, $o, $c, $ob, $g, $m) {
            $this->oreRobot = $or;
            $this->clayRobot = $cr;
            $this->obsidianRobot = $obr;
            $this->geodeRobot = $gr;
            $this->ores = $o;
            $this->clay = $c;
            $this->obsidian = $ob;
            $this->geodes = $g;
            $this->minutes = $m;
        }

        function toStr() {
            return $this->oreRobot."-".
            $this->clayRobot."-".
            $this->obsidianRobot."-".
            $this->geodeRobot."-".
            $this->ores."-".
            $this->clay."-".
            $this->obsidian ."-".
            $this->geodes."-".
            $this->minutes."-";
        }
    }

    class Blueprint {
        public $oreRobotOreCost;

        public $clayRobotOreCost;

        public $obsidianRobotOreCost;
        public $obsidianRobotClayCost;

        public $geodeRobotOreCost;
        public $geodeRobotObsidianCost;

        public $maxOreCost;
        public $maxClayCost;
        public $maxObsidianCost;

        function __construct($oo, $co, $obo, $obc, $go, $gob) {
            $this->oreRobotOreCost = $oo;
            $this->clayRobotOreCost = $co;
            $this->obsidianRobotOreCost = $obo;
            $this->obsidianRobotClayCost = $obc;
            $this->geodeRobotOreCost = $go;
            $this->geodeRobotObsidianCost = $gob;
            $this->maxOreCost = max($oo, $co, $obo, $go);
            $this->maxClayCost = $obc;
            $this->maxObsidianCost = $gob;
        }
    }

    function performTick($state, $time = 1) {
        return new State(
            $state->oreRobot, $state->clayRobot, $state->obsidianRobot, $state->geodeRobot,
            $state->ores+$state->oreRobot*$time, $state->clay+$state->clayRobot*$time, $state->obsidian+$state->obsidianRobot*$time, $state->geodes+$state->geodeRobot*$time,
            $state->minutes+$time
        );
    }

    function echoState($state) {
        echo $state->minutes." m ".$state->oreRobot." oR ". $state->clayRobot . " cR " . $state->obsidianRobot . " obR " . $state->geodeRobot . " geR " . $state->obsidian . " ob<br>";
    }

    function possibleMoves($state, $bp, $maxTime) {
        $moves = array();

        if($state->minutes > $maxTime) {
            return $moves;
        }

        if($state->minutes+1 > $maxTime) {
            return array(performTick($state));
        }

        $oreIn = max(ceil(($bp->oreRobotOreCost-$state->ores)/$state->oreRobot + 1), 1);
        $clayIn = max(ceil(($bp->clayRobotOreCost-$state->ores)/$state->oreRobot + 1), 1);
        $obsidianIn = ($state->clayRobot > 0) ? max(
            ceil(($bp->obsidianRobotOreCost-$state->ores)/$state->oreRobot + 1),
            ceil(($bp->obsidianRobotClayCost-$state->clay)/$state->clayRobot + 1),
            1
        ) : $maxTime*2;
        $geodeIn = ($state->obsidianRobot > 0) ? max(
            ceil(($bp->geodeRobotOreCost-$state->ores)/$state->oreRobot + 1),
            ceil(($bp->geodeRobotObsidianCost-$state->obsidian)/$state->obsidianRobot + 1),
            1
        ) : $maxTime*2;

        if($state->minutes+$geodeIn <= $maxTime+1) {
            $buy_state = performTick($state, $geodeIn);
            $buy_state->ores -= $bp->geodeRobotOreCost;
            $buy_state->obsidian -= $bp->geodeRobotObsidianCost;
            $buy_state->geodeRobot += 1;
            array_push($moves, $buy_state);
        }
        if ($state->minutes+$obsidianIn <= $maxTime+1 && $state->obsidianRobot < $bp->maxObsidianCost) {
            $buy_state = performTick($state, $obsidianIn);
            $buy_state->ores -= $bp->obsidianRobotOreCost;
            $buy_state->clay -= $bp->obsidianRobotClayCost;
            $buy_state->obsidianRobot += 1;
            array_push($moves, $buy_state);
        }
        if($state->minutes+$oreIn <= $maxTime+1 && $state->oreRobot < $bp->maxOreCost) {
            $buy_state = performTick($state, $oreIn);
            $buy_state->ores -= $bp->oreRobotOreCost;
            $buy_state->oreRobot += 1;
            array_push($moves, $buy_state);
        }
        if($state->minutes+$clayIn <= $maxTime+1 && $state->clayRobot < $bp->maxClayCost) {
            $buy_state = performTick($state, $clayIn);
            $buy_state->ores -= $bp->clayRobotOreCost;
            $buy_state->clayRobot += 1;
            array_push($moves, $buy_state);
        }


        return $moves;
    }

    function dfsBp($state, $bp, &$pm, $mt) {
        if ($state->minutes > $mt)
            return $state->geodes;
        
        if (array_key_exists($state->toStr(), $pm))
            return $pm[$state->toStr()];

        $moveGeodes = array(performTick($state)->geodes);
        foreach(possibleMoves($state, $bp, $mt) as $possibleMove) {
            array_push($moveGeodes, dfsBp($possibleMove, $bp, $pm, $mt));
        }
        $biggest = max($moveGeodes);
        $pm[$state->toStr()] = $biggest;
        return $biggest;
    }

    function evaluateBlueprint($blueprint, $maxTime) {
        $previousMoves = array();
        $result = dfsBp(new State(1, 0, 0, 0, 0, 0, 0, 0, 1), $blueprint, $previousMoves, $maxTime);
        $previousMoves = null;
        unset($previousMoves);
        return $result;
    }

    $blueprints = array();

    $lines = file(dirname(__FILE__).'\\input.txt');
    $count = 0;
    foreach($lines as $line) {
       // echo $line."</br>";
        $inputs = explode(" ", $line);
        array_push($blueprints, new Blueprint(intval($inputs[6]), intval($inputs[12]), intval($inputs[18]), intval($inputs[21]), intval($inputs[27]), intval($inputs[30])));
    }

    $blueprintsCalc = array();
    $bpId = 1;
    foreach($blueprints as $bp) {
        $bpeval = evaluateBlueprint($bp, 24);
        array_push($blueprintsCalc, $bpeval*$bpId);
        $bpId++;
    }
    echo "Solution 1: ".array_sum($blueprintsCalc)."<br>";

    $newBps = array();
    foreach(array_slice($blueprints, 0, 3) as $bp) {
        $bpeval = evaluateBlueprint($bp, 32);
        array_push($newBps, $bpeval);
    }
    echo "Solution 2: ".array_product($newBps)."<br>";
?>
