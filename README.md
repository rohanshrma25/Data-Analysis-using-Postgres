# Database creation, 
This repository contains SQL scripts and instructions for setting up a database, importing data in bulk using psql, and performing various data analysis tasks to derive insights into hotel bookings, revenues, occupancy, and guest preferences.

## Prerequisites

- PostgreSQL installed
- Access to `psql` command-line tool
- CSV data files for bulk uploading: `region.csv`, `sales_rep.csv`, `accounts.csv`, `web_events.csv`, `orders.csv` (refer to dataset folder in repo)


## Database Creation

To create the database and tables, following SQL scripts are used:

```sql
postgres=# create database ds;

postgres=# \c ds;

create table dim_hotels(
    property_id int primary key,
    property_name varchar,
    category varchar,
    city varchar
);


create table dim_rooms(
    room_id varchar primary key,
    room_class varchar unique
);


create table fact_aggregated_bookings(
    property_id int,
    check_in_date date,
    room_category varchar,
    successful_bookings int,
    capacity int,
    foreign key (property_id) references dim_hotels(property_id),
    foreign key (room_category) references dim_rooms(room_id)
);


create table fact_booking(
    booking_id varchar,
    property_id int,
    booking_date date,
    check_in_date date,
    checkout_date date,
    no_guests int,
    room_category varchar,
    booking_platform varchar,
    ratings_given int,
    booking_status varchar,
    revenue_generated int,
    revenue_realized int,
    foreign key (property_id) references dim_hotels(property_id),
    foreign key (room_category) references dim_rooms(room_id)
);
```

## Bulk Uploading Data

Bulk upload data from CSV files into the corresponding tables using the following `psql` commands.

```
ds=# \copy dim_hotels from 'C:\Users\Rohan\OneDrive\Desktop\Hotel Data\dim_hotels.csv' DELIMITER ',' CSV HEADER;
ds=# \copy dim_rooms from 'C:\Users\Rohan\OneDrive\Desktop\Hotel Data\dim_rooms.csv' DELIMITER ',' CSV HEADER;
ds=# \copy fact_aggregated_bookings from 'C:\Users\Rohan\OneDrive\Desktop\Hotel Data\fact_aggregated_bookings.csv' DELIMITER ',' CSV HEADER;
ds=# \copy fact_booking from 'C:\Users\Rohan\OneDrive\Desktop\Hotel Data\fact_booking.csv' DELIMITER ',' CSV HEADER;
```


## Types of SQL Queries Used
The SQL queries in this project employ various SQL techniques, including:

* Window functions
* Ranking functions
* Joins and relationships
* Aggregate functions
* Filtering and conditional logic
* Date functions


## Running Queries
Open Data_Analysis.sql to find various SQL queries for analyzing the data. Execute these queries in your PostgreSQL environment to obtain insights such as

* Total bookings per room class.
* Properties with low ratings.
* Monthly revenue by property.
* Stay duration analysis.
* City-wise average hotel occupancy.
* Day of the week with the highest bookings in July.
* City-wise revenue realized.
* Monthly growth rate analysis.
* Top properties with highest ratings.
* Revenue by month for luxury category hotels.


## Usage
Each SQL query is documented and can be directly executed against a compatible relational database management system (RDBMS). Simply copy and paste the query into your preferred SQL editor or environment.

## Dataset
The queries are designed to work with a hypothetical hotel management database. The schema and data can be customized to fit specific requirements.

## Credits
This project was created as part of a Data Analyst portfolio to showcase skills in database querying and analysis.

