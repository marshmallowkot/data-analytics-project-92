--Данный запрос считает общее количество покупателей из таблицы customers
select count(customer_id) as customers_count from customers;

--Данный запрос выводит имя и фамилию продавца, 
--суммарную выручку с проданных товаров и количество проведенных сделок
--Отсортирован по убыванию выручки

select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.sales_id) as operations,
    floor(sum(p.price * s.quantity)) as income
from sales as s
inner join employees as e on s.sales_person_id = e.employee_id
inner join products as p on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

--Данный запрос выводит информацию о продавцах, 
--чья средняя выручка за сделку меньше средней выручки 
--за сделку по всем продавцам
--Отсортирован по возрастанию выручке

select
    concat(e.first_name, ' ', e.last_name) as seller,
    floor(avg(p.price * s.quantity)) as average_income
from sales as s
inner join employees as e on s.sales_person_id = e.employee_id
inner join products as p on s.product_id = p.product_id
group by seller
having
    floor(
        avg(p.price * s.quantity)) < (
        select avg(average_income)
        from (
            select
                concat(e.first_name, ' ', e.last_name) as seller,
                floor(avg(p.price * s.quantity)) as average_income
            from sales as s
            inner join employees as e on s.sales_person_id = e.employee_id
            inner join products as p on s.product_id = p.product_id
            group by seller
        ) as avg_income_sales
    )
order by average_income;

--Данный запрос выводит имя и фамилию продавца, день недели и суммарную выручку
--Отсортирован по порядковому номеру дня недели и seller

with tab as (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
        to_char(s.sale_date, 'day') as day_of_week,
        extract(isodow from s.sale_date) as dow,
        sum(p.price * s.quantity) as income
    from sales as s
    inner join employees as e on s.sales_person_id = e.employee_id
    inner join products as p on s.product_id = p.product_id
    group by seller, day_of_week, dow
)
select seller, day_of_week, floor(income) as income
from tab
order by dow, seller;

--Данный запрос выводит количество покупателей в разных возрастных группах: 
--16-25, 26-40 и 40+
--Отсортирован по возрастным группам

with tab as (
    select (case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+' end) as age_category
    from customers
)
select age_category, count(age_category) as age_count
from tab
group by age_category
order by age_category;

--Данный запрос выводит количество уникальных покупателей и выручке
--Отсортирован по дате по возрастанию

with tab as (
    select
        to_char(s.sale_date, 'YYYY-MM') as date,
        s.customer_id,
        sum(s.quantity * p.price) as income
    from employees as e
    left join sales as s on e.employee_id = s.sales_person_id
    left join products as p on s.product_id = p.product_id
    where to_char(s.sale_date, 'YYYY-MM') is not null
    group by date, s.customer_id
)
select 
    distinct date as selling_month,
    count(customer_id) as total_customers,
    floor(sum(income)) as income
from tab
group by date
order by date;

--Данный запрос выводит таблицу с покупателями, первая покупка которых 
--пприходилась на время проведения акции
--Акционные товары отпускали со стоимостью равной 0
--Отсортирован по id покупателя

with tab as (
    select
        concat(c.first_name, ' ', c.last_name) as customer,
        min(s.sale_date) as sale_date,
        sum(p.price * s.quantity)
    from customers as c
    left join sales as s on c.customer_id = s.customer_id
    left join products as p on s.product_id = p.product_id
    group by customer
    having sum(p.price * s.quantity) = 0
), tab2 as (
    select 
        concat(c.first_name, ' ', c.last_name) as customer,
        min(s.sale_date) as sale_date,
        concat(e.first_name, ' ', e.last_name) as seller
    from sales as s
    left join customers as c on s.customer_id = c.customer_id
    left join employees as e on e.employee_id = s.sales_person_id
    group by customer, seller
)
select tab.customer, tab.sale_date, tab2.seller
from tab
inner join tab2
    on 
        tab.customer = tab2.customer
        and
        tab.sale_date = tab2.sale_date
group by tab.customer, tab.sale_date, tab2.seller
order by tab.customer;
