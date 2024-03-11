--Updating empty cells in the table

Select * from SpotifyProject.dbo.Popular_Spotify_Songs$
where streams is NULL

--The value for column 'streams' is missing from the track 'Love Grows (where My Rosemary Goes)', therefore 
--I check for it on Spotify and update the table with the missing value

UPDATE Popular_Spotify_Songs$
SET streams = 235055654
WHERE track_name = 'Love Grows (Where My Rosemary Goes)';

--Combining the values from the columns 'released_year', 'released_month', 'released_day' into a single column containing
--the release date of each track

ALTER TABLE SpotifyProject.dbo.Popular_Spotify_Songs$
Add release_date DATE;

UPDATE Popular_Spotify_Songs$
SET release_date = CONCAT(released_year, '-', released_month, '-', released_day)

ALTER TABLE SpotifyProject.dbo.Popular_Spotify_Songs$
DROP COLUMN released_year, released_month, released_day


--Checking for duplicates

SELECT track_name, [artist(s)_name]
FROM SpotifyProject.dbo.Popular_Spotify_Songs$
GROUP BY track_name, [artist(s)_name]
HAVING COUNT(*) > 1

--There are four tracks which appear twice, as a result of a track released as a single being considered
--separate from the track released as part of an album, therefore I will only consider the version
--with the higher value for the 'in_spotify_charts' column, or the higher amount of streams where those values are equal

DELETE FROM SpotifyProject.dbo.Popular_Spotify_Songs$
WHERE (track_name = 'About Damn Time' 
or track_name = 'SNAP'
or track_name = 'SPIT IN MY FACE!')
AND in_spotify_charts = 0

DELETE FROM SpotifyProject.dbo.Popular_Spotify_Songs$
WHERE track_name = 'Take My Breath'
AND streams = 130655803

--Checking which tracks have over a billion streams/ over three billion streams

Select track_name, [artist(s)_name], streams
FROM SpotifyProject.dbo.Popular_Spotify_Songs$
WHERE streams >= 1000000000


Select track_name, [artist(s)_name], streams
FROM SpotifyProject.dbo.Popular_Spotify_Songs$
WHERE streams >= 3000000000

--Comparing the amount of songs in Minor vs Major mode, and in each key

Select distinct(mode), count(mode) as total
FROM SpotifyProject.dbo.Popular_Spotify_Songs$
Group by mode
Order by 2

Select distinct([key]), count([key]) as total
FROM SpotifyProject.dbo.Popular_Spotify_Songs$
WHERE [key] is not NULL
Group by [key]
Order by 2

--Checking how many of the tracks were released on each date

Select release_date, count(*) as total, avg(streams) as avg_streams_on_date
FROM SpotifyProject.dbo.Popular_Spotify_Songs$
Group by release_date
Order by release_date


--Checking which tracks are included in the highest number of playlists per stream (with at least 10 million streams)

Select TOP 30 track_name, [artist(s)_name], in_spotify_playlists/streams as playlists_per_stream
FROM SpotifyProject.dbo.Popular_Spotify_Songs$
WHERE streams > 10000000
Order by 3 DESC


--Checking for the average value of each descriptor

SELECT AVG([danceability_%]) AS avg_danceability, AVG([valence_%]) as avg_valence, 
AVG([energy_%]) as avg_energy, AVG([acousticness_%]) as avg_acousticness,
AVG([instrumentalness_%]) as avg_instrumentalness, 
AVG([liveness_%]) as avg_liveness, AVG([speechiness_%]) as avg_speechiness
FROM SpotifyProject.dbo.Popular_Spotify_Songs$

--Comparing the average popularity of a song relative to the amount of artists featured

Select artist_count, AVG(streams) as avg_streams
FROM SpotifyProject.dbo.Popular_Spotify_Songs$
Group by artist_count
Order by 2 DESC