--Данный запрос считает общее количество покупателей из таблицы customers

select count(customer_id) as customers_count 
from customers;

--Данный запрос выводит имя и фамилию продавца, суммарную выручку с проданных товаров и количество проведенных сделок
--Отсортирован по убыванию выручки

select concat(e.first_name,' ',e.last_name) as seller, 
count(s.sales_id) as operations, floor(sum(p.price * s.quantity)) as income
from sales s 
inner join employees e 
on s.sales_person_id = e.employee_id
inner join products p 
on s.product_id = p.product_id
group by seller
order by income desc 
limit 10;

--Данный запрос выводит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
--Отсортирован по возрастанию выручке

select concat(e.first_name,' ',e.last_name) as seller, 
floor(avg(p.price * s.quantity)) as average_income
from sales s 
inner join employees e 
on s.sales_person_id = e.employee_id
inner join products p 
on s.product_id = p.product_id
group by seller
having floor(avg(p.price * s.quantity)) < (select avg(average_income) from 
(select concat(e.first_name,' ',e.last_name) as seller, 
floor(avg(p.price * s.quantity)) as average_income
from sales s 
inner join employees e 
on s.sales_person_id = e.employee_id
inner join products p 
on s.product_id = p.product_id
group by seller) as avg_income_sales)
order by average_income;

--Данный запрос выводит имя и фамилию продавца, день недели и суммарную выручку
--Отсортирован по порядковому номеру дня недели и seller

with tab as (
  select 
		concat(first_name,' ',last_name) as seller, 
		to_char(sale_date, 'day') as day_of_week, 
		extract(isodow from sale_date) as dow,
		sum(price * quantity) as income
	from sales s 
	inner join employees e 
	on s.sales_person_id = e.employee_id
	inner join products p 
	on s.product_id = p.product_id
	group by seller, day_of_week, dow)
select seller, day_of_week, floor(income)
from tab
order by dow, seller;
