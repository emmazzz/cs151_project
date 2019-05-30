# cs151_project
CS151 Project: fact-based Q&A chatbot

## Initial Attempt: simple.pl
Install `swi-prolog` and run
```
$ swipl
```
Load `simple.pl`, `token.pl`, `stringops.pl`, 'query.pl' and interact with it like
```
?- [simple]. [stringops]. [token]. [query].

true.

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

## Stage 2: Interpreting Imprecise Queries; Parsing to Obtain Informed Label for Provided Data
In this stage, we enable users to enter incomplete information in their queries in certain situations and 
prompt them to fill in the missing information in order to retrieve relevant information. For example, if a 
user enters a query such as "What are some movies by Coppola?" the user could either be requesting movies by
Francis Ford Coppola or Sofia Coppola. In situations such as these, we list our predictions for what the user could 
have intended for the director's first name, e.g., Francis Ford or Sofia, and give the user an opportunity to further
clarify what he meant.
___
Also in this stage, we use pattern matching techniques to classify the nature of the information provided in the query
from which to obtain the result. Since attribute-related text in a query can also specify the request subject matter of a query, 
we use surrounding words to discern contextual information and utilize common inquiry-oriented grammatical constructions about the *data 
provided*.

## Stage 3: Advanced Query Parsing
There are many ways humans express query requests in natural language.
In this stage, we develop more comprehensive techniques to parse queries 
for precise information retrieval. We develop pattern-matching rules to 
detect keywords and the patterns within which they reside. 
___
_Examples of queries_ we will be able to parse after completing this stage are as follows (ranging from
simpler to more complex):
* What did _Quentin Tarantino_ act in?
* _Quentin Tarantino_  acted in what?
* _Quentin Tarantino_  and _David Lynch_ are two great directors, but I want to see some
movies by the former.
___
Note that we cannot merely rely on proper nouns being present in our database to completely parse a request into our 
required information fields for proper retrieval from our database, as some actors are also directors and there is often 
available information in the query to inform our predictions of a query's intent.
---
Logic Programming Parsing Procedure
*1.* Top down parsing for tokenization due to restricted vocabulary and specific application.
*2.* DCG formulation, Sentence -> Quesiton word (QW) Provided info (PI) Requested Attribute (RA)
*3.* CFG -- QW --> 'I want to know', 
*4.* Vocabulary e.g. Attribute -> {movie, star, director}
---

4 test examples for demo:
General usage:
Show all movies by Quentin Tarantino?
What was a movie by Tarantino? 
What was a movie with Tarantino involved? //please refine your query ... 3 options -- detecting waht is missing
Pattern detection:
[double negative example]
What movie was Quentin Tarantino an actor for? //forms of word via concat
What was Quentin Tarantino an actor for? //no specification of 'movie' -- see pattern a
QT was an actor for what? //pattern b


Why Logic Programming?
A declarative language is well-suited for key-word and pattern recognitions, which we utilize through our identification of *definite-clause grammars*.