/*
    String helper functions for tokenization.
*/

%Replace substring with string util function for tokenization
replace_word(In, ToRepl, Repl, Out) :- atomic_list_concat(Split, ToRepl, In), 
    atomic_list_concat(Split, Repl, Out).

%Remove illegal characters from strings (for our purposes non alphanumeric with exception of spaces which are okay)
rmvfrm_words([], []).
rmvfrm_words([In | Ins], [Out | Outs]) :- rmvfrm_word(In, Out),
    rmvfrm_words(Ins, Outs).
rmvfrm_word(In, Out) :-
    atom_chars(In, InC),
    good_cs(InC, OutC),
    atom_chars(Out, OutC).
    
good_cs([], []).
good_cs([Char | CharsIn], [Char | CharsOut]) :-
    (Char @>= 'A', Char @=< 'Z'; %only keep alphanums and spaces which we will tokenize by
    Char @>= 'a', Char @=< 'z'; Char @>= '0', Char @=< '9';
    Char = ' '), good_cs(CharsIn, CharsOut).
good_cs([_ | CharsIn], CharsOut) :-
    good_cs(CharsIn, CharsOut).