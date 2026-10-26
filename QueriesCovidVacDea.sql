-- Queries used for Tableau

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS INTEGER)) * 100.0
        / SUM(new_cases) AS DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
--GROUP by date
order by 1,2

--European Union is part of Europe
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
GROUP by location
ORDER by TotalDeathCount DESC

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases * 100.0 / population)) as PercentPopulationInfected
FROM CovidDeaths
GROUP by location, population
ORDER by PercentPopulationInfected desc

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases * 100.0 / population)) as PercentPopulationInfected
FROM CovidDeaths
GROUP by location, population, date
order by PercentPopulationInfected desc