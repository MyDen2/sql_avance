import psycopg
import os
#DSN = os.getenv("DSN")


DSN = "dbname=supershop user=admin password=admin host=db port=5432"

def write_report():
    with open("rapport/report.txt", "w") as f:
        f.write(f"1. Chiffre d affaires total : {trouver_ca_total()} \n")
        f.write(f"2. Panier moyen : {trouver_panier_moyen()} \n")
        f.write(f"3. Article le plus commandé (en quantité totale) : {trouver_article_le_plus_commande()} \n")
        f.write(f"4. Top 3 clients par montant dépensé : {trouver_top_trois_clients()} \n")
        f.write(f"5. Chiffre d affaires par catégorie : \n {trouver_ca_par_categorie()} \n")


def trouver_ca_total():
    try:
        with psycopg.connect(DSN) as conn:
            with conn.cursor() as cur:
                cur.execute("""
                   SELECT SUM(quantity*unit_price)
                    FROM order_items oi;
                """
                )
                ca = cur.fetchone() # Si aucun resultat correspondant, alors nous recevons NULL

                if ca:
                    return round(ca[0], 3)
                else:
                    return "Erreur"
    except Exception as e:
        print ("Erreur à la recherche du ca total : ", e)

def trouver_panier_moyen():
    try:
        with psycopg.connect(DSN) as conn:
            with conn.cursor() as cur:
                cur.execute("""
                   SELECT AVG(quantity * unit_price)
                    FROM order_items oi;
                """
                )
                panier = cur.fetchone() # Si aucun resultat correspondant, alors nous recevons NULL

                if panier:
                    return round(panier[0], 3)
                else:
                    return "Erreur"
    except Exception as e:
        print ("Erreur à la recherche du panier moyen : ", e)

def trouver_article_le_plus_commande():
    try:
        with psycopg.connect(DSN) as conn:
            with conn.cursor() as cur:
                cur.execute("""
                   SELECT oi.id_product, p.product_name, SUM(quantity), COUNT(oi.id_product) 
                    FROM order_items oi INNER JOIN products p ON p.id_product = oi.id_product
                    GROUP BY oi.id_product, p.product_name
                    ORDER BY SUM(quantity) DESC 
                    LIMIT 1;
                """
                )
                article = cur.fetchone() # Si aucun resultat correspondant, alors nous recevons NULL

                if article:
                    return article[1] + " : " + str(article[2]) + " fois"
                else:
                    return "Erreur"
    except Exception as e:
        print ("Erreur à la recherche de l'article le plus commandé : ", e)

def trouver_top_trois_clients():
    try:
        with psycopg.connect(DSN) as conn:
            with conn.cursor() as cur:
                cur.execute("""
                   SELECT c.first_name, c.last_name, SUM(quantity * unit_price)
                    FROM order_items oi INNER JOIN orders o ON o.id_order = oi.id_order
                    INNER JOIN customers c ON c.id_customer = o.id_customer
                    GROUP BY c.first_name, c.last_name
                    ORDER BY SUM(quantity * unit_price) DESC 
                    LIMIT 3;
                """
                )
                top = cur.fetchall() # Si aucun resultat correspondant, alors nous recevons NULL
                if top:
                    return ("\n") + top[0][0] + " " + top[0][1] + ("\n") + top[1][0] + " " + top[1][1] + ("\n") + top[2][0] + " " + top[2][1]
                else:
                    return "Erreur"
    except Exception as e:
        print ("Erreur à la recherche du top trois clients : ", e)

def trouver_ca_par_categorie():
    try:
        with psycopg.connect(DSN) as conn:
            with conn.cursor() as cur:
                cur.execute("""
                   SELECT c.category_name, SUM(quantity * unit_price)
                    FROM order_items oi INNER JOIN products p ON p.id_product = oi.id_product
                    INNER JOIN categories c ON c.id_category = p.id_category
                    GROUP BY c.category_name;
                """
                )
                ca = cur.fetchall() # Si aucun resultat correspondant, alors nous recevons NULL
                if ca:
                    res = ""
                    for c in ca: 
                        res += c[0] + " : " + str(c[1])+ " \n "
                    return res
                else:
                    return "Erreur"
    except Exception as e:
        print ("Erreur à la recherche du ca apr categorie : ", e)

write_report()