CREATE OR REPLACE TABLE `proceso-de-datos-454919.tarea1.keywords` AS
SELECT
  ROW_NUMBER() OVER () AS id_keyword,
  palabra
FROM (
  SELECT DISTINCT palabra
  FROM `proceso-de-datos-454919.tarea1.dataframe`,
       UNNEST(
         SPLIT(
           REPLACE(REPLACE(REPLACE(keywords, "[", ""), "]", ""), "'", ""),
           ", "
         )
       ) AS palabra
);


Consulta 1

WITH conteo_palabras AS (
  SELECT 
    DATE_TRUNC(intervenciones.fecha, MONTH) AS mes,
    keywords.palabra,
    COUNT(*) AS conteo
  FROM 
    `proceso-de-datos-454919.tarea1.intervenciones` AS intervenciones
  JOIN 
    `proceso-de-datos-454919.tarea1.intervenciones_keywords` AS intervenciones_keywords 
    ON intervenciones.id = intervenciones_keywords.intervencion_id
  JOIN 
    `proceso-de-datos-454919.tarea1.keywords` AS keywords 
    ON intervenciones_keywords.keyword_id = keywords.id_keyword
  GROUP BY 
    mes, keywords.palabra
),
ranking_palabras AS (
  SELECT 
    mes,
    palabra,
    conteo,
    ROW_NUMBER() OVER (PARTITION BY mes ORDER BY conteo DESC) AS rank
  FROM 
    conteo_palabras
)
SELECT 
  mes,
  palabra,
  conteo
FROM 
  ranking_palabras
WHERE 
  rank <= 5
ORDER BY 
  mes, rank;
