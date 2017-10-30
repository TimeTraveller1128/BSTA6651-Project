/*Load Animal Classification datasets over the wire*/
%let dsn1=class;
%let dsn2=zoo;
%let url1=https://github.com/TimeTraveller1128/BSTA6651-Project-/raw/master/class.csv;
%let url2=https://github.com/TimeTraveller1128/BSTA6651-Project-/raw/master/zoo.csv;

%macro AnimalClassProjectDataPrep(dsn,url);
	filename tempfile "%sysfunc(getoption(work))/tempfile.csv";
	proc http
		method="get"
		url="&url."
		out=tempfile
		;
	run;

	proc import
		file=tempfile
		out=&dsn.
		dbms=csv
		;
	run;
%mend;

%AnimalClassProjectDataPrep(dsn=&dsn1.,url=&url1.);
%AnimalClassProjectDataPrep(dsn=&dsn2.,url=&url2.);


/*Horizontally merge two datasets for analysis-ready file*/
proc sql;
	create table classification (drop=class_number) as
	select c.class_number,c.class_type as type ,z.*
		from work.class as c
			full join
			work.zoo as z
			on c.class_number=z.class_type
		order by z.class_type
	;
quit;


/*Use Categorical data analysis to build up model for animal classification.
Response Variable : Multinomial
Explanatory Variable : Mixed of Binary Variable and Continuous Variable*/
proc genmod data=classification;
	model class_type=hair feathers eggs milk airborne aquatic predator toothed backbone
	breathes venomous fins legs tail domestic catsize /dist=mult link=cumlogit;
	output out=tempModel;
run;
