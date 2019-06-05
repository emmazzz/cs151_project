/*
  Example queries:
    Simple:
      Who acts in Kill Bill?
      What did John Travolta act in?
      What movie did John Travolta act in?
    Trickier:
      What movie was made by the same filmmaker as Kill Bill?
  Query rules:
    keywords: star, movie, director



*/
attribute(movie).
attribute(star).
attribute(director).
attribute(randomInfo).
%attribute(date). may be supported in future iterations

% Emma
tokenize(WordList, Result, Database) :-
  find_query_attributes(WordList, QAttr,PAttr, Suffix),
  eliminate_double_negation(WordList, WordListNoDoubleNegs),
  tokenize_string_list(WordListNoDoubleNegs, [], _, Database, QAttr, PAttr, Suffix, Result).

%-------------------------------------------------------------------------------
/*
  Accumulated stores the words that might form part of a database element
  and will only be processed until a keyword(neg or star) is hit or the list is
  empty. for example, ["Who", "acts", "in", "Kill", "Bill", "randomtext"]
  the function will detect "acts" first, then ["in", "Kill", "Bill", "randomtext"] will
  all be accumulated until the end and passed into finds_closest_in_database to
  find the closest matched element in the database, which is ["Kill", "Bill"]
*/
% Emma
tokenize_string_list([],Accumulated,[Result],Database,QAttr, PAttr, Suffix,Message) :-
  finds_closest_in_database(Accumulated, Result, Database, QAttr, PAttr, Suffix,Message).
tokenize_string_list([],_,[],_, _,_,_,_).
tokenize_string_list([Word|Rest], Accumulated, [Result,Token|RestTokens],Database, QAttr, PAttr,Suffix,Message) :-
  token(Word, Token, _),
  finds_closest_in_database(Accumulated, Result, Database, QAttr, PAttr,Suffix,Message),
  tokenize_string_list(Rest, [], RestTokens, Database, QAttr, PAttr,Suffix,Message).
tokenize_string_list([Word|Rest], _, [Token|RestTokens],Database, QAttr, PAttr,Suffix,Message) :-
  token(Word, Token, _),
  tokenize_string_list(Rest, [], RestTokens, Database, QAttr, PAttr,Suffix,Message).
tokenize_string_list([Word|Rest], Accumulated, RestTokens, Database, QAttr, PAttr,Suffix,Message) :-
  append(Accumulated, [Word], NewlyAccumulated),
  tokenize_string_list(Rest, NewlyAccumulated, RestTokens, Database, QAttr, PAttr,Suffix,Message).

%-------------------------------------------------------------------------------
% Emma
finds_closest_in_database(WordList, Result, Database, QAttr, PAttr,Suffix, Message) :-
  exists_in_database_left(WordList, Result, Database,RelevantData,ValidRoles, ProvidedInfo), %Last param is ProvidedInfo for future use
  attributeFromList(RelevantData, Database, QAttr, PAttr, _, Message, Suffix,ValidRoles,ProvidedInfo).

finds_closest_in_database(WordList, Result, Database,QAttr, PAttr,Suffix, Message) :-
  exists_in_database_right(WordList, Result, Database,RelevantData, ValidRoles,ProvidedInfo),  %Last param is ProvidedInfo for future use
  attributeFromList(RelevantData, Database, QAttr, PAttr, _, Message,Suffix, ValidRoles,ProvidedInfo).

/* If we couldn't find results for any attribute in the query, we look to last names of stars and directors and prompt user to clarify their
    query if there are ambiguities */
/* Director last names */
finds_closest_in_database(WordList, Result2, Database, QAttr, PAttr,Suffix, Message) :-
  not(exists_in_database_left(WordList, Result, Database,RelevantData,ValidRoles, ProvidedInfo)), %Last param is ProvidedInfo for future use
  not(exists_in_database_right(WordList, Result, Database,RelevantData, ValidRoles,ProvidedInfo)),
  one_word_exists_in_database(WordList, Result2, Database),PAttr = director, concat_string_list(Result2,ResString),
  findall(First,(member(star(_, _, [First, ResString]), Database)),S), sort(S,Less),len(Less, L),((L = 0, write("Sorry, we didn't find any movies with that "),
    write(PAttr), write("\n"))
    ;(L \= 0, write("\nDid you know there are "),
  write(L), write(" "), write(PAttr), write("s you might have meant? \nWhich of these "), write(PAttr), write("s did you mean: "), format_string_list(Less,ToStr),
  write(ToStr), write("?  "), read_line_to_string(user_input,In), ((member(In, Less), writeln("Thanks! Showing results for "), write(In), write(" "), write(ResString),
    write(": "),append(WordList,[In,ResString],NWL),finds_closest_in_database(NWL, [In, ResString], Database, QAttr, PAttr, Suffix, Message), writeln(Message));
     (not(member(In, Less)), write("Sorry, we can't tell which "), write(PAttr), write(" you are looking for."))))).

/* Star last names */
finds_closest_in_database(WordList, Result2, Database, QAttr, PAttr,Suffix, Message) :-
  not(exists_in_database_left(WordList, Result, Database,RelevantData,ValidRoles, ProvidedInfo)),
  not(exists_in_database_right(WordList, Result, Database,RelevantData, ValidRoles,ProvidedInfo)),
  one_word_exists_in_database(WordList, Result2, Database),PAttr = star, concat_string_list(Result2,ResString),
  findall(First,(member(star(_, X, _), Database),member([First,ResString],X)),S),
  sort(S,Less), len(Less, L),((L = 0, write("Sorry, we didn't find any movies with that "),
    write(PAttr), write("\n"));
  (write("\nDid you know there are "),
  write(L), write(" "), write(PAttr), write("s you might have meant? \nWhich of these "), write(PAttr), write("s did you mean: "), format_string_list(Less,ToStr),
  write(ToStr), write("?  "), read_line_to_string(user_input,In), ((member(In, Less), writeln("Thanks! Showing results for "), write(In), write(" "), write(ResString),
    write(": "),append(WordList,[In,ResString],NWL),finds_closest_in_database(NWL, [In, ResString], Database, QAttr, PAttr, Suffix, Message), writeln(Message));
     (not(member(In, Less)), write("Sorry, we can't tell which "), write(PAttr), write(" you are looking for."))))).

finds_closest_in_database(WordList, Result, Database,QAttr, PAttr,Suffix, Message) :-
  append([_], ShorterWordList, WordList),
  finds_closest_in_database(ShorterWordList, Result, Database,QAttr, PAttr,Suffix, Message).
finds_closest_in_database(WordList, Result, Database,QAttr, PAttr, Suffix,Message) :-
  append(ShorterWordList, [_], WordList),
  finds_closest_in_database(ShorterWordList, Result, Database,QAttr, PAttr,Suffix, Message).

% lara
matchesOrNotProvided(PAttr,ValidRoles, _, NewRole) :- PAttr=ValidRoles, NewRole = PAttr.
matchesOrNotProvided(PAttr,ValidRoles, _, NewRole):- not(PAttr = ValidRoles), not(PAttr = notspecified), ValidRoles = stardirector, NewRole = PAttr.
matchesOrNotProvided(PAttr,ValidRoles, _, NewRole):- not(PAttr = ValidRoles), PAttr = notspecified, not(ValidRoles = stardirector),
  NewRole = ValidRoles.
matchesOrNotProvided(PAttr,ValidRoles,ProvidedInfo, NewRole) :- not(PAttr = ValidRoles),PAttr = notspecified, ValidRoles = stardirector,
 concat_string_list(ProvidedInfo, Strinfo), write(Strinfo), write(" has served as both a star and director. Are you looking for movies with him as (a) star, (b) as a director or (c) all movies he was involved in in any capacity? Enter your preference: "),
  read_line_to_string(user_input,In), setRole(In,NewRole).

% lara
setRole(In,NewRole):- In = "a", NewRole = star.
setRole(In,NewRole):- In = "b", NewRole = director.
setRole(In,NewRole):- In = "c", NewRole = stardirector.
setRole(In,NewRole):- In \="a",In\="b",In\="c", NewRole = stardirector, writeln("Didn't quite catch that. We're showing you all the results anyway.").

% lara
/* Plural movie requested */
attributeFromList(_, Database, QAttr, PAttr, _, Message,Suffix, ValidRoles, ProvidedInfo) :-
  QAttr = movie, Suffix = "s", matchesOrNotProvided(PAttr,ValidRoles, ProvidedInfo, NewRole),
  M = "You might be looking for the movies", find_all_movies_by_type(NewRole, ProvidedInfo, Movies, Database),
  concat_string_list_of_lists(Movies,Comb),
  concat_string_list([M,Comb], Message).

/* Singular movie requested */
attributeFromList(_, Database, QAttr, PAttr, _, Message,Suffix, ValidRoles,ProvidedInfo) :-
  QAttr = 'movie', Suffix \= "s", matchesOrNotProvided(PAttr,ValidRoles, ProvidedInfo, NewRole),
  M = "You might be looking for the movie",
  find_all_movies_by_type(NewRole,ProvidedInfo, MList, Database), random_member(Movie, MList),
  concat_string_list(Movie, MString),
  concat_string_list([M,MString], Message).

attributeFromList(RelevantData, _, QAttr, _, Res, Message ,_, _, _) :-
  QAttr = star, nth1(2, RelevantData, Res),
  M = "You might be looking for these stars:",
  concat_string_list_of_lists(Res, Comb),
  concat_string_list([M,Comb],Message).
attributeFromList(RelevantData, _, QAttr, _, Res, Message, _, _, _) :-
  QAttr = director,nth1(3, RelevantData, Res),
  M = "The director you're looking for is",
  concat_string_list(Res,Comb), concat_string_list([M,Comb],
  Message).

% lara
person_both(Person,Database) :- member(star(_,_,Person),Database), member(star(_,S2,_),Database),member(Person,S2).

% emma
exists_in_database_left(WordList, WordList, Database,RelevantData, ValidRoles,ProvidedInfo) :-
  member(star(WordList, Stars, Director), Database),
  RelevantData = [WordList, Stars, Director],
  ProvidedInfo = WordList,
  ValidRoles = movie.
exists_in_database_left(WordList, WordList, Database,RelevantData, ValidRoles,ProvidedInfo) :-
  not(person_both(WordList,Database)),
  member(star(Movie, X, Director), Database),member(WordList,X),
  RelevantData = [Movie, X, Director],
  ProvidedInfo = WordList,
  ValidRoles= star.
exists_in_database_left(WordList, WordList, Database,RelevantData, ValidRoles,ProvidedInfo) :-
  not(person_both(WordList,Database)),
  member(star(Movie, Stars, WordList), Database),
  RelevantData = [Movie,Stars, WordList],
  ProvidedInfo=WordList,
  ValidRoles= director.
exists_in_database_left(WordList, WordList, Database,RelevantData, ValidRoles,ProvidedInfo) :-
  person_both(WordList,Database),
  RelevantData = [_,_, _],
  ProvidedInfo = WordList,
  ValidRoles = stardirector.
exists_in_database_left(WordList, Result, Database,RelevantData, ValidRoles,ProvidedInfo) :-
  append([_], ShorterWordList, WordList),
  exists_in_database_left(ShorterWordList, Result, Database,RelevantData, ValidRoles,ProvidedInfo).

exists_in_database_right(WordList, WordList, Database,RelevantData, ValidRoles,ProvidedInfo) :-
  member(star(WordList, Stars, Director), Database),
  RelevantData = [WordList, Stars, Director],
  ProvidedInfo = WordList,
  ValidRoles = movie.
exists_in_database_right(WordList, WordList, Database,RelevantData, ValidRoles,ProvidedInfo) :-
  not(person_both(WordList,Database)),
  member(star(Movie, X, Director), Database),member(WordList,X),
  RelevantData = [Movie, X, Director],
  ProvidedInfo = WordList,
  ValidRoles= star.
exists_in_database_right(WordList, WordList, Database,RelevantData, ValidRoles,ProvidedInfo) :-
  not(person_both(WordList,Database)),
  member(star(Movie, Stars, WordList), Database),
    RelevantData = [Movie,Stars, WordList],
  ProvidedInfo=WordList,
  ValidRoles= director.
exists_in_database_right(WordList, WordList, Database,RelevantData, ValidRoles,ProvidedInfo) :-
  person_both(WordList,Database),
  RelevantData = [_,_, _],
  ProvidedInfo = WordList, %We don't search for movies this way
  ValidRoles = stardirector.
exists_in_database_right(WordList, Result, Database, RelevantData, ValidRoles,ProvidedInfo) :-
  append(ShorterWordList, [_], WordList),
  exists_in_database_right(ShorterWordList, Result, Database, RelevantData, ValidRoles,ProvidedInfo).

% emma
one_word_exists_in_database(WordList, Result, Database) :-
  one_word_exists_in_database_left(WordList, Result, Database).

one_word_exists_in_database(WordList, Result, Database) :-
  one_word_exists_in_database_right(WordList, Result, Database).

  % emma
one_word_exists_in_database_left(WordList, WordList, Database) :-
  member(star(_, X, _), Database),nth1(1,WordList,Name),member([_,Name],X).
one_word_exists_in_database_left(WordList, WordList, Database) :-
  nth1(1,WordList,Name),member(star(_, _, [_,Name]), Database).
one_word_exists_in_database_left(WordList, Result, Database) :-
  append([_], ShorterWordList, WordList),
  one_word_exists_in_database_left(ShorterWordList, Result, Database).

  % emma
one_word_exists_in_database_right(WordList, WordList, Database) :-
  member(star(_, X, _), Database),nth1(1,WordList,Name),member([_,Name],X).
one_word_exists_in_database_right(WordList, WordList, Database) :-
  nth1(1,WordList,Name),member(star(_, _, [_,Name]), Database).
one_word_exists_in_database_right(WordList, Result, Database) :-
  append(ShorterWordList, [_], WordList),
  one_word_exists_in_database_right(ShorterWordList, Result, Database).
%---------------- Query question patterns ------------------------------------

% lara
find_query_attributes(WordList, QAttr, PAttr, Suffix) :- pattern1(WordList, QAttr, PAttr, Suffix).
find_query_attributes(WordList, QAttr, PAttr, Suffix) :- pattern2(WordList, QAttr, PAttr, Suffix).
%find_question_attribute(WordList, Attr) :- pattern2(WordList, Attr)
find_query_attributes(WordList, QAttr, PAttr, Suffix) :-
  not(pattern1(WordList, QAttr, PAttr, Suffix)),
  not(pattern2(WordList, QAttr, PAttr, Suffix)),
  QAttr = "randomInfo". %all else fails choose a random one not provided info

% lara
%Give ... attribute; e.g. Give me the movie with Bill Pullman
qWordPat1("give").
qWordPat1("who").
qWordPat1("what").
qWordPat1("show").

% lara
pattern1(WordList, ResultQ,ResultP, Suffix) :- member(QW, WordList),string_lower(QW,QWL),
  qWordPat1(QWL), nth1(QInd, WordList, QW), member(X, WordList), token(X, ResultQ, Suffix),
  nth1(AInd, WordList, X),AInd > QInd, member(Y, WordList), token(Y,ResultP,_), nth1(PInd, WordList, Y), PInd>AInd.
pattern1(WordList, ResultQ,ResultP, Suffix) :- member(QW, WordList),string_lower(QW,QWL),
  qWordPat1(QWL), nth1(QInd, WordList, QW), member(X, WordList), token(X, ResultQ, Suffix),
  nth1(AInd, WordList, X),AInd > QInd, not(negPatternHelper(_,WordList,ResultP,_,WordList,AInd)), ResultP = notspecified.

pattern2(WordList, ResultQ,ResultP, Suffix) :- member(QW, WordList),string_lower(QW,QWL),
  qWordPat1(QWL), nth1(QInd, WordList, QW), member(X, WordList), token(X, ResultQ, Suffix),
  nth1(AInd, WordList, X),AInd > QInd, member(Y, WordList), token(Y,ResultP,_), nth1(PInd, WordList, Y), PInd<AInd.
pattern2(WordList, ResultQ,ResultP, Suffix) :- member(QW, WordList),string_lower(QW,QWL),
  qWordPat1(QWL), nth1(QInd, WordList, QW), member(X, WordList), token(X, ResultQ, Suffix),
  nth1(AInd, WordList, X),AInd > QInd, not(negPatternHelper(_,WordList,ResultP,_,WordList,AInd)), ResultP = notspecified.

negPatternHelper(Y,WordList,ResultP,PInd,WordList,AInd) :- member(Y, WordList), token(Y,ResultP,_), nth1(PInd, WordList, Y), PInd>AInd.
%Who ... attribute
%pattern2()
/*selectchk(X, WordList, NewList), */
%----------------- Negation handling -------------------------------------------
% emma
eliminate_double_negation([],[]).
eliminate_double_negation([Word1,Word2|Rest],Result) :-
  negToken(Word1,_),
  negToken(Word2,_),
  eliminate_double_negation(Rest, Result).
eliminate_double_negation([Word|Rest],[Word|Result]) :-
  eliminate_double_negation(Rest, Result).

%------------------- Tokens ---------------------------------------------------
% lara
% any word starting with "star" or "act"...?
token(S, A, Suffix) :- string_lower(S, LowS), attribute_token(LowS, A, Suffix).
attribute_token(S, star,Suffix) :- string_concat("star", Suffix, S).
attribute_token(S, star,Suffix) :- string_concat("act", Suffix, S).
attribute_token(S, director,Suffix) :- string_concat("direct", Suffix, S).
attribute_token(S, director,_) :- S="by".
attribute_token(S, director,Suffix) :- string_concat("filmmaker", Suffix, S).
attribute_token(S, director,Suffix) :- string_concat("made", Suffix, S).
attribute_token(S, director,Suffix) :- string_concat("mak", Suffix, S). %making, make
attribute_token(S, movie, Suffix) :- string_concat("movie", Suffix, S). %movie, movies
attribute_token(S, movie,Suffix) :- S \= "filmmaker", string_concat("film", Suffix, S).
attribute_token(S, movie,Suffix) :- string_concat("flick", Suffix, S).
negToken("not", neg).
negToken("no", neg).
negToken(S, neg) :- string_concat(_,"n't",S).
