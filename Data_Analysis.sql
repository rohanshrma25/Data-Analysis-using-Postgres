-- no of bookings as per room class

select 
	room_class, count(*) as total_bookings
from 
	dim_rooms dr join fact_booking fb on room_category=room_id
group by 
	room_class;


-- properties with specified ratings

select 
	dh.property_name, avg(ratings_given) as avg_ratings
from 
	dim_hotels dh join fact_booking fb on dh.property_id=fb.property_id
group by 
	property_name
having 
	avg(ratings_given)<3;


-- monthly revenue by property

with monthly_rev as (
	select 
		to_char(check_in_date,'month') as month, sum(revenue_generated) as total_revenue
	from 
		fact_booking
	group by 
		month
)

select 
	to_char(check_in_date,'month') as month, dh.property_id, dh.property_name, sum(fb.revenue_generated) as total_revenue,
	round(sum(fb.revenue_generated)::numeric/mr.total_revenue::numeric,4)*100 as pct_monthly_rev,
	row_number() over(partition by to_char(check_in_date,'month') order by sum(fb.revenue_generated) desc) as rev_rank
from 
	fact_booking fb 
join 
	monthly_rev mr on to_char(check_in_date,'month')=mr.month
join 
	dim_hotels dh on fb.property_id=dh.property_id
group by
	to_char(check_in_date,'month'), dh.property_id, dh.property_name, mr.total_revenue
order by 
	to_char(check_in_date,'month'), rev_rank;


-- stay duration

select 
	booking_id, no_guests, check_in_date, checkout_date, (checkout_date - check_in_date) as stay_duration
from 
	fact_booking;


-- city-wise avg hotel occupancy 

select 
	city, round(avg(successful_bookings)/avg(capacity)*100,2) as avg_occupancy_perc 
from 
	dim_hotels dh join fact_aggregated_bookings fab on dh.property_id=fab.property_id
group by 
	city;


-- day of the week with the highest number of bookings in july:

select 
	to_char(check_in_date, 'day') as day_of_week, count(*) as no_of_bookings
from 
	fact_booking 
where 
	check_in_date >= '2022-07-01' and check_in_date <= '2022-08-01' 
group by 
	to_char(check_in_date, 'day')
order by 
	no_of_bookings desc;


-- city wise revenue realized 

select 
	dh.city,
	sum(case when booking_status in ('cancelled') then revenue_generated*0.4 else revenue_generated end) as total_revenue
from 
	dim_hotels dh join fact_booking fb on dh.property_id=fb.property_id
group by 
	dh.city;


-- monthly growth rate

with revenue as (
    select 
        dh.property_id, 
        dh.property_name, 
        extract(month from check_in_date) as month, 
        sum(revenue_generated)::numeric as total_revenue
    from 
        dim_hotels dh 
    join 
        fact_booking fb 
    on 
        dh.property_id = fb.property_id
    group by 
        dh.property_id, dh.property_name, month
)

select 
    property_id, 
    property_name, 
    month, 
    total_revenue,
    round(total_revenue/ lag(total_revenue) over (partition by property_id order by month) -1,4)*100 as prv
from 
    revenue
order by 
    property_id, month;


-- top 5 properties with highest ratings

select 
	dh.property_id, dh.property_name, avg(ratings_given) as avg_ratings
from 
	dim_hotels dh join fact_booking fb on dh.property_id=fb.property_id
group by 
	dh.property_id, dh.property_name
order by 
	avg_ratings desc
limit 5;


-- revenue for each month (luxury category)

select 
	dh.property_id, dh.property_name, to_char(fb.check_in_date,'month') as month,
	sum(case when booking_status in ('checked out','no show') then fb.revenue_realized else fb.revenue_realized*0.6 end) as total_revenue
from 
	dim_hotels dh join fact_booking fb on dh.property_id=fb.property_id
where 
	dh.category='luxury'
group by 
	dh.property_id, dh.property_name, month;