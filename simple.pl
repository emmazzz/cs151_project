/*----------------------------CS 151 PROJECT: MOVIE CHATBOT----------------------------*/
/*----------------------------Lara Bagdasarian, Emma Zhong-----------------------------*/
/* Usage: Enter hi. in the query box (needs to be typed exactly) and click the 'Run!'
 * button. Enter questions according to the prompts in the 'line>' field */
/*-------FOR MORE USAGE DETAILS AND ANALOGOUS EPILOG CODE SEE readme.pdf--------------*/

% entry point
:- consult('stringops.pl').
:- consult('query.pl').
:- consult('token.pl').
:- consult('db.pl').

/*----------------------------QUERY TO START THE DATABASE------------------------------*/

hi :- database(X), start(X).

/*----------------------------PRIMARY CONTROL SEQUENCE---------------------------------*/

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
  tokenize(WordList,Result,Database), ((not_instantiated(Result), writeln("Sorry, we couldn't understand what you said; please try again.")); (not(not_instantiated(Result)),writeln(Result))).
