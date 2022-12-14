open FSharp.Json
open FSharp.Collections

let config = JsonConfig.create(allowUntyped = true)
type PacketPair(one: obj list, two: obj list) =
    member val firstPacket = one
    member val secondPacket = two

type Packet(data: obj list) =
    member val data = data

let readText = System.IO.File.ReadAllLines "./input.txt"

let packetPairs: PacketPair list = [
    for i in [0 .. (readText.Length - 1)/3] do 
    yield new PacketPair(
        Json.deserializeEx<obj list> config readText[i*3], 
        Json.deserializeEx<obj list> config readText[i*3+1]
    )
]

let div2 = new Packet(Json.deserializeEx<obj list> config "[[2]]")
let div6 = new Packet(Json.deserializeEx<obj list> config "[[6]]")
let mutable packets: Packet list = [
    for i in [0 .. (readText.Length - 1)/3] do 
    yield new Packet(Json.deserializeEx<obj list> config readText[i*3])
    yield new Packet (Json.deserializeEx<obj list> config readText[i*3+1])
]
packets <- div2 :: packets
packets <- div6 :: packets

let matchType(item: obj, other: obj): obj =
    match (item :? decimal && not (other :? decimal)) with
    | true -> [item]
    | false -> item

// 0: Incorrect order
// 1: "Same" order
// 2: Correct order
let rec getValid(packet: PacketPair): int =
    let first = packet.firstPacket
    let second = packet.secondPacket
    let mutable smallerFound = false
    let mutable largerFound = false
    let longest = if first.Length-1 > second.Length-1 then first.Length-1 else second.Length-1
    let result = [0..longest] |> Seq.forall (fun i -> 
        if smallerFound then true
        elif (i >= first.Length) then (
            smallerFound <- true
            true
        )
        elif (i >= second.Length) then false
        elif (not (matchType(first[i], second[i]) :? decimal)) then
            let innerResult = getValid(new PacketPair(
                matchType(first[i], second[i]) :?> obj list,
                matchType(second[i], first[i]) :?> obj list
            ))
            if innerResult = 2 then
                smallerFound <- true
                true
            elif innerResult = 1 then true
            else false
        else (
            largerFound <- ((downcast (first[i]) : decimal) > (downcast (second[i]) : decimal) || largerFound) && not smallerFound
            smallerFound <- ((downcast (first[i]) : decimal) < (downcast (second[i]) : decimal) || largerFound) && not largerFound
            let equal = (downcast (first[i]) : decimal) = (downcast (second[i]) : decimal)
            equal
         )
    )
    if smallerFound then 2
    elif result then 1
    else 0

let comparePackets(packet1: Packet)(packet2: Packet): int =
    match getValid(new PacketPair(packet1.data, packet2.data)) >= 1 with
    | true -> 1
    | false -> 0

let mutable totalValid = 0
for p in [1..(packetPairs.Length)] do
    let result = getValid(packetPairs[p-1])
    totalValid <- totalValid + if result >= 1 then (p) else (0)

printfn $"Solution 1: {totalValid}"

let bubbleSort l: Packet list = 
  let rec sortUtil acc rev l: Packet list =
    match l, rev with
    | [], true -> acc |> List.rev
    | [], false -> acc |> List.rev |> sortUtil [] true
    | x::y::tl, _ when getValid(new PacketPair(x.data, y.data)) = 0 -> sortUtil (y::acc) false (x::tl)
    | hd::tl, _ -> sortUtil (hd::acc) rev tl
  sortUtil [] true l

let listSorted = bubbleSort packets
let mutable div2Pos = 0
let mutable div6Pos = 0
for p in [1..(listSorted.Length)] do
    let packet = listSorted[p-1].data
    if packet = div2.data then
        div2Pos <- p
    elif packet = div6.data then
        div6Pos <- p
printfn $"Solution 2: {div2Pos*div6Pos}"
