DELIMITER //
DROP PROCEDURE IF EXISTS chooseparty //
CREATE PROCEDURE chooseparty(IN partychoose VARCHAR(3))
BEGIN
	CASE partychoose
		WHEN 'DEM' THEN
			DROP TABLE IF EXISTS StateGovVotes;
			CREATE TEMPORARY TABLE StateGovVotes AS
				SELECT *
				FROM ALL_PRECINCTS
				WHERE party = 'DEM' AND officename = 'Governor / Lt. Governor';
		WHEN 'REP' THEN
			DROP TABLE IF EXISTS StateGovVotes;
			CREATE TEMPORARY TABLE StateGovVotes AS
				SELECT *
				FROM ALL_PRECINCTS
				WHERE party = 'REP' AND officename = 'Governor / Lt. Governor';
		ELSE
			DROP TABLE IF EXISTS StateGovVotes;
			CREATE TEMPORARY TABLE StateGovVotes AS
				SELECT *
				FROM ALL_PRECINCTS
				WHERE officename = 'Governor / Lt. Governor';
	END CASE;
END;
//

DROP PROCEDURE IF EXISTS StateGovTotals //
CREATE PROCEDURE StateGovTotals(IN geo VARCHAR(10), partychoose VARCHAR(3))
BEGIN
	Call chooseparty(partychoose);
	DROP TABLE IF EXISTS StateGovTotals;
	CREATE TEMPORARY TABLE StateGovTotals AS
		SELECT CASE geo
			WHEN 'legislative' THEN legs
			WHEN 'district' THEN electiondistrict
			WHEN 'precinct' THEN electionprecinct
			WHEN 'congressional' THEN cong
			ELSE county
		END AS split,
		SUM(electionnightvotes) AS votes
		FROM StateGovVotes
		GROUP BY split;
END;
//

DROP PROCEDURE IF EXISTS StateRaceTotals //
CREATE PROCEDURE StateRaceTotals(IN geo VARCHAR(15), race VARCHAR(10))
BEGIN
	DROP TABLE IF EXISTS StateRaceTotals;
	CREATE TEMPORARY TABLE StateRaceTotals AS
		SELECT CASE geo
			WHEN 'legislative' THEN legs
			WHEN 'district' THEN electiondistrict
			WHEN 'precinct' THEN electionprecinct
			WHEN 'congression' THEN cong
			ELSE county
		END AS split,
		CASE race
			WHEN 'Senator' THEN 'U.S. Senator'
			WHEN 'AG' THEN 'Attorney General'
			WHEN 'Congress' THEN 'Representative in Congress'
			ELSE 'Governor / Lt. Governor'
		END AS Office,
		party, SUM(electionnightvotes) AS votes
		FROM ALL_PRECINCTS
		WHERE party = 'REP' OR party = 'DEM'
		GROUP BY split, party
		ORDER BY split, party;
END;
//

DROP PROCEDURE IF EXISTS BaltGovTotals //
CREATE PROCEDURE BaltGovTotals(IN geo VARCHAR(15))
BEGIN
	DROP TABLE IF EXISTS BaltGovTotals;
	CREATE TEMPORARY TABLE BaltGovTotals AS
		SELECT county, CASE geo
			WHEN 'legislative' THEN legs
			WHEN 'district' THEN electiondistrict
			WHEN 'precinct' THEN electionprecinct
			WHEN 'congressional' THEN cong
			ELSE county
			END AS split,
		SUM(electionnightvotes) AS votes
		FROM StateGovVotes
		WHERE county = '03'
		GROUP BY split;
END;
//

DROP PROCEDURE IF EXISTS VehicleRegStats //
CREATE PROCEDURE VehicleRegStats(IN year VARCHAR(4))
BEGIN
	DROP TABLE IF EXISTS VehicleRegStats;
	CREATE TEMPORARY TABLE VehicleRegStats AS
		SELECT county,
		CASE year
			WHEN '2010' THEN `2010`
			WHEN '2011' THEN `2011`
			WHEN '2012' THEN `2012`
			WHEN '2013' THEN `2013`
			WHEN '2015' THEN `2015`
			WHEN '2016' THEN `2016`
			WHEN '2017' THEN `2017`
			END AS RegisteredVehicles
		FROM VEHICLE_REGISTRATION;
END;
//

DROP PROCEDURE IF EXISTS BaltCrime //
CREATE PROCEDURE BaltCrime(IN crime VARCHAR(15))
BEGIN
	DROP TABLE IF EXISTS BaltCrime;
	CREATE TEMPORARY TABLE BaltCrime AS
		SELECT neighborhood, count(*) AS numCrimes
		FROM CRIME_IN_BALTIMORE
		WHERE CASE crime
			WHEN 'larceny' THEN description='LARCENY' OR
				description = 'LARCENY FROM AUTO'
			WHEN 'autotheft' THEN description='AUTO THEFT'
			WHEN 'burglary' THEN description='BURGLARY'
			WHEN 'assualt' THEN description='AGG. ASSAULT'
				OR description = 'COMMON ASSAULT'
				OR description='ASSAULT BY THREAT'
			WHEN 'arson' THEN description='ARSON'
			WHEN 'robbery' THEN description='ROBBERY - STREET'
				OR description='ROBBERY - RESIDENCE'
				OR description='ROBBERY - COMMERCIAL'
				OR description='ROBBERY - CARJACKING'
			WHEN 'shooting' THEN description='SHOOTING'
			WHEN 'homicide' THEN description='HOMICIDE'
			WHEN 'rape' THEN description='RAPE'
			WHEN 'all' THEN description != 'nothing'
		END
		GROUP BY neighborhood;
END;
//

DROP PROCEDURE IF EXISTS DrugAlcDeaths //
CREATE PROCEDURE DrugAlcDeaths(IN year VARCHAR(4))
BEGIN
	DROP TABLE IF EXISTS DrugAlcDeaths;
	CREATE TEMPORARY TABLE DrugAlcDeaths AS
		SELECT county,
		CASE year
			WHEN '2007' THEN `2007`
			WHEN '2008' THEN `2008`
			WHEN '2009' THEN `2009`
			WHEN '2010' THEN `2010`
			WHEN '2011' THEN `2011`
			WHEN '2012' THEN `2012`
			WHEN '2013' THEN `2013`
			WHEN '2015' THEN `2015`
			WHEN '2016' THEN `2016`
			WHEN 'all' THEN 'Total'
			END AS deaths
		FROM DRUG_ALCOHOL_DEATHS;
END;
//

DROP PROCEDURE IF EXISTS CensusStat //
CREATE PROCEDURE CensusStat(IN statistic VARCHAR(20))
BEGIN
	DROP TABLE IF EXISTS CensusStat;
	CREATE TEMPORARY TABLE CensusStat AS
		SELECT county,
		CASE statistic
			WHEN 'Population' THEN Population
			WHEN 'DecadePopChange' THEN DecadePopChange
			WHEN 'Under5' THEN Under5
			WHEN 'Under18' THEN Under18
			WHEN 'Over65' THEN Over65
			WHEN 'Female' THEN Female
			WHEN 'White' THEN White
			WHEN 'Black' THEN Black
			WHEN 'Asian' THEN Asian
			WHEN 'Hispanic' THEN Hispanic
			WHEN 'Veterans' THEN Veterans
			WHEN 'ForeignBorn' THEN ForeignBorn
			WHEN 'HousingUnits' THEN HousingUnits
			WHEN 'MedianHouseValue' THEN MedianHouseValue
			WHEN 'MedianRent' THEN MedianRent
			WHEN 'OtherLanguage' THEN OtherLanguage
			WHEN 'HSGrad' THEN HSGrad
			WHEN 'BachDeg' THEN BachDeg
			WHEN 'Disability' THEN Disability
			WHEN 'TravelToWork' THEN TravelToWork
			WHEN 'Income' THEN Income
			WHEN 'Poverty' THEN Poverty
			WHEN 'Employment' THEN Employment
			WHEN 'Density' THEN Density
		END AS stat
		FROM MDCENSUS;
END;
//

DROP PROCEDURE IF EXISTS ActiveVoters //
CREATE PROCEDURE ActiveVoters(IN party VARCHAR(4))
BEGIN
	DROP TABLE IF EXISTS ActiveVoters;
	CREATE TEMPORARY TABLE ActiveVoters AS
		SELECT county,
		CASE party
			WHEN 'DEM' THEN sum(DEM)
			WHEN 'REP' THEN sum(REP)
			WHEN 'all' THEN sum(DEM) + sum(REP)
	 		END AS activevoters
		FROM ELIGIBLE_ACTIVE_VOTERS
		GROUP BY County;
END;
//

DROP PROCEDURE IF EXISTS VacantBuildings //
CREATE PROCEDURE VacantBuildings()
BEGIN
	DROP TABLE IF EXISTS VacantBuildings;
	CREATE TEMPORARY TABLE VacantBuildings AS
		SELECT neighborhood, COUNT(*) as count
		FROM VACANT_BUILDINGS
		GROUP BY neighborhood;
END;
//

DROP PROCEDURE IF EXISTS 911Calls //
CREATE PROCEDURE 911Calls(IN geo VARCHAR(20))
BEGIN
	DROP TABLE IF EXISTS 911Calls;
	CREATE TEMPORARY TABLE 911Calls AS
		SELECT CASE geo
			WHEN 'legislative' THEN LegislativeDistrict
			WHEN 'congressional' THEN CongressionalDistrict
			WHEN 'zipcode' THEN Zipcode
			ELSE neighborhood
			END AS split, COUNT(*) as count
		FROM 911_CALLS, 911_CALLS_CONVERSION
		WHERE 911_CALLS.location = 911_CALLS_CONVERSION.location
		GROUP BY Location;
END;
//

DROP PROCEDURE IF EXISTS VoteStatByCounty //
CREATE PROCEDURE VoteStatByCounty(IN geo VARCHAR(10),
									 stat VARCHAR(20),
									 input VARCHAR(25))
BEGIN
	DROP TABLE IF EXISTS result1;
	CREATE TABLE result1(county VARCHAR(25), votes INT);
	DROP TABLE IF EXISTS result2;
	CREATE TABLE result2(county VARCHAR(25), stat DOUBLE(10,3));
	DROP TABLE IF EXISTS result;
	CREATE TABLE result(county VARCHAR(25), votes INT, stat DOUBLE(15,3));
	CALL StateGovTotals(geo, 'all');
	INSERT INTO result1 SELECT * FROM StateGovTotals;

	IF stat = 'drugalcdeaths'
		THEN CALL DrugAlcDeaths(input);
		INSERT INTO result2 SELECT * FROM DrugAlcDeaths;
		INSERT INTO result
			SELECT result2.county, result1.votes, result2.stat
			FROM result1, result2, COUNTY_CONVERSION C
			WHERE result1.county = C.cid
			AND C.countycol = result2.county
			ORDER BY county;
	ELSEIF stat = 'activevoters'
		THEN CALL Activevoters(input);
		INSERT INTO result2 SELECT * FROM Activevoters;
		INSERT INTO result
			SELECT result2.county, result1.votes, result2.stat
			FROM result1, result2, COUNTY_CONVERSION C
			WHERE result1.county = C.cid
			AND C.countycol = result2.county
			ORDER BY county;
	ELSEIF stat = 'vehicleregistration'
		THEN CALL VehicleRegStats(input);
		INSERT INTO result2 SELECT * FROM VehicleRegStats;
		INSERT INTO result
			SELECT result2.county, result1.votes, result2.stat
			FROM result1, result2, COUNTY_CONVERSION C
			WHERE result1.county = C.cid
			AND C.countycol = result2.county
		ORDER BY county;
	ELSEIF stat = 'census'
		THEN CALL CensusStat(input);
		INSERT INTO result2 SELECT * FROM censusstat;
		INSERT INTO result
			SELECT result2.county, result1.votes, result2.stat
			FROM result1, result2, COUNTY_CONVERSION C
			WHERE result1.county = C.cid
			AND C.countycol = result2.county
		ORDER BY county;
	END IF;
END;
//

-- DROP PROCEDURE IF EXISTS VoteStatByNeighboorhood //
-- CREATE PROCEDURE VoteStatByCounty(IN geo VARCHAR(10),
-- 									 stat VARCHAR(20),
-- 									 input VARCHAR(15))
-- BEGIN
-- 	DROP TABLE IF EXISTS result1;
-- 	CREATE TABLE result1(neighborhood VARCHAR(25), votes INT);
-- 	DROP TABLE IF EXISTS result2;
-- 	CREATE TABLE result2(neighborhood VARCHAR(25), stat INT);
-- 	DROP TABLE IF EXISTS result;
-- 	CREATE TABLE result(neighborhood VARCHAR(25), votes INT, stat INT);
-- 	CALL BaltGovTotals(geo);
-- 	INSERT INTO result1 SELECT * FROM BaltGovTotals;
--
-- 	IF stat = '911calls'
-- 		THEN CALL 911Calls(geo);
-- 		INSERT INTO result2 SELECT * FROM 911Calls;
-- 		INSERT INTO result
-- 			SELECT result2.county, result1.votes, result2.stat
-- 			FROM NEIGHBOORHOOD_CONVERSION C
-- 			JOIN result1 ON
-- 			LEFT JOIN result2
-- 			WHERE result1.county = C.cid
-- 			AND C.countycol = result2.county;
-- 	ELSEIF stat = 'vacantbuildings'
-- 		THEN CALL VacantBuildings();
-- 		INSERT INTO result2 SELECT * FROM VacantBuildings;
-- 		INSERT INTO result
-- 			SELECT result2.county, result1.votes, result2.stat
-- 			FROM result1, result2, COUNTY_CONVERSION C
-- 			WHERE result1.county = C.cid
-- 			AND C.countycol = result2.county;
-- 	END IF;
-- END;
-- //

DELIMITER ;
