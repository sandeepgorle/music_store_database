--1. Who is the senior most employee based on job title?--

select * from employee
order by levels desc
limit 1;

--2. Which countries have the most Invoices?--
select count(*) as c, billing_country 
from invoice
group by billing_country
order by c desc;

--3. What are top 3 values of total invoice?--

select total from invoice
order by total desc
limit 3;

-- 4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals --

select sum(total) as invoice_total, billing_city 
from invoice
group by billing_city 
order by invoice_total desc;

-- . Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money --

select * from customer
select c.customer_id, c.first_name,c.last_name, sum(i.total) as total
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id
order by total desc
limit 1;

--- Write query to return the email, first name, last name, & Genre of all Rock Music
--listeners. Return your list ordered alphabetically by email starting with A---

select distinct email,first_name,last_name 
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
where track_id in(
	select track_id from track t 
	join genre g on t.genre_id = g.genre_id 
	where g.name like 'Rock'
)
order by email asc;


--Let's invite the artists who have written the most rock music in our dataset. Write a
--query that returns the Artist name and total track count of the top 10 rock bands

select * from artist

select ar.artist_id, ar.name, count(ar.artist_id) as num_of_songs
from track t 
join album al on al.album_id = t.album_id
join artist ar on ar.artist_id = al.artist_id
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by ar.artist_id
order by num_of_songs desc
limit 10;

---Return all the track names that have a song length longer than the average song length.
---Return the Name and Milliseconds for each track. Order by the song length with the
---longest songs listed first

select * from track

select name, milliseconds
from track 
where milliseconds > (
	select avg(milliseconds) as avg_track_length
	from track)
order by milliseconds desc;

--- Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent
select * from customer
select * from artist
select * from invoice

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1








