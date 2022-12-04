start:-
    get_input(Input),

    solve_s1(Input, S1solution, 0),
    write('Solution 1: '),
    writeln(S1solution),

    solve_s2(Input, S2solution, 0),
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

in_range(N, R1, R2, Return):-
    Return is (N >= R1) ; (R2 >= N).

range_inside([R1, R2]):- 
    % Split range into values
    split_string(R1, '-', '', [R1a_s, R1b_s]),
    split_string(R2, '-', '', [R2a_s, R2b_s]),
    % Parse range values to integers
    atom_number(R1a_s, R1a),
    atom_number(R1b_s, R1b),
    atom_number(R2a_s, R2a),
    atom_number(R2b_s, R2b),
    % Check for containment
    (((R1a >= R2a) , (R1b =< R2b)) ; ((R2a >= R1a) , (R2b =< R1b))).

range_overlap([R1, R2]):- 
    % Split range into values
    split_string(R1, '-', '', [R1a_s, R1b_s]),
    split_string(R2, '-', '', [R2a_s, R2b_s]),
    % Parse range values to integers
    atom_number(R1a_s, R1a),
    atom_number(R1b_s, R1b),
    atom_number(R2a_s, R2a),
    atom_number(R2b_s, R2b),
    % Check for overlap
    (R1a =< R2b), (R1b >= R2a).

incr(X, X1) :-
    X1 is X+1.

solve_s1([Current|Next], InsideRanges, Count):-
    string_chars(Ranges, Current),
    split_string(Ranges, ',', '', Intervals),
    ((range_inside(Intervals) -> incr(Count, NewCount)); NewCount is Count),
    (not(is_empty(Next)) -> solve_s1(Next, InsideRanges, NewCount) ; InsideRanges is NewCount).
    
solve_s2([Current|Next], InsideRanges, Count):-
    string_chars(Ranges, Current),
    split_string(Ranges, ',', '', Intervals),
    ((range_overlap(Intervals) -> incr(Count, NewCount)); NewCount is Count),
    (not(is_empty(Next)) -> solve_s2(Next, InsideRanges, NewCount) ; InsideRanges is NewCount).
