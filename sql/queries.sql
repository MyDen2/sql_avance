--- # 5️⃣ Partie 3 – Requêtes SQL de base -- 

--- 1. Lister tous les clients triés par date de création de compte (plus anciens → plus récents). ---

SELECT * FROM customers ORDER BY created_at ASC;

--- 2. Lister tous les produits (nom + prix) triés par prix décroissant. ---

SELECT product_name, price FROM products ORDER BY price DESC;

--- 3. Lister les commandes passées entre deux dates (par exemple entre le 1er et le 15 mars 2024). ---

SELECT * FROM orders WHERE order_date BETWEEN '2024-03-01 00:00' AND '2024-03-15 23:59' ;

--- 4. Lister les produits dont le prix est strictement supérieur à 50 €. --- 

SELECT * FROM products WHERE price > 50; 

--- 5. Lister tous les produits d’une catégorie donnée (par exemple “Électronique”). ---

SELECT * FROM products WHERE id_category IN (SELECT id_category FROM categories WHERE category_name = 'Électronique');

--- # 6️⃣ Partie 4 – Jointures simples --- 

--- 1. Lister tous les produits avec le nom de leur catégorie. --- 

SELECT p.*, c.category_name FROM products p INNER JOIN categories c ON p.id_category = c.id_category;  

--- 2. Lister toutes les commandes avec le nom complet du client (prénom + nom). ---

SELECT o.*, c.first_name, c.last_name FROM orders o INNER JOIN customers c ON c.id_customer = o.id_customer; 

--- 3. Lister toutes les lignes de commande avec :

---   * le nom du client,
---   * le nom du produit,
---   * la quantité,
---   * le prix unitaire facturé. 

SELECT c.first_name, c.last_name, p.product_name, oi.quantity, oi.unit_price FROM order_items oi 
INNER JOIN products p ON oi.id_product = p.id_product 
INNER JOIN orders o ON oi.id_order = o.id_order
INNER JOIN customers c ON c.id_customer = o.id_customer; 

--- 4. Lister toutes les commandes dont le statut est `PAID` ou `SHIPPED`. ---

SELECT * FROM orders WHERE order_status IN ('PAID', 'SHIPPED');


--- # 7️⃣ Partie 5 – Jointures avancées --- 

-- 1. Afficher le détail complet de chaque commande avec :

--    * date de commande,
--    * nom du client,
--    * liste des produits,
--    * quantité,
--    * prix unitaire facturé,
--    * montant total de la ligne (quantité × prix unitaire).

--- SELECT o.order_date, c.last_name, oi.


-- 2. Calculer le **montant total de chaque commande** et afficher uniquement :

--    * l’ID de la commande,
--    * le nom du client,
--    * le montant total de la commande.

SELECT oi.id_order, c.last_name, SUM(unit_price) FROM order_items oi 
INNER JOIN orders o ON o.id_order = oi.id_order
INNER JOIN customers c ON c.id_customer = o.id_customer
GROUP BY oi.id_order, c.last_name;

--- 3. Afficher les commandes dont le montant total **dépasse 100 €**. ---

SELECT id_order, SUM(unit_price*quantity) FROM order_items 
GROUP BY id_order
HAVING SUM(unit_price*quantity) > 100;

--- 4. Lister les catégories avec leur **chiffre d’affaires total** 
--- (somme du montant des lignes sur tous les produits de cette catégorie). ---

SELECT c.category_name , SUM(unit_price*quantity) FROM order_items oi
INNER JOIN products p ON p.id_product = oi.id_product
INNER JOIN categories c ON c.id_category = p.id_category
GROUP BY c.category_name;

--- # 8️⃣ Partie 6 – Sous-requêtes ---

--- 1. Lister les produits qui ont été vendus **au moins une fois**. ---
SELECT DISTINCT oi.id_product, p.product_name FROM order_items oi
INNER JOIN products p ON p.id_product = oi.id_product;

--- 2. Lister les produits qui **n’ont jamais été vendus**. --- 
SELECT id_product, product_name FROM products 
WHERE id_product NOT IN (SELECT DISTINCT oi.id_product FROM order_items oi);

--- 3. Trouver le client qui a **dépensé le plus** (TOP 1 en chiffre d’affaires cumulé). ---

SELECT c.first_name, c.last_name, SUM(quantity*unit_price) 
FROM order_items INNER JOIN orders ON orders.id_order = order_items.id_order
INNER JOIN customers c ON c.id_customer = orders.id_customer 
GROUP BY c.first_name, c.last_name
ORDER BY SUM(quantity*unit_price) DESC 
LIMIT 1;

--- 4. Afficher les **3 produits les plus vendus** en termes de quantité totale. ---
-- à vérifier
SELECT oi.id_product, p.product_name, SUM(quantity), COUNT(oi.id_product) 
FROM order_items oi INNER JOIN products p ON p.id_product = oi.id_product
GROUP BY oi.id_product, p.product_name
ORDER BY SUM(quantity) DESC 
LIMIT 3;

--- 5. Lister les commandes dont le montant total 
--- est **strictement supérieur à la moyenne** de toutes les commandes.



