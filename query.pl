/*
  find_all_movies_by_person(["David", "Lynch"],Movies,[
    star(["Mulholland", "Drive"],[["Justin", "Theroux"], ["Naomi", "Watts"]],["David","Lynch"]),
    star(["Lost", "Highway"],[["Balthazar", "Getty"], ["Bill", "Pullman"]],["David","Lynch"]),
    star(["Pulp","Fiction"], [["John","Travolta"],["Uma", "Thurman"]], ["Quentin", "Tarantino"]),
    star(["Movie","Starring","Lynch"], [["David", "Lynch"]], ["Some", "Director"])]).
  will return:
  Movies = [["Movie", "Starring", "Lynch"], ["Lost", "Highway"], ["Mulholland", "Drive"]].
*/

/* movies by person; can't tell if star or director provided */
find_all_movies_by_type(NewRole, ProvidedInfo, Movies, Database) :-
	NewRole = stardirector, find_all_movies_by_person(ProvidedInfo, Movies, Database).

/* movies by star */
find_all_movies_by_type(NewRole, ProvidedInfo, Movies, Database) :-
	NewRole = star ,
	find_all_movies_by_star(ProvidedInfo, Movies, Database).

/* movies by director */
find_all_movies_by_type(NewRole, ProvidedInfo, Movies, Database) :-
	NewRole = director,
	find_all_movies_by_director(ProvidedInfo, Movies, Database).

find_all(Person, Movies) :- database(D), find_all_movies_by_person(Person, Movies, D).
/* specific find_all_movies_by_x definitions */
find_all_movies_by_person(Person, Movies, Database) :-
  find_all_movies_by_star(Person, StarredMovies, Database),
  find_all_movies_by_director(Person, DirectedMovies, Database),
  union(StarredMovies, DirectedMovies, Movies).

find_all_movies_by_star(Star, Movies, Database) :-
  setof(Movie,find_one_movie_by_star(Star, Movie, Database), Movies).
find_one_movie_by_star(Star, Movie, Database) :-
  member(star(Movie, Stars, _), Database),
  member(Star, Stars).

find_all_movies_by_director(Director, Movies, Database) :-
  setof(Movie,find_one_movie_by_director(Director, Movie, Database), Movies).
find_one_movie_by_director(Director, Movie, Database) :-
  member(star(Movie, _, Director), Database).

/* TODO: find all actors related to director;
		 find all directors related to actor
*/
