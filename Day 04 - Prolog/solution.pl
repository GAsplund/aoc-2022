start:-
    get_input(Input),

    solve(Input, S1solution, S2solution, 0, 0),
    write('Solution 1: '),
    writeln(S1solution),
    write('Solution 2: '),
    writeln(S2solution).

get_input(Input):-
    open("input.txt", read, Stream),
    read_line_to_codes(Stream,Line1),
    get_input(Stream, Line1, Input).

get_input(Stream, Line1, Input):-
    get_input(Stream, Line1, [], Input).

get_input(_, end_of_file, Input, Input).

get_input(Stream, Line, Acc, Input):-
    is_list(Line),
    append(Acc, [Line], Acc1),
    read_line_to_codes(Stream,Line1),
    get_input(Stream, Line1, Acc1, Input).

is_empty(List):- not(member(_,List)).

range_numbers(R1, R2, R1a, R1b, R2a, R2b):-
    % Split range into values
    split_string(R1, '-', '', [R1a_s, R1b_s]),
    split_string(R2, '-', '', [R2a_s, R2b_s]),
    % Parse range values to integers
    atom_number(R1a_s, R1a),
    atom_number(R1b_s, R1b),
    atom_number(R2a_s, R2a),
    atom_number(R2b_s, R2b).

range_inside([R1, R2]):- 
    range_numbers(R1, R2, R1a, R1b, R2a, R2b),
    % Check for containment
    (((R1a >= R2a) , (R1b =< R2b)) ; ((R2a >= R1a) , (R2b =< R1b))).

range_overlap([R1, R2]):- 
    range_numbers(R1, R2, R1a, R1b, R2a, R2b),
    % Check for overlap
    (R1a =< R2b), (R1b >= R2a).

incr(X, X1) :-
    X1 is X+1.

solve([Current|Next], InsideRanges, OverlapRanges, CountInside, CountOverlap):-
    string_chars(Ranges, Current),
    split_string(Ranges, ',', '', Intervals),
    % Check if one range is inside the other. Increment counter if true.
    ((range_inside(Intervals) -> incr(CountInside, NewCountInside)); NewCountInside is CountInside),
    % Check if ranges overlap. Increment counter if true.
    ((range_overlap(Intervals) -> incr(CountOverlap, NewCountOverlap)); NewCountOverlap is CountOverlap),
    % Keep going if tail isn't empty...
    (not(is_empty(Next)) -> solve(Next, InsideRanges, OverlapRanges, NewCountInside, NewCountOverlap)
    % ...otherwise set output values and return
    ; (InsideRanges is NewCountInside, OverlapRanges is NewCountOverlap)).
