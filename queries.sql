select count(customer_id) as customers_count 
from customers
--С помощью агрегатной финкции count мы считаем общее количество покупателей по столбцу customer_id и называем колонку customers_count 
--далее мы пишем из какой таблице взять данные