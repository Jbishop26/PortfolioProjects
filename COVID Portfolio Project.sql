SELECT Location, date, total_cases, new_cases, total_deaths, population
	FROM CovidDeaths
	ORDER BY location, date


--Total cases vs Total deaths
--Likely hood of death if Covid has been contracted.
SELECT Location, date, total_cases, total_deaths, (Total_Deaths/Total_Cases)*100 AS Death_Percentage
	FROM CovidDeaths
	WHERE  Location LIKE '%States%' 
	ORDER BY location, date

--Total Cases vs Population
SELECT Location, date, Population ,total_cases,(Total_Cases/Population)*100 AS Cases_Percentage
	FROM CovidDeaths
	WHERE  Location LIKE '%States%' 
	ORDER BY location, date


--Highest infection rate 
SELECT Location, Population ,MAX(total_cases) AS Highest_Infection_Count, MAX((Total_Cases/Population)*100) AS Cases_Percentage
	FROM CovidDeaths
	GROUP BY Location, Population
	ORDER BY Cases_Percentage DESC


--Countries with the highest Death Count per population
SELECT Location, MAX(cast(Total_Deaths as int)) AS TotalDeathCount
	FROM CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY Location
	ORDER BY TotalDeathCount DESC

--Highest Death Count per continent
SELECT continent, MAX(cast(Total_Deaths as int)) AS TotalDeathCount
	FROM CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT  date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPercentage
	FROM CovidDeaths
	--WHERE  Location LIKE '%States%' 
	WHERE continent IS NOT NULL
	GROUP BY date
	ORDER BY date


--Looking at Total Population vs Vaccinations
SELECT Dea.continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations AS bigint)) OVER (PARTITION BY Dea.Location ORDER BY dea.location,Dea.Date) AS Rolling_Vaccinations
	FROM CovidDeaths  AS Dea
	JOIN CovidVaccinations AS Vac
		ON Dea.Location = Vac.Location AND Dea.Date = Vac.Date
	WHERE Dea.Continent IS NOT NULL
	ORDER BY  Dea.location, Dea.date


--USING CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_Vaccinations)
as(
SELECT Dea.continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations AS int)) OVER (PARTITION BY Dea.Location ORDER BY dea.location,Dea.Date) AS Rolling_Vaccinations
	FROM CovidDeaths  AS Dea
	JOIN CovidVaccinations AS Vac
		ON Dea.Location = Vac.Location AND Dea.Date = Vac.Date
	WHERE Dea.Continent IS NOT NULL
	--ORDER BY  Dea.location, Dea.date
	)

SELECT *, (Rolling_Vaccinations/Population) * 100
	FROM PopvsVac


--USING TEMP TABLE
--DROP TABLE IF EXISTS #Percent_Population_Vac
CREATE TABLE #Percent_Population_Vac
(
CONTINENT nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_Vaccinations numeric
)

INSERT INTO #Percent_Population_Vac
SELECT Dea.continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations AS int)) OVER (PARTITION BY Dea.Location ORDER BY dea.location,Dea.Date) AS Rolling_Vaccinations
	FROM CovidDeaths  AS Dea
	JOIN CovidVaccinations AS Vac
		ON Dea.Location = Vac.Location AND Dea.Date = Vac.Date
	WHERE Dea.Continent IS NOT NULL
	--ORDER BY  Dea.location, Dea.date

SELECT *, (Rolling_Vaccinations/Population) * 100
	FROM #Percent_Population_Vac




--Creating View to store data

CREATE VIEW Percent_Population_Vac AS 
SELECT Dea.continent, Dea.Location, Dea.Date, Dea.Population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations AS int)) OVER (PARTITION BY Dea.Location ORDER BY dea.location,Dea.Date) AS Rolling_Vaccinations
	FROM CovidDeaths  AS Dea
	JOIN CovidVaccinations AS Vac
		ON Dea.Location = Vac.Location AND Dea.Date = Vac.Date
	WHERE Dea.Continent IS NOT NULL
	--ORDER BY  Dea.location, Dea.date