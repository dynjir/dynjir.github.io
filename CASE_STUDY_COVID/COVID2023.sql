SELECT
*
FROM portfolio_covid.covid_deaths
where date = "2020-01-23"
and new_cases != 0
and continent is not null;

-- SELECT DATA THAT WE'LL BE USING
SELECT
	`index`,
	location, 
	date,
	total_cases,
	new_cases,
	total_deaths,
	population 
FROM portfolio_covid.covid_deaths
order by location, date;

-- TOTAL CASES VS TOTAL DEATHS IN USA
-- THE LIKELIHOOD OF DYING IF COVID IS CONTRACTED IN USA
SELECT
	location, 
	date,
	total_cases,
	total_deaths,
	concat(round((total_deaths/total_cases)*100,2),"%") as death_percentage
FROM portfolio_covid.covid_deaths
where location = "United States"
	and total_cases is not NULL
order by location, date;

-- TOTAL CASES VS POPULATION IN USA
-- THE LIKELIHOOD OF CONTRACTING COVID IN USA
SELECT
	location, 
	date,
	population,
	total_cases,
	total_deaths,
	concat(round((total_cases/population)*100,2),"%") as percentage_population_infected
FROM portfolio_covid.covid_deaths
where location = "United States"
	and total_cases is not NULL
order by location, date;

-- TOTAL CASES VS POPULATION WORLDWIDE
-- THE LIKELIHOOD OF CONTRACTING COVID BY COUNTRY
SELECT
	location as country, 
	max(date) as last_updated,
	max(population) as population,
	max(total_cases) as total_cases,
	max(total_deaths) as total_deaths,
	cast((max(total_cases)/max(population))*100 AS DECIMAL(5,3)) as percentage_population_infected
FROM portfolio_covid.covid_deaths
where total_cases is not NULL
	and continent is not null
group by location
order by percentage_population_infected desc;

-- HIGHEST DEATH COUNT PER POPULATION WORLDWIDE
-- RANKING OF COUNTRIES BY THE DEATH COUNT VIA COVID
SELECT
	location as country, 
	max(total_deaths) as total_deaths
FROM portfolio_covid.covid_deaths
where total_cases is not NULL
	and continent is not null
group by location
order by max(total_deaths) desc;

-- HIGHEST DEATH COUNT PER POPULATION WORLDWIDE BY CONTINENT
-- RANKING OF COUNTRIES BY THE DEATH COUNT VIA COVID BY CONTINENT
SELECT
	location as location,
	max(total_deaths) as total_deaths
FROM portfolio_covid.covid_deaths
where continent is null
	and location not regexp "income"
	and location != "World"
	and location != "European Union"
group by location
order by max(total_deaths) desc;

-- GLOBAL NUMBERS: PROGRESSION OF COVID ACROSS THE WORLD
SELECT
	-- date,
	sum(new_cases) as global_total_cases,
	sum(new_deaths) as global_total_deaths,
	(sum(new_deaths)/sum(new_cases))*100 as global_death_percentage
FROM portfolio_covid.covid_deaths
where continent is not null
-- group by date
order by date

-- VACCINATIONS
SELECT * FROM portfolio_covid.covid_vaccs;

select *
from portfolio_covid.covid_vaccs as a
left join portfolio_covid.covid_deaths as b
	on a.location = b.location
	and a.date = b.date;
    
    
-- HOW MANY PEOPLE GOT VACC'D OVER TIME
select 
	a.continent,
    a.location,
	a.date,
    a.population,
    b.new_vaccinations -- per day
from portfolio_covid.covid_deaths as a
left join portfolio_covid.covid_vaccs as b
	on a.index = b.index
where a.continent is not null
order by a.continent, a.location, a.date;
    
-- TOTAL POPULATION VS VACCINATIONS WITH ROLLING COUNT
select
	a.continent,
    a.location,
	a.date,
    a.population,
    b.new_vaccinations, -- per day 
    sum(b.new_vaccinations) over (partition by a.location order by a.location, a.date) as rolling_people_vaccinated,
    (sum(b.new_vaccinations) over (partition by a.location order by a.location, a.date)) / (a.population) * 100 as vaccinated_percentage -- this will be re-created using different methods
from portfolio_covid.covid_deaths as a
left join portfolio_covid.covid_vaccs as b
	on a.index = b.index
where a.continent is not null
order by a.continent, a.location, a.date;

-- TOTAL POPULATION VS VACCINATIONS WITH ROLLING COUNT (WITH A CTE)
with population_vs_vaccinated (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as (select
		a.continent,
		a.location,
		a.date,
		a.population,
		b.new_vaccinations, -- per day 
		sum(b.new_vaccinations) over (partition by a.location order by a.location, a.date) as rolling_people_vaccinated
	from portfolio_covid.covid_deaths as a
	left join portfolio_covid.covid_vaccs as b
		on a.index = b.index
	where a.continent is not null
	)
select
	*,
	(rolling_people_vaccinated / population) * 100 as vaccinated_percentage
    from population_vs_vaccinated
order by continent, location, date;

--  TOTAL POPULATION VS VACCINATIONS WITH ROLLING COUNT (WITH TEMP TABLES)
drop table if exists percent_population_vaccinated;

create temporary table percent_population_vaccinated
as (select
		a.continent,
		a.location,
		a.date,
		a.population,
		b.new_vaccinations, -- per day 
		sum(b.new_vaccinations) over (partition by a.location order by a.location, a.date) as rolling_people_vaccinated
	from portfolio_covid.covid_deaths as a
	left join portfolio_covid.covid_vaccs as b
		on a.index = b.index
	where a.continent is not null);

select 
*,
(rolling_people_vaccinated / population) * 100 as vaccinated_percentage
from percent_population_vaccinated;
    
--  TOTAL POPULATION VS VACCINATIONS WITH ROLLING COUNT (VIEW)
create view rolling_vaccinated_percentage as
    select
		a.continent,
		a.location,
		a.date,
		a.population,
		b.new_vaccinations, -- per day 
		sum(b.new_vaccinations) over (partition by a.location order by a.location, a.date) as rolling_people_vaccinated,
		(sum(b.new_vaccinations) over (partition by a.location order by a.location, a.date)) / (a.population) * 100 as vaccinated_percentage -- this will be re-created using different methods
	from portfolio_covid.covid_deaths as a
	left join portfolio_covid.covid_vaccs as b
		on a.index = b.index
	where a.continent is not null
	order by a.continent, a.location, a.date;

SELECT * FROM portfolio_covid.rolling_vaccinated_percentage;

-- RANKING OF COUNTRIES BY THE DEATH COUNT VIA COVID BY CONTINENT (VIEW)
create view global_death_count as
	SELECT
		location as location,
		max(total_deaths) as total_deaths
	FROM portfolio_covid.covid_deaths
	where continent is null
		and location not regexp "income"
		and location != "World"
		and location != "European Union"
	group by location
	order by max(total_deaths) desc;

SELECT * FROM portfolio_covid.global_death_count;

-- TABLEAU VIEW 1: GLOBAL NUMBERES (VIEW)
select
sum(new_cases) as total_cases, 
sum(new_deaths) as total_deaths,
sum(new_deaths) / sum(new_cases)*100 as death_percentage
from covid_deaths
where continent is not null 
order by 1,2;

-- TABLEAU VIEW 2: TOTAL DEATHS PER CONTINENT (VIEW)
select 
location, 
sum(new_deaths) as total_death_count
from covid_deaths
where continent is null 
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc;

-- TABLUEA VIEW 3: PERCENT POPULATION INFECTED PER COUNTRY (VIEW)
create view `vw_global_population_infected` as
	select 
		location,
		population,
		MAX(total_cases) as highest_infection_count, 
		Max((total_cases/population))*100 as percent_population_infected
	from covid_deaths
    where continent is null
		and location not regexp "income"
		and location != "World"
		and location != "European Union"
	group by location, population
	order by percent_population_infected desc;

-- TABLEAU VIEW 4: PROGRESSION OF PERCENT POPULATION INFECTED BY LOCATION (VIEW)
create view `vw_rolling_global_population_infected` as
	select
		location,
		population,
		date,
		MAX(total_cases) as highest_infection_count,
		Max((total_cases/population))*100 as percent_population_infected
	from covid_deaths
    where continent is null
		and location not regexp "income"
		and location != "World"
		and location != "European Union"
	group by Location, Population, date
	order by percent_population_infected desc