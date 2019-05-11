% entry point
hi :- start([ % start with these movies
  directs(["The", "Terminator"],["James", "Cameron"]),
  directs(["Pulp","Fiction"] ,["Quentin","Tarantino"])]).

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

answer(["Who","directs"|Movie],Database, Answer,Database) :-
  member(directs(Movie, AnswerList), Database),
  concat_string_list(AnswerList, Answer).
answer(["Who","directs"|_], Database, "I don't know this movie sorry :(", Database).
answer(InputList, Database,
  "Thanks for your information!", [directs(Movie, Person)|Database]) :-
  append(Person, ["directs"|Movie], InputList).
answer(_, Database, "Pardon?", Database).

concat_string_list([],"").
concat_string_list([Head], Head).
concat_string_list([Head|Tail], Result) :-
  concat_string_list(Tail, Rest),
  string_concat(Head, " ", HeadSpace),
  string_concat(HeadSpace, Rest, Result).
