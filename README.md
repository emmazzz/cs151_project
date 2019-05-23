# cs151_project
CS151 Project: fact-based Q&A chatbot

## Initial Attempt: simple.pl
Install `swi-prolog` and run
```
$ swipl
```
Load `simple.pl`, `token.pl`, `stringops.pl` and interact with it like
```
?- [simple]. [stringops]. [token].

true.

true.

true.

?- hi.
Question: Who directs Pulp  Fiction
Quentin Tarantino
Question: Thanks!
Pardon? // he doesn't understand this
Question: Who directs Forrest Gump
I don't know this movie sorry :(
Question: Robert Zemeckis directs Forrest Gump // add to database
Thanks for your information!
Question: Who directs Forrest Gump
Robert Zemeckis
Question: bye
Have a nice day!
true .
```

## Stage 1: movie terminology detection
Single response to single-keyword-specifying queries.
Questions involve any one of the three attributes:
* movie (i.e. title)
* star
* director
