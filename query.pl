/*
  find_all_movies_by_person(["David", "Lynch"],Movies,[
    star(["Mulholland", "Drive"],[["Justin", "Theroux"], ["Naomi", "Watts"]],["David","Lynch"]),
    star(["Lost", "Highway"],[["Balthazar", "Getty"], ["Bill", "Pullman"]],["David","Lynch"]),
    star(["Pulp","Fiction"], [["John","Travolta"],["Uma", "Thurman"]], ["Quentin", "Tarantino"]),
    star(["Movie","Starring","Lynch"], [["David", "Lynch"]], ["Some", "Director"])]).
  will return:
  Movies = [["Movie", "Starring", "Lynch"], ["Lost", "Highway"], ["Mulholland", "Drive"]].
*/

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
