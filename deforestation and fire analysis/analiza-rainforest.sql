CREATE TABLE deforestation_area (
    year INT,
    ACRE INT,
    AMAZONAS INT,
    AMAPA INT,
    MARANHAO INT,
    MATO_GROSSO INT,
    PARA INT,
    RONDONIA INT,
    RORAIMA INT,
    TOCANTINS INT,
    AMZ_LEGAL INT
);


SELECT * FROM deforestation_area LIMIT 10;


CREATE TABLE fire_incidents (
    year INT,
    month INT,
    state VARCHAR(50),
    latitude DECIMAL(15, 10),
    longitude DECIMAL(15, 10),
    firespots INT
);

select * from fire_incidents limit 10;


CREATE TABLE climate_events (
    start_year INT,
    end_year INT,
    phenomenon VARCHAR(50),
    severity VARCHAR(50)
);


-- Zidentyfikowanie lat o najwyższym wylesieniu
-- Analiza trendu deforestacji - jak zmieniała się powierzchnia wylesienia w poszczególnych latach
SELECT da.year, da.amz_legal as total_deforested_area
FROM deforestation_area da
GROUP BY da.year, da.amz_legal
ORDER BY da.amz_legal desc;

--Identyfikacja czynników wpływających na wylesienie
---- Korelacja pomiędzy pożarami a deforestacją - czy liczba pożarów w danym roku wpływa na wylesienie
SELECT da.year, da.amz_legal AS total_deforested_area, 
       SUM(fi.firespots) AS total_firespots
FROM deforestation_area da
JOIN fire_incidents fi
ON da.year = fi.year
GROUP BY da.year, da.amz_legal
ORDER BY total_deforested_area desc;


---- Wpływ zjawisk klimatycznych na pożary i deforestację - czy El Niño i La Niña wpłynęły na wylesienie i liczbę pożarów:
SELECT ce.phenomenon, ce.severity, ce.start_year, ce.end_year, da.amz_legal AS total_deforested_area, 
       SUM(f.firespots) AS total_firespots
FROM climate_events ce
LEFT JOIN deforestation_area da
ON da.year BETWEEN ce.start_year AND ce.end_year
LEFT JOIN fire_incidents f
ON f.year BETWEEN ce.start_year AND ce.end_year
GROUP BY ce.phenomenon, ce.severity,  da.amz_legal , ce.start_year, ce.end_year
ORDER BY da.amz_legal desc;


-- Analiza, którym stanie jest najwięcej ognisk pożarów
select fi.state, max(fi.firespots)
from fire_incidents fi 
group by fi.state
order by max(fi.firespots) DESC;


-- Analiza w jakich miesiącach jest najwięcej pożarów
select fi.month , sum(fi.firespots)
from fire_incidents fi 
group by fi.month 
having sum(fi.firespots) > 10000
order by sum(fi.firespots) desc;



CREATE TABLE climate_analysis AS
SELECT 
    ce.phenomenon, 
    ce.severity, 
    ce.start_year, 
    ce.end_year, 
    SUM(da.amz_legal) AS total_deforested_area, 
    SUM(f.firespots) AS total_firespots
FROM 
    climate_events ce
LEFT JOIN 
    deforestation_area da ON da.year BETWEEN ce.start_year AND ce.end_year
LEFT JOIN 
    fire_incidents f ON f.year BETWEEN ce.start_year AND ce.end_year
GROUP BY 
    ce.phenomenon, 
    ce.severity,  
    ce.start_year, 
    ce.end_year
ORDER BY 
    total_deforested_area DESC;
   
   
select * from climate_analysis ca;
