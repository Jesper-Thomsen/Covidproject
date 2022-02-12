--finding date for first death by country
select country, min(date) as first_death, max(cast(total_deaths as int)) as totaldeaths
from CovidProject..CovidDeath
where new_deaths > 0 
group by country
order by totaldeaths desc

--finding total deaths per region
select max(cast(total_deaths as int)) as totaldeaths, country
from CovidProject..CovidDeath
where total_deaths IS NOT NULL
group by country
order by max(cast(total_deaths as int)) desc 


--finding ratio of deaths to cases
select sum(new_cases) as sumcases, sum(cast(new_deaths as int)) as sumdeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidProject..CovidDeath
where continent is not null
--group by date
order by 1,2


--finding percentage people vaccinated
select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.country order by dea.country, cast(dea.date as datetime)) as sumvac
from CovidProject..CovidDeath dea
join CovidProject..CovidVaccinations vac
	on dea.country = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


	With PopvsVac (Continent, country, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.country Order by dea.country, cast(dea.Date as datetime)) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From covidproject..CovidDeath dea
	Join CovidProject..CovidVaccinations vac
		On dea.country = vac.location
		and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3
	)
	Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac


Create View PopulationVaccinated as
Select dea.continent, dea.country, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.country Order by dea.country, cast(dea.Date as datetime)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeath dea
Join CovidProject..CovidVaccinations vac
	On dea.country = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PopulationVaccinated

