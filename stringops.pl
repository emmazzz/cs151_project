/*----------------------------OUR UTIL RULES---------------------------------*/
/*
    String and list helper functions for tokenization and parsing use.
*/

/* Holds if Var is not instantiated to a value */
not_instantiated(Var):-
  \+(\+(Var=0)),
  \+(\+(Var=1)).

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
    Char @>= 'a', Char @=< 'z'; Char @>= '0', Char @=< '9'; Char = ':'; Char = '.';
    Char = ' '), good_cs(CharsIn, CharsOut).
good_cs([_ | CharsIn], CharsOut) :-
    good_cs(CharsIn, CharsOut).

/*
    Concatenates strings stored in a list.
    Usage: concat([str1,str2,...,stri], combinedstring)
            note that combined string cannot also be contained in StrList
*/
concat(StrList, Res) :-
    maplist(atom_chars, StrList, Lists),
    append(Lists, List),
    atom_chars(Res, List).

/* String representation of list, formatted such that elements are separated by spaces */
concat_string_list([],"").
concat_string_list([Head], Head).
concat_string_list([Head|Tail], Result) :-
  concat_string_list(Tail, Rest),
  string_concat(Head, " ", HeadSpace),
  string_concat(HeadSpace, Rest, Result).

/*
    Gets comma and and-formatted string from list of strings (i.e. not nested;
    see concat_string_list_of_lists for formatting nested lists)
*/
format_string_list([],"").
format_string_list([Head], Head).
format_string_list([First, Second], H) :- concat_string_list([First, "and",Second],H).
format_string_list([Head|Tail], Result) :-
  format_string_list(Tail, Rest),
  string_concat(Head, ", ", HeadSpace),
  string_concat(HeadSpace, Rest, Result).

/* Gets length of list; stores it in LenResult*/
len([], LenResult):-
    LenResult is 0.
len([_|Y], LenResult):-
    len(Y, L),
    LenResult is L+1.
/*
    Formats a list of lists in the following manner:
    Usage: concat_string_list_of_lists([["David", "Lynch"], ["First", "Last"], ["Some",  "Name"]], Result), writeln(Result).
    ==> "David Lynch, First Last, and Some Name"
*/
concat_string_list_of_lists([],"").
concat_string_list_of_lists([Head], H):- concat_string_list(Head, H).
concat_string_list_of_lists([First,Second],H):- concat_string_list(First,F),
    concat_string_list(Second, S), concat_string_list([F, "and", S],H).
concat_string_list_of_lists([Head|Tail], Result) :-
  concat_string_list_of_lists(Tail, Rest),
  concat_string_list(Head, H),
  string_concat(H, ", ", HeadSpace),
  string_concat(HeadSpace, Rest, Result).

/* List append: W is [ elements of Y , elements of Z ] */
append( [], A, A).
append( [A | B], C, [A | D]) :- append( B, C, D).

/* Checks if list is empty */
list_empty([], true).
list_empty([_|_], false).