/*
misc. notes:

ssh cs336@cs336-13.rutgers.edu
cs930396

source C:/Users/Andrew/workspace/CS336proj/db/schema.sql
*/


drop trigger if exists maintainBlogHierarchy;
drop trigger if exists removeDeletedMessages;
drop table if exists hasFriend;
drop table if exists hasMessage;
drop table if exists hasHobby;
drop table if exists hasCar;
drop table if exists befriend;
drop table if exists BlogComment;
drop table if exists BlogEntry;
drop table if exists BlogHierarchy;
drop table if exists Blog;
drop table if exists Car;
drop table if exists Hobby;
drop table if exists Messages;
drop table if exists Friend;
drop table if exists Profile;
drop table if exists Users;


CREATE TABLE Users(
	userID INTEGER,
	username VARCHAR(30)
		NOT NULL
		UNIQUE,
	userPhone VARCHAR(10),
	userFirstName VARCHAR(50) NOT NULL,
	userLastName VARCHAR(50) NOT NULL,
	userAddrState VARCHAR(2),
	userAddrCity VARCHAR(75),
	userAddrStreet VARCHAR(100),
	userEmail VARCHAR(50) NOT NULL,
	userPW VARCHAR(50) NOT NULL,
	userDateJoined TIMESTAMP
		NOT NULL
		DEFAULT '0000-00-00 00:00:00', /* mySQL doesn't allow two timestamps to default to CURRENT_TIMESTAMP*/
	userDateLastLogin TIMESTAMP
		NOT NULL
		DEFAULT CURRENT_TIMESTAMP,
	userAdmin BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY (userID)
	);
	
CREATE VIEW Administrator(
	userID INTEGER,
	username VARCHAR(30)
		NOT NULL
		UNIQUE,
	userPhone VARCHAR(10),
	userFirstName VARCHAR(50) NOT NULL,
	userLastName VARCHAR(50) NOT NULL,
	userAddrState VARCHAR(2),
	userAddrCity VARCHAR(75),
	userAddrStreet VARCHAR(100),
	userEmail VARCHAR(50) NOT NULL,
	userPW VARCHAR(50) NOT NULL,
	userDateJoined TIMESTAMP
		NOT NULL
		DEFAULT '0000-00-00 00:00:00', /* mySQL doesn't allow two timestamps to default to CURRENT_TIMESTAMP*/
	userDateLastLogin TIMESTAMP
		NOT NULL
		DEFAULT CURRENT_TIMESTAMP,
	userAdmin BOOLEAN NOT NULL DEFAULT 0,
	PRIMARY KEY (userID)
	) AS
	SELECT *
	FROM Users u
	WHERE u.userAdmin = 1;

/*CREATE TABLE Friend(
	userID INTEGER,
	frDateBefriended TIMESTAMP
		NOT NULL
		DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY(userID),
	FOREIGN KEY(userID) REFERENCES Users(userID)
		on DELETE CASCADE
		on UPDATE CASCADE
	);*/
	
CREATE TABLE Profile(
	pID INTEGER AUTO_INCREMENT,
	PRIMARY KEY (pID),
	/* User hasPofile*/
	userID INTEGER NOT NULL,
	FOREIGN KEY(userID) REFERENCES Users(userID)
		on DELETE CASCADE
		on UPDATE CASCADE
	);
	
CREATE TABLE Blog(
	bTitle VARCHAR(250),
	PRIMARY KEY (bTitle),
	/* Profile hasBlog */
	pID INTEGER NOT NULL,
	FOREIGN KEY(pID) REFERENCES Profile(pID)
		on DELETE CASCADE
		on UPDATE CASCADE
	);
	
CREATE TABLE BlogHierarchy(
	bhNodeID INTEGER AUTO_INCREMENT,
	bhString VARCHAR(100) NOT NULL,
	bhNodeParent INTEGER DEFAULT NULL,
	
	PRIMARY KEY(bhNodeID)
	);

CREATE TABLE BlogEntry(
	beID INTEGER AUTO_INCREMENT, 
	beTitle VARCHAR(250),
	beText VARCHAR(5000),
	beDatePosted TIMESTAMP
		NOT NULL
		DEFAULT CURRENT_TIMESTAMP,
	beTags VARCHAR(250),
	
	/*beCategory VARCHAR (20),*/
	beHierarchyBottom INTEGER DEFAULT NULL,
	FOREIGN KEY(beHierarchyBottom) REFERENCES BlogHierarchy(bhNodeID)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	
	PRIMARY KEY (beID),
	/* Blog hasBlogEntry*/
	bTitle VARCHAR(50) NOT NULL,
	FOREIGN KEY(bTitle) REFERENCES Blog(bTitle)
		on DELETE CASCADE
		on UPDATE CASCADE
	);

CREATE TABLE BlogComment(
	bcID INTEGER AUTO_INCREMENT,
	beID INTEGER,
	bcTitle VARCHAR(250),
	bcText VARCHAR(5000),
	bcDatePosted TIMESTAMP
		NOT NULL
		DEFAULT CURRENT_TIMESTAMP,
	bcUserId INTEGER,
	PRIMARY KEY (beID, bcID),
	FOREIGN KEY(beID) REFERENCES BlogEntry(beID)
		on DELETE CASCADE
		on UPDATE CASCADE,
	FOREIGN KEY(bcUserId) REFERENCES Users(userID)
		on DELETE SET NULL
		on UPDATE CASCADE
	);
	
CREATE TABLE Messages(
	msgID INTEGER,
	msgText VARCHAR(500),
	msgDatePosted TIMESTAMP
		NOT NULL
		DEFAULT CURRENT_TIMESTAMP,
	msgFromID INTEGER NOT NULL,
	msgToID INTEGER NOT NULL,
	msgDeletedBySender BOOLEAN NOT NULL DEFAULT false,
	msgDeletedByReceiver BOOLEAN NOT NULL DEFAULT false,
	PRIMARY KEY (msgID),
	FOREIGN KEY (msgFromID) REFERENCES Users(userID)
		on DELETE CASCADE
		on UPDATE CASCADE,
	FOREIGN KEY (msgToID) REFERENCES Users(userID)
		on DELETE CASCADE
		on UPDATE CASCADE
	);

CREATE TABLE Car(
	carID INTEGER AUTO_INCREMENT,
	carMake VARCHAR(50),
	carModel VARCHAR(50),
	carType VARCHAR(50),
	carColor VARCHAR(50),
	carYear INTEGER,
	carEngine VARCHAR(50),
	carModifications VARCHAR(1000),
	PRIMARY KEY (carID)
	);
	
CREATE VIEW classicCar(carID INTEGER AUTO_INCREMENT,
	carMake VARCHAR(50),
	carModel VARCHAR(50),
	carType VARCHAR(50),
	carColor VARCHAR(50),
	carYear INTEGER,
	carEngine VARCHAR(50),
	carModifications VARCHAR(1000),
	PRIMARY KEY (carID)
	) AS
	SELECT * 
	FROM Car c
	WHERE c.Year <= 1985;

CREATE TABLE Hobby(
	hID INTEGER AUTO_INCREMENT,
	hTitle VARCHAR(100),
	hText VARCHAR(500),
	hDatePosted TIMESTAMP
		NOT NULL
		DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (hID)
	);

CREATE TABLE befriend(
	/*accepted BOOLEAN NOT NULL,*/
	bfDateSubmitted TIMESTAMP
		NOT NULL
		DEFAULT CURRENT_TIMESTAMP,
	initiatorID INTEGER,
	recipientID INTEGER,
	PRIMARY KEY(initiatorID, recipientID),
	FOREIGN KEY(initiatorID) REFERENCES Users(userID)
		on DELETE CASCADE
		on UPDATE CASCADE,
	FOREIGN KEY(recipientID) REFERENCES Users(userID)
		on DELETE CASCADE
		on UPDATE CASCADE
	);
CREATE TABLE hasFriend(
	pID INTEGER, /* profile of user who has this friend */
	userID INTEGER, /* friend's userID */
	frDateBefriended TIMESTAMP
		NOT NULL
		DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY(pID, userID),
	FOREIGN KEY(userID) REFERENCES Users(userID)
		on DELETE CASCADE
		on UPDATE CASCADE,
	FOREIGN KEY(pID) REFERENCES Profile(pID)
		on DELETE CASCADE
		on UPDATE CASCADE
	);
CREATE TABLE hasMessage(
	pID INTEGER,
	msgID INTEGER,
	PRIMARY KEY(pID, msgID),
	FOREIGN KEY(pID) REFERENCES Profile(pID)
		on DELETE CASCADE
		on UPDATE CASCADE,
	FOREIGN KEY(msgID) REFERENCES Messages(msgID)
		on DELETE CASCADE
		on UPDATE CASCADE
	);
	
CREATE TABLE hasCar(
	pID INTEGER,
	carID INTEGER,
	PRIMARY KEY(pID, carID),
	FOREIGN KEY(pID) REFERENCES Profile(pID)
		on DELETE CASCADE
		on UPDATE CASCADE,
	FOREIGN KEY(carID) REFERENCES Car(carID)
		on DELETE CASCADE
		on UPDATE CASCADE
	);
CREATE TABLE hasHobby(
	pID INTEGER,
	hID INTEGER,
	PRIMARY KEY(pID, hID),
	FOREIGN KEY(pID) REFERENCES Profile(pID)
		on DELETE CASCADE
		on UPDATE CASCADE,
	FOREIGN KEY(hID) REFERENCES Hobby(hID)
		on DELETE CASCADE
		on UPDATE CASCADE
	);
	
/*CREATE ASSERTION friend_in_profile
	CHECK (NOT EXISTS (
			SELECT *
			FROM Friend f
			WHERE f.userID NOT IN (SELECT hasf.userID FROM hasFriend hasF));
CREATE ASSERTION friend_in_profile
	CHECK (NOT EXISTS (
			SELECT *
			FROM Friend f
			WHERE f.userID NOT IN (SELECT hasf.userID FROM hasFriend hasF));
*/
	
/* After deleting a node in a tree, this will reattach all children
 * of that deleted node back into the tree by making their "grandparent" node
 * their new "parent" node.
 * 
 * mySQL doesn't support altering/deleting from the same table
 * that the trigger was envoked on!!!! 
 */
/*
DELIMITER //
CREATE TRIGGER maintainBlogHierarchy
	AFTER DELETE ON BlogHierarchy
	FOR EACH ROW
	BEGIN
		-- start the looping through the children with the lowest child ID
		DECLARE child_node_id INTEGER;
		SET child_node_id =	(SELECT MIN(bh.bhNodeID)
							FROM BlogHierarchy bh
							WHERE bh.bhNodeParent = OLD.bhNodeID);
								
		WHILE (child_node_id IS NOT NULL)
		DO
			-- reconnect the child to the hierarchy/tree since its parent was deleted.
			UPDATE BlogHierarchy
				SET bhNodeParent = OLD.bhNodeParent
				WHERE bhNodeID = child_node_id;
			
			-- continue looping through the child nodes of the deleted node
			SET child_node_id =	(SELECT MIN(bh.bhNodeID)
								FROM BlogHierarchy bh
								WHERE bh.bhNodeParent = OLD.bhNodeID
									AND
									bh.bhNodeID > child_node_id);
		END WHILE;
	END;
//
DELIMITER ;
*/

/* Completely remove messages that have been 
 * "deleted" by both the sender and receiver.
 * 
 * mySQL doesn't support altering/deleting from the same table
 * that the trigger was envoked on!!!! 
 */
/*
DELIMITER //
CREATE TRIGGER removeDeletedMessages
	AFTER UPDATE ON Messages
	FOR EACH ROW
	BEGIN
		IF (NEW.msgDeletedBySender = true AND NEW.msgDeletedByReceiver = true) THEN
			DELETE FROM Messages WHERE msgID = NEW.msgID;
		END IF;

	END;
//
DELIMITER ;
*/

SELECT '<inserting some data for testing purposes>' AS ' ';

INSERT INTO Users(userID,username,userFirstName,userLastName,userEmail,userPW,userDateJoined,userDateLastLogin,userAdmin, userAddrState, userAddrCity, userAddrStreet, userPhone)
	values(1, 'JonAlvarez', 'Jonathan', 'Alvarez', 'epedemic@eden.rutgers.edu', 'pw', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 'NJ', 'Trenton', '123 Main St.', 6091234567);
insert into Users(userID, username, userFirstName, userLastName, userEmail, userPW, userDateJoined, userDateLastLogin, userAdmin)
	values(2, 'AFreed', 'Andrew', 'Freedgood', 'afreed@eden.rutgers.edu', 'pw', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1);
insert into Users(userID, username, userFirstName, userLastName, userEmail, userPW, userDateJoined, userDateLastLogin, userAdmin, userAddrState, userAddrCity)
	values(3, 'racergirlxoxo', 'Rebecca', 'Chambers', 'RebCham@gmail.com', 'pw', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 'NJ', 'Bruns');

insert into Profile(pID, userID) values(1, 1);
insert into Profile(pID, userID) values(2, 2);
insert into Profile(pID, userID) values(3, 3);

insert into Blog(bTitle, pID) values('Racing', 3);
insert into Blog(bTitle, pID) values('AndrewBlog', 2);

insert into BlogEntry(beID, beTitle, beText, beTags, bTitle)
	values(1, 'Andrew First Blog', 'Computer Science is Fun', 
	'There is nothing more gratifying than staring at a computer screen all day', 'AndrewBlog');

insert into BlogHierarchy(bhNodeID, bhString, bhNodeParent)
	values (1, 'Cars', NULL);
insert into BlogHierarchy(bhNodeID, bhString, bhNodeParent)
	values (2, 'Sedans', 1);
insert into BlogHierarchy(bhNodeID, bhString, bhNodeParent)
	values (3, 'Ford', 2);
insert into BlogHierarchy(bhNodeID, bhString, bhNodeParent)
	values (4, 'Mazda', 2);
insert into BlogHierarchy(bhNodeID, bhString, bhNodeParent)
	values (5, 'Racing', 1);
insert into BlogHierarchy(bhNodeID, bhString, bhNodeParent)
	values (6, 'Street', 5);
insert into BlogHierarchy(bhNodeID, bhString, bhNodeParent)
	values (7, 'Professional', 5);
	
insert into BlogEntry(beID, beTitle, beText, beTags, bTitle, beHierarchyBottom)
	values(2, 'Racing at Seaside', 'I won a few races at seaside today. The competition there is horrible.', 'seaside, racing, competition', 'Racing', 6);
insert into BlogEntry(beID, beTitle, beText, beTags, bTitle, beHierarchyBottom)
	values(3, 'Andrew Second Blog', 'I recently purchased a red mazda 2009 in celebration of graduating from Rutgers.', 'graduation, mazda', 'AndrewBlog', 4);
insert into BlogEntry(beID, beTitle, beText, beTags, bTitle, beHierarchyBottom)
	values(4, 'Andrew Third Blog', 'My brother is also graduating and he decided to get a Ford F350.', 'ford, graduation', 'AndrewBlog', 3);

insert into Messages(msgID, msgFromID, msgToID, msgText) values (1, 1, 2, 'Good race the other day, up for another later tomorrow?');
insert into Messages(msgID, msgFromID, msgToID, msgText) values (2, 3, 2, 'I like your car! Care for a money match?');
update Messages set msgDeletedBySender=true where msgID = 1;

insert into Car(carMake, carModel, carType, carColor, carYear, carEngine, carModifications)
	values('Mazda', 'RX8', 'Compact', 'Red', '2008', 'V8', 'spoiler');
insert into Car(carMake, carModel, carType, carColor, carYear, carEngine)
	values('Ford', 'Mustang GT', 'Hatchback', 'White', '1989', '(5.0 HO/ T-5)'); /* extra credit? ;D */
insert into Car(carMake, carModel, carType, carColor, carYear, carEngine, carModifications)
	values('Ford', 'F350', 'Truck', 'White', '1999', 'V8 3.0L', 'windshield');
insert into Car(carMake, carModel, carType, carColor, carYear, carEngine, carModifications)
	values('Toyota', 'Supra', 'Coupe', 'Blue', '2003', 'V8', 'racing stripe');
insert into Car(carMake, carModel, carType, carColor, carYear, carEngine)
	values('Ford', 'Explorer', 'SUV', 'White', '2009', 'V8');
insert into hasCar(pID, carID) values(2, 1);
insert into hasCar(pID, carID) values(1, 2);
insert into hasCar(pID, carID) values(1, 3);
insert into hasCar(pID, carID) values(3, 4);
insert into hasCar(pID, carID) values(3, 5);;

insert into befriend(initiatorID, recipientID) values (1, 2);
insert into befriend(initiatorID, recipientID) values (3, 2);
insert into befriend(initiatorID, recipientID) values (1, 3);

insert into Hobby(hTitle, hText)
	values ('Racing', 'I race everyday at Racetown, NJ and I have a 75% win rate.')
insert into Hobby(hTitle, hText)
	values ('Modding', 'I mod cars for other people, mainly dealing with audio system setup and painting.')

insert into hasHobby(pID, hID) values (1, 2);
insert into hasHobby(pID, hID) values (3, 1);
