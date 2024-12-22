-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Looking at the crime scene report with details we know
SELECT *
FROM crime_scene_reports
WHERE year = 2023
AND month = 7
AND day = 28
AND street = "Humphrey Street"
;

-- we are investigating on id = 295
SELECT *
FROM crime_scene_reports
WHERE id = 295;

-- let us only look at description
SELECT description
FROM crime_scene_reports
WHERE id = 295;

-- time - 10:15am, 3 witness, and we have to look at the bakery logs

-- a peek at bakery logs
.schema bakery_security_logs

Select *
FROM bakery_security_logs
LIMIT 3;

-- time is in 24hrs, we might have to look at entrance and exit and match with lincene_plate

-- lets see what happened at 10
Select *
FROM bakery_security_logs
WHERE day = 28
AND month = 7
AND hour = 10
ORDER BY minute;

-- someone with plate = 13FNH73 entered at 10 14 am lets look at him
Select *
FROM bakery_security_logs
WHERE license_plate = "13FNH73";

-- this person has entered the bakery on 29 also but we know the thieve left the town so this cant be the person

--one person has left the bakery at 10 16 with plate = 5P2BI95
Select *
FROM bakery_security_logs
WHERE license_plate = "5P2BI95";

-- this person has enterd the bakery at 9 15 that is 1 hour before the reported time, this can be a suspect, lets try to find more details

-- the people table has information with lincense plate
SELECT *
FROM people
WHERE license_plate = "5P2BI95";
-- name : Vanessa, id : 221103, phno : (725) 555-4692, pp no : 2963008352

-- let's see if he took a fligth after the crime scene, we can use his passport details for this
-- we can only find their flight id from the passengers table using passport number.
SELECT *
FROM passengers
WHERE passport_number = 2963008352;
-- he was is flight_id : 2, 20, 39

-- lets use this in flights table to look the the dates
SELECT *
FROM flights
WHERE id = 2
OR id = 20
OR id = 39;
-- flight id 20 was on 28th of july at 15:22 (some hours after the crime) - origin airport : 6, dest airport : 8

-- lets see the airport details
SELECT *
FROM airports
WHERE id = 6
OR id = 8;

-- the origin airport is fiftyville(where the crime happened) and the suspected criminal went to BOS airport(Logan International Airport - Boston)

-- WE now need to find the accomplice who helped him

-- lets begin with phone calls
-- we cannot determine the phone_calls id directly with phone number, we have to find another way
-- lets look at his bank details - we can reference to it using people_id which we know
SELECT *
FROM bank_accounts
WHERE person_id = 221103;
-- there is no account related to the person id, sad life

-- lets peek into phone_calls table
SELECT *
FROM phone_calls
LIMIT 5;
-- We can acutually determine the phone_calls id directly with phone number, we made wrong assumption before without looking at the table

-- Lets look at the suspects call history
SELECT *
FROM phone_calls
WHERE caller = "(725) 555-4692"
OR receiver = "(725) 555-4692"
ORDER BY day;
-- on 28th he made a call to (821) 555-5262,

-- let find the other person from the people table
SELECT *
FROM people
WHERE phone_number = "(821) 555-5262";
-- name : Amanda, ID : 632023, pp no : 1618186613, Licence plate : RS7I6A0

-- lets look at the other persons bank details, for some proofs
SELECT *
FROM bank_accounts
WHERE person_id = 632023;
-- bank acc no : 90209473

-- using the account number we can look into his atm transactions
SELECT *
FROM atm_transactions
WHERE account_number = 90209473;
-- not much info, we need to look at some other data i.e table

-- lets look into the inteviews table
select * from interviews limit 3;

-- lets see if we can find anything on the day the crime was reported
SELECT *
FROM interviews
WHERE year = 2023
AND month = 7
AND day = 28;
-- interview with Ruth, Eugene and Raymond -
-- i think all the details we got was wrong,

-- someone left the bakery within 10 min of theft i.e before 10:25 - Ruth
-- On morning of the same day he withdraw money at Leggett Street - Eugene
-- phone call less than a minute - flying out of fiftyville the next day i.e 29th - Raymond

-- We have to  start from scratch, lets look at the bakery logs between 10 15 and 10 25
Select *
FROM bakery_security_logs
WHERE day = 28
AND month = 7
AND hour = 10
AND minute BETWEEN 15 AND 25
ORDER BY minute;

-- lets look at the details of people related to these plates
SELECT *
FROM people
WHERE license_plate IN (
    Select license_plate
    FROM bakery_security_logs
    WHERE day = 28
    AND month = 7
    AND hour = 10
    AND minute BETWEEN 15 AND 25
);
-- we have already looked at Vanessa,
-- lets get their back account details and see their atm transactions to see if anyone wihtdraw at Leggett street
-- lets get their back details
SELECT *
FROM bank_accounts
WHERE person_id IN(
    SELECT id
    FROM people
    WHERE license_plate IN (
        Select license_plate
        FROM bakery_security_logs
        WHERE day = 28
        AND month = 7
        AND hour = 10
        AND minute BETWEEN 15 AND 25
)
);

-- lets use this info to get thier atm transactions and find the trancsactions at Leggett Street atm
SELECT *
FROM atm_transactions
WHERE account_number IN(
    SELECT account_number
    FROM bank_accounts
    WHERE person_id IN(
        SELECT id
        FROM people
        WHERE license_plate IN (
            Select license_plate
            FROM bakery_security_logs
            WHERE day = 28
            AND month = 7
            AND hour = 10
            AND minute BETWEEN 15 AND 25
        )
    )
)
AND atm_location = "Leggett Street"
AND day = 28
;

-- now we have 4 suspects, now we have to see which of them left fiftyville the next day of the theft

-- let us get the passport details of this individuals
SELECT *
FROM people
WHERE id IN(
    SELECT person_id
    FROM bank_accounts
    WHERE account_number IN(
        SELECT account_number
        FROM atm_transactions
        WHERE account_number IN(
            SELECT account_number
            FROM bank_accounts
            WHERE person_id IN(
                SELECT id
                FROM people
                WHERE license_plate IN (
                    Select license_plate
                    FROM bakery_security_logs
                    WHERE day = 28
                    AND month = 7
                    AND hour = 10
                    AND minute BETWEEN 15 AND 25
                )
            )
        )
AND atm_location = "Leggett Street"
AND day = 28
    )
);
-- we have got the folloing names along with thier pp numbers:
-- +--------+-------+----------------+-----------------+---------------+
-- |   id   | name  |  phone_number  | passport_number | license_plate |
-- +--------+-------+----------------+-----------------+---------------+
-- | 396669 | Iman  | (829) 555-5269 | 7049073643      | L93JTIZ       |
-- | 467400 | Luca  | (389) 555-5198 | 8496433585      | 4328GD8       |
-- | 514354 | Diana | (770) 555-1861 | 3592750733      | 322W7JE       |
-- | 686048 | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |
-- +--------+-------+----------------+-----------------+--------------

-- let us get passenger info for these suspects
SELECT *
FROM passengers
JOIN people ON passengers.passport_number = people.passport_number
WHERE passengers.passport_number IN (
    SELECT passport_number
    FROM people
    WHERE id IN (
        SELECT person_id
        FROM bank_accounts
        WHERE account_number IN (
            SELECT account_number
            FROM atm_transactions
            WHERE account_number IN (
                SELECT account_number
                FROM bank_accounts
                WHERE person_id IN (
                    SELECT id
                    FROM people
                    WHERE license_plate IN (
                        SELECT license_plate
                        FROM bakery_security_logs
                        WHERE day = 28
                        AND month = 7
                        AND hour = 10
                        AND minute BETWEEN 15 AND 25
                    )
                )
            )
        AND atm_location = 'Leggett Street'
        AND day = 28
        )
    )
);


-- using the flight id, get the details of the flights


SELECT passengers.*, people.name,flights.*
FROM passengers
JOIN people ON passengers.passport_number = people.passport_number
JOIN flights ON passengers.flight_id = flights.id
WHERE passengers.passport_number IN (
    SELECT passport_number
    FROM people
    WHERE id IN (
        SELECT person_id
        FROM bank_accounts
        WHERE account_number IN (
            SELECT account_number
            FROM atm_transactions
            WHERE account_number IN (
                SELECT account_number
                FROM bank_accounts
                WHERE person_id IN (
                    SELECT id
                    FROM people
                    WHERE license_plate IN (
                        SELECT license_plate
                        FROM bakery_security_logs
                        WHERE day = 28
                        AND month = 7
                        AND hour = 10
                        AND minute BETWEEN 15 AND 25
                    )
                )
            )
        AND atm_location = 'Leggett Street'
        AND day = 28
        )
    )
    AND origin_airport_id = 8
);
-- +-----------+-----------------+------+-------+----+-------------------+------------------------+------+-------+-----+------+--------+
-- | flight_id | passport_number | seat | name  | id | origin_airport_id | destination_airport_id | year | month | day | hour | minute |
-- +-----------+-----------------+------+-------+----+-------------------+------------------------+------+-------+-----+------+--------+
-- | 11        | 8496433585      | 5D   | Luca  | 11 | 8                 | 12                     | 2023 | 7     | 30  | 13   | 7      |
-- | 18        | 3592750733      | 4C   | Diana | 18 | 8                 | 6                      | 2023 | 7     | 29  | 16   | 0      |
-- | 36        | 5773159633      | 4A   | Bruce | 36 | 8                 | 4                      | 2023 | 7     | 29  | 8    | 20     |
-- | 36        | 8496433585      | 7B   | Luca  | 36 | 8                 | 4                      | 2023 | 7     | 29  | 8    | 20     |
-- | 54        | 3592750733      | 6C   | Diana | 54 | 8                 | 5                      | 2023 | 7     | 30  | 10   | 19     |
-- +-----------+-----------------+------+-------+----+-------------------+------------------------+------+-------+-----+------+--------+

SELECT  *
FROM passengers as p
JOIN flights as f ON p.flight_id = f.id
WHERE passport_number = 8496433585 -- luca;
-- luca was back to fiftyville on 30, he can be excluded
-- the same with diana , he was back on 30 and he left again on 30th

-- bruce or diana
-- +--------+-------+----------------+-----------------+---------------+
-- |   id   | name  |  phone_number  | passport_number | license_plate |
-- +--------+-------+----------------+-----------------+---------------+
-- |  id  | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |
-- +--------+-------+----------------+-----------------+---------------+

-- +--------+-------+----------------+-----------------+---------------+
-- |   id   | name  |  phone_number  | passport_number | license_plate |
-- +--------+-------+----------------+-----------------+---------------+
-- | 514354 | Diana | (770) 555-1861 | 3592750733      | 322W7JE       |
-- +--------+-------+----------------+-----------------+---------------+
-- bruce from bakery log - (367) 555-5533
-- +-----+------+-------+-----+------+--------+----------+---------------+
-- | id  | year | month | day | hour | minute | activity | license_plate |
-- +-----+------+-------+-----+------+--------+----------+---------------+
-- | 232 | 2023 | 7     | 28  | 8    | 23     | entrance | 94KL13X       |
-- | 261 | 2023 | 7     | 28  | 10   | 18     | exit     | 94KL13X       |
-- +-----+------+-------+-----+------+--------+----------+---------------+


-- diana from bakery log - (770) 555-1861
-- +-----+------+-------+-----+------+--------+----------+---------------+
-- | id  | year | month | day | hour | minute | activity | license_plate |
-- +-----+------+-------+-----+------+--------+----------+---------------+
-- | 240 | 2023 | 7     | 28  | 8    | 36     | entrance | 322W7JE       |
-- | 266 | 2023 | 7     | 28  | 10   | 23     | exit     | 322W7JE       |
-- +-----+------+-------+-----+------+--------+----------+---------------+

-- lets look at their call history

-- this is Bruce's call log on 28
-- | 233 | (367) 555-5533 | (375) 555-8161 | 2023 | 7     | 28  | 45       |
-- | 236 | (367) 555-5533 | (344) 555-9601 | 2023 | 7     | 28  | 120      |
-- | 245 | (367) 555-5533 | (022) 555-4052 | 2023 | 7     | 28  | 241      |
-- | 285 | (367) 555-5533 | (704) 555-5790 | 2023 | 7     | 28  | 75       |


-- this is Diana's call log on 28
-- | 241 | (068) 555-0183 | (770) 555-1861 | 2023 | 7     | 28  | 371      |
-- | 255 | (770) 555-1861 | (725) 555-3243 | 2023 | 7     | 28  | 49


SELECT  *
FROM passengers as p
JOIN flights as f ON p.flight_id = f.id
WHERE passport_number = 3592750733;

-- diana is excluded from the suspects list, therefore bruce is the theive

-- lets find bruce's friend
-- lets find any thing from his call history which we have
-- bruce called (375) 555-8161 for 45 sec which is short

SELECT *
FROM people
WHERE phone_number = "(375) 555-8161";

-- +--------+-------+----------------+-----------------+---------------+
-- |   id   | name  |  phone_number  | passport_number | license_plate |
-- +--------+-------+----------------+-----------------+---------------+
-- | 864400 | Robin | (375) 555-8161 | NULL            | 4V16VO0       |
-- +--------+-------+----------------+-----------------+---------------+

-- using his perosn id - lets see his bank account

SELECT *
FROM bank_accounts
WHERE person_id = 864400;

-- +----------------+-----------+---------------+
-- | account_number | person_id | creation_year |
-- +----------------+-----------+---------------+
-- | 94751264       | 864400    | 2019          |
-- +----------------+-----------+---------------+

-- Let's see his transactions
SELECT *
FROM atm_transactions
WHERE account_number = 94751264;

