create table input_data (calories int);

.import input.txt input_data

-- clear input and assing an order number for each row
with carrying as
     (select
        iif(calories = '', null, calories) as calories,
        ROW_NUMBER() OVER(ORDER BY(SELECT NULL)) as id
      from input_data),
-- add rolling sum column and offset calories column by one
with_rolling_sum as
       (select
            lead(calories) over w as lead,
            sum(COALESCE(calories, 0)) over w as sums
        from carrying
        window w as (order by id)),
-- use only sums where offseted calories have a gap
rolling_sum_totals as
        (select
            iif(lead is null, sums, null) as some
        from with_rolling_sum where some != 0),
-- unroll sums by substracting previous values
totals as
      (select
        some - coalesce(lag(some) over (order by some), 0) as totals
       from rolling_sum_totals)
-- finaly we can find maximum sum
select max(totals) from totals;
