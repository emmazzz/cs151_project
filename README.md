# CS151 Project: Movie Q&A Chatbot

## What is inside this folder?
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
Peter Jackson: You might be looking for the movies King Kong, The Hobbit: An Unexpected Journey, The
Hobbit: The Battle of the Five Armies, The Hobbit: The Desolation of Smaug, The Lord of the Rings: The
Fellowship of the Ring, The Lord of the Rings: The Return of the King, The Lord of the Rings: The Two
Towers and The Lovely Bones
You might be looking for the movies King Kong, The Hobbit: An Unexpected Journey, The Hobbit: The Battle
of the Five Armies, The Hobbit: The Desolation of Smaug, The Lord of the Rings: The Fellowship of the
Ring, The Lord of the Rings: The Return of the King, The Lord of the Rings: The Two Towers and The
Lovely Bones
Enter another question or 'bye' to quit.

Question: What is a movie with Quentin Tarantino
Quentin Tarantino has served as both a star and director. Are you looking for movies with him as (a)
star, (b) as a director or (c) all movies he was involved in in any capacity? Enter your preference: c
You might be looking for the movie The Hateful Eight
Enter another question or 'bye' to quit.

Question: What is a movie with Quentin Tarantino
Quentin Tarantino has served as both a star and director. Are you looking for movies with him as (a)
star, (b) as a director or (c) all movies he was involved in in any capacity? Enter your preference: a
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
