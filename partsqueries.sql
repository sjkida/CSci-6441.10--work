/*create tables suppliers, parts and catalog on database FirstAssignment*/
CREATE TABLE suppliers(
	id INTEGER,
	sname VARCHAR(256),
	address VARCHAR(256),
        CONSTRAINT suppliers_pk PRIMARY KEY (id)
	);
CREATE TABLE parts (
	id INTEGER,
	pname VARCHAR(256),
	color VARCHAR(100),
        CONSTRAINT parts_pk PRIMARY KEY (id)
	);
CREATE TABLE catalog (
	sid INTEGER,
	pid INTEGER,
	cost NUMERIC(10,2),
	CONSTRAINT catalog_pk PRIMARY KEY(sid,pid),
	CONSTRAINT catalog_sid_fk FOREIGN KEY(sid) REFERENCES suppliers(id),
	CONSTRAINT catalog_pid_fk FOREIGN KEY(pid) REFERENCES parts(id)
	);
/*insert tables with values*/
INSERT INTO parts VALUES (1, 'Left Handed Bacon Stretcher Cover', 'Red');
INSERT INTO parts VALUES (2, 'Smoke Shifter End', 'Black');
INSERT INTO parts VALUES (3, 'Acme Widget Washer', 'Red');
INSERT INTO parts VALUES (4, 'Acme Widget Washer', 'Silver');
INSERT INTO parts VALUES (5, 'I Brake for Crop Circles Sticker', 'Translucent');
INSERT INTO parts VALUES (6, 'Anti-Gravity Turbine Generator', 'Cyan');
INSERT INTO parts VALUES (7, 'Anti-Gravity Turbine Generator', 'Magenta');
INSERT INTO parts VALUES (8, 'Fire Hydrant Cap', 'Red');
INSERT INTO parts VALUES (9, '7 Segment Display', 'Green');
INSERT INTO suppliers VALUES (1, 'Acme Widget Suppliers', '1 Grub St., Potemkin Village, IL 61801');
INSERT INTO suppliers VALUES (2, 'Big Red Tool and Die', '4 My Way, Bermuda Shorts, OR 90305');
INSERT INTO suppliers VALUES (3, 'Perfunctory Parts', '99999 Short Pier, Terra Del Fuego, TX 41299');
INSERT INTO suppliers VALUES (4, 'Alien Aircaft Inc.', '2 Groom Lake, Rachel, NV 51902');
INSERT INTO catalog VALUES (1, 3, 0.50);
INSERT INTO catalog VALUES (1, 4, 0.50);
INSERT INTO catalog VALUES (1, 8, 11.70);
INSERT INTO catalog VALUES (2, 3, 0.55);
INSERT INTO catalog VALUES (2, 8, 7.95);
INSERT INTO catalog VALUES (2, 1, 16.50);
INSERT INTO catalog VALUES (3, 8, 12.50);
INSERT INTO catalog VALUES (3, 9, 1.00);
INSERT INTO catalog VALUES (4, 5, 2.20);
INSERT INTO catalog VALUES (4, 6, 1247548.23);
INSERT INTO catalog VALUES (4, 7, 1247548.23);

/*query1£ºFind the names of parts for which there is no supplier.*/
SELECT pname 
FROM   parts 
WHERE  NOT EXISTS( SELECT *
                   FROM   catalog
				   WHERE  id=pid);

/*query2: Find the names of suppliers who supply every part.*/
/*If a supplier supplies every part, then there will be 9 tuples for the same sid)*/
SELECT sname
FROM   suppliers
WHERE  ( SELECT COUNT(*)
         FROM   catalog
         WHERE  id = sid)=9;

/*query3: Find the names of suppliers who supply every red part.*/
SELECT sname
FROM   suppliers AS s
WHERE  s.id IN ( SELECT s.id
                 FROM (parts AS p JOIN catalog AS c ON p.id=c.pid)
                 WHERE p.color='Red' AND s.id=c.sid);

/*query4: Find the names of parts supplied by Acme Widget Suppliers and no one else*/
SELECT p.pname
FROM   parts AS p
WHERE  ( SELECT COUNT(*)
         FROM   catalog 
         WHERE  p.id=pid)=1 
       AND 
       p.id IN( SELECT pid
                FROM suppliers AS s JOIN catalog ON s.id=sid
                WHERE s.sname='Acme Widget Suppliers');                     
/*query5: Find the IDs of suppliers who charge more for 
some part than the average cost of that part (average over all suppliers who supply that part).*/

SELECT DISTINCT c0.sid
FROM   catalog AS c0
WHERE  c0.cost>( SELECT AVG(c1.cost) FROM catalog AS c1
              WHERE  c0.pid=c1.pid)

/*query6: For each part, find the name of the supplier who charges the most for that part.*/

SELECT sname
FROM   suppliers JOIN catalog AS c0 ON id=c0.sid 
WHERE  c0.cost=(SELECT MAX(c1.cost) FROM catalog AS c1        
                WHERE c0.pid=c1.pid)
ORDER BY c0.pid 
/*query7: Find the IDs of suppliers who do not sell any non-red parts*/

SELECT  DISTINCT s.id
FROM    suppliers AS s JOIN catalog AS c ON s.id=c.sid
WHERE   ((SELECT COUNT(*) FROM catalog AS c0, parts AS p
          WHERE p.color='RED' AND p.id=c0.pid AND c0.sid=c.sid)=
        ( SELECT COUNT(*) FROM catalog c1 
          WHERE  c1.sid=c.sid));  

/*query8: Find the IDs of suppliers who sell a red part and a green part.*/
SELECT DISTINCT s.id
FROM   suppliers AS s JOIN catalog AS c ON s.id=c.sid
WHERE  (EXISTS(SELECT * FROM catalog AS c0, parts AS p
         WHERE  p.color='RED' AND p.id=c0.pid AND c0.sid=c.sid))
       AND
	   (EXISTS(SELECT * FROM catalog AS c1 ,parts AS p1
         WHERE p1.color='GREEN' AND p1.id=c1.pid AND c1.sid=c.sid));

/*query9£ºFind the IDs of suppliers who sell a red part or a green part.*/
SELECT DISTINCT s.id
FROM   suppliers AS s JOIN catalog ON s.id=sid
WHERE  (EXISTS( SELECT * FROM parts AS p0
         WHERE  P0.color='RED' AND p0.id=pid))
       OR
	   ( EXISTS(SELECT * FROM parts AS p1
         WHERE p1.color='GREEN' AND p1.id=pid));

/*query10:For every supplier that only supplies green parts, 
print the name of the supplier and the total number of parts that she supplies.*/
SELECT  DISTINCT s.sname, COUNT(c.sid)
FROM    suppliers AS s JOIN catalog AS c ON s.id=c.sid
WHERE   ((SELECT COUNT(*) FROM catalog AS c0, parts AS p
          WHERE p.color='GREEN' AND p.id=c0.pid AND c0.sid=c.sid)=
        ( SELECT COUNT(*) FROM catalog c1 
          WHERE  c1.sid=c.sid))  
GROUP BY s.sname; 

/*query11:For every supplier that supplies a green part and a red part, 
print both the name and price of the most expensive part
 that she supplies and the name and price of the least expensive part that she supplies.*/
SELECT	 s.sname, MAX(c.cost)AS MAC
FROM     suppliers AS s, parts AS p, catalog AS c
WHERE    p.id = c.pid AND c.sid = s.id
GROUP BY s.sname, s.id,p.color
HAVING   p.color IN ('Green','Red')

SELECT   s.sname, MIN(c.cost)as MIC
FROM     suppliers AS s, parts AS p, catalog AS c
WHERE    p.id = c.pid AND c.sid = s.id
GROUP BY s.sname, s.id,p.color
HAVING   p.color IN ('Green','Red')