CREATE SCHEMA SMDB;
SET SEARCH_PATH TO SMDB;

CREATE TABLE "User"(
    UID numeric(5,0) PRIMARY KEY,
    "Name" varchar(20) NOT NULL,
    MailID varchar(30) NOT NULL,
    "Password" varchar(20) NOT NULL,
    "Location" varchar(20),
    Gender char (1) NOT NULL
);

CREATE TABLE PERSON(
	PersonID numeric(7,0) PRIMARY KEY,
	PersonName varchar(20) NOT NULL,
	Gender char(1) NOT NULL,
	DOB date,
	POB varchar(20)
);

CREATE TABLE Theatre(
	TheatreID numeric(5,0) PRIMARY KEY,
	Tname varchar(20) NOT NULL,
	Tlocation varchar(20) NOT NULL
);

CREATE TABLE Show(
	ShowID smallint PRIMARY KEY,
	StartTime time NOT NULL,
	EndTime time NOT NULL
);

CREATE TABLE Movie(
	MovieID numeric(7,0) PRIMARY KEY,
	Title varchar(30) NOT NULL,
	Genre varchar(90),
	ReleaseDate date NOT NULL,
	WriterID numeric(7,0) NOT NULL,
	Description varchar(1000),
	BOCollection integer,
	Rating numeric(4,2) DEFAULT 0,
	runtime integer,
	DirectorID numeric(7,0) NOT NULL,
	RateCount integer DEFAULT 0,
	FOREIGN KEY (WriterID) REFERENCES Person(PersonID) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (DirectorID) REFERENCES Person(PersonID) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE MovieAwards(
	AwardName varchar(20),
	MovieID numeric(7,0) REFERENCES Movie(MovieID) ON DELETE CASCADE ON UPDATE CASCADE,
	Catagory varchar(20),
	"Year" numeric(4,0) NOT NULL,
	PRIMARY KEY (AwardName, MovieID, Catagory)
);

CREATE TABLE Watchlist(
	UserID numeric(5,0) REFERENCES "User"(UID) ON DELETE CASCADE ON UPDATE CASCADE,
	MovieID numeric(7,0) REFERENCES Movie(MovieID) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(UserID, MovieID)
);

CREATE TABLE ProductionHouse(
	Name varchar(20) PRIMARY KEY,
	HeadID numeric(7,0) NOT NULL REFERENCES Person(PersonID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Rating(
	UID numeric(5,0) REFERENCES "User"(UID) ON DELETE CASCADE ON UPDATE CASCADE,
	MovieID numeric(7,0) REFERENCES Movie(MovieID) ON DELETE CASCADE ON UPDATE CASCADE,
	ReviewDesc varchar(400),
	Rating numeric(10,2) NOT NULL,
	PRIMARY KEY (UID, MovieID),
	constraint rating_between_0_to_10 check (Rating<=10 and Rating>=0)
);

CREATE TABLE Produced(
	PName varchar(20) REFERENCES ProductionHouse(Name) ON DELETE CASCADE ON UPDATE CASCADE,
	MovieID numeric(7,0) REFERENCES Movie(MovieID) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (PName, MovieID)
);

CREATE TABLE Premier (
	MovieID numeric(7,0) REFERENCES Movie(MovieID) ON DELETE CASCADE ON UPDATE CASCADE,
	TheatreID numeric(5,0) REFERENCES Theatre(TheatreID) ON DELETE CASCADE ON UPDATE CASCADE,
	ShowID smallint,
	date date,
	PRIMARY KEY (MovieID, TheatreID, ShowID,date)
);

CREATE TABLE Trivia(
	TriviaNo numeric(7,0) PRIMARY KEY,
	movieID numeric(7,0) NOT NULL REFERENCES Movie(MovieID) ON DELETE CASCADE ON UPDATE CASCADE,
	Trivia varchar(1000) NOT NULL
);

CREATE TABLE PersonAwards (
	AwardsName varchar(20),
	Category varchar(20),
	PersonID numeric(7,0) REFERENCES Person(PersonID) ON DELETE CASCADE ON UPDATE CASCADE,
	MovieID numeric(7,0) REFERENCES Movie(MovieID) ON DELETE CASCADE ON UPDATE CASCADE,
	"Year" numeric(4,0) NOT NULL,
	PRIMARY KEY (MovieID, PersonID, AwardsName, Category) 
);

CREATE TABLE character(
	charid integer PRIMARY KEY,
	PersonID numeric(7,0) NOT NULL REFERENCES Person(PersonID) ON DELETE SET NULL ON UPDATE CASCADE,
	MovieID numeric(7,0) NOT NULL REFERENCES Movie(MovieID) ON DELETE CASCADE ON UPDATE CASCADE,
	CharName varchar(20) NOT NULL,
	CharDescr varchar(400) 
);

CREATE TABLE Quotes(
	QuoteNo numeric (7,0) PRIMARY KEY,
	charid integer NOT NULL REFERENCES character(charid) ON DELETE CASCADE ON UPDATE CASCADE,
	Quote varchar(400) NOT NULL
);

--trigger

create or replace function calculate_rating() returns trigger as $void$
DECLARE
	r movie%rowtype;
	count integer;
	total numeric;
	rating  numeric (10,2);
	movieid decimal (7,0);
	avgrat decimal (10,2);
BEGIN
	IF (TG_OP = 'INSERT') THEN
		rating := new.rating;
		select * into r from movie where movie.movieid=new.movieid;
		total := r.rating * r.ratecount;
		r.ratecount := r.ratecount+1;
		r.rating := (total + new.rating) / r.ratecount;
		UPDATE movie SET rating=r.rating where movie.movieid=new.movieid;
		UPDATE movie SET ratecount=r.ratecount where movie.movieid=new.movieid;	
		delete from watchlist where watchlist.movieid=new.movieid AND watchlist.userid=new.UID;
	ELSIF (TG_OP = 'UPDATE') THEN 
		movieid := new.movieid;
		rating := new.rating;
		select * into r from movie where movie.movieid=new.movieid;
		total := r.rating*r.ratecount;
		r.rating := (total+new.rating-old.rating)/r.ratecount;
		UPDATE movie SET rating=r.rating where movie.movieid=new.movieid;
	END IF;
	RETURN NULL;
END; $void$ LANGUAGE plpgsql;

create trigger ratingtrig after insert or update on rating for each row execute procedure calculate_rating();




-- User Data
insert into "User" values (1,'Akash Gajjar','akashgajjar@live.com','dummypasswd','Mehsana','M');
insert into "User" values (2,'Jeel Prajapati','jeelprajapatijp@gmail.com','iamchotu','Gandhinagar','M');
insert into "User" values (3,'Pratik Pajapati','pratikthepapi@gmail.com','beyou','Gandhinagar','M');
insert into "User" values (4,'Jeel Santoki','jeelsantoki@comcast.net','kohliroxx','Ahmedabad','M');
insert into "User" values (5,'Kaustuk Rathod','kaustukrathod@gmail.com','youknowwho','Bhavnagar','M');
insert into "User" values (6,'Priyanka Chopra','pcdaddygirl@bollywood.net','quanticoroxx','Gandhinagar','F');
insert into "User" values (7,'John Doe','johndoe@dummy.com','iamnoone','Bhopal','T');
insert into "User" values (8,'Romil Shah','romilshah@committee.com','romudchomu','Bhavnagar','M');
insert into "User" values (9,'Nehal Vasava','nate19@stud.com','imdstud','Vadodra','M');
insert into "User" values (10,'Rahul Patel','rahulpatel@gmail.com','rahulp','Surat','M');
insert into "User" values (11,'Rutwik Sheth','rutwikprabhu@heaven.com','omshanti','Ahmedabad','M');
insert into "User" values (12,'Kirti Tapodhan','ktyy@nift.com','ktstud','Bhavnagar','M');
insert into "User" values (13,'Gaurav Lad','gabbalad@gmail.com','ladbhai','Surat','M');
insert into "User" values (14,'Chirang Malviya','chiru@synapse.com','convenerroxx','Ahmedabad','M');
insert into "User" values (15,'Angel Priya','priyaangel@gmail.com','iamangel','Gandhinagar','F');
insert into "User" values (16,'Kavi Prajapati','kaviprajapati@jm.edu','kaviprarthi','Mehsana','M');
insert into "User" values (17,'Akshay Maru','akshaymaru@ak.com','maruaksay','Bhavnagar','M');
insert into "User" values (18,'Pratik Bambhania','pratikb@dexter.evil','prk9090','Bhavnagar','M');
insert into "User" values (19,'Kunal Khatri','khatrikunalk@gmail.com','iamkunal','Ahmedabad','M');
insert into "User" values (20,'Byom Permur','venomv@northkorea.com','kimjongbyom','Gandhinagar','M');
insert into "User" values (21,'Darshan Makwana','litsoluchan@dank.com','opisalegend','Gandhinagar','M');


-- person Data
set datestyle=dmy;
insert into person values (1,'Frank Darabont','M','28/01/1959','France');
insert into person values (2,'Stephan King','M','21/08/1947','Maine');
insert into person values (3,'Tim Robbins','M','16/10/1958','California');
insert into person values (4,'Morgan Freeman','M','01/06/1938','Tenessee');
insert into person values (5,'Bob Gunton','M','15/11/1945','California');
insert into person values (6,'Francis Ford Coppola','M','07/04/1939','Michigan');
insert into person values (7,'Mario Puzo','M','15/10/1920','NY');
insert into person values (8,'Marlon Brando','M','03/04/1924','Nebraska');
insert into person values (9,'AL Pacino','M','25/04/1940','NY');
insert into person values (10,'James Cann','M','26/03/1940','NY');
insert into person values (11,'Robert De Niro','M','17/08/1943','NY');
insert into person values (12,'Robert Duwall','M','05/01/1931','California');
insert into person values (13,'Christopher Nolan','M','30/07/1970','London');
insert into person values (14,'Johnathan Nolan','M','06/06/1976','London');
insert into person values (15,'Christian Bale','M','30/01/1974','Wales');
insert into person values (16,'Heath Ledger','M','04/04/1979','Western Australia');
insert into person values (17,'Aaron Eckhart','M','12/04/1968','Calfornia');
insert into person values (18,'Sidney Lumet','M','25/06/1925','Pennsynvania');
insert into person values (19,'Reginald Rose','M','10/12/1920','NY');
insert into person values (20,'Henry Fonda','M','16/05/1905','Nebraska');
insert into person values (21,'Lee J. Cobb','M','08/12/1911','NY');
insert into person values (22,'Martin Balsam','M','04/11/1919','NY');
insert into person values (23,'Steven Spielberg','M','18/12/1946','Ohio');
insert into person values (24,'Thomas Keneally','M','07/10/1935','Wales');
insert into person values (25,'Liam Neeson','M','07/06/1952','Northern Ireland');
insert into person values (26,'Ralph Fiennes','M','22/12/1962','Suffolk');
insert into person values (27,'Ben Kingsley','M','31/12/1943','Yorkshire');
insert into person values (28,'Quintin Tarantino','M','27/03/1963','Tennessee');
insert into person values (29,'Roger Awary','M','23/08/1964','Canada');
insert into person values (30,'John Travolta','M','19/03/1943','NJ');
insert into person values (31,'Uma Thurman','F','29/04/1970','Masachussets');
insert into person values (32,'Samuel L Jackson','M','21/12/1948','Washington');
insert into person values (33,'Peter Jackson','M','21/10/1961','New Zealand');
insert into person values (34,'JRR Talkien','M','03/01/1892','South Africa');
insert into person values (35,'Elijah Wood','M','28/01/1981','Iowa');
insert into person values (36,'Viggo Motrensen','M','20/10/1958','NY');
insert into person values (37,'Ian McKellen','M','25/05/1939','England');
insert into person values (38,'Sergoi Leone','M','03/01/1929','Itly');
insert into person values (39,'Luciano Vincenzoni','M','07/03/1926','Itly');
insert into person values (40,'Clint Eastwood','M','31/05/1930','California');
insert into person values (41,'Eli Wallach','M','07/12/1915','NY');
insert into person values (42,'Lee Vann Cleef','M','09/01/1925','New Jeresy');
insert into person values (43,'David Fincher','M','28/10/1962','Colorado');
insert into person values (44,'Chuck Palaniuk','M','21/02/1962','Washington');
insert into person values (45,'Brad Pitt','M','18/12/1963','Oklahoma');
insert into person values (46,'Edward Nortan','M','18/08/1969','Masachuettes');
insert into person values (47,'Meat Loaf','M','27/09/1947','Texas');
insert into person values (48,'Orlando Bloom','M','13/01/1977','England');
insert into person values (49,'Robert Zemeckis','M','14/05/1952','Illinois');
insert into person values (50,'Winston Groom','M','01/06/1944','Washington');
insert into person values (51,'Tom Hanks','M','09/07/1956','California');
insert into person values (52,'Robin Wright','F','08/04/1966','Texas');
insert into person values (53,'Gary Sinise','M','17/03/1955','Illinois');
insert into person values (54,'Irvin Kershner','M','29/04/1923','Pannseylvania');
insert into person values (55,'Ligh Brackett','M','07/12/1915','California');
insert into person values (56,'Mark Hamill','M','25/08/1951','California');
insert into person values (57,'Harrison Ford','M','13/07/1942','Illinois');
insert into person values (58,'Carrie Fisher','F','21/08/1956','California');
insert into person values (59,'Leonardo DiCaprio','M','11/11/1974','California');
insert into person values (60,'Joseph Gordan-Levitt','M','17/02/1981','California');
insert into person values (61,'Ellen Page','F','21/02/1970','Canada');
insert into person values (62,'Milos Forman','M','18/02/1932','Czechoslovakia');
insert into person values (63,'Lawrence Hauben','M','03/03/1931','NY');
insert into person values (64,'Jack Nicholson','M','22/04/1937','New Jeresy');
insert into person values (65,'Louise Fletcher','F','22/07/1934','Alabama');
insert into person values (66,'Michael Berryman','M','04/09/1948','California');
insert into person values (67,'Martin Scoresese','M','17/11/1942','NY');
insert into person values (68,'Nicholas Pileggi','M','22/02/1933','NY');
insert into person values (69,'Ray Liotta','M','18/12/1954','New Jeresy');
insert into person values (70,'Joe Peaci','M','09/02/1943','New Jeresy');
insert into person values (71,'Lana Wachowski','F','21/06/1965','Illinois');
insert into person values (72,'Lilly Wachowski','F','29/12/1967','Illinois');
insert into person values (73,'Keanu Reeves','M','02/09/1964','Lebanon');
insert into person values (74,'Lawrence Fishburne','M','30/07/1961','Georgia');
insert into person values (75,'Carrie-Anne Moss','F','21/08/1967','Canada');
insert into person values (76,'Akira Kurisawa','M','23/03/1910','Japan');
insert into person values (77,'Shinobu Hashimoto','M','18/04/1918','Japan');
insert into person values (78,'Toshiro Mifune','M','01/04/1920','China');
insert into person values (79,'Takashi Shimura','M','12/03/1905','Japan');
insert into person values (80,'Taiko Chusima','F','07/02/1926','Japan');
insert into person values (81,'George Lucas','M','14/04/1944','California');


--movie Data
insert into movie values (1,'The Shawshank Redemption','Drama','14/08/2014',2,'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',28341469,0,142,1,0);
insert into movie values (2,'The Godfather','Crime','24/03/2017',7,'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.',134966411,0,175,6,0);
insert into movie values (3,'The Godfather: Part II','Crime','20/12/2014',7,'The early life and career of Vito Corleone in 1920s New York is portrayed while his son, Michael, expands and tightens his grip on the family crime syndicate.',57300000,0,202,6,0);
insert into movie values (4,'The Dark Knight','Action','18/07/2014',14,'When the menace known as the Joker emerges from his mysterious past, he wreaks havoc and chaos on the people of Gotham, the Dark Knight must accept one of the greatest psychological and physical tests of his ability to fight injustice.',534858444,0,152,13,0);
insert into movie values (5,'12 Angry Men','Drama','01/04/2017',19,'A jury holdout attempts to prevent a miscarriage of justice by forcing his colleagues to reconsider the evidence.',350000,0,96,18,0);
insert into movie values (6,'Schindlers List','Biography','04/02/2016',23,'In German-occupied Poland during World War II, Oskar Schindler gradually becomes concerned for his Jewish workforce after witnessing their persecution by the Nazi Germans.',96067170,0,195,23,0);
insert into movie values (7,'Pulp Fiction','Crime','14/08/2015',28,'The lives of two mob hit men, a boxer, a gangsters wife, and a pair of diner bandits intertwine in four tales of violence and redemption.',107929607,0,178,28,0);
insert into movie values (9,'LOTR - The Return of the King','Adventure','17/12/2015',34,'Gandalf and Aragorn lead the World of Men against Saurons army to draw his gaze from Frodo and Sam as they approach Mount Doom with the One Ring',377845905,0,254,33,0);
insert into movie values (10,'The Good,the Bad and the Ugly','Western','29/12/2016',38,'A bounty hunting scam joins two men in an uneasy alliance against a third in a race to find a fortune in gold buried in a remote cemetery.',6100000,0,179,38,0);
insert into movie values (11,'Fight Club','Drama','15/10/2015',43,'An insomniac office worker, looking for a way to change his life, crosses paths with a devil-may-care soap maker, forming an underground fight club that evolves into something much, much more.',37030102,0,139,43,0);
insert into movie values (12,'LOTR: Fellowship of the Ring','Adventure','19/12/2016',34,'A meek Hobbit from the Shire and eight companions set out on a journey to destroy the powerful One Ring and save Middle Earth from the Dark Lord Sauron.',315544750,0,180,33,0);
insert into movie values (13,'Forrest Gump','Romance','06/07/2014',49,'JFK, LBJ, Vietnam, Watergate, and other history unfold through the perspective of an Alabama man with an IQ of 75.',330252182,0,142,49,0);
insert into movie values (14,'Star Wars: Episode V','Action','20/06/2014',55,'After the rebels are overpowered by the Empire on their newly established base, Luke Skywalker begins Jedi training with Yoda. His friends accept shelter from a questionable ally as Darth Vader hunts them in a plan to capture Luke.',290475067,0,124,54,0);
insert into movie values (15,'Inception','Adventure','16/10/2015',13,'A thief, who steals corporate secrets through use of dream-sharing technology, is given the inverse task of planting an idea into the mind of a CEO.',292576195,0,150,13,0);
insert into movie values (16,'LOTR: The Two Towers','Adventure','16/09/2017',34,'While Frodo and Sam edge closer to Mordor with the help of the shifty Gollum, the divided fellowship makes a stand against Saurons new ally, Saruman, and his hordes of Isengard.',342551365,0,180,33,0);
insert into movie values (17,'One Flew Over the Cuckoos Nest','Drama','19/11/2016',64,'A criminal pleads insanity after getting into trouble again and once in the mental institution rebels against the oppressive nurse and rallies up the scared patients.',112000000,0,134,62,0);
insert into movie values (18,'Goofellas','Crime','21/08/2014',67,'The story of Henry Hill and his life through the teen years into the years of mafia, covering his relationship with his wife Karen Hill and his Mob partners Jimmy Conway and Tommy DeVito in the Italian-American crime syndicate.',46836394,0,149,67,0);
insert into movie values (19,'The Matrix','Action','31/03/2017',72,'A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.',171479930,0,139,71,0);
insert into movie values (20,'Seven Samurai','Adventure','19/11/2016',76,'A poor village under attack by bandits recruits seven unemployed samurai to help them defend themselves.',269061457,0,220,77,0);
insert into movie values (8,'Star Wars: A New Hope','Adventure','25/5/2017',81,'Luke Skywalker joins forces with a Jedi Knight, a cocky pilot, a Wookiee, and two droids to save the galaxy from the Empires world-destroying battle-station, while also attempting to rescue Princess Leia from the evil Darth Vader.',322740140,0,121,81,0);



--char Data
insert into character values (1, 3, 1, 'Andy Dufresne', 'Andy Dufresne served as vice president of a Portland, Maine bank before being erroneously convicted of the murder of his wife and her lover, a golf pro, and was sentenced to two life terms. He was sent to Shawshank Prison in 1947. Dufresne was the frequent target of sexual abuse from a prison clique known as the Sisters');
insert into character values (2, 4, 1, 'Ellis Boyd', 'Convicted murderer Ellis Boyd Redding was sent to Shawshank Prison in Maine in 1927. He was given the nickname "Red" for his Irish heritage and as a play on his last name. Redding had a reputation for smuggling items into prison such as playing cards, whiskey, marijuana, and posters.');
insert into character values (3, 5, 1, 'Warden Norton', 'The Warden of Shawshank Prison. He believes in two things: discipline and the bible. Ironically, his interest in the bible manifests itself in selfish and evil ways. He takes advantage of his prisoners and is not incapable of having those who pose a threat murdered. ');
insert into character values (4, 8, 2, 'Don Vito Corleone', 'Vito is the head of the Corleone crime family, the most powerful Mafia family in the New York City.');
insert into character values (5, 9, 2, 'Michael Corleone', 'Michael is the youngest son of Don Vito Corleone.');
insert into character values (6, 10, 2, 'Sonny Corleone', 'The eldest son of Don Vito Corleone.');
insert into character values (7, 9, 3, 'Michael', 'Michael is the youngest son of Don Vito Corleone.');
insert into character values (8, 11, 3, 'Vito Corleone ', 'Vito is the head of the Corleone crime family, the most powerful Mafia family in the New York City.');
insert into character values (9, 12, 3, 'Tom Hagen', 'Tom Hagen was orphaned as a child and spent an entire winter on the streets of New York. He then met Sonny, who brought him home with him.');
insert into character values (10, 15, 4, 'Bruce Wayne', 'Bruce Wayne is the billionaire son of Thomas and Martha Wayne and CEO of Wayne Enterprises. He is also the secret identity of the crime-fighting Vigilante known as the Batman.');
insert into character values (11, 16, 4, 'Joker', 'Appearing to be the most evil, deranged, and flat out psychotic killer of all comic book villains, The Joker is the primary antagonist of Batman.');
insert into character values (12, 17, 4, 'Harvey Dent', 'He is the Harvey Two face');
insert into character values (13, 22, 5, 'Juror 1', 'one of 12 men');
insert into character values (14, 20, 5, 'Juror 8 ', 'one of 12 men');
insert into character values (15, 21, 5, 'Juror 3', 'one of 12 men');
insert into character values (16, 25, 6, 'Oskar Schindler', 'Oskar Schindler was a German industrialist, former member of the Nazi Party and possibly the most famous "Righteous Gentile" who is credited with saving as many as 1,200 Jews during the Holocaust');
insert into character values (17, 27, 6, 'Itzhak Stern', 'performed by Ben Kingsley');
insert into character values (18, 26, 6, 'Amon Goeth ', 'Played by Ralph Fiennes, Amon Goeth was an Austrian SS-Hauptsturmf?hrer (captain) and the commandant of the Krak?w-Pasz?w concentration camp in Pasz?w in German-occupied Poland for most of the camps existence during World War II. ');
insert into character values (19, 30, 7, 'Vincent Vega', 'Came from Amsterdam, Crime underboss, falls in love with his bosss wife. ');
insert into character values (20, 31, 7, 'Mia Wallace', 'Marcellus Wallaces wife');
insert into character values (21, 32, 7, 'Jules Winnfield', 'Whether he was working for gang boss Marsellus Wallace or not, for years one thing that gangster Jules Winnfield openly recited was a version of the Biblical chapter Ezekiel 25:17 to his victims before he killed them.');
insert into character values (22, 35, 8, 'Frodo', 'Mr. Proudfoot was a grumpy old gaffer, who minded his own business and tending his garden. However, he enjoyed Gandalfs fireworks and only expressed his disapproval when his wife arrived. He was present at Bilbos Farewell Party. He later met the four hobbits as they returned home from their journey');
insert into character values (23, 36, 8, 'Aragorn', 'Frodo Baggins is a Hobbit of the Shire, born on September 22nd in the year 2968 (1368 Shire Reckoning) of the Third Age of Middle-earth (using J.R.R. Tolkiens literary timeline).');
insert into character values (24, 37, 8, 'Bilbo', 'Bilbo Baggins is a Hobbit of the Shire, born on September 22nd in the year 2890 (1290 Shire Reckoning) of the Third Age of Middle-earth (using J.R.R. Tolkiens literary timeline).');
insert into character values (25, 41, 9, 'Tuco', 'Tuco Benedicto Pacifico Juan Maria Ramirez is a Mexican bandit and the protagonist of "The Good, the Bad and the Ugly".');
insert into character values (26, 40, 9, 'Blondie', '"The Man with No Name" is a man of mystery who travels the country on his mule or horse. His usual ventures often involve getting a money reward or helping people.');
insert into character values (27, 42, 9, 'Sentenza', 'The Bad, a ruthless, unfeeling and sociopathic mercenary named "Angel Eyes" (Sentenza - Sentence - in the original script and the Italian version), who always finishes a job hes paid for (which is usually finding...and killing people).');
insert into character values (28, 45, 10, 'Tyler Durden', 'This is what he says about himself, which in turn says it all?');
insert into character values (29, 46, 10, 'The Narrator', 'The Narrator ');
insert into character values (30, 47, 10, 'Robert Bob Paulsen', 'His name was Robert Paulson.');
insert into character values (31, 35, 11, 'Frodo', 'Mr. Proudfoot was a grumpy old gaffer, who minded his own business and tending his garden. However, he enjoyed Gandalfs fireworks and only expressed his disapproval when his wife arrived. He was present at Bilbos Farewell Party. He later met the four hobbits as they returned home from their journey');
insert into character values (32, 37, 11, 'Bounder', 'Bilbo Baggins is a Hobbit of the Shire, born on September 22nd in the year 2890 (1290 Shire Reckoning) of the Third Age of Middle-earth (using J.R.R. Tolkiens literary timeline).');
insert into character values (33, 48, 11, 'Legolas', 'Legolas is an Elf who was part of the Fellowship of the Ring in the Third Age.');
insert into character values (34, 51, 12, 'Forrest Gump', 'Forrest Gump grew up in Greenbow, Alabama and became good friends with Jenny Curran. They parted ways after college when Forrest joined the army.');
insert into character values (35, 52, 12, 'Jenny Curran', 'Young Jenny Curran ');
insert into character values (36, 53, 12, 'Bus Recruit ', 'Bus Recruit ');
insert into character values (37, 56, 13, 'Luke Skywalker ', 'He is born to Padm? Amidala, moments before his twin sister, Leia. His mother dies in childbirth. Jedi Masters Yoda and Obi-Wan Kenobi hide the children to prevent the newly declared Galactic Empire and its ruler, Palpatine, using them to gain greater control over the galaxy. ');
insert into character values (38, 57, 13, 'Han Solo', 'At the beginning of A New Hope, Solo and Chewbacca are notorious smugglers. However, during one Kessel Run, the Imperial Navy intercepts and boards their ship, forcing Solo to jettison his cargo to avoid arrest. This results in a large and mounting debt to his former employer, Jabba the Hutt, who places a bounty on Solos capture.');
insert into character values (39, 58, 13, 'Princess Leia', 'Leia Organa is the deuteragonist of the Star Wars franchise. She is Lukes younger sister.');
insert into character values (40, 59, 14, 'Cobb','Cobb is an extractor - he enters peoples dreams, steals their secrets, and sells them to their competitors. He used to have a legal job involving extraction and dream sharing, but is currently a wanted man and must resort to other means.');
insert into character values (41, 60, 14, 'Arthur', 'Arthur is Cobbs right hand man, and apparently closest friend. They have known each other since before the tragic death of Cobbs wife. He lives in America, but travels the world with Cobb.');
insert into character values (42, 61, 14, 'Ariadne', 'Ariadne is a student of architecture in France. She meets Cobb through one of her teachers, who is Cobbs father-in-law. After a few tests, she is brought into the team as their official Architect.');
insert into character values (43, 35, 15, 'Frodo', 'Mr. Proudfoot was a grumpy old gaffer, who minded his own business and tending his garden. However, he enjoyed Gandalfs fireworks and only expressed his disapproval when his wife arrived. He was present at Bilbos Farewell Party. He later met the four hobbits as they returned home from their journey');
insert into character values (44, 37, 15, 'Gandalf', 'Gandalf the Grey (also known as Mithrandir and Ol?rin) is a wise wizard who was sent to Middle-Earth around year 1000 in the Third Age, more than 2000 years before the setting of The Lord of the Rings, to help the free peoples fight the evil Sauron, along with Saruman the White (who later abandoned his task) and three other wizards.');
insert into character values (45, 36, 15, 'Aragorn', 'Aragorn II was the son of Arathorn and Gilraen, and an only child. He was born on March 1st, 2931 of the Third Age, he was the thirty-ninth generation of the heirs of Isildur');
insert into character values (46, 64, 16, 'R.P. McMurphy', 'Randle Patrick McMurphy, or simply R.P., is frequently on the wrong side of the law. Arrested for battery and gambling, McMurphy dodges a short prison sentence to a work camp by feigning insanity.');
insert into character values (47, 65, 16, 'Nurse Ratched', 'Named fifth worst movie villain, by the American Film Institute, Nurse Ratched is a cold, dictatorial nurse who controls a psych ward with an iron fist.');
insert into character values (48, 66, 16, 'Ellis', 'Ellis');
insert into character values (49, 11, 17, 'James Conway', 'James "Jimmy" Conway was a fictional character played by Robert De Niro in the film Goodfellas. The character was based directly on the real-life gangster Jimmy Burke.');
insert into character values (50, 69, 17, 'Henry Hill', 'Henry Hill grew up in a poor working class family in Brownsville, Brooklyn, then a largely Jewish-Italian neighborhood. His father Henry Sr. was an electrician of Irish descent, and his mother Carmella was of Sicilian descent.');
insert into character values (51, 70, 17, 'Tommy DeVito ', 'His relative Rosario DeSimone was the boss over Los Angeles, San Diego and Las Vegas from 1931 until his death in 1946. Tommys uncle, Frank DeSimone, was a criminal attorney-turned-mobster');
insert into character values (52, 73, 18, 'Neo', 'The word Neo is an anagram not only of the word one, but also for eon. Neo is also Greek for new, suggesting messianic overtones for his mission in the Matrix. In Gnosticism eons, or aeons, is a kind of superhuman being with supernatural powers.');
insert into character values (53, 74, 18, 'Morpheus ', 'Morpheus is the captain of the Nebuchadnezzar, which is a hovercraft of the human forces of the last human city, Zion, in a devastated world where most humans are grown by sentient Machines and kept imprisoned in the Matrix, a virtual computer-generated world. Morpheus was once a human living inside the Matrix until he was freed earlier in life.');
insert into character values (54, 75, 18, 'Trinity', 'Like the series other principal characters, Trinity is a computer programmer and a hacker who has escaped from the Matrix, a sophisticated computer program in which most of the human race is imprisoned.');
insert into character values (55, 78, 19, 'Kikuchiyo ', 'Kikuchiyo is the 7th samurai recruited. Hes turned down at first, as hes the only one of the seven whos not really a samurai, but is eventually accepted by the group after trailing them for quite a while.');
insert into character values (56, 79, 19, 'Kambei Shimada ', 'Kambei Shimada');
insert into character values (57, 80, 19, 'Shino', 'Shino');
insert into character values (58, 56, 20, 'Luke Skywalker', 'He is born to Padm? Amidala, moments before his twin sister, Leia. His mother dies in childbirth. Jedi Masters Yoda and Obi-Wan Kenobi hide the children to prevent the newly declared Galactic Empire and its ruler, Palpatine, using them to gain greater control over the galaxy.');
insert into character values (59, 57, 20, 'Han Solo', 'At the beginning of A New Hope, Solo and Chewbacca are notorious smugglers. However, during one Kessel Run, the Imperial Navy intercepts and boards their ship, forcing Solo to jettison his cargo to avoid arrest. This results in a large and mounting debt to his former employer, Jabba the Hutt, who places a bounty on Solos capture.');
insert into character values (60, 58, 20, 'Princess Leia Organa', 'Leia Organa is the deuteragonist of the Star Wars franchise. She is Lukes younger sister.');


-- movieAwards Data
insert into movieawards values('Oscar',4,'BestMovie',2014);
insert into movieawards values('GoladenGlobe',1,'BestMovie',2014);
insert into movieawards values('filmFare',4,'BestMovie',2014);
insert into movieawards values('Oscar',3,'BestMusic',2014);
insert into movieawards values('GoladenGlobe',4,'BestMusic',2014);
insert into movieawards values('filmFare',14,'BestMusic',2014);
insert into movieawards values('Oscar',4,'BestScreenPlay',2014);
insert into movieawards values('GoladenGlobe',1,'BestScreenPlay',2014);
insert into movieawards values('filmFare',14,'BestScreenPlay',2014);
insert into movieawards values('Oscar',15,'BestMovie',2015);
insert into movieawards values('GoladenGlobe',7,'BestMovie',2015);
insert into movieawards values('filmFare',9,'BestMovie',2015);
insert into movieawards values('Oscar',11,'BestMusic',2015);
insert into movieawards values('GoladenGlobe',7,'BestMusic',2015);
insert into movieawards values('filmFare',9,'BestMusic',2015);
insert into movieawards values('Oscar',7,'BestScreenPlay',2015);
insert into movieawards values('GoladenGlobe',11,'BestScreenPlay',2015);
insert into movieawards values('filmFare',7,'BestScreenPlay',2015);
insert into movieawards values('Oscar',12,'BestMovie',2016);
insert into movieawards values('GoladenGlobe',17,'BestMovie',2016);
insert into movieawards values('filmFare',12,'BestMovie',2016);
insert into movieawards values('Oscar',10,'BestMusic',2016);
insert into movieawards values('GoladenGlobe',20,'BestMusic',2016);
insert into movieawards values('filmFare',12,'BestMusic',2016);
insert into movieawards values('Oscar',17,'BestScreenPlay',2016);
insert into movieawards values('GoladenGlobe',20,'BestScreenPlay',2016);
insert into movieawards values('filmFare',10,'BestScreenPlay',2016);
insert into movieawards values('Oscar',2,'BestMovie',2017);
insert into movieawards values('GoladenGlobe',16,'BestMovie',2017);
insert into movieawards values('filmFare',19,'BestMovie',2017);
insert into movieawards values('Oscar',5,'BestMusic',2017);
insert into movieawards values('GoladenGlobe',8,'BestMusic',2017);
insert into movieawards values('filmFare',2,'BestMusic',2017);
insert into movieawards values('Oscar',16,'BestScreenPlay',2017);
insert into movieawards values('GoladenGlobe',19,'BestScreenPlay',2017);
insert into movieawards values('filmFare',2,'BestScreenPlay',2017);


--personAwards
insert into personawards values('Oscar','Best Direct',1,1,2014);
insert into personawards values('Oscar','Best StoryWriter',14,4,2014);
insert into personawards values('Oscar','Best Act',11,3,2014);
insert into personawards values('Oscar','Best SupportingAct',60,14,2014);
insert into personawards values('FilmFare','Best StoryWriter',67,18,2014);
insert into personawards values('FilmFare','Best Act',74,18,2014);
insert into personawards values('FilmFare','Best SupportingAct',3,1,2014);
insert into personawards values('StarAwards','Best Direct',13,4,2014);
insert into personawards values('StarAwards','Best StoryWriter',55,14,2014);
insert into personawards values('StarAwards','Best Act',12,3,2014);
insert into personawards values('Oscar','Best Direct',33,9,2015);
insert into personawards values('Oscar','Best StoryWriter',28,7,2015);
insert into personawards values('Oscar','Best Act',40,9,2015);
insert into personawards values('Oscar','Best SupportingAct',36,15,2015);
insert into personawards values('FilmFare','Best StoryWriter',28,7,2015);
insert into personawards values('FilmFare','Best Act',35,11,2015);
insert into personawards values('FilmFare','Best SupportingAct',41,9,2015);
insert into personawards values('StarAwards','Best Direct',43,11,2015);
insert into personawards values('StarAwards','Best StoryWriter',13,15,2015);
insert into personawards values('StarAwards','Best Act',31,7,2015);
insert into personawards values('Oscar','Best Direct',38,16,2016);
insert into personawards values('Oscar','Best StoryWriter',64,17,2016);
insert into personawards values('Oscar','Best Act',56,20,2016);
insert into personawards values('Oscar','Best SupportingAct',47,10,2016);
insert into personawards values('FilmFare','Best StoryWriter',34,12,2016);
insert into personawards values('FilmFare','Best Act',56,20,2016);
insert into personawards values('FilmFare','Best SupportingAct',69,17,2016);
insert into personawards values('StarAwards','Best Direct',33,12,2016);
insert into personawards values('StarAwards','Best StoryWriter',34,16,2016);
insert into personawards values('StarAwards','Best Act',45,10,2016);
insert into personawards values('Oscar','Best Direct',6,2,2017);
insert into personawards values('Oscar','Best StoryWriter',81,8,2017);
insert into personawards values('Oscar','Best Act',66,16,2017);
insert into personawards values('Oscar','Best SupportingAct',80,19,2017);
insert into personawards values('FilmFare','Best StoryWriter',19,5,2017);
insert into personawards values('FilmFare','Best Act',66,16,2017);
insert into personawards values('FilmFare','Best SupportingAct',10,2,2017);
insert into personawards values('StarAwards','Best Direct',71,19,2017);
insert into personawards values('StarAwards','Best StoryWriter',19,5,2017);
insert into personawards values('StarAwards','Best Act',35,8,2017);




--WATCH LIST
insert into watchlist values(1,5);
insert into watchlist values(1,1);
insert into watchlist values(1,13);
insert into watchlist values(1,17);
insert into watchlist values(2,3);
insert into watchlist values(2,7);
insert into watchlist values(3,11);
insert into watchlist values(5,5);
insert into watchlist values(5,16);
insert into watchlist values(5,18);
insert into watchlist values(5,20);
insert into watchlist values(6,13);
insert into watchlist values(6,3);
insert into watchlist values(7,3);
insert into watchlist values(7,19);
insert into watchlist values(8,12);
insert into watchlist values(9,7);
insert into watchlist values(9,10);
insert into watchlist values(9,20);
insert into watchlist values(10,2);
insert into watchlist values(10,4);
insert into watchlist values(10,5);
insert into watchlist values(10,7);
insert into watchlist values(10,8);
insert into watchlist values(10,11);
insert into watchlist values(10,13);
insert into watchlist values(10,16);
insert into watchlist values(10,17);
insert into watchlist values(10,18);
insert into watchlist values(10,20);
insert into watchlist values(11,3);
insert into watchlist values(11,7);
insert into watchlist values(11,16);
insert into watchlist values(12,12);
insert into watchlist values(13,3);
insert into watchlist values(13,14);
insert into watchlist values(14,9);
insert into watchlist values(15,4);
insert into watchlist values(15,8);
insert into watchlist values(15,14);
insert into watchlist values(15,18);
insert into watchlist values(16,1);
insert into watchlist values(16,7);
insert into watchlist values(16,17);
insert into watchlist values(18,1);
insert into watchlist values(18,2);
insert into watchlist values(18,3);
insert into watchlist values(18,5);
insert into watchlist values(18,7);
insert into watchlist values(18,11);
insert into watchlist values(18,13);
insert into watchlist values(18,17);
insert into watchlist values(18,19);
insert into watchlist values(19,19);
insert into watchlist values(20,2);
insert into watchlist values(20,6);
insert into watchlist values(20,9);
insert into watchlist values(20,12);
insert into watchlist values(20,13);
insert into watchlist values(20,20);

--production house
insert into productionhouse values ('red chilli',12);
insert into productionhouse values ('paramount pictures',3);
insert into productionhouse values ('20th Century Fox',35);
insert into productionhouse values ('star fox',64);
insert into productionhouse values ('Yash Raj Films',12);
insert into productionhouse values ('Universal Pictures',78);
insert into productionhouse values ('Sony Pictures',78);
insert into productionhouse values ('Walt Disney',64);
insert into productionhouse values ('Dharma Productions',17);
insert into productionhouse values ('Balaji Pictures',64);
insert into productionhouse values ('Reliance Studio',12);


--pruduced
insert into produced values ('red chilli',1);
insert into produced values ('Dharma Productions',1);
insert into produced values ('Universal Pictures',1);
insert into produced values ('star fox',2);
insert into produced values ('paramount pictures',2);
insert into produced values ('20th Century Fox',2);
insert into produced values ('Sony Pictures',3);
insert into produced values ('Reliance Studio',3);
insert into produced values ('paramount pictures',4);
insert into produced values ('Walt Disney',4);
insert into produced values ('Yash Raj Films',5);
insert into produced values ('Balaji Pictures',5);
insert into produced values ('red chilli',5);
insert into produced values ('Dharma Productions',6);
insert into produced values ('red chilli',6);
insert into produced values ('Reliance Studio',7);
insert into produced values ('Universal Pictures',7);
insert into produced values ('20th Century Fox',9);
insert into produced values ('Yash Raj Films',9);
insert into produced values ('Balaji Pictures',9);
insert into produced values ('Balaji Pictures',10);
insert into produced values ('Dharma Productions',10);
insert into produced values ('red chilli',11);
insert into produced values ('Yash Raj Films',11);
insert into produced values ('Universal Pictures',11);
insert into produced values ('Balaji Pictures',12);
insert into produced values ('Sony Pictures',12);
insert into produced values ('paramount pictures',13);
insert into produced values ('20th Century Fox',13);
insert into produced values ('Walt Disney',14);
insert into produced values ('Sony Pictures',14);
insert into produced values ('Universal Pictures',14);
insert into produced values ('Yash Raj Films',15);
insert into produced values ('Reliance Studio',15);
insert into produced values ('star fox',15);
insert into produced values ('Walt Disney',16);
insert into produced values ('red chilli',16);
insert into produced values ('Balaji Pictures',17);
insert into produced values ('Dharma Productions',17);
insert into produced values ('Sony Pictures',18);
insert into produced values ('Dharma Productions',18);
insert into produced values ('paramount pictures',19);
insert into produced values ('star fox',19);
insert into produced values ('star fox',20);
insert into produced values ('20th Century Fox',20);
insert into produced values ('Reliance Studio',8);
insert into produced values ('20th Century Fox',8);
insert into produced values ('Sony Pictures',8);


--quotes
insert into quotes values (1,2,'Andy Dufresne - who crawled through a river of shit and came out clean on the other side.');
insert into quotes values (2,1,'Remember Red, hope is a good thing, maybe the best of things, and no good thing ever dies.');
insert into quotes values (3,1,'I guess it comes down a simple choice: Get busy living, or get busy dying.');
insert into quotes values (4,5,'Only dont tell me youre innocent. Because it insults my intelligence and makes me very angry.');
insert into quotes values (5,4,'We have known each other many years, but this is the first time youve come to me for counsel or for help. I cant remember the last time you invited me to your house for a cup of coffee, even though my wife is godmother to your only child. But lets be frank here. You never wanted my friendship. And you feared to be in my debt.');
insert into quotes values (6,6,'You touch my sister again, Ill kill you.');
insert into quotes values (7,7,'My father taught me many things here - he taught me in this room. He taught me: keep your friends close, but your enemies closer.');
insert into quotes values (8,8,'Michael, your father loves you very much. Very much.');
insert into quotes values (9,7,'I trust these men with my life, Senator. To ask them to leave would be an insult.');
insert into quotes values (10,12,'You either die a hero or you live long enough to see yourself become the villain.');
insert into quotes values (11,11,'Dont talk like one of them. Youre not! Even if youd like to be. To them, youre just a freak, like me! They need you right now, but when they dont, theyll cast you out, like a leper! You see, their morals, their code, its a bad joke. Dropped at the first sign of trouble. Theyre only as good as the world allows them to be. Ill show you. ');
insert into quotes values (12,10,'Criminals arent complicated, Alfred. Just have to figure out what hes after.');
insert into quotes values (13,14,'Let me ask you this: Do you really think the boyd shout out a thing like that so the whole neighborhood could hear him? I dont think so - hes much too bright for that.');
insert into quotes values (14,15,'Brother, Ive seen all kinds of dishonesty in my day, but this little display takes the cake. Yall come in here with your hearts bleedin all over the floor about slum kids and injustice, you listen to some fairy tales... Suddenly, you start gettin through to some of these old ladies. Well, youre not getting through to me, Ive had enough.');
insert into quotes values (15,14,'Nobody has to prove otherwise. The burden of proof is on the prosecution. The defendant doesnt even have to open his mouth. Thats in the Constitution.');
insert into quotes values (16,16,'Thats what the Emperor said. A man steals something, hes brought in before the Emperor, he throws himself down on the ground. He begs for his life, he knows hes going to die. And the Emperor... pardons him. This worthless man, he lets him go.');
insert into quotes values (17,17,'Oskar, there are eleven hundred people who are alive because of you. Look at them.');
insert into quotes values (18,18,'Today is history. Today will be remembered. Years from now the young will ask with wonder about this day. Today is history and you are part of it. Six hundred years ago, when elsewhere they were footing the blame for the Black Death, Casimir the Great - so called - told the Jews they could come to Krakow. They came.');
insert into quotes values (19,21,'Im sorry, did I break your concentration? I didnt mean to do that. Please, continue, you were saying something about best intentions. Whats the matter? Oh, you were finished! Well, allow me to retort. What does Marsellus Wallace look like?');
insert into quotes values (20,21,'Theres a passage I got memorized. Ezekiel 25:17. "The path of the righteous man is beset on all sides by the inequities of the selfish and the tyranny of evil men. Blessed is he who, in the name of charity and good will, shepherds the weak through the valley of the darkness, for he is truly his brothers keeper and the finder of lost children."');
insert into quotes values (21,19,'I dont mean any disrespect, I just dont like people barking orders at me.');
insert into quotes values (22,23,'Hold your ground, hold your ground! Sons of Gondor, of Rohan, my brothers! I see in your eyes the same fear that would take the heart of me. A day may come when the courage of men fails, when we forsake our friends and break all bonds of fellowship, but it is not this day. An hour of wolves and shattered shields, when the age of men comes crashing down!');
insert into quotes values (23,22,'And thus it was. A fourth age of middle-earth began. And the fellowship of the ring... though eternally bound by friendship and love... was ended. Thirteen months to the day since Gandalf sent us on our long journey... we found ourselves looking upon a familiar sight. We were home. How do you pick up the threads of an old life? ');
insert into quotes values (24,24,'I think Im... quite ready for another adventure! [Bilbo climbs on board with Elrond. Galadriel follows with Celeborn]');
insert into quotes values (25,26,'You see, in this world theres two kinds of people, my friend: Those with loaded guns and those who dig. You dig.');
insert into quotes values (26,25,'While Im waiting for the Lord to remember me, I, Tuco Ramirez, brother of "Brother" Ramirez will tell you something! You think youre better than I am... where we came from, if one did not want to die in poverty, one became a priest or a bandit! You chose your way, I chose mine. *Mine* was harder! You talk about Mother and Father...');
insert into quotes values (27,27,'Oh I almost forgot. He gave me a thousand. I think his idea was that I kill you');
insert into quotes values (28,28,'Man, I see in fight club the strongest and smartest men whove ever lived. I see all this potential, and I see squandering. God damn it, an entire generation pumping gas, waiting tables; slaves with white collars. Advertising has us chasing cars and clothes, working jobs we hate so we can buy shit we dont need. Were the middle children of history, man.');
insert into quotes values (29,28,'Youre not your job. Youre not how much money you have in the bank. Youre not the car you drive. Youre not the contents of your wallet. Youre not your khakis. Youre the all-singing, all-dancing crap of the world.');
insert into quotes values (30,29,'I felt like putting a bullet between the eyes of every Panda that wouldnt screw to save its species. I wanted to open the dump valves on oil tankers and smother all the French beaches Id never see. I wanted to breathe smoke.');
insert into quotes values (31,31,'Come on, Sam. Remember what Bilbo used to say: "Its a dangerous business, Frodo, going out your door. You step onto the road, and if you dont keep your feet, theres no knowing where you might be swept off to."');
insert into quotes values (32,32,'It is a strange fate that we should suffer so much fear and doubt over so small a thing. Such a little thing');
insert into quotes values (33,33,'[to Aragorn] We must move on, we cannot linger.');
insert into quotes values (34,34,'My momma always said, "Life was like a box of chocolates. You never know what youre gonna get."');
insert into quotes values (35,36,'My given name is Benjamin Buford Blue, but people call me Bubba. Just like one of them ol redneck boys. Can you believe that?');
insert into quotes values (36,35,'Listen, you promise me something, OK? Just if youre ever in trouble, dont be brave. You just run, OK? Just run away.');
insert into quotes values (37,37,'Size matters not. Look at me. Judge me by my size, do you? Hmm? Hmm. And well you should not. For my ally is the Force, and a powerful ally it is. Life creates it, makes it grow. Its energy surrounds us and binds us. Luminous beings are we, not this crude matter. You must feel the Force around you; here, between you, me, the tree, the rock, everywhere, yes. Even between the land and the ship.');
insert into quotes values (38,38,'That place... is strong with the dark side of the Force. A domain of evil it is. In you must go.');
insert into quotes values (39,39,'I had nothing to do with it. General Rieekan thinks its dangerous for anyone to leave the system until theyve activated the energy shield.');
insert into quotes values (40,40,'What is the most resilient parasite? Bacteria? A virus? An intestinal worm? An idea. Resilient... highly contagious. Once an idea has taken hold of the brain its almost impossible to eradicate. An idea that is fully formed - fully understood - that sticks; right in there somewhere.');
insert into quotes values (41,41,'Because in a 747, the pilots up top, and the first class cabins in the nose, so no one would walk through. But youd have to buy out the entire cabin. And the first class flight attendant...');
insert into quotes values (42,42,'Brain function in the dream will be about twenty times to normal. When you enter a dream within that dream, the effect is compounded: its three dreams, thats ten hours times twen...');
insert into quotes values (43,43,'Forty-two? Oh, thats not bad for a pointy-eared elvish princeling. Hmph! I myself am sitting pretty on forty-THREE.');
insert into quotes values (44,44,'We wants it, we needs it. Must have the precious. They stole it from us. Sneaky little hobbitses. Wicked, tricksy, false!');
insert into quotes values (45,45,'The battle of Helms Deep is over; the battle for Middle-earth is about to begin.');
insert into quotes values (46,46,'Jesus, I mean, you guys do nothing but complain about how you cant stand it in this place here and you dont have the guts just to walk out? What do you think you are, for Chrissake, crazy or somethin? Well youre not! Youre not!');
insert into quotes values (47,47,'You know Billy, what worries me is how your mother is going to take this.');
insert into quotes values (48,48,'Aw come on, youre not gonna say that now! Youre not gonna say that now! Youre gonna pull that hen house? Now when the vote... the Chief just voted - it was 10 to 9. Now I want that television set turned on *right now*!');
insert into quotes values (49,49,'Anything I wanted was a phone call away. Free cars. The keys to a dozen hideout flats all over the city. I bet twenty, thirty grand over a weekend and then Id either blow the winnings in a week or go to the sharks to pay back the bookies.');
insert into quotes values (50,50,'Didnt matter. It didnt mean anything. When I was broke, Id go out and rob some more. We ran everything. We paid off cops. We paid off lawyers. We paid off judges. Everybody had their hands out. Everything was for the taking. And now its all over.');
insert into quotes values (51,51,'One day some of the kids from the neighborhood carried my mothers groceries all the way home. You know why? It was outta respect.');
insert into quotes values (52,53,'This is your last chance. After this, there is no turning back. You take the blue pill - the story ends, you wake up in your bed and believe whatever you want to believe. You take the red pill - you stay in Wonderland and I show you how deep the rabbit-hole goes.');
insert into quotes values (53,52,'What are you trying to tell me? That I can dodge bullets?');
insert into quotes values (54,54,'I imagine that right now, youre feeling a bit like Alice. Hmm? Tumbling down the rabbit hole?');
insert into quotes values (55,55,'This is the nature of war: By protecting others, you save yourselves. If you only think of yourself, youll only destroy yourself.');
insert into quotes values (56,57,'You fool! Damn you! You call yourself a horse! For shame! Hey! Wait! Please! I apologize! Forgive me!');
insert into quotes values (57,56,'Train yourself, distinguish yourself in war... But time flies. Before your dream materializes, you get gray hair. By that time your parents and friends are dead and gone.');
insert into quotes values (58,58,'Alderaan? Im not going to Alderaan, Ive gotta get *home*, its late, Im in for it as it is!');
insert into quotes values (59,60,'You cant win, Darth. If you strike me down, I shall become more powerful than you could possibly imagine.');
insert into quotes values (60,59,'It is for me, sister. Look, I aint in this for your revolution, and Im not in it for you, Princess. I expect to be well paid. Im in it for the money.');



--trivia
insert into trivia values (1,1,'Andy and Reds opening chat in the prison yard, in which Red is throwing a baseball, took nine hours to shoot. Morgan Freeman threw the baseball for the entire nine hours without a word of complaint. He showed up for work the next day with his arm in a sling.');
insert into trivia values (2,1,'Morgan Freemans favorite film of his own.');
insert into trivia values (3,1,'Clint Eastwood, Harrison Ford, Paul Newman, and Robert Redford were all considered for the part of Red. In the original novel, Red is a middle-aged Irishman with graying red hair. However, Frank Darabont always had Morgan Freeman in mind for the role, because of his authoritative presence, demeanor and deep voice. Darabont alluded to the casting choice, by having Red jokingly reply to Andys inquiry about his nickname with the line, "Maybe its because Im Irish."');
insert into trivia values (4,1,'Although a very modest hit in theaters, it became one of the highest-grossing video rentals of all time.');
insert into trivia values (5,1,'Frank Darabont watched Goodfellas (1990) every Sunday while shooting this film, and drew inspiration from it, on using voice-over narration and showing the passage of time.');
insert into trivia values (6,2,'Lenny Montana (Luca Brasi) was so nervous about working with Marlon Brando that in the first take of their scene together, he flubbed some lines. Director Francis Ford Coppola liked the genuine nervousness and used it in the final cut. The scenes of Luca practicing his speech were added later.');
insert into trivia values (7,2,'During an early shot of the scene where Vito Corleone returns home and his people carry him up the stairs, Marlon Brando put weights under his body on the bed as a prank, to make it harder to lift him.');
insert into trivia values (8,2,'Animal rights activists protested the horses head scene. Francis Ford Coppola told Variety, "There were many people killed in that movie, but everyone worries about the horse. It was the same on the set. When the head arrived, it upset many crew members who are animal lovers, who like little doggies. What they dont know is that we got the head from a pet food manufacturer who slaughters two hundred horses a day just to feed those little doggies."');
insert into trivia values (9,2,'Marlon Brando wanted to make Don Corleone "look like a bulldog," so he stuffed his cheeks with cotton wool for the audition. For the actual filming, he wore a mouthpiece made by a dentist. This appliance is on display in the American Museum of the Moving Image in Queens, New York.');
insert into trivia values (10,2,'Whenever oranges appear in the film, they foreshadow death or a near death involving the Corleone family.');
insert into trivia values (11,3,'Marlon Brando and Robert De Niro are the only two actors to ever win separate Oscars for playing the same character. Brando won Best Actor for The Godfather (1972) and De Niro won Best Actor in a Supporting Role for this movie, both in the role of Vito Corleone.');
insert into trivia values (12,3,'Robert De Niro spent four months learning to speak the Sicilian dialect in order to play Vito Corleone. Nearly all the dialogue that his character speaks in the film was in Sicilian.');
insert into trivia values (13,3,'To prepare for his role, Robert De Niro lived in Sicily for three months.');
insert into trivia values (14,3,'When little Vito arrives at Ellis Island, he is marked with a circled X. Ellis Island immigrants were marked with this if the inspector believed the person had a mental defect.');
insert into trivia values (15,3,'Originally, the actors in the flashback scenes wore pants with zippers. One of the musicians pointed out that the zipper had not been invented at that time, so some scenes had to be re-shot with button-fly trousers.');
insert into trivia values (16,4,'In Sir Michael Caines opinion, Heath Ledger beat the odds and topped Jack Nicholsons Joker from Batman (1989): "Jack was like a clown figure, benign but wicked, maybe a killer old uncle. He could be funny and make you laugh. Heaths gone in a completely different direction to Jack, hes like a really scary psychopath. Hes a lovely guy and his Joker is going to be a hell of a revelation in this picture." Caine bases this belief on a scene where the Joker pays a visit to Bruce Waynes penthouse. Hed never met Ledger before, so when Ledger arrived and performed he gave Caine such a fright, he forgot his lines.');
insert into trivia values (17,4,'Made more money than Batman Begins (2005)s entire domestic run in only six days of release.');
insert into trivia values (18,4,'While the movie was filming a chase scene on Lake Street, the Chicago Police Department received several calls from concerned citizens stating that the police were involved in a vehicle pursuit with a dark vehicle of unknown make or model.');
insert into trivia values (19,4,'While the film is dedicated to Heath Ledger, it also bears a dedication to Conway Wickliffe, a stuntman who was killed when the car he was driving crashed.');
insert into trivia values (20,4,'While filming the chase scene with the Joker and the SWAT vans, one of only four IMAX cameras in the world at that time was destroyed.');
insert into trivia values (21,5,'The ethnic background of the teenaged suspect was deliberately left unstated. For the purposes of the film, the important facts were that he was not of Northern European ancestry, and that prejudice (or lack of it) from some jurors would be a major part of the deliberation process.');
insert into trivia values (22,5,'This film is commonly used in business schools and workshops to illustrate team dynamics and conflict resolution techniques.');
insert into trivia values (23,5,'With the death of Jack Klugman (Juror #5) on December 24, 2012, none of the twelve jurors from the film are alive today.');
insert into trivia values (24,6,'When survivor Mila Pfefferberg was introduced to Ralph Fiennes on the set, she began shaking uncontrollably, as he reminded her too much of the real Amon Goeth.');
insert into trivia values (25,6,'Steven Spielberg was able to get permission to film inside Auschwitz, but chose not to, out of respect for the victims, so the scenes of the death camp were actually filmed outside the gates on a set constructed in a mirror image of the real location on the other side.');
insert into trivia values (26,7,'In real life, Vincent Vegas 1964 Chevelle Malibu convertible belongs to Writer and Director Quentin Tarantino, and was stolen during the production of the film. In 2013, a police officer saw two kids stripping an older car. He arrested them, and when researching the vehicle, found the VIN had been altered. It turned out that it was the car stolen off Quentin Tarantino. The owner had recently purchased it, and had no idea it was stolen.');
insert into trivia values (27,7,'Uma Thurman originally turned down the role of Mia Wallace. Quentin Tarantino was so desperate to have her as Mia, he ended up reading her the script over the phone, finally convincing her to take on the role.');
insert into trivia values (28,7,'The movie cost eight million dollars to make, with five million dollars going to pay the actors salaries.');
insert into trivia values (29,8,'George Lucas was so sure the film would flop that instead of attending the premiere, he went on vacation to Hawaii with his good friend Steven Spielberg, where they came up with the idea for Raiders of the Lost Ark (1981).');
insert into trivia values (30,8,'The first film to make over $300,000,000.');
insert into trivia values (31,8,'James Earl Jones and David Prowse, who play the voice and body of Darth Vader respectively, have never met.');
insert into trivia values (32,8,'Stunt doubles were not used for the scene where Luke and Leia swing to safety. Carrie Fisher and Mark Hamill performed the stunt themselves, shooting it in just one take.');
insert into trivia values (33,9,'Andy Serkis and Elijah Wood were each given prop rings by Peter Jackson, used in the movie. They both thought they had the only one.');
insert into trivia values (34,9,'The dead oliphaunt carcass, used in this film, is reportedly the largest prop ever built for a movie. According to members of the Prop Department, Director Peter Jackson still thought it could have been bigger.');
insert into trivia values (35,9,'A normal movie averages about two hundred visual effects shots. This film had one thousand four hundred eighty-eight.');
insert into trivia values (36,10,'Because Sergio Leone spoke barely any English and Eli Wallach spoke barely any Italian, the two communicated in French.');
insert into trivia values (37,10,'Clint Eastwood wore the same poncho through all three "Man with No Name" movies without replacement or cleaning.');
insert into trivia values (39,10,'The film was budgeted at an expensive (for the time) $1.6 million.');
insert into trivia values (40,11,'When a Fight Club member sprays the priest with a hose, the camera briefly shakes. This happens because the cameraman couldnt keep himself from laughing.');
insert into trivia values (41,11,'In the short scene when Brad Pitt and Edward Norton are drunk and hitting golf balls, they really are drunk, and the golf balls are sailing directly into the side of the catering truck.');
insert into trivia values (42,12,'Sir Christopher Lee (Saruman) read "The Lord of the Rings" once a year, until his death in 2015, and had done so since the year it was published, and is the only member of the cast and crew ever to have met J.R.R. Tolkien.');
insert into trivia values (43,12,'Viggo Mortensen chipped a tooth while filming a fight sequence. He wanted Peter Jackson to superglue it back on, so he could finish his scene, but Jackson took him to the dentist on his lunch break, had it patched up, and returned to the set that afternoon.');
insert into trivia values (44,13,'When Forrest gets up to talk at the Vietnam rally in Washington, the microphone plug is pulled and you cannot hear him. According to Tom Hanks, he says, "Sometimes when people go to Vietnam, they go home to their mommas without any legs. Sometimes they dont go home at all. Thats a bad thing. Thats all I have to say about that."');
insert into trivia values (45,13,'When Forrest first learns to play ping-pong in the infirmary, he is told the trick is to "keep his eye on the ball" by another soldier. After that moment, whenever he is shown playing ping-pong, he never blinks.');
insert into trivia values (46,13,'Bill Murray, John Travolta, and Chevy Chase turned down the role of Forrest Gump. Travolta later admitted that passing on the role was a mistake.');
insert into trivia values (47,14,'The shots where Luke uses his Jedi powers to retrieve his lightsaber from a distance were achieved by having Mark Hamill throw the lightsaber away and then running the film in reverse.');
insert into trivia values (48,14,'With the exception of being sucked out of a Cloud City window, Mark Hamill did all of his own stunts.');
insert into trivia values (49,15,'In an effort to combat confusion, television broadcasts in Japan include text in the upper-left corner of the screen to remind viewers which level of the dream a specific scene takes place in.');
insert into trivia values (50,15,'According to Cinematographer Wally Pfister, Warner Brothers executives approached Christopher Nolan about making the film in 3-D, but he refused the idea, claiming "it will distract the storytelling experience of Inception".');
insert into trivia values (51,16,'They couldnt recruit enough men in the six foot height area to play Uruk-hai, so men from five foot high were cast as well. They were affectionately nicknamed the Uruk-Low.');
insert into trivia values (52,16,'As the Orcs have black blood, it was only natural that the inside of their mouths should not be pink, but black as well. To achieve this, the Orc actors had to swill a liquorice-based mouthwash prior to each of their scenes.');
insert into trivia values (53,17,'Many extras were authentic mental patients.');
insert into trivia values (54,17,'Louise Fletcher was so upset with the fact that the other cast members could laugh and be happy, while she had to be so cold and heartless, that near the end of production, she removed her dress, and stood in only her panties, to prove to the cast members she was not "a cold-hearted monster".');
insert into trivia values (55,18,'According to Nicholas Pileggi, some actual mobsters were hired as extras to lend authenticity to scenes. The mobsters gave fake Social Security numbers to Warner Bros. and it is unknown how they received their paychecks.');
insert into trivia values (56,18,'According to Ray Liotta, Martin Scorsese was so involved in every detail of the casts wardrobe that he tied Liottas tie himself to make sure it was accurate for the films setting.');
insert into trivia values (57,18,'Martin Scorsese and Nicholas Pileggi collaborated on the screenplay, and over the course of the 12 drafts it took to reach the ideal script, the reporter realized "the visual styling had to be completely redone... So we decided to share credit". They decided which sections of the book they liked and put them together like building blocks. Scorsese persuaded Pileggi that they did not need to follow a traditional narrative structure. The director wanted to take the gangster film and deal with it episode by episode, but start in the middle and move backwards and forwards. Scorsese would compact scenes and realized that if they were kept short, "the impact after about an hour and a half would be terrific".');
insert into trivia values (58,19,'The opening action scene took six months of training and four days to shoot.');
insert into trivia values (59,19,'After the lobby shoot-out, the camera pans back, showing the aftermath of the gunfight in the lobby. During this, a piece of one of the pillars falls off. This happened by coincidence during the filming, and was not planned, but was left, since it seemed appropriate.');
insert into trivia values (60,20,'After months of research, all of the seven major characters in the film wound up being based on historical samurai.');
insert into trivia values (61,20,'Often credited as the first modern action movie. Many now commonly used cinematographic and plot elements--such as slow motion for dramatic flair and the reluctant hero to name a couple--are seen for perhaps the first time. Other movies may have used them separately before, but Akira Kurosawa brought them all together.');
insert into trivia values (62,20,'This was the first film on which Akira Kurosawa used multiple cameras, so he wouldnt interrupt the flow of the scenes and could edit the film as he pleased in post-production. He used the multiple-camera set-up on every subsequent film.');
insert into trivia values (38,20,'The movie is set in 1586. We learn during the scroll scene that the real Kikuchiyo was born in year two of the Tensho era (1574) and is now 13 years old. Japanese convention considered a child to be one year old when he was born and advanced his age one year each new year.');



--theatre
insert into theatre values (1,'PVR: Motera','Ahmedabad');
insert into theatre values (2,'City Gold: Motera','Ahmedabad');
insert into theatre values (3,'Cinemax: Red Carpet','Ahmedabad');
insert into theatre values (4,'Amber Cinema','Ahmedabad');
insert into theatre values (5,'City Gold','Ahmedabad');
insert into theatre values (6,'Time Cinema: CG Road','Ahmedabad');
insert into theatre values (7,'Wide Angle','Ahmedabad');
insert into theatre values (8,'PVR: Acropolis','Ahmedabad');
insert into theatre values (9,'Cinepolis', 'Ahmedabad');
insert into theatre values (10,'Wide Angle','Mehsana');
insert into theatre values (11,'Cine Pulse','Mehsana');
insert into theatre values (12,'City Pulse','Gandhinagar');
insert into theatre values (13,'INOX: R15','Gandhinagar');
insert into theatre values (14,'INOX: R21','Gandhinagar');
insert into theatre values (15,'The Entertnmnt Park','Bhavnagar');
insert into theatre values (16,'Maxus Cinemas','Bhavnagar');
insert into theatre values (17,'Top3 Multiplex','Bhavnagar');
insert into theatre values (18,'Cinepolis','Surat');
insert into theatre values (19,'INOX: VR Mall','Surat');
insert into theatre values (20,'PVR: Rahul Raj','Surat');
insert into theatre values (21,'Time Cinema','Surat');
insert into theatre values (22,'Harmony Cinema','Surat');
insert into theatre values (23,'Alpana Cinema','Vadodara');


--show
insert into show values(1,'9:00:00','11:50:00');
insert into show values(2,'10:00:00','12:50:00');
insert into show values(3,'11:00:00','13:50:00');
insert into show values(4,'12:00:00','14:50:00');
insert into show values(5,'13:00:00','15:50:00');
insert into show values(6,'14:00:00','16:50:00');
insert into show values(7,'15:00:00','17:50:00');
insert into show values(8,'16:00:00','18:50:00');
insert into show values(9,'17:00:00','19:50:00');
insert into show values(10,'18:00:00','20:50:00');
insert into show values(11,'19:00:00','21:50:00');
insert into show values(12,'20:00:00','22:50:00');
insert into show values(13,'21:00:00','23:50:00');
insert into show values(14,'22:00:00','00:50:00');



--rating
INSERT INTO rating VALUES(1, 2, 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 8);
INSERT INTO rating VALUES(1, 3, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', 3.5);
INSERT INTO rating VALUES(1, 4, 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', 4.5);
INSERT INTO rating VALUES(1, 6, 'Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.', 6.5);
INSERT INTO rating VALUES(1, 7, 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', 3.5);
INSERT INTO rating VALUES(1, 8, 'Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', 8.5);
INSERT INTO rating VALUES(1, 9, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 9);
INSERT INTO rating VALUES(1, 10, 'Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.', 9.5);
INSERT INTO rating VALUES(1, 11, 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', 8.5);
INSERT INTO rating VALUES(1, 12, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 7.5);
INSERT INTO rating VALUES(1, 14, 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.', 2);
INSERT INTO rating VALUES(1, 15, 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 5.5);
INSERT INTO rating VALUES(1, 18, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 3.5);
INSERT INTO rating VALUES(1, 19, 'Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl.', 4.5);
INSERT INTO rating VALUES(1, 20, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.', 6.5);
INSERT INTO rating VALUES(2, 1, 'Aliquam erat volutpat. In congue. Etiam justo.', 8);
INSERT INTO rating VALUES(2, 2, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 8.5);
INSERT INTO rating VALUES(2, 4, 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.', 9);
INSERT INTO rating VALUES(2, 5, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 9.5);
INSERT INTO rating VALUES(2, 6, 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', 8.5);
INSERT INTO rating VALUES(2, 8, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 7.5);
INSERT INTO rating VALUES(2, 9, 'Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.', 2);
INSERT INTO rating VALUES(2, 10, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', 5.5);
INSERT INTO rating VALUES(2, 11, 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', 3.5);
INSERT INTO rating VALUES(2, 12, 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', 4.5);
INSERT INTO rating VALUES(2, 13, 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 6.5);
INSERT INTO rating VALUES(2, 14, 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', 3.5);
INSERT INTO rating VALUES(2, 15, 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 8.5);
INSERT INTO rating VALUES(2, 16, 'Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', 5);
INSERT INTO rating VALUES(2, 17, 'Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', 9.5);
INSERT INTO rating VALUES(2, 18, 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.', 8.5);
INSERT INTO rating VALUES(2, 19, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 7.5);
INSERT INTO rating VALUES(2, 20, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 2);
INSERT INTO rating VALUES(3, 1, 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', 8);
INSERT INTO rating VALUES(3, 2, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', 3.5);
INSERT INTO rating VALUES(3, 3, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', 4.5);
INSERT INTO rating VALUES(3, 4, 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', 6.5);
INSERT INTO rating VALUES(3, 5, 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 3.5);
INSERT INTO rating VALUES(3, 6, 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', 8.5);
INSERT INTO rating VALUES(3, 7, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', 9);
INSERT INTO rating VALUES(3, 8, 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 9.5);
INSERT INTO rating VALUES(3, 9, 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.', 8.5);
INSERT INTO rating VALUES(3, 10, 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.', 7.5);
INSERT INTO rating VALUES(3, 12, 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.', 2);
INSERT INTO rating VALUES(3, 13, 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 5.5);
INSERT INTO rating VALUES(3, 14, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', 3.5);
INSERT INTO rating VALUES(3, 15, 'Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus.', 4.5);
INSERT INTO rating VALUES(3, 16, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 6.5);
INSERT INTO rating VALUES(3, 17, 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 3.5);
INSERT INTO rating VALUES(3, 18, 'Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', 8.5);
INSERT INTO rating VALUES(3, 19, 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', 9);
INSERT INTO rating VALUES(3, 20, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', 9.5);
INSERT INTO rating VALUES(4, 1, 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', 8.5);
INSERT INTO rating VALUES(4, 2, 'Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', 7.5);
INSERT INTO rating VALUES(4, 3, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 2);
INSERT INTO rating VALUES(4, 4, 'In congue. Etiam justo. Etiam pretium iaculis justo.', 5.5);
INSERT INTO rating VALUES(4, 5, 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', 3.5);
INSERT INTO rating VALUES(4, 6, 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 4.5);
INSERT INTO rating VALUES(4, 7, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', 6.5);
INSERT INTO rating VALUES(4, 8, 'Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus.', 3.5);
INSERT INTO rating VALUES(4, 9, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', 8.5);
INSERT INTO rating VALUES(4, 10, 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.', 9);
INSERT INTO rating VALUES(4, 11, 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.', 9.5);
INSERT INTO rating VALUES(4, 12, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.', 8.5);
INSERT INTO rating VALUES(4, 13, 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', 7.5);
INSERT INTO rating VALUES(4, 14, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 2);
INSERT INTO rating VALUES(4, 15, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend.', 5.5);
INSERT INTO rating VALUES(4, 16, 'Fusce consequat. Nulla nisl. Nunc nisl.', 3.5);
INSERT INTO rating VALUES(4, 17, 'Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', 4.5);
INSERT INTO rating VALUES(4, 18, 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 6.5);
INSERT INTO rating VALUES(4, 19, 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', 3.5);
INSERT INTO rating VALUES(4, 20, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 8.5);
INSERT INTO rating VALUES(5, 1, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 9);
INSERT INTO rating VALUES(5, 2, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 9.5);
INSERT INTO rating VALUES(5, 3, 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', 8.5);
INSERT INTO rating VALUES(5, 4, 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', 7.5);
INSERT INTO rating VALUES(5, 6, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 2);
INSERT INTO rating VALUES(5, 7, 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', 5.5);
INSERT INTO rating VALUES(5, 8, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', 3.5);
INSERT INTO rating VALUES(5, 9, 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', 4.5);
INSERT INTO rating VALUES(5, 10, 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', 6.5);
INSERT INTO rating VALUES(5, 11, 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', 3.5);
INSERT INTO rating VALUES(5, 12, 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio.', 8.5);
INSERT INTO rating VALUES(5, 13, 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', 9);
INSERT INTO rating VALUES(5, 14, 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', 9.5);
INSERT INTO rating VALUES(5, 15, 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', 8.5);
INSERT INTO rating VALUES(5, 17, 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.', 7.5);
INSERT INTO rating VALUES(5, 19, 'Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', 2);
INSERT INTO rating VALUES(6, 1, 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio.', 9);
INSERT INTO rating VALUES(6, 2, 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 3.5);
INSERT INTO rating VALUES(6, 4, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 4.5);
INSERT INTO rating VALUES(6, 5, 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', 6.5);
INSERT INTO rating VALUES(6, 6, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 3.5);
INSERT INTO rating VALUES(6, 7, 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', 8.5);
INSERT INTO rating VALUES(6, 8, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', 9);
INSERT INTO rating VALUES(6, 9, 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 9.5);
INSERT INTO rating VALUES(6, 10, 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.', 8.5);
INSERT INTO rating VALUES(6, 11, 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', 7.5);
INSERT INTO rating VALUES(6, 12, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 2);
INSERT INTO rating VALUES(6, 14, 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', 3.5);
INSERT INTO rating VALUES(6, 15, 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', 8.5);
INSERT INTO rating VALUES(6, 16, 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio.', 4);
INSERT INTO rating VALUES(6, 17, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 9.5);
INSERT INTO rating VALUES(6, 18, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 8.5);
INSERT INTO rating VALUES(6, 19, 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', 7.5);
INSERT INTO rating VALUES(6, 20, 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', 2);
INSERT INTO rating VALUES(7, 1, 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.', 7);
INSERT INTO rating VALUES(7, 2, 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', 3.5);
INSERT INTO rating VALUES(7, 4, 'Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', 4.5);
INSERT INTO rating VALUES(7, 5, 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 6.5);
INSERT INTO rating VALUES(7, 6, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 3.5);
INSERT INTO rating VALUES(7, 7, 'Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.', 8.5);
INSERT INTO rating VALUES(7, 8, 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 9);
INSERT INTO rating VALUES(7, 9, 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.', 9.5);
INSERT INTO rating VALUES(7, 10, 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', 8.5);
INSERT INTO rating VALUES(7, 11, 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', 7.5);
INSERT INTO rating VALUES(7, 12, 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', 2);
INSERT INTO rating VALUES(7, 13, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.', 5.5);
INSERT INTO rating VALUES(7, 14, 'Aliquam erat volutpat. In congue. Etiam justo.', 3.5);
INSERT INTO rating VALUES(7, 15, 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', 4.5);
INSERT INTO rating VALUES(7, 16, 'Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.', 4.5);
INSERT INTO rating VALUES(7, 17, 'Fusce consequat. Nulla nisl. Nunc nisl.', 3.5);
INSERT INTO rating VALUES(7, 18, 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', 8.5);
INSERT INTO rating VALUES(7, 20, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 9);
INSERT INTO rating VALUES(8, 1, 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', 9.5);
INSERT INTO rating VALUES(8, 2, 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', 8.5);
INSERT INTO rating VALUES(8, 3, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 7.5);
INSERT INTO rating VALUES(8, 4, 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', 2);
INSERT INTO rating VALUES(8, 5, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 5.5);
INSERT INTO rating VALUES(8, 6, 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.', 3.5);
INSERT INTO rating VALUES(8, 7, 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio.', 4.5);
INSERT INTO rating VALUES(8, 8, 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', 6.5);
INSERT INTO rating VALUES(8, 9, 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', 3.5);
INSERT INTO rating VALUES(8, 10, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 8.5);
INSERT INTO rating VALUES(8, 11, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.', 9);
INSERT INTO rating VALUES(8, 13, 'Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor.', 9.5);
INSERT INTO rating VALUES(8, 14, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.', 8.5);
INSERT INTO rating VALUES(8, 15, 'Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante.', 7.5);
INSERT INTO rating VALUES(8, 16, 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 2);
INSERT INTO rating VALUES(8, 18, 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', 3.5);
INSERT INTO rating VALUES(8, 19, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', 8.5);
INSERT INTO rating VALUES(8, 20, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 9);
INSERT INTO rating VALUES(9, 1, 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.', 9.5);
INSERT INTO rating VALUES(9, 2, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 8.5);
INSERT INTO rating VALUES(9, 3, 'Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', 7.5);
INSERT INTO rating VALUES(9, 4, 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', 2);
INSERT INTO rating VALUES(9, 5, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 5.5);
INSERT INTO rating VALUES(9, 6, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 3.5);
INSERT INTO rating VALUES(9, 8, 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', 4.5);
INSERT INTO rating VALUES(9, 9, 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', 6.5);
INSERT INTO rating VALUES(9, 11, 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.', 3.5);
INSERT INTO rating VALUES(9, 12, 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', 8.5);
INSERT INTO rating VALUES(9, 13, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 9);
INSERT INTO rating VALUES(9, 14, 'Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', 9.5);
INSERT INTO rating VALUES(9, 15, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 8.5);
INSERT INTO rating VALUES(9, 16, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', 7.5);
INSERT INTO rating VALUES(9, 17, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 2);
INSERT INTO rating VALUES(9, 18, 'Aliquam erat volutpat. In congue. Etiam justo.', 5.5);
INSERT INTO rating VALUES(9, 19, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 3.5);
INSERT INTO rating VALUES(10, 1, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 8.5);
INSERT INTO rating VALUES(10, 3, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 6.5);
INSERT INTO rating VALUES(10, 6, 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 3.5);
INSERT INTO rating VALUES(10, 9, 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.', 8.5);
INSERT INTO rating VALUES(10, 10, 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', 9);
INSERT INTO rating VALUES(10, 12, 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', 9.5);
INSERT INTO rating VALUES(10, 14, 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 8.5);
INSERT INTO rating VALUES(10, 15, 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', 7.5);
INSERT INTO rating VALUES(10, 19, 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 2);
INSERT INTO rating VALUES(11, 1, 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', 9.5);
INSERT INTO rating VALUES(11, 2, 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', 3.5);
INSERT INTO rating VALUES(11, 4, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 4.5);
INSERT INTO rating VALUES(11, 5, 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh.', 6.5);
INSERT INTO rating VALUES(11, 6, 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', 3.5);
INSERT INTO rating VALUES(11, 8, 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 8.5);
INSERT INTO rating VALUES(11, 9, 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', 9);
INSERT INTO rating VALUES(11, 10, 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 9.5);
INSERT INTO rating VALUES(11, 11, 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', 8.5);
INSERT INTO rating VALUES(11, 12, 'Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', 7.5);
INSERT INTO rating VALUES(11, 13, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', 2);
INSERT INTO rating VALUES(11, 14, 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 3.5);
INSERT INTO rating VALUES(11, 15, 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', 8.5);
INSERT INTO rating VALUES(11, 17, 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio.', 9);
INSERT INTO rating VALUES(11, 18, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 9.5);
INSERT INTO rating VALUES(11, 19, 'Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue.', 8.5);
INSERT INTO rating VALUES(11, 20, 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 7.5);
INSERT INTO rating VALUES(12, 1, 'Nunc purus. Phasellus in felis. Donec semper sapien a libero.', 7);
INSERT INTO rating VALUES(12, 2, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', 5.5);
INSERT INTO rating VALUES(12, 3, 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', 3.5);
INSERT INTO rating VALUES(12, 4, 'Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue.', 4.5);
INSERT INTO rating VALUES(12, 5, 'In congue. Etiam justo. Etiam pretium iaculis justo.', 6.5);
INSERT INTO rating VALUES(12, 6, 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', 3.5);
INSERT INTO rating VALUES(12, 7, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 8.5);
INSERT INTO rating VALUES(12, 8, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 9);
INSERT INTO rating VALUES(12, 9, 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', 9.5);
INSERT INTO rating VALUES(12, 10, 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', 8.5);
INSERT INTO rating VALUES(12, 11, 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh.', 7.5);
INSERT INTO rating VALUES(12, 13, 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.', 2);
INSERT INTO rating VALUES(12, 14, 'Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', 5.5);
INSERT INTO rating VALUES(12, 15, 'Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', 3.5);
INSERT INTO rating VALUES(12, 16, 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.', 4.5);
INSERT INTO rating VALUES(12, 17, 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.', 6.5);
INSERT INTO rating VALUES(12, 18, 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis.', 3.5);
INSERT INTO rating VALUES(12, 19, 'In congue. Etiam justo. Etiam pretium iaculis justo.', 8.5);
INSERT INTO rating VALUES(12, 20, 'Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', 9);
INSERT INTO rating VALUES(13, 1, 'Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', 9.5);
INSERT INTO rating VALUES(13, 2, 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', 8.5);
INSERT INTO rating VALUES(13, 4, 'Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', 7.5);
INSERT INTO rating VALUES(13, 5, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', 2);
INSERT INTO rating VALUES(13, 6, 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', 5.5);
INSERT INTO rating VALUES(13, 7, 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', 3.5);
INSERT INTO rating VALUES(13, 8, 'Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti.', 4.5);
INSERT INTO rating VALUES(13, 9, 'Fusce consequat. Nulla nisl. Nunc nisl.', 6.5);
INSERT INTO rating VALUES(13, 10, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.', 3.5);
INSERT INTO rating VALUES(13, 11, 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', 8.5);
INSERT INTO rating VALUES(13, 12, 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', 9);
INSERT INTO rating VALUES(13, 13, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 9.5);
INSERT INTO rating VALUES(13, 15, 'Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', 8.5);
INSERT INTO rating VALUES(13, 16, 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', 6.5);
INSERT INTO rating VALUES(13, 17, 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', 2);
INSERT INTO rating VALUES(13, 18, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 3.5);
INSERT INTO rating VALUES(13, 19, 'Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', 8.5);
INSERT INTO rating VALUES(13, 20, 'Fusce consequat. Nulla nisl. Nunc nisl.', 9);
INSERT INTO rating VALUES(14, 1, 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', 9.5);
INSERT INTO rating VALUES(14, 2, 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 8.5);
INSERT INTO rating VALUES(14, 3, 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', 7.5);
INSERT INTO rating VALUES(14, 4, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', 2);
INSERT INTO rating VALUES(14, 5, 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio.', 5.5);
INSERT INTO rating VALUES(14, 6, 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio.', 3.5);
INSERT INTO rating VALUES(14, 7, 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', 4.5);
INSERT INTO rating VALUES(14, 8, 'In congue. Etiam justo. Etiam pretium iaculis justo.', 6.5);
INSERT INTO rating VALUES(14, 10, 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh.', 3.5);
INSERT INTO rating VALUES(14, 11, 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 8.5);
INSERT INTO rating VALUES(14, 12, 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 9);
INSERT INTO rating VALUES(14, 13, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 9.5);
INSERT INTO rating VALUES(14, 14, 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', 8.5);
INSERT INTO rating VALUES(14, 15, 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', 7.5);
INSERT INTO rating VALUES(14, 16, 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', 2);
INSERT INTO rating VALUES(14, 17, 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', 5.5);
INSERT INTO rating VALUES(14, 18, 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', 3.5);
INSERT INTO rating VALUES(14, 19, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend.', 4.5);
INSERT INTO rating VALUES(14, 20, 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis.', 6.5);
INSERT INTO rating VALUES(15, 1, 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.', 8);
INSERT INTO rating VALUES(15, 2, 'Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.', 8.5);
INSERT INTO rating VALUES(15, 3, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', 9);
INSERT INTO rating VALUES(15, 5, 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', 9.5);
INSERT INTO rating VALUES(15, 6, 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 8.5);
INSERT INTO rating VALUES(15, 7, 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', 7.5);
INSERT INTO rating VALUES(15, 9, 'Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.', 2);
INSERT INTO rating VALUES(15, 10, 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', 5.5);
INSERT INTO rating VALUES(15, 11, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 3.5);
INSERT INTO rating VALUES(15, 12, 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.', 4.5);
INSERT INTO rating VALUES(15, 13, 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis.', 6.5);
INSERT INTO rating VALUES(15, 15, 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.', 3.5);
INSERT INTO rating VALUES(15, 16, 'Aliquam erat volutpat. In congue. Etiam justo.', 7.5);
INSERT INTO rating VALUES(15, 17, 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', 9);
INSERT INTO rating VALUES(15, 19, 'Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', 9.5);
INSERT INTO rating VALUES(15, 20, 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', 8.5);
INSERT INTO rating VALUES(16, 2, 'Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', 7.5);
INSERT INTO rating VALUES(16, 3, 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', 2);
INSERT INTO rating VALUES(16, 4, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 3.5);
INSERT INTO rating VALUES(16, 5, 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', 8.5);
INSERT INTO rating VALUES(16, 6, 'Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', 9);
INSERT INTO rating VALUES(16, 8, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 9.5);
INSERT INTO rating VALUES(16, 9, 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', 8.5);
INSERT INTO rating VALUES(16, 10, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 7.5);
INSERT INTO rating VALUES(16, 11, 'Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', 2);
INSERT INTO rating VALUES(16, 12, 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', 5.5);
INSERT INTO rating VALUES(16, 13, 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh.', 3.5);
INSERT INTO rating VALUES(16, 14, 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 4.5);
INSERT INTO rating VALUES(16, 15, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.', 6.5);
INSERT INTO rating VALUES(16, 16, 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.', 3.5);
INSERT INTO rating VALUES(16, 18, 'Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', 8.5);
INSERT INTO rating VALUES(16, 19, 'Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor.', 9);
INSERT INTO rating VALUES(16, 20, 'Morbi a ipsum. Integer a nibh. In quis justo.', 9.5);
INSERT INTO rating VALUES(17, 1, 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', 8.5);
INSERT INTO rating VALUES(17, 2, 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', 7.5);
INSERT INTO rating VALUES(17, 3, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.', 2);
INSERT INTO rating VALUES(17, 4, 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', 5.5);
INSERT INTO rating VALUES(17, 5, 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', 3.5);
INSERT INTO rating VALUES(17, 6, 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 4.5);
INSERT INTO rating VALUES(17, 7, 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', 6.5);
INSERT INTO rating VALUES(17, 8, 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', 3.5);
INSERT INTO rating VALUES(17, 9, 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', 8.5);
INSERT INTO rating VALUES(17, 10, 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', 9);
INSERT INTO rating VALUES(17, 11, 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', 9.5);
INSERT INTO rating VALUES(17, 12, 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.', 8.5);
INSERT INTO rating VALUES(17, 13, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', 7.5);
INSERT INTO rating VALUES(17, 14, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', 2);
INSERT INTO rating VALUES(17, 15, 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 5.5);
INSERT INTO rating VALUES(17, 16, 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus.', 3.5);
INSERT INTO rating VALUES(17, 17, 'Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', 4.5);
INSERT INTO rating VALUES(17, 18, 'Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus.', 6.5);
INSERT INTO rating VALUES(17, 19, 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 3.5);
INSERT INTO rating VALUES(17, 20, 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.', 8.5);
INSERT INTO rating VALUES(19, 1, 'Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue.', 9);
INSERT INTO rating VALUES(19, 2, 'Morbi a ipsum. Integer a nibh. In quis justo.', 9.5);
INSERT INTO rating VALUES(19, 3, 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', 8.5);
INSERT INTO rating VALUES(19, 4, 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 7.5);
INSERT INTO rating VALUES(19, 5, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', 2);
INSERT INTO rating VALUES(19, 6, 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst.', 3.5);
INSERT INTO rating VALUES(19, 7, 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.', 8.5);
INSERT INTO rating VALUES(19, 8, 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.', 9);
INSERT INTO rating VALUES(19, 9, 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.', 9.5);
INSERT INTO rating VALUES(19, 10, 'Morbi a ipsum. Integer a nibh. In quis justo.', 8.5);
INSERT INTO rating VALUES(19, 11, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 7.5);
INSERT INTO rating VALUES(19, 12, 'Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', 2);
INSERT INTO rating VALUES(19, 13, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 5.5);
INSERT INTO rating VALUES(19, 14, 'Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', 3.5);
INSERT INTO rating VALUES(19, 15, 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', 4.5);
INSERT INTO rating VALUES(19, 16, 'In congue. Etiam justo. Etiam pretium iaculis justo.', 2);
INSERT INTO rating VALUES(19, 17, 'Aliquam erat volutpat. In congue. Etiam justo.', 3.5);
INSERT INTO rating VALUES(19, 18, 'In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', 8.5);
INSERT INTO rating VALUES(19, 20, 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', 9);
INSERT INTO rating VALUES(18, 4, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 9.5);
INSERT INTO rating VALUES(18, 6, 'Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat.', 8.5);
INSERT INTO rating VALUES(18, 8, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', 7.5);
INSERT INTO rating VALUES(18, 9, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 2);
INSERT INTO rating VALUES(18, 10, 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.', 5.5);
INSERT INTO rating VALUES(18, 12, 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.', 3.5);
INSERT INTO rating VALUES(18, 14, 'Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', 4.5);
INSERT INTO rating VALUES(18, 15, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 6.5);
INSERT INTO rating VALUES(18, 16, 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.', 3.5);
INSERT INTO rating VALUES(18, 18, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 8.5);
INSERT INTO rating VALUES(18, 20, 'Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.', 9);
INSERT INTO rating VALUES(20, 1, 'Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl.', 9.5);
INSERT INTO rating VALUES(20, 3, 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.', 8.5);
INSERT INTO rating VALUES(20, 4, 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', 7.5);
INSERT INTO rating VALUES(20, 5, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 2);
INSERT INTO rating VALUES(20, 7, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 5.5);
INSERT INTO rating VALUES(20, 8, 'Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', 3.5);
INSERT INTO rating VALUES(20, 9, 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', 4.5);
INSERT INTO rating VALUES(20, 10, 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 6.5);
INSERT INTO rating VALUES(20, 11, 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 3.5);
INSERT INTO rating VALUES(20, 14, 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', 8.5);
INSERT INTO rating VALUES(20, 15, 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh.', 9);
INSERT INTO rating VALUES(20, 16, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 9.5);
INSERT INTO rating VALUES(20, 17, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', 8.5);
INSERT INTO rating VALUES(20, 18, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', 7.5);
INSERT INTO rating VALUES(20, 19, 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', 2);
}
INSERT INTO rating VALUES(21, 1, 'Uper vala uper bulaega toh uper chal jayenge niche bulayega toh niche bul jayenge, Aap bhi dekhie maja aa jayega', 10);



--- premier
SET DATESTYLE = DMY;
INSERT INTO premier VALUES(2, 1, 1, '17/11/2017');
INSERT INTO premier VALUES(5, 1, 5, '17/11/2017');
INSERT INTO premier VALUES(8, 1, 10, '17/11/2017');
INSERT INTO premier VALUES(16, 2, 2, '17/11/2017');
INSERT INTO premier VALUES(19, 2, 6, '17/11/2017');
INSERT INTO premier VALUES(5, 2, 12, '17/11/2017');
INSERT INTO premier VALUES(2, 3, 1, '17/11/2017');
INSERT INTO premier VALUES(19, 3, 4, '17/11/2017');
INSERT INTO premier VALUES(16, 3, 9, '17/11/2017');
INSERT INTO premier VALUES(8, 4, 3, '17/11/2017');
INSERT INTO premier VALUES(16, 4, 11, '17/11/2017');
INSERT INTO premier VALUES(19, 5, 1, '17/11/2017');
INSERT INTO premier VALUES(2, 5, 6, '17/11/2017');
INSERT INTO premier VALUES(8, 5, 14, '17/11/2017');
INSERT INTO premier VALUES(5, 6, 2, '17/11/2017');
INSERT INTO premier VALUES(16, 6, 6, '17/11/2017');
INSERT INTO premier VALUES(2, 6, 11, '17/11/2017');
INSERT INTO premier VALUES(5, 7, 1, '17/11/2017');
INSERT INTO premier VALUES(19, 7, 4, '17/11/2017');
INSERT INTO premier VALUES(5, 7, 8, '17/11/2017');
INSERT INTO premier VALUES(16, 7, 13, '17/11/2017');
INSERT INTO premier VALUES(19, 8, 3, '17/11/2017');
INSERT INTO premier VALUES(19, 8, 7, '17/11/2017');
INSERT INTO premier VALUES(2, 8, 12, '17/11/2017');
INSERT INTO premier VALUES(5, 9, 2, '17/11/2017');
INSERT INTO premier VALUES(8, 9, 7, '17/11/2017');
INSERT INTO premier VALUES(16, 10, 1, '17/11/2017');
INSERT INTO premier VALUES(19, 10, 6, '17/11/2017');
INSERT INTO premier VALUES(2, 10, 10, '17/11/2017');
INSERT INTO premier VALUES(5, 11, 3, '17/11/2017');
INSERT INTO premier VALUES(8, 11, 7, '17/11/2017');
INSERT INTO premier VALUES(16, 11, 11, '17/11/2017');
INSERT INTO premier VALUES(19, 12, 1, '17/11/2017');
INSERT INTO premier VALUES(16, 12, 5, '17/11/2017');
INSERT INTO premier VALUES(19, 13, 3, '17/11/2017');
INSERT INTO premier VALUES(5, 13, 7, '17/11/2017');
INSERT INTO premier VALUES(5, 13, 14, '17/11/2017');
INSERT INTO premier VALUES(8, 14, 2, '17/11/2017');
INSERT INTO premier VALUES(16, 14, 6, '17/11/2017');
INSERT INTO premier VALUES(19, 14, 12, '17/11/2017');
INSERT INTO premier VALUES(2, 15, 1, '17/11/2017');
INSERT INTO premier VALUES(5, 15, 4, '17/11/2017');
INSERT INTO premier VALUES(8, 15, 8, '17/11/2017');
INSERT INTO premier VALUES(16, 16, 2, '17/11/2017');
INSERT INTO premier VALUES(2, 16, 6, '17/11/2017');
INSERT INTO premier VALUES(8, 16, 10, '17/11/2017');
INSERT INTO premier VALUES(5, 17, 3, '17/11/2017');
INSERT INTO premier VALUES(19, 17, 14, '17/11/2017');
INSERT INTO premier VALUES(16, 18, 1, '17/11/2017');
INSERT INTO premier VALUES(8, 18, 4, '17/11/2017');
INSERT INTO premier VALUES(5, 18, 9, '17/11/2017');
INSERT INTO premier VALUES(8, 18, 13, '17/11/2017');
INSERT INTO premier VALUES(2, 19, 2, '17/11/2017');
INSERT INTO premier VALUES(19, 19, 5, '17/11/2017');
INSERT INTO premier VALUES(5, 19, 9, '17/11/2017');
INSERT INTO premier VALUES(2, 20, 2, '17/11/2017');
INSERT INTO premier VALUES(8, 20, 8, '17/11/2017');
INSERT INTO premier VALUES(2, 21, 2, '17/11/2017');
INSERT INTO premier VALUES(19, 21, 6, '17/11/2017');
INSERT INTO premier VALUES(2, 21, 10, '17/11/2017');
INSERT INTO premier VALUES(5, 22, 1, '17/11/2017');
INSERT INTO premier VALUES(8, 22, 8, '17/11/2017');
INSERT INTO premier VALUES(19, 23, 1, '17/11/2017');
INSERT INTO premier VALUES(2, 23, 5, '17/11/2017');
INSERT INTO premier VALUES(19, 23, 9, '17/11/2017');
INSERT INTO premier VALUES(2, 1, 1, '18/11/2017');
INSERT INTO premier VALUES(5, 1, 5, '18/11/2017');
INSERT INTO premier VALUES(8, 1, 10, '18/11/2017');
INSERT INTO premier VALUES(16, 2, 2, '18/11/2017');
INSERT INTO premier VALUES(19, 2, 6, '18/11/2017');
INSERT INTO premier VALUES(5, 2, 12, '18/11/2017');
INSERT INTO premier VALUES(2, 3, 1, '18/11/2017');
INSERT INTO premier VALUES(19, 3, 4, '18/11/2017');
INSERT INTO premier VALUES(16, 3, 9, '18/11/2017');
INSERT INTO premier VALUES(8, 4, 3, '18/11/2017');
INSERT INTO premier VALUES(16, 4, 11, '18/11/2017');
INSERT INTO premier VALUES(19, 5, 1, '18/11/2017');
INSERT INTO premier VALUES(2, 5, 6, '18/11/2017');
INSERT INTO premier VALUES(8, 5, 14, '18/11/2017');
INSERT INTO premier VALUES(5, 6, 2, '18/11/2017');
INSERT INTO premier VALUES(16, 6, 6, '18/11/2017');
INSERT INTO premier VALUES(2, 6, 11, '18/11/2017');
INSERT INTO premier VALUES(5, 7, 1, '18/11/2017');
INSERT INTO premier VALUES(19, 7, 4, '18/11/2017');
INSERT INTO premier VALUES(5, 7, 8, '18/11/2017');
INSERT INTO premier VALUES(16, 7, 13, '18/11/2017');
INSERT INTO premier VALUES(19, 8, 3, '18/11/2017');
INSERT INTO premier VALUES(19, 8, 7, '18/11/2017');
INSERT INTO premier VALUES(2, 8, 12, '18/11/2017');
INSERT INTO premier VALUES(5, 9, 2, '18/11/2017');
INSERT INTO premier VALUES(8, 9, 7, '18/11/2017');
INSERT INTO premier VALUES(16, 10, 1, '18/11/2017');
INSERT INTO premier VALUES(19, 10, 6, '18/11/2017');
INSERT INTO premier VALUES(2, 10, 10, '18/11/2017');
INSERT INTO premier VALUES(5, 11, 3, '18/11/2017');
INSERT INTO premier VALUES(8, 11, 7, '18/11/2017');
INSERT INTO premier VALUES(16, 11, 11, '18/11/2017');
INSERT INTO premier VALUES(19, 12, 1, '18/11/2017');
INSERT INTO premier VALUES(16, 12, 5, '18/11/2017');
INSERT INTO premier VALUES(19, 13, 3, '18/11/2017');
INSERT INTO premier VALUES(5, 13, 7, '18/11/2017');
INSERT INTO premier VALUES(5, 13, 14, '18/11/2017');
INSERT INTO premier VALUES(8, 14, 2, '18/11/2017');
INSERT INTO premier VALUES(16, 14, 6, '18/11/2017');
INSERT INTO premier VALUES(19, 14, 12, '18/11/2017');
INSERT INTO premier VALUES(2, 15, 1, '18/11/2017');
INSERT INTO premier VALUES(5, 15, 4, '18/11/2017');
INSERT INTO premier VALUES(8, 15, 8, '18/11/2017');
INSERT INTO premier VALUES(16, 16, 2, '18/11/2017');
INSERT INTO premier VALUES(2, 16, 6, '18/11/2017');
INSERT INTO premier VALUES(8, 16, 10, '18/11/2017');
INSERT INTO premier VALUES(5, 17, 3, '18/11/2017');
INSERT INTO premier VALUES(19, 17, 14, '18/11/2017');
INSERT INTO premier VALUES(16, 18, 1, '18/11/2017');
INSERT INTO premier VALUES(8, 18, 4, '18/11/2017');
INSERT INTO premier VALUES(5, 18, 9, '18/11/2017');
INSERT INTO premier VALUES(8, 18, 13, '18/11/2017');
INSERT INTO premier VALUES(2, 19, 2, '18/11/2017');
INSERT INTO premier VALUES(19, 19, 5, '18/11/2017');
INSERT INTO premier VALUES(5, 19, 9, '18/11/2017');
INSERT INTO premier VALUES(2, 20, 2, '18/11/2017');
INSERT INTO premier VALUES(8, 20, 8, '18/11/2017');
INSERT INTO premier VALUES(2, 21, 2, '18/11/2017');
INSERT INTO premier VALUES(19, 21, 6, '18/11/2017');
INSERT INTO premier VALUES(2, 21, 10, '18/11/2017');
INSERT INTO premier VALUES(5, 22, 1, '18/11/2017');
INSERT INTO premier VALUES(8, 22, 8, '18/11/2017');
INSERT INTO premier VALUES(19, 23, 1, '18/11/2017');
INSERT INTO premier VALUES(2, 23, 5, '18/11/2017');
INSERT INTO premier VALUES(19, 23, 9, '18/11/2017');
INSERT INTO premier VALUES(2, 1, 1, '19/11/2017');
INSERT INTO premier VALUES(5, 1, 5, '19/11/2017');
INSERT INTO premier VALUES(8, 1, 10, '19/11/2017');
INSERT INTO premier VALUES(16, 2, 2, '19/11/2017');
INSERT INTO premier VALUES(19, 2, 6, '19/11/2017');
INSERT INTO premier VALUES(5, 2, 12, '19/11/2017');
INSERT INTO premier VALUES(2, 3, 1, '19/11/2017');
INSERT INTO premier VALUES(19, 3, 4, '19/11/2017');
INSERT INTO premier VALUES(16, 3, 9, '19/11/2017');
INSERT INTO premier VALUES(8, 4, 3, '19/11/2017');
INSERT INTO premier VALUES(16, 4, 11, '19/11/2017');
INSERT INTO premier VALUES(19, 5, 1, '19/11/2017');
INSERT INTO premier VALUES(2, 5, 6, '19/11/2017');
INSERT INTO premier VALUES(8, 5, 14, '19/11/2017');
INSERT INTO premier VALUES(5, 6, 2, '19/11/2017');
INSERT INTO premier VALUES(16, 6, 6, '19/11/2017');
INSERT INTO premier VALUES(2, 6, 11, '19/11/2017');
INSERT INTO premier VALUES(5, 7, 1, '19/11/2017');
INSERT INTO premier VALUES(19, 7, 4, '19/11/2017');
INSERT INTO premier VALUES(5, 7, 8, '19/11/2017');
INSERT INTO premier VALUES(16, 7, 13, '19/11/2017');
INSERT INTO premier VALUES(19, 8, 3, '19/11/2017');
INSERT INTO premier VALUES(19, 8, 7, '19/11/2017');
INSERT INTO premier VALUES(2, 8, 12, '19/11/2017');
INSERT INTO premier VALUES(5, 9, 2, '19/11/2017');
INSERT INTO premier VALUES(8, 9, 7, '19/11/2017');
INSERT INTO premier VALUES(16, 10, 1, '19/11/2017');
INSERT INTO premier VALUES(19, 10, 6, '19/11/2017');
INSERT INTO premier VALUES(2, 10, 10, '19/11/2017');
INSERT INTO premier VALUES(5, 11, 3, '19/11/2017');
INSERT INTO premier VALUES(8, 11, 7, '19/11/2017');
INSERT INTO premier VALUES(16, 11, 11, '19/11/2017');
INSERT INTO premier VALUES(19, 12, 1, '19/11/2017');
INSERT INTO premier VALUES(16, 12, 5, '19/11/2017');
INSERT INTO premier VALUES(19, 13, 3, '19/11/2017');
INSERT INTO premier VALUES(5, 13, 7, '19/11/2017');
INSERT INTO premier VALUES(5, 13, 14, '19/11/2017');
INSERT INTO premier VALUES(8, 14, 2, '19/11/2017');
INSERT INTO premier VALUES(16, 14, 6, '19/11/2017');
INSERT INTO premier VALUES(19, 14, 12, '19/11/2017');
INSERT INTO premier VALUES(2, 15, 1, '19/11/2017');
INSERT INTO premier VALUES(5, 15, 4, '19/11/2017');
INSERT INTO premier VALUES(8, 15, 8, '19/11/2017');
INSERT INTO premier VALUES(16, 16, 2, '19/11/2017');
INSERT INTO premier VALUES(2, 16, 6, '19/11/2017');
INSERT INTO premier VALUES(8, 16, 10, '19/11/2017');
INSERT INTO premier VALUES(5, 17, 3, '19/11/2017');
INSERT INTO premier VALUES(19, 17, 14, '19/11/2017');
INSERT INTO premier VALUES(16, 18, 1, '19/11/2017');
INSERT INTO premier VALUES(8, 18, 4, '19/11/2017');
INSERT INTO premier VALUES(5, 18, 9, '19/11/2017');
INSERT INTO premier VALUES(8, 18, 13, '19/11/2017');
INSERT INTO premier VALUES(2, 19, 2, '19/11/2017');
INSERT INTO premier VALUES(19, 19, 5, '19/11/2017');
INSERT INTO premier VALUES(5, 19, 9, '19/11/2017');
INSERT INTO premier VALUES(2, 20, 2, '19/11/2017');
INSERT INTO premier VALUES(8, 20, 8, '19/11/2017');
INSERT INTO premier VALUES(2, 21, 2, '19/11/2017');
INSERT INTO premier VALUES(19, 21, 6, '19/11/2017');
INSERT INTO premier VALUES(2, 21, 10, '19/11/2017');
INSERT INTO premier VALUES(5, 22, 1, '19/11/2017');
INSERT INTO premier VALUES(8, 22, 8, '19/11/2017');
INSERT INTO premier VALUES(19, 23, 1, '19/11/2017');
INSERT INTO premier VALUES(2, 23, 5, '19/11/2017');
INSERT INTO premier VALUES(19, 23, 9, '19/11/2017');
INSERT INTO premier VALUES(2, 1, 1, '20/11/2017');
INSERT INTO premier VALUES(5, 1, 5, '20/11/2017');
INSERT INTO premier VALUES(8, 1, 10, '20/11/2017');
INSERT INTO premier VALUES(16, 2, 2, '20/11/2017');
INSERT INTO premier VALUES(19, 2, 6, '20/11/2017');
INSERT INTO premier VALUES(5, 2, 12, '20/11/2017');
INSERT INTO premier VALUES(2, 3, 1, '20/11/2017');
INSERT INTO premier VALUES(19, 3, 4, '20/11/2017');
INSERT INTO premier VALUES(16, 3, 9, '20/11/2017');
INSERT INTO premier VALUES(8, 4, 3, '20/11/2017');
INSERT INTO premier VALUES(16, 4, 11, '20/11/2017');
INSERT INTO premier VALUES(19, 5, 1, '20/11/2017');
INSERT INTO premier VALUES(2, 5, 6, '20/11/2017');
INSERT INTO premier VALUES(8, 5, 14, '20/11/2017');
INSERT INTO premier VALUES(5, 6, 2, '20/11/2017');
INSERT INTO premier VALUES(16, 6, 6, '20/11/2017');
INSERT INTO premier VALUES(2, 6, 11, '20/11/2017');
INSERT INTO premier VALUES(5, 7, 1, '20/11/2017');
INSERT INTO premier VALUES(19, 7, 4, '20/11/2017');
INSERT INTO premier VALUES(5, 7, 8, '20/11/2017');
INSERT INTO premier VALUES(16, 7, 13, '20/11/2017');
INSERT INTO premier VALUES(19, 8, 3, '20/11/2017');
INSERT INTO premier VALUES(19, 8, 7, '20/11/2017');
INSERT INTO premier VALUES(2, 8, 12, '20/11/2017');
INSERT INTO premier VALUES(5, 9, 2, '20/11/2017');
INSERT INTO premier VALUES(8, 9, 7, '20/11/2017');
INSERT INTO premier VALUES(16, 10, 1, '20/11/2017');
INSERT INTO premier VALUES(19, 10, 6, '20/11/2017');
INSERT INTO premier VALUES(2, 10, 10, '20/11/2017');
INSERT INTO premier VALUES(5, 11, 3, '20/11/2017');
INSERT INTO premier VALUES(8, 11, 7, '20/11/2017');
INSERT INTO premier VALUES(16, 11, 11, '20/11/2017');
INSERT INTO premier VALUES(19, 12, 1, '20/11/2017');
INSERT INTO premier VALUES(16, 12, 5, '20/11/2017');
INSERT INTO premier VALUES(19, 13, 3, '20/11/2017');
INSERT INTO premier VALUES(5, 13, 7, '20/11/2017');
INSERT INTO premier VALUES(5, 13, 14, '20/11/2017');
INSERT INTO premier VALUES(8, 14, 2, '20/11/2017');
INSERT INTO premier VALUES(16, 14, 6, '20/11/2017');
INSERT INTO premier VALUES(19, 14, 12, '20/11/2017');
INSERT INTO premier VALUES(2, 15, 1, '20/11/2017');
INSERT INTO premier VALUES(5, 15, 4, '20/11/2017');
INSERT INTO premier VALUES(8, 15, 8, '20/11/2017');
INSERT INTO premier VALUES(16, 16, 2, '20/11/2017');
INSERT INTO premier VALUES(2, 16, 6, '20/11/2017');
INSERT INTO premier VALUES(8, 16, 10, '20/11/2017');
INSERT INTO premier VALUES(5, 17, 3, '20/11/2017');
INSERT INTO premier VALUES(19, 17, 14, '20/11/2017');
INSERT INTO premier VALUES(16, 18, 1, '20/11/2017');
INSERT INTO premier VALUES(8, 18, 4, '20/11/2017');
INSERT INTO premier VALUES(5, 18, 9, '20/11/2017');
INSERT INTO premier VALUES(8, 18, 13, '20/11/2017');
INSERT INTO premier VALUES(2, 19, 2, '20/11/2017');
INSERT INTO premier VALUES(19, 19, 5, '20/11/2017');
INSERT INTO premier VALUES(5, 19, 9, '20/11/2017');
INSERT INTO premier VALUES(2, 20, 2, '20/11/2017');
INSERT INTO premier VALUES(8, 20, 8, '20/11/2017');
INSERT INTO premier VALUES(2, 21, 2, '20/11/2017');
INSERT INTO premier VALUES(19, 21, 6, '20/11/2017');
INSERT INTO premier VALUES(2, 21, 10, '20/11/2017');
INSERT INTO premier VALUES(5, 22, 1, '20/11/2017');
INSERT INTO premier VALUES(8, 22, 8, '20/11/2017');
INSERT INTO premier VALUES(19, 23, 1, '20/11/2017');
INSERT INTO premier VALUES(2, 23, 5, '20/11/2017');
INSERT INTO premier VALUES(19, 23, 9, '20/11/2017');