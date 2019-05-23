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

tokenize(WordList, Result, Database) :-
  find_question_attribute(WordList, Attr),
  tokenize_string_list(WordList, [], Tokens, Database, Attr),
  eliminate_double_negation(Tokens, Result).

%-------------------------------------------------------------------------------
/*
  Accumulated stores the words that might form part of a database element
  and will only be processed until a keyword(neg or star) is hit or the list is
  empty. for example, ["Who", "acts", "in", "Kill", "Bill", "randomtext"]
  the function will detect "acts" first, then ["in", "Kill", "Bill", "randomtext"] will
  all be accumulated until the end and passed into finds_closest_in_database to
  find the closest matched element in the database, which is ["Kill", "Bill"]
*/
tokenize_string_list([],Accumulated,[Result],Database, Attr) :-
  finds_closest_in_database(Accumulated, Result, Database, Attr).
tokenize_string_list([],_,[],_, _) :- !.
tokenize_string_list([Word|Rest], Accumulated, [Result,Token|RestTokens],Database, Attr) :-
  negToken(Word, Token),
  finds_closest_in_database(Accumulated, Result, Database, Attr),
  tokenize_string_list(Rest, [], RestTokens, Database, Attr).
tokenize_string_list([Word|Rest], _, [Token|RestTokens],Database, Attr) :-
  negToken(Word, Token),
  tokenize_string_list(Rest, [], RestTokens, Database, Attr),!.
tokenize_string_list([Word|Rest], Accumulated, RestTokens, Database, Attr) :-
  append(Accumulated, [Word], NewlyAccumulated),
  tokenize_string_list(Rest, NewlyAccumulated, RestTokens, Database, Attr),!.


%-------------------------------------------------------------------------------

finds_closest_in_database(WordList, Result, Database, Attr) :-
  exists_in_database_left(WordList, Result, Database,RelevantData, _), %Last param is ProvidedInfo for future use
  attributeFromList(RelevantData, Attr, Res, Message), writeln(""), write(Message),nth1(1,Res, SingleResult1), 
  nth1(2,Res,SingleResult2),write(SingleResult1),write(" "), write(SingleResult2), writeln("").
  %change above for printing variable length
finds_closest_in_database(WordList, Result, Database,Attr) :-
  exists_in_database_right(WordList, Result, Database,RelevantData, _),  %Last param is ProvidedInfo for future use
  attributeFromList(RelevantData, Attr, Res, Message), writeln(""),write(Message),nth1(1,Res, SingleResult1),
  nth1(2,Res,SingleResult2),write(SingleResult1), write(" "), write(SingleResult2), writeln("").
    %change above for printing variable length

finds_closest_in_database(WordList, Result, Database,Attr) :-
  append([_], ShorterWordList, WordList),
  finds_closest_in_database(ShorterWordList, Result, Database,Attr).
finds_closest_in_database(WordList, Result, Database,Attr) :-
  append(ShorterWordList, [_], WordList),
  finds_closest_in_database(ShorterWordList, Result, Database,Attr).

attributeFromList(RelevantData, Attr, Res, Message) :- Attr = 'movie', nth1(1, RelevantData, Res), Message = "You might be looking for the movie ".
attributeFromList(RelevantData, Attr, Res, Message) :- Attr = 'star', nth1(2, RelevantData, Res), Message = "You might be looking for these stars: ".
attributeFromList(RelevantData, Attr, Res, Message) :- Attr = 'director', nth1(3, RelevantData, Res), Message = "The director you're looking for is ".


exists_in_database_left(WordList, WordList, Database,RelevantData, ProvidedInfo) :-
  member(star(WordList, Stars, Director), Database), 
  RelevantData = [WordList, Stars, Director], 
  ProvidedInfo = [WordList, [], []].
exists_in_database_left(WordList, WordList, Database,RelevantData, ProvidedInfo) :-
  member(star(Movie, X, Director), Database),member(WordList,X),
  RelevantData = [Movie, X, Director],
  ProvidedInfo = [[],WordList,[]].
exists_in_database_left(WordList, WordList, Database,RelevantData, ProvidedInfo) :-
  member(star(Movie, Stars, WordList), Database), 
  RelevantData = [Movie,Stars, WordList],
  ProvidedInfo = [[],[],WordList, []].
exists_in_database_left(WordList, Result, Database,RelevantData, ProvidedInfo) :-
  append([_], ShorterWordList, WordList),
  exists_in_database_left(ShorterWordList, Result, Database,RelevantData, ProvidedInfo).

exists_in_database_right(WordList, WordList, Database, RelevantData, ProvidedInfo) :-
  member(star(WordList, Stars, Director), Database), 
  RelevantData = [WordList, Stars, Director], 
  ProvidedInfo = [WordList, [], []].
exists_in_database_right(WordList, WordList, Database, RelevantData, ProvidedInfo) :-
  member(star(Movie, X, Director), Database),member(WordList,X),
  RelevantData = [Movie, X, Director],
  ProvidedInfo = [[],WordList,[]].
exists_in_database_right(WordList, WordList, Database, RelevantData, ProvidedInfo) :-
  member(star(Movie, Stars, WordList), Database), 
  RelevantData = [Movie,Stars, WordList],
  ProvidedInfo = [[],[],WordList, []].
exists_in_database_right(WordList, Result, Database, RelevantData, ProvidedInfo) :-
  append(ShorterWordList, [_], WordList),
  exists_in_database_right(ShorterWordList, Result, Database, RelevantData, ProvidedInfo).

%---------------- Query question patterns ------------------------------------
 
find_question_attribute(WordList, Attr) :- pattern1(WordList, Attr).
%find_question_attribute(WordList, Attr) :- pattern2(WordList, Attr)
find_question_attribute(WordList, Attr) :-  not(pattern1(WordList, Attr)),
  Attr = "randomInfo". %all else fails choose a random one not provided info

%Give ... attribute; e.g. Give me the movie with Bill Pullman
qWordPat1("give").
qWordPat1("who").
qWordPat1("what").
pattern1(WordList, Result) :- member(QW, WordList),string_lower(QW,QWL),
  qWordPat1(QWL), nth1(QInd, WordList, QW), member(X, WordList), token(X, Result),
  nth1(AInd, WordList, X),AInd > QInd.
%Who ... attribute
%pattern2()

%----------------- Negation handling -------------------------------------------
 
eliminate_double_negation([],[]).
eliminate_double_negation([neg,neg|Rest],Result) :-
  eliminate_double_negation(Rest, Result).
eliminate_double_negation([Word|Rest],[Word|Result]) :-
  eliminate_double_negation(Rest, Result).

%------------------- Tokens ---------------------------------------------------

% any word starting with "star" or "act"...?
token(S, A) :- string_lower(S, LowS), attribute_token(LowS, A).
attribute_token(S, star) :- string_concat("star", _, S).
attribute_token(S, star) :- string_concat("act", _, S).
attribute_token(S, director) :- string_concat("direct", _, S).
attribute_token(S, director) :- string_concat("filmmaker", _, S).
attribute_token(S, director) :- string_concat("made", _, S).
attribute_token(S, director) :- string_concat("mak", _, S). %making, make
attribute_token(S, movie) :- string_concat("movie", _, S). %movie, movies
attribute_token(S, movie) :- S \= "filmmaker", string_concat("film", _, S).
attribute_token(S, movie) :- string_concat("flick", _, S).
negToken("not", neg).
negToken("no", neg).
negToken(S, neg) :- string_concat(_,"n't",S).
