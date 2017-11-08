/*Import data from local drive*/
proc import
	datafile="C:\Users\LishengWang\Desktop\Study Material\BSTA6651 Categorical Data in Biostatistics\Auto\used-cars-database\autos.csv"
	out=auto
	dbms=csv
	;
run;

/*Model : count = avgPrice vehicletype yearRegister gearbox powerPS km brand notRepairedDamage */

/*Car Brand :
Europe & America: alfa , audi , bmw, chrys, citroen ,dacia , fiat ,jaguar,jeep,lada, lancia, land_rover, merce,mini,opel,
peugeot,pors,renault,rover,saab,seat,skoda,smart,cheve, ford, volk, volvo
Asia:daewoo , daihatsu , honda, hyundai,kia,maz , mitrubishi,nissan,suba,suzuki,toy,trabant
*/

/*Data Clean up*/
data automodify (keep=price vehicleType yearOfRegistration powerPS kilometer brand transmission Damage);
	set auto;
	length transmission $12;
	if vehicleType="bus" then vehicleType=10;
	if vehicleType="kombi" then vehicleType=8;
	if vehicleType="suv" then vehicleType=6;
	if vehicleType in ("kleinwagen","limousine") then vehicleType=4;
	if vehicleType= "cabrio" then vehicleType=2;
	if vehicleType= "coupe" then vehicleType=2;	
	if vehicleType in ("andere"," ") then delete;
	if brand in ("daewoo","daihatsu","honda","hyundai","kia","mazda","mitsubishi","nissan","subaru","suzuki","toyota","trabant") then brand="Asia";
		else brand="Europe";
	if gearbox="manuell" then transmission="manual";
	if gearbox="automatik" then transmission="automatic";
	if gearbox=" " then delete;
	if notRepairedDamage="ja" then Damage="1";
	if notRepairedDamage="nein" then Damage="0";
	if notRepairedDamage=" " then delete;
	if price=0 then delete;
	if powerPS=0 then delete;
run;


proc sql;
	create table Autoanalysis as
	select 
	count(*) as count,
	round(avg(price/1000),0.001) as avgPrice, 
	vehicleType,
	yearOfRegistration as year,
	round(avg(powerPS),0.1) as power,
	round(avg(kilometer/1000),0.001) as mileage, 
	brand,
	transmission,
	damage
	from work.Automodify 
	where yearOfRegistration > 1990
	group by brand, transmission, damage, vehicletype, yearOfRegistration;
quit;

/*Explore variables*/
proc univariate data=Autoanalysis;
	var count;
	histogram;
run;

/*Model fit*/
proc genmod data=autoanalysis;
class brand transmission damage vehicleType;
model count=avgPrice vehicleType year power mileage brand transmission damage/dist=poi link=log;
run;

/*Export to csv file*/
proc export data=Autoanalysis
	dbms=csv
	outfile="C:\Users\LishengWang\Desktop\Study Material\BSTA6651 Categorical Data in Biostatistics\Auto\used-cars-database\Auto Analysis Ready.csv"
	replace
	;
run;
