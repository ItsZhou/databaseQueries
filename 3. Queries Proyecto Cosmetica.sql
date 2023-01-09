USE Cosmetica_v1;
 
--
-- 1. Quiero un listado de todos los usuarios cuyo nombre tenga la letra 'a', su fecha de nacimiento sea a partir del año 1990 y el correo contenga 'gmail.'
--
SELECT *
FROM USUARIOS
WHERE( nomusuario LIKE "%a%" AND YEAR(fecnacimiento) >= "1990" )
AND( email LIKE "%gmail.%" );
--
-- 2. Quiero saber cuantos pedidos ha habido por año. 
--
SELECT YEAR(fecpedido) AS `Año de pedido`, COUNT(idpedido) AS `Numero de pedidos`
FROM PEDIDOSONLINE
GROUP BY YEAR(fecpedido);
--
-- 3. Quiero saber cual es el producto mas caro de cada Subcategoriatipo ordenado por precio de menor a mayor.
--
SELECT nomsubcategoriatipo AS Subcategoriatipo, nomproducto AS Producto, MAX(precio) AS Precio
FROM SUBCATEGORIATIPOS
INNER JOIN PRODUCTOS
ON SUBCATEGORIATIPOS.idsubcategoriatipo = PRODUCTOS.idsubcategoriatipo
GROUP BY nomsubcategoriatipo
ORDER BY precio ASC;
--
-- 4. Quiero un listado de los pedidos en los que no se ha utilizado codigopromocional y quiero saber qué han pedido.
--
SELECT *
FROM PEDIDOSONLINE 
LEFT JOIN CODIGOSPROMOCIONALESPORPEDIDO
ON PEDIDOSONLINE.idpedido = CODIGOSPROMOCIONALESPORPEDIDO.idpedido
INNER JOIN ARTICULOSPEDIDOSONLINE
ON PEDIDOSONLINE.idpedido = ARTICULOSPEDIDOSONLINE.idpedido
WHERE CODIGOSPROMOCIONALESPORPEDIDO.idpedido IS NULL;
--
-- 5. Quiero saber cuantos productos tengo de cada marca.
--
SELECT nommarca, COUNT(T1.idproducto) AS Cantidad
FROM PRODUCTOS AS T1
INNER JOIN MARCAS 
ON T1.idmarca = MARCAS.idmarca
LEFT JOIN ARTICULOS
ON T1.idproducto = ARTICULOS.idproducto
GROUP BY nommarca;
--
-- 6. Quiero saber las calificaciones de los articulos que se han pedido, si la puntuacion es menos de 5, entonces calificacion mala, si es entre 5 y 7, entonces calificacion buena
-- y a partir de 7 calificacacion muy buena. Ordenado por puntuacion de menor a mayor
--
SELECT idarticulo,
        CASE
        WHEN calificacion < 5 THEN "Calificacion mala"
        WHEN calificacion BETWEEN 5 AND 7 THEN "Calificacion buena"
        ELSE "Calificacion muy buena"
        END AS Calificaciones
FROM CALIFICACIONES 
ORDER BY calificacion ASC;
--
-- 7. Quiero saber cual es el producto mas caro y mas barato que hay.
--
SELECT MAX(precio)
FROM PRODUCTOS;

SELECT MIN(precio)
FROM PRODUCTOS;

SELECT *
FROM PRODUCTOS
WHERE precio IN (   
                    SELECT MAX(precio)
                    FROM PRODUCTOS
                    UNION
                    SELECT MIN(precio)
                    FROM PRODUCTOS
                );
--
-- 8. Muestra los tres productos mas caros
--
WITH T1 AS (
            SELECT nomproducto, precio
            FROM PRODUCTOS
            WHERE precio <> (
                                SELECT MAX(precio)
                                FROM PRODUCTOS
                            )
), T2 AS (
            SELECT nomproducto, precio
            FROM T1
            WHERE precio <> (
                                SELECT MAX(precio)
                                FROM T1
                            )
         )
SELECT nomproducto, precio
FROM PRODUCTOS
WHERE precio >= (
                SELECT MAX(precio)
                FROM T2
               )
ORDER BY precio;
--
-- 9. Quiero saber de cada producto su precio y la diferencia respecto al producto mas caro dentro de su Subcategoriatipo.
--
SELECT nomsubcategoriatipo, nomproducto, precio,
        (
            SELECT MAX(precio)
            FROM PRODUCTOS
        ) AS maxPrecio,
        (
            SELECT MAX(precio)
            FROM PRODUCTOS
        ) - precio AS Diferencia
FROM PRODUCTOS
INNER JOIN SUBCATEGORIATIPOS
ON PRODUCTOS.idsubcategoriatipo = SUBCATEGORIATIPOS.idsubcategoriatipo
ORDER BY diferencia ASC;
--
-- 10. Quiero saber el usuario que ha hecho el pedido mas caro cada año.
--
SELECT YEAR(fecpedido) AS Año, nomusuario, preciopedido
FROM PEDIDOSONLINE AS T1
INNER JOIN ARTICULOSPEDIDOSONLINE
ON T1.idpedido = ARTICULOSPEDIDOSONLINE.idpedido
INNER JOIN USUARIOS
ON T1.idusuario = USUARIOS.idusuario
WHERE preciopedido = (
                        SELECT MAX(preciopedido)
                        FROM PEDIDOSONLINE AS T2
                        WHERE YEAR(T2.fecpedido) = YEAR(T1.fecpedido)
                        GROUP BY YEAR(T2.fecpedido)
                     );

--
-- 11. Quiero saber en que pedidos se compra mas de un articulo de la misma marca.
-- y de que marca, y...que usuario
-- idarticulo    idpedido       precio    idmarca
     1              28           3,99        A
     2              28           5,99        B
     3              28           2,99        C

-- Asi aparecen todos los pedidos y los que tienen mas de un articulo de la misma marca.
--
SELECT T2.idproducto, T1.idarticulo, idpedido, precio, idmarca
FROM ARTICULOSPEDIDOSONLINE AS T1
INNER JOIN ARTICULOS AS T2
ON T1.idarticulo = T2.idarticulo
INNER JOIN PRODUCTOS 
ON T2.idproducto = PRODUCTOS.idproducto;

-- 11.1. Y de que marca, y que usuario.
--
SELECT T2.idproducto, T1.idarticulo, T1.idpedido, precio, PRODUCTOS.idmarca, nommarca, T3.idusuario, nomusuario
FROM ARTICULOSPEDIDOSONLINE AS T1
INNER JOIN ARTICULOS AS T2
ON T1.idarticulo = T2.idarticulo
INNER JOIN PRODUCTOS 
ON T2.idproducto = PRODUCTOS.idproducto
INNER JOIN MARCAS 
ON PRODUCTOS.idmarca = MARCAS.idmarca
INNER JOIN PEDIDOSONLINE AS T3
ON T1.idpedido = T3.idpedido
LEFT JOIN USUARIOS
ON T3.idusuario = USUARIOS.idusuario;

-- Asi aparecen solo los pedidos que tienen mas de un articulo de la misma marca.
--
SELECT T2.idproducto, T1.idarticulo, idpedido, precio, idmarca, COUNT(*) AS numArticulos
FROM ARTICULOSPEDIDOSONLINE AS T1
INNER JOIN ARTICULOS AS T2
ON T1.idarticulo = T2.idarticulo
INNER JOIN PRODUCTOS 
ON T2.idproducto = PRODUCTOS.idproducto
GROUP BY idpedido
HAVING numArticulos > 1;

-- Y de que marca, y que usuario.
--
SELECT T2.idproducto, T1.idarticulo, T1.idpedido, precio, PRODUCTOS.idmarca, nommarca, T3.idusuario, nomusuario, COUNT(*) AS numArticulos
FROM ARTICULOSPEDIDOSONLINE AS T1
INNER JOIN ARTICULOS AS T2
ON T1.idarticulo = T2.idarticulo
INNER JOIN PRODUCTOS 
ON T2.idproducto = PRODUCTOS.idproducto
INNER JOIN MARCAS 
ON PRODUCTOS.idmarca = MARCAS.idmarca
INNER JOIN PEDIDOSONLINE AS T3
ON T1.idpedido = T3.idpedido
LEFT JOIN USUARIOS
ON T3.idusuario = USUARIOS.idusuario
GROUP BY idpedido
HAVING numArticulos > 1;

--
-- 12. Quiero saber que usuarios han comprado la misma marca en dos meses consecutivos
-- y que marca y la diferencia de dias
--
WITH TablaA AS (

    SELECT T1.idusuario, nomusuario, idmarca, MONTH(fecpedido) AS mesPedido, COUNT(*) AS numArticulos
    FROM USUARIOS
    INNER JOIN PEDIDOSONLINE AS T1
    ON USUARIOS.idusuario = T1.idusuario
    INNER JOIN ARTICULOSPEDIDOSONLINE AS T2
    ON T1.idpedido = T2.idpedido
    INNER JOIN ARTICULOS
    ON T2.idarticulo = ARTICULOS.idarticulo
    INNER JOIN PRODUCTOS
    ON ARTICULOS.idproducto = PRODUCTOS.idproducto
    GROUP BY T1.idusuario, idmarca, MONTH( fecpedido )
    )

SELECT *
FROM TablaA AS T1
INNER JOIN TablaA AS T2
ON T1.idusuario = T2.idusuario
AND T1.idmarca = T2.idmarca
AND T1.mesPedido < T2.mesPedido;

--
-- 13. Quiero saber que clientes no han comprado el producto mas vendido.
-- Primero cual es el producto mas vendido
-- Despues sacar los clientes no han comprado
--
