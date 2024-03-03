select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2;

-- looking at total cases vs total deaths
-- shows the likelihood of dyinf if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from covid_deaths
where location = 'Brazil'
order by 1,2;


-- looking at total cases vs population
-- shows percentage of population that got covid

select location, date, total_cases, population, (total_cases / population)*100 as TotalCasesPerPopulation
from covid_deaths
where location ilike '%states%'
order by 1,2;


-- looking at countries with highest infection rate compared to population

select location, max(total_cases) as HighestInfectionCount, population, max(((total_cases) / population))*100 as HighestInfectionRate
from covid_deaths
group by location, population
having max(((total_cases) / population))*100 is not null
order by HighestInfectionRate desc;


-- showing countries with highest death count per population

select location, max(total_deaths) as TotalDeathCount
from covid_deaths
where continent is not null
group by location
having max(total_deaths) is not null
order by TotalDeathCount desc;


-- showing by continents



-- showing continents with the highest death count per population

select continent, max(total_deaths) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- global numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentageGlobal
from covid_deaths
where continent is not null
-- group by date
order by 1,2;



-- looking at total population vs vaccinations
-- use cte

with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
-- , (rolling_people_vaccinated/dea.population)*100
from covid_deaths as dea
join covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinated/population)*100 from pop_vs_vac;

-- -- looking at countries with highest vaccinations rate

-- select dea.location, total_new_vaccinations, dea.population, (total_new_vaccinations/dea.population)*100 as percentage_peo_vac_pop
-- from covid_deaths as dea
-- join (
-- 	select location,
-- 	sum(new_vaccinations) as total_new_vaccinations
-- 	from covid_vaccinations
-- 	where continent is not null
-- 	group by location
-- ) as vac
-- on dea.location = vac.location
-- where dea.continent is not null
-- and total_new_vaccinations is not null
-- group by dea.location, total_new_vaccinations, dea.population
-- order by 4 desc

-- temp table

drop table if exists percent_population_vaccinated;
create temp table percent_population_vaccinated
(
	continent varchar(50),
	location varchar(50),
	date date,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
);

insert into percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
-- , (rolling_people_vaccinated/dea.population)*100
from covid_deaths as dea
join covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
--order by 2,3

select *, (rolling_people_vaccinated/population)*100 
from percent_population_vaccinated;




-- creating view to store data for later visualizations

create view percent_population_vaccinated_view as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
-- , (rolling_people_vaccinated/dea.population)*100
from covid_deaths as dea
join covid_vaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
--order by 2,3


select * from
percent_population_vaccinated_view;