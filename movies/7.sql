SELECT title, ratings.rating
FROM movies
JOIN ratings ON movies.id = movie_id
WHERE year = 2010
ORDER BY rating DESC, title;
