USE MUSICSTORE;

-- Question Set 1 - Easy

-- 1.Who is the senior most employee based on job title?
select * from employee;
select * from employee order by levels desc limit 1;

select concat(first_name,' ',last_name) as name_of_employee,title from employee where levels =
(select levels from employee order by levels desc limit 1);

-- 2.Which countries have the most Invoices?
select * from invoice;
select billing_country,count(invoice_id) no_of_invoice from invoice 
group by billing_country order by no_of_invoice desc;

-- 3.What are top 3 values of total invoice?
select * from invoice;
select total from invoice order by total desc limit 3;
select * from invoice order by total desc limit 3;

-- 4.Which city has the best customers? We would like to throw a promotional Music.
select * from invoice;
select billing_city,count(customer_id) from invoice group by billing_city order by count(customer_id) desc;

-- 5.Festival in the city we made the most money. Write a query that returns one city that has the highest sum 
-- of invoice totals. Return both the city name & sum of all invoice totals.
select * from invoice;
select billing_city,sum(total) from invoice group by billing_city order by sum(total) desc;

-- 6.Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
select * from invoice;
select * from customer where customer_id =
(select customer_id from invoice group by customer_id order by sum(total) desc limit 1);


select customer_id,sum(total) from invoice group by customer_id order by sum(total) desc;

-- Question Set 2 – Moderate

-- 1.Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your 
-- list ordered alphabetically by email starting with A.

select
     cu.email,
	 cu.first_name,
     cu.last_name,
     ge.name as genre
from customer cu
     inner join
     invoice inv on cu.customer_id = inv.customer_id
     inner join
     invoice_line invl on inv.invoice_id = invl.invoice_id
     inner join 
     track tr on invl.track_id = tr.track_id
     inner join
     genre ge on tr.genre_id = ge.genre_id
where ge.name = 'rock'
order by cu.email;

-- 2.Let's invite the artists who have written the most rock music in our dataset. Write a query that returns 
-- the Artist name and total track count of the top 10 rock bands.
select
     ar.name,
     count(tr.track_id)
from 
   artist ar
   inner join
   album2 al on ar.artist_id = al.artist_id
   inner join
   track tr on al.album_id = tr.album_id
   inner join
   genre ge on tr.genre_id = ge.genre_id
where ge.name = 'Rock'
group by ar.name
order by count(tr.track_id) desc
limit 10;

-- 3.Return all the track names that have a song length longer than the average song length. Return the Name 
-- and Milliseconds for each track. Order by the song length with the longest songs listed first.
select * from track;

select name,milliseconds from track where milliseconds >
(select avg(milliseconds) from track)
order by milliseconds desc;

select
     cu.email,
     cu.first_name,
     cu.last_name,
     ge.name
from 
   customer cu 
   inner join
   invoice inv on cu.customer_id = inv.customer_id
   inner join 
   invoice_line invl on inv.invoice_id = invl.invoice_id
   inner join 
   track tr on invl.track_id = tr.track_id
   inner join 
   genre ge on tr.genre_id = ge.genre_id 
   where ge.name = 'Rock'
   order by cu.email;
   
-- Question Set 3 – Advance

-- 1.Find how much amount spent by each customer on artists? Write a query to returncustomer name, artist name 
-- and total spent.
select 
     concat(cu.first_name,' ',cu.last_name) as customer_name,
     art.name as artist_name,
     sum(invl.unit_price) as total_spent
from
   customer cu
   inner join 
   invoice inv on cu.customer_id = inv.customer_id
   inner join
   invoice_line invl on inv.invoice_id = invl.invoice_id
   inner join
   track tr on invl.track_id = tr.track_id
   inner join 
   album2 alb on tr.album_id = alb.album_id
   inner join 
   artist art on alb.artist_id = art.artist_id
group by customer_name,artist_name
order by total_spent desc;

-- 2.We want to find out the most popular music Genre for each country. We determine the most popular genre as 
-- the genre with the highest amount of purchases. Write a query that returns each country along with the top 
-- Genre. For countries where the maximum number of purchases is shared return all Genres.

select country,genre_name from 
(select
     inv.billing_country as country,
     ge.name as genre_name,
     rank() over(partition by inv.billing_country order by sum(invl.unit_price) desc) genre_rank
from 
   invoice inv 
   inner join 
   invoice_line invl on inv.invoice_id = invl.invoice_id
   inner join 
   track tr on invl.track_id = tr.track_id
   inner join 
   genre ge on tr.genre_id = ge.genre_id
group by country,genre_name) as x 
where genre_rank = 1;

-- 3. Write a query that determines the customer that has spent the most on music for each country. Write a 
-- query that returns the country along with the top customer and how much they spent. For countries where the 
-- top amount spent is shared, provide all customers who spent this amount.

select country,customer_name,total_spent from
(select 
     inv.billing_country as country,
     concat(cu.first_name,' ',cu.last_name) as customer_name,
     sum(invl.unit_price) as total_spent,
     dense_rank() over(partition by inv.billing_country order by sum(invl.unit_price) desc) rnk
from
    customer cu 
    inner join 
    invoice inv on cu.customer_id = inv.customer_id
    inner join
    invoice_line invl on inv.invoice_id = invl.invoice_id 
group by inv.billing_country,customer_name
order by inv.billing_country,rnk) as x
where rnk = 1;

-- 1. Find the total number of tracks available for each genre.

select 
     ge.name as genre_name,
     count(tr.track_id) as No_of_tracks
from 
   track tr
   inner join
   genre ge on tr.genre_id = ge.genre_id
group by genre_name
order by No_of_tracks desc;

-- 2. Identify the top-selling album in terms of the total revenue generated.

select
     al.title as album_title,
     sum(invl.unit_price) as total_revenue
from
   invoice_line invl
   inner join
   track tr on invl.track_id = tr.track_id
   inner join
   album2 al on tr.album_id = al.album_id
group by album_title
order by total_revenue desc;

-- 3.Determine the average song length for each genre.

select 
     ge.name as genre_name,
     avg(tr.milliseconds) / 1000 as avg_song_length
from 
   track tr
   inner join
   genre ge on tr.genre_id = ge.genre_id
group by genre_name
order by avg_song_length desc;

-- 4.Who is the artist with the highest number of tracks in the dataset?

select
     ar.name as artist_name,
     count(tr.track_id) No_of_tracks
from
   artist ar
   inner join
   album2 al on ar.artist_id = al.artist_id
   inner join 
   track tr on al.album_id = tr.album_id
group by artist_name
order by No_of_tracks desc;

-- 5.Find the customer who made the earliest purchase in the dataset.

-- moderate
-- 1.Return the list of customers who have made purchases in at least three different countries. 

-- 2. Find the top 5 countries with the highest average invoice total.
select billing_country,avg(total)
from invoice 
group by billing_country
order by avg(total) desc
limit 5;

SELECT
    it.billing_country,
    AVG(it.total) AS average_invoice_total
FROM
    (
        SELECT
            i.billing_country,
            i.invoice_id,
            SUM(il.unit_price * il.quantity) AS total
        FROM
            invoice i
            INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
        GROUP BY
            i.invoice_id, i.billing_country
    ) AS it
GROUP BY
    it.billing_country
ORDER BY
    average_invoice_total DESC
LIMIT 5;

-- 3.Return the top 3 artists who have the highest total sales in terms of revenue. 

select
     ar.artist as artist_name,
     sum(invl.unit_price * invl.quantity) as revenue
from
   artist ar 
   inner join
   album2 al on ar.artist_id = al.artist_id
   inner join
   track tr on al.album_id = tr.album_id
   inner join
   



     
































  
   

   




















