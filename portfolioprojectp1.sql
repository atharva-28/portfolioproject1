select * 
from PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

--select *
--from PortfolioProject..Covidvaccination
--order by 3,4


--select data that we are going to use 


select location, date , total_cases , new_cases , total_deaths , population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths in respective country

select location, date , total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2


--looking at the total cases vs population

select location, date , total_cases , population , (total_cases/population)*100 as Percentageofpopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%India%'
order by 1,2


--looking at countries with highest	infection rate compared to population
select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as Percentageofpopulationinfected
from PortfolioProject..CovidDeaths
group by location , population
order by Percentageofpopulationinfected desc


--showing countries with the highest death count per population

select location, max(cast(total_deaths as int)) as totaldeaths          --cast is done to convert the data type to integer as this data contains nvarchar
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by totaldeaths desc


--breaking down things according to continent




--showing the continents with highest death count

select continent, max(cast(total_deaths as int)) as totaldeaths         
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeaths desc


--global numbers

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 



--looking at total population vs vaccination


select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,sum(convert(int, vac.new_vaccinations)) over (partition by  dea.location order by dea.location,
dea.date) as new_vaccinationsadded
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
on dea.location =  vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--use CTE

with PopvsVac( continent, location, date,population, new_vaccination, new_vaccinationsadded)
as 
(
select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,sum(convert(int, vac.new_vaccinations)) over (partition by  dea.location order by dea.location,
dea.date) as new_vaccinationsadded
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
on dea.location =  vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *,(new_vaccinationsadded/population)*100
from PopvsVac


--temp table
drop table if exists #percentpoplationvaccinated
create table #percentpoplationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
new_vaccinationsadded numeric)

insert into #percentpoplationvaccinated

select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,sum(convert(int, vac.new_vaccinations)) over (partition by  dea.location order by dea.location,
dea.date) as new_vaccinationsadded
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
on dea.location =  vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select *, (new_vaccinationsadded/population)
from #percentpoplationvaccinated



--creating view to store data for further visualization
create view percentpopulationvaccinated3 as
select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,sum(convert(int, vac.new_vaccinations)) over (partition by  dea.location order by dea.location,
dea.date) as new_vaccinationsadded
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination vac
on dea.location =  vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3