DELIMITER $$

/*
  @name: GetAircraft
  @role: Get a specific aircraft

  @parameters: aircraft_id

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Selects a specific aircraft by 'aircraft_id'
*/
DROP PROCEDURE IF EXISTS GetAircraft $$
CREATE PROCEDURE GetAircraft (aircraft_id char(6))
BEGIN
	SELECT aircraftID, aircraftType, maxNumberOfPassangers, 
  enteredService, aircraftName 
  FROM aircrafts
	WHERE aircrafts.aircraftID = aircraft_id;
END $$

/*
  @name: InsertAircraft
  @role: Insert a specific aircraft

  @parameters: aircraft_id

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Inserts a specific aircraft by 'aircraft_id'
*/
DROP PROCEDURE IF EXISTS InsertAircraft $$
CREATE PROCEDURE InsertAircraft (aircraft_id char(6), aircraft_type varchar(35), maxpassengers int, enteredservice date, aircraft_name varchar(55))
BEGIN
	INSERT INTO aircrafts (aircraftID, aircraftType, maxNumberOfPassangers, enteredService, aircraftName)
	VALUES (aircraft_id, aircraft_type, maxpassengers, enteredservice, aircraft_name);
END $$

/*
  @name: UpdateAircraft
  @role: Update a specific aircraft

  @parameters: aircraft_id

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Updates a specific aircraft by 'aircraft_id'
*/
DROP PROCEDURE IF EXISTS UpdateAircraft $$
CREATE PROCEDURE UpdateAircraft (aircraft_id char(6), aircraft_type varchar(35), maxpassengers int, enteredservice date, aircraft_name varchar(55))
BEGIN
	UPDATE aircrafts
	SET aircraftType = aircraft_type, maxNumberOfPassangers = maxpassengers,
	enteredService = enteredservice, aircraftName = aircraft_name
	WHERE aircrafts.aircraftID = aircraft_id;
END $$

/*
  @name: DeleteAircraft
  @role: Delete a specific aircraft

  @parameters: aircraft_id

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Deletes a specific aircraft by 'aircraft_id'
*/
DROP PROCEDURE IF EXISTS DeleteAircraft $$
CREATE PROCEDURE DeleteAircraft (aircraft_id char(6))
BEGIN
	DELETE FROM aircrafts
	WHERE aircrafts.aircraftID = aircraft_id;
END $$

/*
  @name: GetPriceCategory
  @role: Get a specific PriceCategory

  @parameters: category_id

  @created: 10.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Selects a specific PriceCategory by 'category_id'
*/
DROP PROCEDURE IF EXISTS GetPriceCategory $$
CREATE PROCEDURE GetPriceCategory (category_id int)
BEGIN
  SELECT categoryID, categoryName, validFrom, validTo, 
  minimumPrice, refundable, seatNumberRestrictions,classID 
  FROM pricecategories
  WHERE categoryID = category_id;
END $$

/*
  @name: InsertPriceCategories
  @role: Insert a specific PriceCategories

  @parameters: category_id

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Inserts a specific PriceCategory by 'category_id'
*/
DROP PROCEDURE IF EXISTS InsertPriceCategory $$
CREATE PROCEDURE InsertPriceCategory (category_name varchar(35), valid_from date, valid_to date, 
  minimum_price int, refundable bool, seat_number_restrictions int, class_id int, OUT out_param int
)
BEGIN
	INSERT INTO pricecategories (categoryName, validFrom, validTo, 
	minimumPrice, refundable, seatNumberRestrictions, classID)
	VALUES (category_name, valid_from, valid_to, minimum_price, refundable, seat_number_restrictions, class_id);
  SET out_param = LAST_INSERT_ID();
END $$

/*
  @name: UpdatePriceCategory
  @role: Update a specific PriceCategory

  @parameters: PriceCategory_id

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Updates a specific PriceCategory by 'category_id'
*/
DROP PROCEDURE IF EXISTS UpdatePriceCategory $$
CREATE PROCEDURE UpdatePriceCategory (category_id int, category_name varchar(35), 
	valid_from date, valid_to date, minimum_price int, _refundable bool, seat_number_restrictions int, class_id int
)
BEGIN
	UPDATE pricecategories
	SET categoryName = category_name, validFrom = valid_from, validTo = valid_to,
	minimumPrice = minimum_price, refundable = _refundable,
	seatNumberRestrictions = seat_number_restrictions, classID = class_id
	WHERE pricecategories.categoryID = category_id;
END $$

/*
  @name: DeletePriceCategory
  @role: Delete a specific PriceCategory

  @parameters: category_id

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Deletes a specific PriceCategory by 'category_id'
*/
DROP PROCEDURE IF EXISTS DeletePriceCategory $$
CREATE PROCEDURE DeletePriceCategory (category_id int)
BEGIN
	DELETE FROM pricecategories
	WHERE pricecategories.categoryID = category_id;
END $$

/*
  @name: GetPassengerCount
  @role: Gets the amount of passenger onboard of a plane

  @parameters: flight_code

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Gets the amount of passenger onboard of a plane
*/
DROP FUNCTION IF EXISTS GetPassengerCount $$
CREATE FUNCTION GetPassengerCount (flight_code int)
RETURNS int
DETERMINISTIC
BEGIN
	return (SELECT COUNT(*) FROM passengers
	INNER JOIN bookings ON passengers.bookingNumber = bookings.bookingNumber
	WHERE flightCode = flight_code);
END $$

/*
  @name: BookFlight
  @role: Books a flight for one or more passengers

  @parameters: flight_number, flight_date, credit_info, passengers_array

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Books a flight for one or more passengers
*/
DROP PROCEDURE IF EXISTS BookFlight $$
CREATE PROCEDURE BookFlight (flight_number CHAR(5), flight_date date, credit_info varchar(255), passengers_array TEXT)
BEGIN
    DECLARE currentPosition INT;
    DECLARE workingArray TEXT;
    DECLARE currentPassenger TEXT;
    DECLARE currentName VARCHAR(75);
    DECLARE currentPersonID VARCHAR(35);
    DECLARE currentPriceID int;
    DECLARE currentSeatID int;
    DECLARE booking_number int;
    DECLARE class_id int;
    DECLARE flight_code int;
    DECLARE i int;
    
    SET flight_code = (SELECT flightCode from flights
    	WHERE flights.flightNumber = flight_number
    	AND flights.flightDate = flight_date);
    
    SET workingArray = passengers_array;
    SET currentPosition = 1;
    SET i = 0;

    WHILE CHAR_LENGTH(workingArray) > 0 AND currentPosition > 0 DO
        SET currentPosition = INSTR(workingArray, ':');
        IF currentPosition = 0 THEN
            SET currentPassenger = workingArray;
        ELSE
            SET currentPassenger = LEFT(workingArray, currentPosition - 1);
        END IF;

        IF TRIM(currentPassenger) != '' THEN
        	SET currentName = SUBSTRING_INDEX(SUBSTRING_INDEX(currentPassenger, ',', 1), ',', -1);
        	SET currentPersonID = SUBSTRING_INDEX(SUBSTRING_INDEX(currentPassenger, ',', 2), ',', -1);
        	SET currentPriceID = SUBSTRING_INDEX(SUBSTRING_INDEX(currentPassenger, ',', 3), ',', -1);
        	SET currentSeatID = SUBSTRING_INDEX(SUBSTRING_INDEX(currentPassenger, ',', 4), ',', -1);

        	-- Insert the credit card owner
        	IF i = 0 THEN
        		-- Get the classID
        		SET class_id = (
        			SELECT classID FROM prices
					INNER JOIN pricecategories ON pricecategories.categoryID = prices.priceCategoryID
					WHERE priceID = currentPriceID
				);

        		INSERT INTO bookings(timeOfBooking, paymentType, cardIssuedBy, cardholdersName, flightCode, classID, returnFlight)
        		VALUES (NOW(), 1, credit_info, currentName, flight_code, class_id, 1);
        		SET booking_number = last_insert_id();
       		END IF;

        	-- Insert the passenger
           	INSERT INTO passengers(PersonID, priceID, personName, seatID, bookingNumber)
           	VALUES (currentPersonID, currentPriceID, currentName, currentSeatID, booking_number);
           	SET i = i + 1;
        END IF;

        SET workingArray = SUBSTRING(workingArray, currentPosition + 1);
    END WHILE;
END $$
-- EXAMPLE: CALL bookFlight('FA501','2014-05-01', 'VISA', 'Margrét Benediktsdóttir,IS934671,4,3319:Sigurður Egilsson,IS916472,4,3320:Guðmundur Sigurðsson,IS295715,4,3321:Þuríður Sigurðardóttir,IS883461,4,3322');

/*
	LISTS (VIEWS)
*/
DELIMITER ;
/*
  @name: AircraftsView
  @role: View for aircrafts

  @parameters: None

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: View for aircrafts
*/
DROP VIEW IF EXISTS AircraftsView;
CREATE VIEW AircraftsView AS
SELECT aircraftID, aircraftType, maxNumberOfPassangers, 
  enteredService, aircraftName 
  FROM aircrafts;

/*
  @name: DestinationsView
  @role: View for destinations

  @parameters: None

  @created: 12.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: View for destinations
*/
DROP VIEW IF EXISTS DestinationsView;
CREATE VIEW DestinationsView AS
  SELECT airports.airportName AS 'destinationAirport', cities.cityName
  FROM flightschedules
  INNER JOIN airports ON airports.IATACode = destinationAirport
  INNER JOIN cities ON cities.cityID = airports.cityID;

/*
  @name: PriceCategoriesView
  @role: View for pricecategories

  @parameters: None

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: View for pricecategories
*/
DROP VIEW IF EXISTS PriceCategoriesView;
CREATE VIEW PriceCategoriesView AS
	SELECT categoryID, categoryName, validFrom, validTo, 
	minimumPrice, refundable, seatNumberRestrictions,classes.classID as 'classID',className
  FROM pricecategories
  INNER JOIN classes ON classes.classID = pricecategories.classID;

/*
  @name: AirportsView
  @role: View for airports

  @parameters: None

  @created: 10.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: View for airports
*/
DROP VIEW IF EXISTS AirportsView;
CREATE VIEW AirportsView AS
  SELECT IATAcode, airportName, cityName, countryCode FROM airports
  INNER JOIN cities ON airports.cityID = cities.cityID;

/*
  @name: FlightSchedulesView
  @role: View for FlightSchedules

  @parameters: None

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: View for airports
*/
DROP VIEW IF EXISTS FlightSchedulesView;
CREATE VIEW FlightSchedulesView AS
	SELECT flightNumber, oa.airportName AS 'originatingAirport', da.airportName AS 'destinationAirport', distance
  FROM flightschedules
  INNER JOIN airports AS oa ON oa.IATACode = originatingAirport
  INNER JOIN airports as da ON da.IATACode = destinationAirport;

/*
  @name: before_bookings_insert Trigger
  @role: Stops a booking if a flight is full

  @parameters: None

  @created: 8.11.2015
  @author: Guðmundur
  @todo: Nothing
  @description: Stops a booking if a flight is full
*/
DELIMITER $$
drop trigger if exists before_bookings_insert $$
create trigger before_bookings_insert
  before insert on bookings
  for each row
  begin
    declare msg varchar(255);
    declare capacity int;
    declare passengers int;
    declare aircraft_id char(6);

    set aircraft_id = (SELECT aircraftID FROM flights WHERE flightCode = new.flightCode);
    set capacity = (SELECT COUNT(*) FROM aircraftseats WHERE aircraftseats.aircraftID = aircraft_id);
    -- eda set capacity = (SELECT maxNumberOfPassangers FROM aircrafts WHERE aircraftID = aircraft_id);
    
    set passengers = (
      SELECT COUNT(*) FROM passengers
      INNER JOIN bookings ON passengers.bookingNumber = bookings.bookingNumber
      WHERE flightCode = new.flightCode
    );
    if (passengers >= capacity) then
      set msg = concat('There are no available seats in this flight  flightCode: ', new.flightCode);
            signal sqlstate '45000' set message_text = msg;
    end if;
end $$
-- comment