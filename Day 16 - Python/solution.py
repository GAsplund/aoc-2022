import itertools
import re

puzzle_input = []
with open("input.txt") as f:
    for line in f.readlines():
        valve_in = [line[6:8]]
        valve_in.append(re.findall('\d+', line)[0])
        valve_in.append(re.findall('(valve |alves )([^#\r\n]*)', line))
        puzzle_input.append(valve_in)

valves = {}
valve_flow_rates = {}
valve_flags = {}
valve_dists = {}

for i, valve in enumerate(puzzle_input):
    valves[valve[0]] = valve[2][0][1].split(", ")
    if int(valve[1]) > 0: valve_flow_rates[valve[0]] = int(valve[1])
    valve_flags[valve[0]] = 1 << i

for valve1 in valves.keys():
    for valve2 in valves.keys():
        valve_dists[(valve1, valve2)] = 1 if valve2 in valves[valve1] else 50

for k, i, j in itertools.permutations(valves, 3):
    valve_dists[i, j] = min(valve_dists[i, j], valve_dists[i, k] + valve_dists[k, j])

def traverse_valves(total_minutes):
    queue = [('AA', total_minutes, 0, 0)]
    visited = set()
    ans = {}

    while queue:
        next_state = queue.pop()
        if (next_state in visited):
            continue
        visited.add(next_state)
        valve = next_state[0]; time = next_state[1]; mask = next_state[2]
        pressure = next_state[3]
        ans[mask] = max(ans.get(mask, 0), pressure)
        for to_valve, flow_rate in valve_flow_rates.items():
            rem_time = time - valve_dists[(valve, to_valve)] - 1
            if valve_flags[to_valve] & mask or rem_time <= 0:
                continue
            queue.append((to_valve, rem_time, mask|valve_flags[to_valve], pressure + flow_rate * rem_time))

    return ans

part1 = max(traverse_valves(30).values())
print("Solution 1: ", part1)

part2_base = traverse_valves(26).items()
part2 = max(person_1+person_2 for mask_1, person_1 in part2_base
            for mask_2, person_2 in part2_base if not mask_1 & mask_2)
print("Solution 2: ", part2)
