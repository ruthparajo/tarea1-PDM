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

Consulta 2

WITH intervenciones_mes AS (
  SELECT 
    p.nombre_partido AS partido_politico,
    DATE_TRUNC(i.FECHA, MONTH) AS mes,
    COUNT(i.ID) AS total_intervenciones
  FROM `proceso-de-datos-454919.tarea1.intervenciones` i
  JOIN `proceso-de-datos-454919.tarea1.parlamentarios` pa ON i.PARLAMENTARIO_ID = pa.id_parlamentario
  JOIN `proceso-de-datos-454919.tarea1.partidos` p ON pa.PARTIDO_ID = p.id_partido
  GROUP BY p.nombre_partido, mes
)
SELECT 
  partido_politico,
  mes,
  AVG(total_intervenciones) OVER (
    PARTITION BY partido_politico
    ORDER BY mes
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS media_movil_intervenciones
FROM intervenciones_mes
ORDER BY mes;


Constulta 4

WITH temas_trimestre AS (
  SELECT 
    p.nombre_partido AS partido_politico,
    DATE_TRUNC(i.FECHA, QUARTER) AS trimestre,
    k.palabra AS tema,
    COUNT(k.id_keyword) AS frecuencia
  FROM `proceso-de-datos-454919.tarea1.intervenciones` i
  JOIN `proceso-de-datos-454919.tarea1.parlamentarios` pa ON i.PARLAMENTARIO_ID = pa.id_parlamentario
  JOIN `proceso-de-datos-454919.tarea1.partidos` p ON pa.PARTIDO_ID = p.id_partido
  JOIN `proceso-de-datos-454919.tarea1.intervenciones_keywords` ik ON i.ID = ik.intervencion_id
  JOIN `proceso-de-datos-454919.tarea1.keywords` k ON ik.keyword_id = k.id_keyword
  GROUP BY p.nombre_partido, trimestre, k.palabra
)
SELECT 
  partido_politico,
  trimestre,
  tema AS tema_principal
FROM temas_trimestre t1
WHERE frecuencia = (
  SELECT MAX(t2.frecuencia)
  FROM temas_trimestre t2
  WHERE t2.partido_politico = t1.partido_politico
    AND t2.trimestre = t1.trimestre
)
ORDER BY trimestre, partido_politico;


consulta 4
para enero de 2023

WITH temas_por_mes AS (
  SELECT 
    p.nombre_partido AS partido_politico,
    DATE_TRUNC(i.FECHA, MONTH) AS mes,
    k.palabra AS tema,
    COUNT(k.id_keyword) AS frecuencia
  FROM `proceso-de-datos-454919.tarea1.intervenciones` i
  JOIN `proceso-de-datos-454919.tarea1.parlamentarios` pa ON i.PARLAMENTARIO_ID = pa.id_parlamentario
  JOIN `proceso-de-datos-454919.tarea1.partidos` p ON pa.PARTIDO_ID = p.id_partido
  JOIN `proceso-de-datos-454919.tarea1.intervenciones_keywords` ik ON i.ID = ik.intervencion_id
  JOIN `proceso-de-datos-454919.tarea1.keywords` k ON ik.keyword_id = k.id_keyword
  WHERE DATE_TRUNC(i.FECHA, MONTH) = '2023-01-01'
  GROUP BY partido_politico, mes, tema
),
ranking_temas AS (
  SELECT 
    partido_politico,
    mes,
    tema,
    frecuencia,
    RANK() OVER (
      PARTITION BY partido_politico, mes 
      ORDER BY frecuencia DESC
    ) AS rank_tema
  FROM temas_por_mes
)
SELECT 
  partido_politico,
  tema AS tema_principal,
  frecuencia
FROM ranking_temas
WHERE rank_tema <= 3
ORDER BY partido_politico, rank_tema;
