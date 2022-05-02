-- Projeto Portifolio SQL analise de dados sobre a Covid --

-- Dataset usado foi retirado do site https://ourworldindata.org/covid-deaths --

SELECT * 
FROM cap07.covid_mortes
ORDER BY 3, 4;

SELECT * 
FROM cap07.covid_vacinacao
ORDER BY 3, 4; 

-- Selecionar os dados que estarei usando no projeto
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM cap07.covid_mortes
ORDER BY 1, 2;

-- Procurar pelo Total de Casos x Total de Mortes, para descobrir o percentual de quantas mortes existem pelo total de casos.
-- Mostra a probabilidade de morrer se você pegar covid em cada páis

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS percentual_mortes
FROM cap07.covid_mortes
ORDER BY 1, 2;

-- o Filtro mostra a probabilidade de morrer se você pegar covid no Brasil até a data de 07/04/2021

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS percentual_mortes
FROM cap07.covid_mortes
where location = "Brazil"
ORDER BY 1, 2;

-- Temos um resultado de aproximadamente 2,79% até a data de 07/04/2021, atualmente os valores devem estar bem menores devido ao avanço da vacinação, mas não contamos com o acesso a esses dados nesse dataset para afirmar com certeza.

-- Procurar o Total de Casos x População 
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS percentual_populacao
FROM cap07.covid_mortes
ORDER BY 1, 2;

-- Filtrando apenas o Brasil Total de Casos x População 
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS percentual_populacao
FROM cap07.covid_mortes
WHERE location = "Brazil"
ORDER BY 1, 2;

-- Chegamos ao valor de 8,83% de total de casos de Covid na população brasileira até 07/04/2021.

-- Quais países tem as maiores percentuais de contaminação de Covid comparado a sua população 
SELECT location, population, MAX(total_cases) AS maiores_contaminacao_covid, MAX((total_cases/population)) * 100 AS percentual_infeccao
FROM cap07.covid_mortes
GROUP BY population,location
ORDER BY percentual_infeccao DESC;

-- Quais países tem mais mortes por Covid
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS maiores_mortes_covid
FROM cap07.covid_mortes
GROUP BY location
ORDER BY maiores_mortes_covid DESC;

-- os dados saem com resultados de continentes como Europa, Asia e etc, para solucionar esse problema a querye ficaria melhor dessa forma:
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS maiores_mortes_covid
FROM cap07.covid_mortes
WHERE continent <> ""
GROUP BY location
ORDER BY maiores_mortes_covid DESC;

-- podemos verificar com base nessa base de dados o Brasil está em 2° lugar, apenas atrás dos Estados Unidos no número total de mortos.


-- Quais continentes tem mais mortes por Covid
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS maiores_mortes_covid
FROM cap07.covid_mortes
WHERE continent = ""
GROUP BY location
ORDER BY maiores_mortes_covid DESC;

-- Quais são o números de infectados e mortos por Covid no mundo por dia
SELECT date, SUM(new_cases) AS novos_casos, SUM(new_deaths) AS novas_mortes, (SUM(new_deaths)/SUM(new_cases))*100 AS percentual_mortes
FROM cap07.covid_mortes
WHERE continent <> ""
GROUP BY date
ORDER BY 1, 2;

-- Quais são o números de infectados e mortos por Covid no mundo por dia
SELECT date, SUM(new_cases) AS novos_casos, SUM(new_deaths) AS novas_mortes, (SUM(new_deaths)/SUM(new_cases))*100 AS percentual_mortes
FROM cap07.covid_mortes
WHERE continent <> ""
GROUP BY date
ORDER BY 1, 2;

-- Número geral de casos de Covid e percentual de mortes no dataset
SELECT SUM(new_cases) AS novos_casos, SUM(new_deaths) AS novas_mortes, (SUM(new_deaths)/SUM(new_cases))*100 AS percentual_mortes
FROM cap07.covid_mortes
WHERE continent <> ""
ORDER BY 1, 2;

-- temos um resultado de percentual de mortes de aproximadamente 2,16 % de mortes no mundo

-- Join com a tabela de vacinados por Covid
SELECT *
FROM cap07.covid_mortes AS MOR
JOIN cap07.covid_vacinacao AS VAC
ON MOR.location = VAC.location
AND MOR.date = VAC.date; 


-- Vamos ver o Total de População x Total de Vacinados
SELECT mor.continent, mor.location, mor.date, mor.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY mor.location ORDER BY mor.date) AS contagem_vacinados
FROM cap07.covid_mortes AS MOR
JOIN cap07.covid_vacinacao AS VAC
ON MOR.location = VAC.location
AND MOR.date = VAC.date
WHERE MOR.continent <> ""
ORDER BY 2, 3; 

-- Qual o percentual da população com pelo menos 1 dose da vacina ao longo do tempo?

-- Usando Common Table Expressions (CTE) 
WITH PopvsVac (continent,location, date, population, new_vaccinations, TotalMovelVacinacao) AS
(
SELECT mortos.continent,
       mortos.location,
       mortos.date,
       mortos.population,
       vacinados.new_vaccinations,
       SUM(CAST(vacinados.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY mortos.location ORDER BY mortos.date) AS TotalMovelVacinacao
FROM cap07.covid_mortes mortos 
JOIN cap07.covid_vacinacao vacinados 
ON mortos.location = vacinados.location 
AND mortos.date = vacinados.date
WHERE mortos.continent <> ""
)
SELECT *, (TotalMovelVacinacao / population) * 100 AS Percentual_1_Dose FROM PopvsVac;

##Criando visualização dos dados para futuras visualizações

CREATE VIEW cap07.PercentualPopVac AS 
WITH PopvsVac (continent,location, date, population, new_vaccinations, TotalMovelVacinacao) AS
(
SELECT mortos.continent,
       mortos.location,
       mortos.date,
       mortos.population,
       vacinados.new_vaccinations,
       SUM(CAST(vacinados.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY mortos.location ORDER BY mortos.date) AS TotalMovelVacinacao
FROM cap07.covid_mortes mortos 
JOIN cap07.covid_vacinacao vacinados 
ON mortos.location = vacinados.location 
AND mortos.date = vacinados.date
WHERE mortos.continent <> ""
)
SELECT *, (TotalMovelVacinacao / population) * 100 AS Percentual_1_Dose FROM PopvsVac;

-- fazer um select na view para consulta
SELECT * 
FROM cap07.PercentualPopVac;
