/*--------------HIGHEST-LEVEL QUERY PROCESSING AND ANSWER RETREIVAL-------------------*/
/*
  Example queries:
      Who acts in Kill Bill?
      What was Quentin Tarantino in?
      What movie did Quentin Tarantino act in?
  keywords: star, movie, director
*/

tokenize(WordList, Result, Database) :-
  find_query_attributes(WordList, QAttr,PAttr, Suffix, WL),
  eliminate_double_negation(WL, WordListNoDoubleNegs),
  tokenize_string_list(WordListNoDoubleNegs, [], _, Database, QAttr, PAttr, Suffix, Result).

%--------------------------TOKENIZATION AND PARSING------------------------------------*/
/* Our three supported attributes about which users can ask questions 
 * and provide info for a question using
 * */
attribute(movie).
attribute(star).
attribute(director).

/*
  Accumulated stores the words that might form part of a database element
  and will only be processed until a keyword (e.g. star) is hit or the list is
  empty. for example, ["Who", "acts", "in", "Titanic", "randomtext"]
  the function will detect "acts" first, then ["in", "Titanic", "randomtext"] will
  all be accumulated until the end and passed into finds_closest_in_database to
  find the closest matched element in the database, which is ["Titanic"]
*/
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
/* Using the question attribute (QAttr) and provided attribute (PAttr), supplied by find_query_attributes,
 * find_closest_in_database populates Result with the desired attribute sourced from our database that answers
 * the user's question. The below two definitions deal with the cases when provided info is
 * (1) an entire movie name (2) an entire director name, or (3) an entire star name.
*/
finds_closest_in_database(WordList, Result, Database, QAttr, PAttr,Suffix, Message) :-
  exists_in_database_left(WordList, Result, Database,RelevantData,ValidRoles, ProvidedInfo),
  attributeFromList(RelevantData, Database, QAttr, PAttr, _, Message, Suffix,ValidRoles,ProvidedInfo).

finds_closest_in_database(WordList, Result, Database,QAttr, PAttr,Suffix, Message) :-
  exists_in_database_right(WordList, Result, Database,RelevantData, ValidRoles,ProvidedInfo),
  attributeFromList(RelevantData, Database, QAttr, PAttr, _, Message,Suffix, ValidRoles,ProvidedInfo).

/* If we couldn't find results for any attribute in the query, we look to last names of stars and directors and prompt user to clarify their
    query if there are ambiguities */
/* Director last names */
finds_closest_in_database(WordList, Result2, Database, QAttr, PAttr,Suffix, Message) :-
  not(exists_in_database_left(WordList, Result, Database,RelevantData,ValidRoles, ProvidedInfo)),
  not(exists_in_database_right(WordList, Result, Database,RelevantData, ValidRoles,ProvidedInfo)),
  one_word_exists_in_database(WordList, Result2, Database),PAttr = director, concat_string_list(Result2,ResString),
  findall(First,(member(star(_, _, [First, ResString]), Database)),S), sort(S,Less),len(Less, L),((L = 0, write("Sorry, we didn't find any movies with that director\n"))
    ;(L \= 0, write("\nDid you know there are "),
  write(L), write(" directors you might have meant? \nWhich of these directors did you mean: "), format_string_list(Less,ToStr),
  write(ToStr), write("?  "), read_line_to_string(user_input,In), ((member(In, Less), writeln("Thanks! Showing results for "), write(In), write(" "), write(ResString),
    write(": "),append(WordList,[In,ResString],NWL),finds_closest_in_database(NWL, [In, ResString], Database, QAttr, PAttr, Suffix, Message), writeln(Message));
     (not(member(In, Less)), write("Sorry, we can't tell which director you are looking for."))))).

/* Star last names */
finds_closest_in_database(WordList, Result2, Database, QAttr, PAttr,Suffix, Message) :-
  not(exists_in_database_left(WordList, Result, Database,RelevantData,ValidRoles, ProvidedInfo)),
  not(exists_in_database_right(WordList, Result, Database,RelevantData, ValidRoles,ProvidedInfo)),
  one_word_exists_in_database(WordList, Result2, Database),PAttr = star, concat_string_list(Result2,ResString),
  findall(First,(member(star(_, X, _), Database),member([First,ResString],X)),S),
  sort(S,Less), len(Less, L),((L = 0, write("Sorry, we didn't find any movies with that star\n"));
  (write("\nDid you know there are "),
  write(L), write(" stars you might have meant? \nWhich of these stars did you mean: "), format_string_list(Less,ToStr),
  write(ToStr), write("?  "), read_line_to_string(user_input,In), ((member(In, Less), writeln("Thanks! Showing results for "), write(In), write(" "), write(ResString),
    write(": "),append(WordList,[In,ResString],NWL),finds_closest_in_database(NWL, [In, ResString], Database, QAttr, PAttr, Suffix, Message), writeln(Message));
     (not(member(In, Less)), write("Sorry, we can't tell which star you are looking for."))))).

finds_closest_in_database(WordList, Result, Database,QAttr, PAttr,Suffix, Message) :-
  append([_], ShorterWordList, WordList),
  finds_closest_in_database(ShorterWordList, Result, Database,QAttr, PAttr,Suffix, Message).
finds_closest_in_database(WordList, Result, Database,QAttr, PAttr, Suffix,Message) :-
  append(ShorterWordList, [_], WordList),
  finds_closest_in_database(ShorterWordList, Result, Database,QAttr, PAttr,Suffix, Message).


matchesOrNotProvided(PAttr,ValidRoles, _, NewRole) :- PAttr=ValidRoles, NewRole = PAttr.
matchesOrNotProvided(PAttr,ValidRoles, _, NewRole):- not(PAttr = ValidRoles), not(PAttr = notspecified), ValidRoles = stardirector, NewRole = PAttr.
matchesOrNotProvided(PAttr,ValidRoles, _, NewRole):- not(PAttr = ValidRoles), PAttr = notspecified, not(ValidRoles = stardirector),
  NewRole = ValidRoles.
matchesOrNotProvided(PAttr,ValidRoles,ProvidedInfo, NewRole) :- not(PAttr = ValidRoles),PAttr = notspecified, ValidRoles = stardirector,
  concat_string_list(ProvidedInfo, Strinfo), write(Strinfo), 
  write(" has served as both a star and director. Are you looking for movies with him as (a) star, (b) as a director or (c) all movies he was involved in in any capacity? Enter a, b, or c to indicate your preference: "),
  read_line_to_string(user_input,In), setRole(In,NewRole).

setRole(In,NewRole):- In = "a", NewRole = star.
setRole(In,NewRole):- In = "b", NewRole = director.
setRole(In,NewRole):- In = "c", NewRole = stardirector.
setRole(In,NewRole):- In \="a",In\="b",In\="c", NewRole = stardirector, writeln("Didn't quite catch that. We're showing you all the results anyway.").

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

person_both(Person,Database) :- member(star(_,_,Person),Database), member(star(_,S2,_),Database),member(Person,S2).

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


one_word_exists_in_database(WordList, Result, Database) :-
  one_word_exists_in_database_left(WordList, Result, Database).

one_word_exists_in_database(WordList, Result, Database) :-
  one_word_exists_in_database_right(WordList, Result, Database).

one_word_exists_in_database_left(WordList, WordList, Database) :-
  member(star(_, X, _), Database),nth1(1,WordList,Name),member([_,Name],X).
one_word_exists_in_database_left(WordList, WordList, Database) :-
  nth1(1,WordList,Name),member(star(_, _, [_,Name]), Database).
one_word_exists_in_database_left(WordList, Result, Database) :-
  append([_], ShorterWordList, WordList),
  one_word_exists_in_database_left(ShorterWordList, Result, Database).

one_word_exists_in_database_right(WordList, WordList, Database) :-
  member(star(_, X, _), Database),nth1(1,WordList,Name),member([_,Name],X).
one_word_exists_in_database_right(WordList, WordList, Database) :-
  nth1(1,WordList,Name),member(star(_, _, [_,Name]), Database).
one_word_exists_in_database_right(WordList, Result, Database) :-
  append(ShorterWordList, [_], WordList),
  one_word_exists_in_database_right(ShorterWordList, Result, Database).
%---------------- Query question patterns ------------------------------------

find_query_attributes(WordList, QAttr, PAttr, Suffix, WL) :- pattern1(WordList, QAttr, PAttr, Suffix, WL).
find_query_attributes(WordList, QAttr, PAttr, Suffix, WL) :-
  not(pattern1(WordList, QAttr, PAttr, Suffix, WL)),
  QAttr = "randomInfo". %all else fails choose a random one not provided info
without_last([_], []).
without_last([X|Xs], [X|WithoutLast]) :- 
    without_last(Xs, WithoutLast).
%Give ... attribute; e.g. Give me the movie with Bill Pullman
qWordPat1("give").
qWordPat1("who").
qWordPat1("what").
qWordPat1("show").

%QW refers to question word, the placement of which is useful for determining the placements of the desired attribute (ResultQ)
% and the attribute of the information provided (ResultP)
% Each definition of pattern refers to a distinct pattern and obtains the desired 
pattern1(WordList, ResultQ,ResultP, Suffix, WL) :- member(QW, WordList),string_lower(QW,QWL),
  qWordPat1(QWL), nth1(QInd, WordList, QW), member(X, WordList), token(X, ResultQ, Suffix),
  nth1(AInd, WordList, X),AInd > QInd, member(Y, WordList), token(Y,ResultP,_), nth1(PInd, WordList, Y), PInd>AInd, WL = WordList.
pattern1(WordList, ResultQ,ResultP, Suffix, WL) :- member(QW, WordList),string_lower(QW,QWL),
  qWordPat1(QWL), nth1(QInd, WordList, QW), member(X, WordList), token(X, ResultQ, Suffix),
  nth1(AInd, WordList, X),AInd > QInd, not(negPatternHelper(_,WordList,ResultP,_,WordList,AInd)), ResultP = notspecified, WL = WordList.
%X [role] [QW]
pattern1(WordList, ResultQ,ResultP, Suffix, WL) :- member(QW, WordList),string_lower(QW,QWL),
  qWordPat1(QWL), nth1(QInd, WordList, QW), member(X, WordList), token(X, ResultQ, Suffix),
  nth1(AInd, WordList, X),AInd > QInd, not(negPatternHelper(_,WordList,ResultP,_,WordList,AInd)), ResultP = notspecified, WL = WordList.
%Inferring 'movie' from missing attribute'
%What ... in
pattern1(WordList, ResultQ,ResultP, Suffix, WL) :- member(QW, WordList),string_lower(QW,QWL),len(WordList, Len),
  nth1(Len, WordList, QW),  QWL = "in", ResultQ = movie, ResultP = star,Suffix = "",append(["movie"],WordList,WL1), without_last(WL1,WL).

negPatternHelper(Y,WordList,ResultP,PInd,WordList,AInd) :- member(Y, WordList), token(Y,ResultP,_), nth1(PInd, WordList, Y), PInd>AInd.
%----------------- Negation handling -------------------------------------------

eliminate_double_negation([],[]).
eliminate_double_negation([Word1,Word2|Rest],Result) :-
  negToken(Word1,_),
  negToken(Word2,_),
  eliminate_double_negation(Rest, Result).
eliminate_double_negation([Word|Rest],[Word|Result]) :-
  eliminate_double_negation(Rest, Result).

%------------------- Tokens ---------------------------------------------------

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

/* movies by person; can't tell if star or director provided */
find_all_movies_by_type(NewRole, ProvidedInfo, Movies, Database) :-
	NewRole = stardirector, find_all_movies_by_person(ProvidedInfo, Movies, Database).

/* movies by star */
find_all_movies_by_type(NewRole, ProvidedInfo, Movies, Database) :-
	NewRole = star ,
	find_all_movies_by_star(ProvidedInfo, Movies, Database).

/* movies by director */
find_all_movies_by_type(NewRole, ProvidedInfo, Movies, Database) :-
	NewRole = director,
	find_all_movies_by_director(ProvidedInfo, Movies, Database).

/* specific find_all_movies_by_x definitions */
find_all_movies_by_person(Person, Movies, Database) :-
  find_all_movies_by_star(Person, StarredMovies, Database),
  find_all_movies_by_director(Person, DirectedMovies, Database),
  union(StarredMovies, DirectedMovies, Movies).

find_all_movies_by_star(Star, Movies, Database) :-
  setof(Movie,find_one_movie_by_star(Star, Movie, Database), Movies).
find_one_movie_by_star(Star, Movie, Database) :-
  member(star(Movie, Stars, _), Database),
  member(Star, Stars).

find_all_movies_by_director(Director, Movies, Database) :-
  setof(Movie,find_one_movie_by_director(Director, Movie, Database), Movies).
find_one_movie_by_director(Director, Movie, Database) :-
  member(star(Movie, _, Director), Database).
