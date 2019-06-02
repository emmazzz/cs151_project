% entry point
:- consult('stringops.pl').
:- consult('query.pl').
:- consult('token.pl').
:- consult('db.pl').

hi :- database(X), start(X).
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

answer(WordList, Database, "Enter another question or 'bye' to quit.\n", Database) :-
  tokenize(WordList,Result,Database), writeln(Result).
