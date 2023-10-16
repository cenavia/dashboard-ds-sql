/*Top 10 de perliculas para Dashaboard*/
SELECT 
	peliculas.pelicula_id AS id,
	peliculas.titulo,
	COUNT(*) AS numero_rentas,
	ROW_NUMBER () OVER (
		ORDER BY COUNT(*) DESC
	) AS lugar
FROM rentas
	INNER JOIN inventarios ON rentas.inventario_id = inventarios.inventario_id
	INNER JOIN peliculas ON inventarios.pelicula_id = peliculas.pelicula_id
GROUP BY peliculas.pelicula_id
ORDER BY numero_rentas DESC
LIMIT 10;


/*Cambio de moneda*/

SELECT peliculas.pelicula_id,
        tipos_cambio.tipo_cambio_id,
        tipos_cambio.cambio_usd * perliculas.precio_renta as precio_mxn
FROM peliculas,
     tipos_cambio
WHERE tipos_cambio.codigo = 'MXN'

/* Trigger Cambio de moneda*/
CREATE OR REPLACE FUNCTION public.precio_peliculas_tipo_cambio()
	returns trigger
	LANGUAGE plpgsql
AS $$
	BEGIN
INSERT INTO precio_peliculas_tipo_cambio(
pelicula_id,
tipo_cambio_id,
precio_tipo_cambio,
ultima_actualizacion
)
select  NEW.pelicula_id,
	    tipos_cambio.tipo_cambio_id,
		tipos_cambio.cambio_usd * NEW.precio_renta AS precio_tipo_cambio,
		CURRENT_TIMESTAMP
FROM tipos_cambio
WHERE tipos_cambio.codigo = 'MXN';
RETURN NEW;
	END
$$
;

create trigger trigger_update_tipos_cambio after
insert
	or
update
	on
	public.peliculas for each row execute procedure public.precio_peliculas_tipo_cambio() ;


/*Forma 2*/

BEGIN
    INSERT INTO precio_peliculas_tipo_cambio(
      pelicula_id,
      tipo_cambio_id,
      precio_tipo_cambio,
      ultima_actualizacion
      )
      SELECT NEW.pelicula_id,
        tipos_cambio.tipo_cambio_id,
        tipos_cambio.cambio_usd * NEW.precio_renta AS precio_tipo_cambio,
        CURRENT_TIMESTAMP
      FROM tipos_cambio
      WHERE tipos_cambio = 'MXN';
      RETURN NEW;
END

CREATE TRIGGER trigger_update_tipos_cambio
	AFTER INSERT OR UPDATE
	ON public.peliculas
	FOR EACH ROW
	EXECUTE PROCEDURE public.precio_peliculas_tipo_cambio();


/* rank y percent rank */

SELECT 
	peliculas.pelicula_id AS id,
	peliculas.titulo,
	COUNT(*) AS numero_rentas,
	PERCENT_RANK() OVER (
		ORDER BY COUNT(*) DESC
	) AS lugar
FROM rentas
	INNER JOIN inventarios ON rentas.inventario_id = inventarios.inventario_id
	INNER JOIN peliculas ON inventarios.pelicula_id = peliculas.pelicula_id
GROUP BY peliculas.pelicula_id
ORDER BY numero_rentas DESC;


SELECT 
	peliculas.pelicula_id AS id,
	peliculas.titulo,
	COUNT(*) AS numero_rentas,
	PERCENT_RANK() OVER (
		ORDER BY COUNT(*) ASC
	) AS lugar
FROM rentas
	INNER JOIN inventarios ON rentas.inventario_id = inventarios.inventario_id
	INNER JOIN peliculas ON inventarios.pelicula_id = peliculas.pelicula_id
GROUP BY peliculas.pelicula_id
ORDER BY numero_rentas DESC;



SELECT 
	peliculas.pelicula_id AS id,
	peliculas.titulo,
	COUNT(*) AS numero_rentas,
	DENSE_RANK() OVER (
		ORDER BY COUNT(*) DESC
	) AS lugar
FROM rentas
	INNER JOIN inventarios ON rentas.inventario_id = inventarios.inventario_id
	INNER JOIN peliculas ON inventarios.pelicula_id = peliculas.pelicula_id
GROUP BY peliculas.pelicula_id
ORDER BY numero_rentas DESC;


/* ordenando los datos por ciudades */
SELECT ciudades.ciudad_id,
		ciudades.ciudad,
		COUNT (*) AS rentas_por_ciudad
FROM ciudades
	INNER JOIN direcciones ON ciudades.ciudad_id = direcciones.ciudad_id
	INNER JOIN tiendas ON tiendas.direccion_id = direcciones.direccion_id
	INNER JOIN inventarios ON inventarios.tienda_id = tiendas.tienda_id
	INNER JOIN rentas ON inventarios.inventario_id = rentas.inventario_id
GROUP BY ciudades.ciudad_id;


/* Linea de tiempo*/
SELECT date_part('year', rentas.fecha_renta) AS anio,
		date_part('month', rentas.fecha_renta) AS mes,
		peliculas.titulo,
		COUNT (*) AS numero_rentas
FROM rentas
	INNER JOIN inventarios ON rentas.inventario_id = inventarios.inventario_id
	INNER JOIN peliculas ON peliculas.pelicula_id = inventarios.pelicula_id
GROUP BY anio, mes, peliculas.pelicula_id;

SELECT date_part('year', rentas.fecha_renta) AS anio,
		date_part('month', rentas.fecha_renta) AS mes,
		COUNT (*) AS numero_rentas
FROM rentas
GROUP BY anio, mes;

SELECT date_part('year', rentas.fecha_renta) AS anio,
		date_part('month', rentas.fecha_renta) AS mes,
		COUNT (*) AS numero_rentas
FROM rentas
GROUP BY anio, mes
ORDER BY anio, mes;