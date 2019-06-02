# cs151_project
CS151 Project: fact-based Q&A chatbot

## Initial Attempt: simple.pl
Install `swi-prolog` and run
```
$ ./run.sh
```
Which will load `simple.pl`, and you can interact with it like
```
?- hi.
Question: Who directs Titanic
The director you're looking for is James Cameron
Enter another question or 'bye' to quit.

Question: Show me stars in Titanic
You might be looking for these stars: Leonardo DiCaprio, Kate Winslet and Gloria Stuart
Enter another question or 'bye' to quit.

Question: Give me all movies by Jackson
[Mick,Peter]
Did you know there are 2 directors you might have meant?
Which of these directors did you mean: Mick and Peter?  Peter
Thanks! Showing results for
Peter Jackson: You might be looking for the movies King Kong, The Hobbit: An Unexpected Journey, The Hobbit: The Battle of the Five Armies, The Hobbit: The Desolation of Smaug, The Lord of the Rings: The Fellowship of the Ring, The Lord of the Rings: The Return of the King, The Lord of the Rings: The Two Towers and The Lovely Bones
You might be looking for the movies King Kong, The Hobbit: An Unexpected Journey, The Hobbit: The Battle of the Five Armies, The Hobbit: The Desolation of Smaug, The Lord of the Rings: The Fellowship of the Ring, The Lord of the Rings: The Return of the King, The Lord of the Rings: The Two Towers and The Lovely Bones
Enter another question or 'bye' to quit.

Question: What is a movie with Quentin Tarantino
Quentin Tarantino has served as both a star and director. Are you looking for movies with him as (a) star, (b) as a director or (c) all movies he was involved in in any capacity? Enter your preference: c
You might be looking for the movie Lara Croft: Tomb Raider
Enter another question or 'bye' to quit.

Question: What is a movie with Quentin Tarantino
Quentin Tarantino has served as both a star and director. Are you looking for movies with him as (a) star, (b) as a director or (c) all movies he was involved in in any capacity? Enter your preference: a
You might be looking for the movie Grindhouse
Enter another question or 'bye' to quit.

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
