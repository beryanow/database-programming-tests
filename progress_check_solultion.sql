SELECT
    film.film_id
FROM
    film
WHERE
    title = 'Alien Center'
_______________________________________________________________________________________________________________________________________

SELECT
    customer.address_id
FROM
    rental, customer
WHERE
    rental.customer_id = customer.customer_id
GROUP BY 
    customer.address_id
HAVING 
    COUNT(rental.customer_id) > 40
_______________________________________________________________________________________________________________________________________

SELECT
    film.title
FROM 
    (SELECT
        selected_films.selected_film_id as final_film_id
     FROM 
        (SELECT 
            film.film_id as selected_film_id
        FROM 
            film, film_category, (SELECT 
                                     film_category.category_id as needed_category
                                  FROM 
                                     film_category
                                  GROUP BY 
                                     film_category.category_id
                                  HAVING 
                                     COUNT(film_category.film_id) > 70) as categories
        WHERE 
            film.film_id = film_category.film_id AND categories.needed_category = film_category.category_id) as selected_films, rental
        INTERSECT
        SELECT
            film.film_id
        FROM
            film, inventory, (SELECT
                                 rental.inventory_id as needed_inventory
                              FROM
                                 rental
                              GROUP BY
                                 rental.inventory_id
                              HAVING
                                 COUNT(rental.rental_id) > 2) as inventories
        WHERE
            inventories.needed_inventory = inventory.inventory_id AND inventory.film_id = film.film_id) as final_films, film
WHERE
    film.film_id = final_films.final_film_id
_______________________________________________________________________________________________________________________________________

SELECT
	film_mapped_group.category_group AS cat_group,
	SUM(amount) AS total_sum
FROM
	(SELECT 
        film_id, mapped_categories.category_group
	FROM film_category, (SELECT
				            category_id, CASE
					                        WHEN 
                                                 COUNT(film_category.category_id) <= 50 THEN 'Group 1'
					                        WHEN 
                                                 COUNT(film_category.category_id) > 50 AND 
                                                 COUNT(film_category.category_id) <= 60 THEN 'Group 2' 
					                        ELSE 
                                                 'Group 3'
				                         END AS category_group
				         FROM 
					        film_category
				         GROUP BY 
                            category_id) as mapped_categories
		                 WHERE 
                            mapped_categories.category_id = film_category.category_id) as film_mapped_group
	JOIN
	(inventory 
        JOIN 
            rental 
        ON 
            inventory.inventory_id = rental.inventory_id 
        JOIN 
            payment 
        ON 
            rental.rental_id = payment.rental_id) as paid_films
	ON 
        paid_films.film_id = film_mapped_group.film_id
WHERE 
    rental_date <= '2005-07-07' AND rental_date >= '2005-06-07'
GROUP BY 
    film_mapped_group.category_group
_______________________________________________________________________________________________________________________________________

SELECT
	customer_group AS film_group,
    SUM(paid) AS total_amount,
    COUNT(rid) AS rental_count
FROM
	(SELECT
	    film_id AS fid,
	    rental.rental_id AS rid,
	    amount AS paid
	FROM
		payment 
	RIGHT JOIN
        rental 
	ON 
        payment.rental_id = rental.rental_id 
	JOIN 
        inventory 
	ON 
        rental.inventory_id = inventory.inventory_id) paid_films
	JOIN
	(SELECT 
		rented_films.film_id, CASE
			                     WHEN 
                                    AVG(DATE_PART('day', rented_films.return_date - rented_films.rental_date)) < 3 THEN 'I'
			                     WHEN 
                                    AVG(DATE_PART('day', rented_films.return_date - rented_films.rental_date)) >= 3 AND 
                                    AVG(DATE_PART('day', rented_films.return_date - rented_films.rental_date)) < 7 THEN 'II' 
			                     ELSE 
                                    'III'
		                      END AS customer_group
	FROM 
		(rental 
        JOIN 
            inventory 
		ON 
            rental.inventory_id = inventory.inventory_id) rented_films
	GROUP BY
        rented_films.film_id) film_groups
	ON 
        film_groups.film_id = paid_films.fid
GROUP BY 
    film_groups.customer_group;
_______________________________________________________________________________________________________________________________________

SELECT 
    film_category.category_id,
    COUNT(film_category.film_id) as film_cnt
FROM 
    film_category
GROUP BY 
    film_category.category_id
_______________________________________________________________________________________________________________________________________

SELECT
    customer.customer_id,
    COUNT(rental.customer_id) as total_count
FROM
    customer, rental
WHERE
    customer.customer_id = rental.customer_id
GROUP BY
    customer.customer_id
ORDER BY
    total_count
LIMIT 6
_______________________________________________________________________________________________________________________________________

SELECT 
    COUNT (DISTINCT needed_customers.rental_customer) as customer_cnt
FROM 
    (SELECT 
        rental.rental_id, rental.customer_id as rental_customer
    FROM
        rental
    EXCEPT
    SELECT 
        rental.rental_id, rental.customer_id as rental_customer
    FROM
        rental, payment
WHERE 
    rental.rental_id = payment.rental_id) as needed_customers