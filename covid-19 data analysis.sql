--This project is full of data analysis with o sql on covid data
--SOME interesting information will be going to reveal

select * from portfolio_project..CovidDeaths
	where continent is not null
	order by 1 ,4


-- now select data that we are going to be use 

select location,date,total_cases,new_cases,total_deaths,population 
	from portfolio_project..CovidDeaths
	where continent is not null
	order by 1,2


-- first one 1.Total cases vs Total deaths


-- In here you can dead percentage for all global on specific date

select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as dead_percentage 
	from portfolio_project..CovidDeaths
	where continent is not null
	order by 1,2




--you can see dead_percentage for desired country 

select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as dead_percentage 
	from portfolio_project..CovidDeaths
	where location = 'India' and continent is not null
	order by 1,2

--you can see total dead_percentage for all country and you can use where to find specific country dead_percentage

select sum(total_cases) as total_cases ,sum(cast(total_deaths as int)) as total_death,(sum(cast(total_deaths as int))/sum(total_cases)) * 100 as total_dead_percentage 
from portfolio_project..CovidDeaths
where continent is not null




--2.we going to see Total cases vs population



--for now we see infection percentage of total population of country

select location,date,total_cases,population,(total_deaths/population) * 100 as dead_percentage 
	from portfolio_project..CovidDeaths
	where continent is not null
	order by 1,2


-- now seeing at countries with highest infection rate compared to others

select location,population,max(total_cases) as InfectionCount, max((total_cases/population)) *100 as MaxInfectionRate
	from portfolio_project..CovidDeaths
	where continent is not null
	group by location,population
	order by 4 desc 


--now select things down by continent

--you can which continent as highest dead

select continent,Max(cast(total_deaths as int)) as totaldeathcount
	from portfolio_project..CovidDeaths
	where continent is not null
	group by continent
	order by 2 desc

--Global number

-- we can see total case , total death and deathpercentage on that paticular date  on globally.
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)) * 100 
	as Deathpercentage
	from portfolio_project..CovidDeaths
	where continent is not null
	group by date
	order by 1

-- looking for total case, total deaths and Deathpercentage for total data. 
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)) * 100 
	as Deathpercentage
	from portfolio_project..CovidDeaths
	where continent is not null
	order by 1

-- selecting data to be used for futher analysis.

select *
	from portfolio_project..CovidDeaths  death
	join portfolio_project..CovidVaccinations vaccine
		on death.location = vaccine.location
		and death.date  = vaccine.date


--looking on Total Population Vs Vaccination

-- seeing the information of continent, location, date, population, new_vaccinations, peoplevaccinated on country.
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
    sum(cast(vaccine.new_vaccinations as int)) over(partition by death.location order by death.date) as peoplevaccinated
	from portfolio_project..CovidDeaths  death
	join portfolio_project..CovidVaccinations vaccine
		on death.location = vaccine.location
			and death.date  = vaccine.date
	where death.continent is not null
	order by 2,3

-- now we  don't see the null data on new_vaccination

select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
    sum(cast(vaccine.new_vaccinations as float)) over(partition by death.location order by death.date) as peoplevaccinated
	from portfolio_project..CovidDeaths  death
	join portfolio_project..CovidVaccinations vaccine
		on death.location = vaccine.location
			and death.date  = vaccine.date
	where death.continent is not null
	      and vaccine.new_vaccinations is not null
	order by 2,3

-- looking for percentage of population vaccinated on that country

with popvac (Continent,Location,Date,Population,New_vaccinations,Peoplevaccinated)
as

(
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
    sum(cast(vaccine.new_vaccinations as int)) over(partition by death.location order by death.date) as peoplevaccinated
	from portfolio_project..CovidDeaths  death
	join portfolio_project..CovidVaccinations vaccine
		on death.location = vaccine.location
			and death.date  = vaccine.date
	where death.continent is not null
	      and vaccine.new_vaccinations is not null
)

select location,(max(Peoplevaccinated)/Population)*100 as percentvaccinate from popvac


-- looking for which country has highest percentage of vaccinated people


with popvac (Continent,Location,Date,Population,New_vaccinations,Peoplevaccinated)
as

(
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
    sum(cast(vaccine.new_vaccinations as float)) over(partition by death.location order by death.date) as peoplevaccinated
	from portfolio_project..CovidDeaths  death
	join portfolio_project..CovidVaccinations vaccine
		on death.location = vaccine.location
			and death.date  = vaccine.date
	where death.continent is not null
	      and vaccine.new_vaccinations is not null
)

select location,(max(Peoplevaccinated)/Population)*100 as percentvaccinate from popvac
group by location,Population
order by 2 DESC



-- creating temporary table for percent of population vaccinated

drop table  if exists #percentpopulationvaccinated

create table #percentpopulationvaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinated numeric,
	Peoplevaccinated numeric
	)

insert into #percentpopulationvaccinated
	
	select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
    sum(cast(vaccine.new_vaccinations as int)) over(partition by death.location order by death.date) as peoplevaccinated
	from portfolio_project..CovidDeaths  death
	join portfolio_project..CovidVaccinations vaccine
		on death.location = vaccine.location
			and death.date  = vaccine.date
	where death.continent is not null
	      and vaccine.new_vaccinations is not null

select * from #percentpopulationvaccinated



--creating view for percent of population vaccinated

create view percentpopulationvaccinated
	as
	select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
    sum(cast(vaccine.new_vaccinations as int)) over(partition by death.location order by death.date) as peoplevaccinated
	from portfolio_project..CovidDeaths  death
	join portfolio_project..CovidVaccinations vaccine
		on death.location = vaccine.location
			and death.date  = vaccine.date
	where death.continent is not null
	      and vaccine.new_vaccinations is not null
