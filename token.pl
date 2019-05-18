
tokenize(WordList, Result, Database) :-
  tokenize_string_list(WordList, [], Tokens, Database),
  eliminate_double_negation(Tokens, Result).

%-------------------------------------------------------------------------------
/*
  Accumulated stores the words that might form part of a database element
  and will only be processed until a keyword(neg or star) is hit or the list is
  empty. for example, ["Who", "acts", "in", "Kill", "Bill", "lol"]
  the function will detect "acts" first, then ["in", "Kill", "Bill", "lol"] will
  all be accumulated until the end and passed into finds_closest_in_database to
  find the closest matched element in the database, which is ["Kill", "Bill"]
*/
tokenize_string_list([],Accumulated,[Result],Database) :-
  finds_closest_in_database(Accumulated, Result, Database),!.
tokenize_string_list([],_,[],_) :- !.
tokenize_string_list([Word|Rest], Accumulated, [Result,Token|RestTokens],Database) :-
  token(Word, Token),
  finds_closest_in_database(Accumulated, Result, Database),
  tokenize_string_list(Rest, [], RestTokens, Database),!.
tokenize_string_list([Word|Rest], _, [Token|RestTokens],Database) :-
  token(Word, Token),
  tokenize_string_list(Rest, [], RestTokens, Database),!.
tokenize_string_list([Word|Rest], Accumulated, RestTokens, Database) :-
  append(Accumulated, [Word], NewlyAccumulated),
  tokenize_string_list(Rest, NewlyAccumulated, RestTokens, Database),!.

%-------------------------------------------------------------------------------

finds_closest_in_database(WordList, Result, Database) :-
  exists_in_database_left(WordList, Result, Database),!.
finds_closest_in_database(WordList, Result, Database) :-
  exists_in_database_right(WordList, Result, Database),!.
finds_closest_in_database(WordList, Result, Database) :-
  append([_], ShorterWordList, WordList),
  finds_closest_in_database(ShorterWordList, Result, Database),!.
finds_closest_in_database(WordList, Result, Database) :-
  append(ShorterWordList, [_], WordList),
  finds_closest_in_database(ShorterWordList, Result, Database),!.

exists_in_database_left(WordList, WordList, Database) :-
  member(star(WordList, _), Database),!.
exists_in_database_left(WordList, WordList, Database) :-
  member(star(_, WordList), Database),!.
exists_in_database_left(WordList, Result, Database) :-
  append([_], ShorterWordList, WordList),
  exists_in_database_left(ShorterWordList, Result, Database),!.
exists_in_database_right(WordList, WordList, Database) :-
  member(star(WordList, _), Database),!.
exists_in_database_right(WordList, WordList, Database) :-
  member(star(_, WordList), Database),!.
exists_in_database_right(WordList, Result, Database) :-
  append(ShorterWordList, [_], WordList),
  exists_in_database_right(ShorterWordList, Result, Database),!.

%-------------------------------------------------------------------------------

eliminate_double_negation([],[]).
eliminate_double_negation([neg,neg|Rest],Result) :-
  eliminate_double_negation(Rest, Result),!.
eliminate_double_negation([Word|Rest],[Word|Result]) :-
  eliminate_double_negation(Rest, Result),!.

%------------------- Tokens ---------------------------------------------------

% any word starting with "star" or "act"...?
token(S, star) :- string_concat("star",_,S).
token(S, star) :- string_concat("act",_,S).

token("not", neg).
token("no", neg).
token(S, neg) :- string_concat(_,"n't",S).
