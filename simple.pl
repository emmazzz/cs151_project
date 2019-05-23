% entry point
hi :- start([ % start with these movies Movie, Actor list, director
  star(["Kill", "Bill"],[["Uma", "Thurman"],["Michael", "Madsen"]], ["Quentin", "Tarantino"]),
  star(["Kill", "Bill", "Three"],[["Uma", "Thurman"]], ["Quentin", "Tarantino"]),
  star(["Mulholland", "Drive"],[["Justin", "Theroux"], ["Naomi", "Watts"]],["David","Lynch"]),
  star(["Lost", "Highway"],[["Balthazar", "Getty"], ["Bill", "Pullman"]],["David","Lynch"]),
  star(["Pulp","Fiction"], [["John","Travolta"],["Uma", "Thurman"]], ["Quentin", "Tarantino"])]).

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
  replace_word(Input, ",", " ", InputSpNoCommas),
  rmvfrm_word(InputSpNoCommas, NoPunctInput),
  split_string(NoPunctInput, " ", " " , WordList),
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
  tokenize(WordList,Result,Database).
  %writeln(Result).

concat_string_list([],"").
concat_string_list([Head], Head).
concat_string_list([Head|Tail], Result) :-
  concat_string_list(Tail, Rest),
  string_concat(Head, " ", HeadSpace),
  string_concat(HeadSpace, Rest, Result).
