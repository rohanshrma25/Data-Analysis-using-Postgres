-- 1 No of bookings as per room class

SELECT
    dr.room_class,
    COUNT(*) AS total_bookings
FROM
    dim_rooms dr
JOIN
    fact_bookings fb ON dr.room_id = fb.room_category
GROUP BY
    dr.room_class;
	

-- 2 Properties with specified ratings

SELECT
    dh.property_name,
    AVG(fb.ratings_given) AS avg_ratings
FROM
    dim_hotels dh
JOIN
    fact_bookings fb ON dh.property_id = fb.property_id
GROUP BY
    dh.property_name
HAVING
    AVG(fb.ratings_given) < 3;


-- 3 Stay duration

SELECT
    fb.booking_id,
	fb.no_guests,
    fb.check_in_date,
    fb.checkout_date,
    DATEDIFF(day, fb.check_in_date, fb.checkout_date) AS stay_duration_days
FROM
    fact_bookings fb
JOIN
    dim_hotels dh ON fb.property_id = dh.property_id
JOIN
    dim_rooms dr ON fb.room_category = dr.room_id;


-- 4 City-wise Avg hotel Occupancy 

SELECT
    city,
    ROUND((AVG(successful_bookings) / AVG(capacity)) * 100, 2) AS avg_occupancy_percentage
FROM
    dim_hotels
JOIN
    fact_aggregated_bookings ON dim_hotels.property_id = fact_aggregated_bookings.property_id
GROUP BY
    city;


-- 5 Day of the week with the highest number of bookings in July:

SELECT 
    DATENAME(WEEKDAY, fb.check_in_date) AS day_of_week,
    COUNT(DISTINCT fb.booking_id) AS total_bookings
FROM
    fact_bookings fb
WHERE
    fb.check_in_date >= '2022-07-01' AND fb.check_in_date < '2022-08-01'
GROUP BY
    DATENAME(WEEKDAY, fb.check_in_date)
ORDER BY
    total_bookings DESC;


-- 6 City wise revenue realized 

SELECT
    dh.city,
    SUM(CASE WHEN fb.booking_status IN ('Cancelled') THEN fb.revenue_generated * 0.4
             ELSE fb.revenue_generated END) AS total_revenue
FROM
    dim_hotels dh
JOIN
    fact_bookings fb ON dh.property_id = fb.property_id
GROUP BY
    dh.city;


-- 7 Top 5 properties with highest ratings

WITH Ratings AS (
    SELECT
        property_id,
        ROUND(AVG(ratings_given),2) AS avg_rating
    FROM
        fact_bookings
    GROUP BY
        property_id
)
SELECT TOP 5
    dh.property_id,
    dh.property_name,
    rc.avg_rating
FROM
    Ratings rc
JOIN
    dim_hotels dh ON rc.property_id = dh.property_id
ORDER BY
    rc.avg_rating DESC;


-- 8 Revenue for each month (Luxury category)

SELECT
    dh.property_id,
    dh.property_name,
    DATENAME(MONTH, fb.check_in_date) AS month,
    SUM(CASE WHEN fb.booking_status IN ('Checked Out', 'No show') THEN fb.revenue_realized
             ELSE fb.revenue_realized * 0.6 END) AS total_revenue
FROM
    dim_hotels dh
JOIN
    fact_bookings fb ON dh.property_id = fb.property_id
WHERE
    dh.category = 'Luxury'
GROUP BY
    dh.property_id, dh.property_name, DATENAME(MONTH, fb.check_in_date);


-- 9 Month on month growth rate

WITH RevenueCTE AS (
    SELECT
        dh.property_id,
        dh.property_name,
        DATEPART(MONTH, fb.check_in_date) AS month,
        SUM(CASE WHEN fb.booking_status IN ('Checked Out', 'No show') THEN fb.revenue_realized
                 ELSE fb.revenue_realized * 0.6 END) AS total_revenue
    FROM
        dim_hotels dh
    JOIN
        fact_bookings fb ON dh.property_id = fb.property_id
    GROUP BY
        dh.property_id, dh.property_name, DATEPART(MONTH, fb.check_in_date)
)
SELECT
    property_id,
    property_name,
    month,
    total_revenue,
    (total_revenue / LAG(total_revenue) OVER (PARTITION BY property_id ORDER BY month) - 1) AS growth_rate
FROM
    RevenueCTE;


-- 10 Pivot table: revenue as per room class

SELECT *
FROM (
    SELECT dr.room_class, fb.revenue_realized
    FROM fact_bookings fb
    INNER JOIN dim_rooms dr ON fb.room_category = dr.room_id
) AS src
PIVOT (
    SUM(revenue_realized)
    FOR room_class IN ([Standard], [Elite], [Premium], [Presidential])
) AS pivoted_table;


-- 11 Ranking top revenue property name

WITH RevenueSummary AS (
    SELECT
        dh.property_name,
        SUM(fb.revenue_generated) AS revenue,
        RANK() OVER (ORDER BY SUM(fb.revenue_generated) DESC) AS revenue_rank
    FROM
        dim_hotels dh
    JOIN
        fact_bookings fb ON dh.property_id = fb.property_id
    GROUP BY
        dh.property_name
)
SELECT top 3
    property_name,
    revenue,
    revenue_rank
FROM
    RevenueSummary
