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


---# 9️⃣ Partie 7 – Statistiques & agrégats 

--- 1. Calculer le **chiffre d’affaires total** (toutes commandes confondues, 
--- hors commandes annulées si souhaité).

SELECT SUM(quantity * unit_price) 
FROM order_items oi
INNER JOIN (SELECT * FROM orders WHERE order_status <> 'CANCELLED') t ON t.id_order = oi.id_order;

--- 2. Calculer le **panier moyen** (montant moyen par commande). --- 

SELECT AVG(quantity * unit_price)
FROM order_items oi;

--- 3. Calculer la **quantité totale vendue par catégorie**. --- 
SELECT c.category_name, SUM(quantity)
FROM order_items oi INNER JOIN products p ON p.id_product = oi.id_product
INNER JOIN categories c ON c.id_category = p.id_category
GROUP BY c.category_name;

--- 4. Calculer le **chiffre d’affaires par mois** (au moins sur les données fournies).

SELECT DATE_PART('month', order_date), SUM(quantity * unit_price) 
FROM order_items oi INNER JOIN orders o 
ON o.id_order = oi.id_order
GROUP BY DATE_PART('month', order_date); 

--- 5. Formater les montants pour n’afficher que **deux décimales**.
SELECT round((SELECT AVG(quantity * unit_price)
FROM order_items oi),2);
 

--- # 🔟 Partie 8 – Logique conditionnelle (CASE)

-- 1. Pour chaque commande, afficher :

--    * l’ID de la commande,
--    * le client,
--    * la date,
--    * le statut,
--    * une version “lisible” du statut en français via `CASE` :

--      * `PAID` → “Payée”
--      * `SHIPPED` → “Expédiée”
--      * `PENDING` → “En attente”
--      * `CANCELLED` → “Annulée”

SELECT o.id_order, c.first_name, c.last_name, o.order_date,
CASE
      WHEN o.order_status = 'PAID' THEN 'Payée'
      WHEN o.order_status = 'SHIPPED' THEN 'Expédiée'
      WHEN o.order_status = 'PENDING' THEN 'En attente'
      ELSE 'Annulée'
    END
FROM orders o INNER JOIN customers c ON c.id_customer = o.id_customer;

--- 2. Pour chaque client, calculer le **montant total dépensé** et le classer en segments :

--    * `< 100 €`  → “Bronze”
--    * `100–300 €` → “Argent”
--    * `> 300 €`  → “Or”

--    Afficher : prénom, nom, montant total, segment.

SELECT c.first_name, c.last_name, SUM(quantity * unit_price),
CASE 
     WHEN SUM(quantity * unit_price) < 100 THEN 'BRONZE'
     WHEN SUM(quantity * unit_price) > 300 THEN 'OR'
     ELSE 'ARGENT'
    END
FROM order_items oi INNER JOIN orders o ON oi.id_order = o.id_order 
INNER JOIN customers c ON c.id_customer = o.id_customer
GROUP BY c.first_name, c.last_name; 


--- # 1️⃣1️⃣ Partie 9 – Challenge final

--- 1. Top 5 des clients les plus actifs (nombre de commandes).

SELECT c.first_name, c.last_name, COUNT(o.id_customer)
FROM orders o INNER JOIN customers c ON c.id_customer = o.id_customer
GROUP BY c.first_name, c.last_name
ORDER BY COUNT(o.id_customer) DESC 
LIMIT 5;

--- 2. Top 5 des clients qui ont dépensé le plus (CA total).

SELECT c.first_name, c.last_name, SUM(quantity * unit_price)
FROM order_items oi INNER JOIN orders o ON o.id_order = oi.id_order
INNER JOIN customers c ON c.id_customer = o.id_customer
GROUP BY c.first_name, c.last_name
ORDER BY SUM(quantity * unit_price) DESC 
LIMIT 5;

--- 3. Les 3 catégories les plus rentables (CA total).

SELECT c.category_name, SUM(quantity * unit_price)
FROM order_items oi INNER JOIN products p ON p.id_product = oi.id_product
INNER JOIN categories c ON c.id_category = p.id_category
GROUP BY c.category_name
ORDER BY SUM(quantity * unit_price) DESC 
LIMIT 3;


--- 4. Les produits qui ont généré au total **moins de 10 €** de CA.

SELECT p.product_name, SUM(quantity * unit_price)
FROM order_items oi INNER JOIN products p ON p.id_product = oi.id_product
GROUP BY p.product_name
HAVING SUM(quantity * unit_price) < 10; 

--- 5. Les clients n’ayant passé **qu’une seule commande**.

SELECT c.first_name, c.last_name, COUNT(o.id_customer)
FROM orders o INNER JOIN customers c ON c.id_customer = o.id_customer
GROUP BY c.first_name, c.last_name
HAVING COUNT(o.id_customer) = 1; 

--- 6. Les produits présents dans des commandes **annulées**, avec le montant “perdu”.
SELECT p.product_name, SUM(quantity * unit_price)
FROM order_items oi INNER JOIN orders o ON o.id_order = oi.id_order
INNER JOIN products p ON p.id_product = oi.id_product
WHERE o.order_status = 'CANCELLED'
GROUP BY p.product_name;


