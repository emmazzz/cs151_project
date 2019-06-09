# CS151 Project: Movie Q&A chatbot

## What is inside this repository?
#### Prolog code

`run.sh`: script loading and running the interactive prolog program  
`simple.pl`: top level code providing entry/exit point, dedicated to control flow of the program   
`token.pl`: main file containing the core part of our project(parsing, pattern matching, etc)  
`stringops.pl`: utility code realizing some string operations that are useful for parsing  
`query.pl`: code defining query interface interacting with the database  
`db.pl`: database containing entries in the form `star(MovieTitle, StarList, Director)` 
`db_generation/gen_db.py`: python code reading from the csv file and outputting entries in the form mentioned above  
`db_generation/movie_metadata.csv`: source data

#### Epilog code

`epilog_code`: epilog code with some comments for ease of examination   
`epilog_code_without_comments`: epilog code without comments, which can be directly pasted into Sierra and interacted with

## How to run the Prolog program
Install `swi-prolog`, (you might need to do `chmod +x run.sh` to make it runnable) and run
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
Did you know there are 2 directors you might have meant?
Which of these directors did you mean: Mick and Peter?  Peter
Thanks! Showing results for
Peter Jackson: You might be looking for the movies King Kong, The Hobbit: An Unexpected Journey, The Hobbit: The Battle of the Five Armies, The Hobbit: The Desolation of Smaug, The Lord of the Rings: The Fellowship of the Ring, The Lord of the Rings: The Return of the King, The Lord of the Rings: The Two Towers and The Lovely Bones
You might be looking for the movies King Kong, The Hobbit: An Unexpected Journey, The Hobbit: The Battle of the Five Armies, The Hobbit: The Desolation of Smaug, The Lord of the Rings: The Fellowship of the Ring, The Lord of the Rings: The Return of the King, The Lord of the Rings: The Two Towers and The Lovely Bones
Enter another question or 'bye' to quit.

Question: What is a movie with Quentin Tarantino
Quentin Tarantino has served as both a star and director. Are you looking for movies with him as (a) star, (b) as a director or (c) all movies he was involved in in any capacity? Enter your preference: c
You might be looking for the movie The Hateful Eight
Enter another question or 'bye' to quit.

Question: What is a movie with Quentin Tarantino
Quentin Tarantino has served as both a star and director. Are you looking for movies with him as (a) star, (b) as a director or (c) all movies he was involved in in any capacity? Enter your preference: a
You might be looking for the movie Grindhouse
Enter another question or 'bye' to quit.

Question: bye
Have a nice day!
true .

```

## What about the Epilog Program
Our epilog program provides a more limited interface compared to the Prolog program in the following ways:  
1. Only alphanumeric characters and words starting with lower case letters are permitted in the database.  
2. You can only ask about movies directed by a certain director or acted by a certain star.  
3. No disambiguation is supported.  

Start by pasting all the code in `epilog_code_without_comments` into Sierra.  
The main query function provided is `answer(+Query, -Answer)`. You can query the following in Sierra:
```
Pattern: Answer
Query: answer("show me movies acted by emma z", Answer)
Result: "You might be looking for the movies awesome movie one and awesome movie three"

Pattern: Answer
Query: answer("what are movies lara b is in", Answer)
Result: "You might be looking for the movies awesome movie two and awesome movie one"

Pattern: Answer
Query: answer("give me movies whose director is some one else", Answer)
Result: "You might be looking for the movies awesome movie three"

Pattern: Answer
Query: answer("show me all movies abhijeet m was a star for", Answer)
"You might be looking for the movies awesome movie one"
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

__Note that we cannot merely rely on proper nouns being present in our database to completely parse a request into our
required information fields for proper retrieval from our database, as some actors are also directors and there is often
available information in the query to inform our predictions of a query's intent.__

__Logic Programming Parsing Procedure   
*1.* Top down parsing for tokenization due to restricted vocabulary and specific application.  
*2.* DCG formulation, Sentence -> Quesiton word (QW) Provided info (PI) Requested Attribute (RA)  
*3.* CFG -- QW --> 'I want to know',  
*4.* Vocabulary e.g. Attribute -> {movie, star, director}__  


## test examples for demo:  
General usage:  
Show all movies by Quentin Tarantino?  
What was a movie by Tarantino?  
What was a movie with Tarantino involved? //please refine your query ... 3 options -- detecting waht is missing . 

Pattern detection:  
Who didn't not act in Titanic  // double negation   
What movie was Quentin Tarantino an actor for? //forms of word via concat  
What was Quentin Tarantino an actor for? //no specification of 'movie' -- see pattern a  
QT was an actor for what? //pattern b  


Why Logic Programming?  
A declarative language is well-suited for key-word and pattern recognitions, which we utilize through our identification of *definite-clause grammars*.
