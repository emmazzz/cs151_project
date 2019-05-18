% entry point
hi :- start([ % start with these movies
  star(["Kill", "Bill"],["Uma", "Thurman"]),
  star(["Kill", "Bill", "Three"],["Uma", "Thurman"]),
  star(["Pulp","Fiction"], ["John","Travolta"])]).

start(Database) :-
  ask(Input),
  control(Input, Database).

ask(Input) :-
  write('Question: '),
  flush,
  read_line_to_string(user_input,Input).

control("bye", _) :-
  writeln('Have a nice day!'),flush.
control(Input, Database) :-
  split_string(Input, " ", " " , WordList),
  answer(WordList, Database, Answer, NewDatabase),
  writeln(Answer),flush,
  start(NewDatabase).

% answer(["Who","directs"|Movie],Database, Answer,Database) :-
%   member(direct(Movie, AnswerList), Database),
%   concat_string_list(AnswerList, Answer).
% answer(["Who","directs"|_], Database, "I don't know this movie sorry :(", Database).
% answer(InputList, Database,
%   "Thanks for your information!", [direct(Movie, Person)|Database]) :-
%   append(Person, ["directs"|Movie], InputList).
answer(WordList, Database, "Pardon?", Database) :-
  tokenize(WordList,Result,Database),
  writeln(Result).

concat_string_list([],"").
concat_string_list([Head], Head).
concat_string_list([Head|Tail], Result) :-
  concat_string_list(Tail, Rest),
  string_concat(Head, " ", HeadSpace),
  string_concat(HeadSpace, Rest, Result).
