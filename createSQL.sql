drop table ports_hosts;
drop table hosts;
drop table ports;

CREATE TABLE hosts (
  id INT primary key AUTO_INCREMENT,
  hostname VARCHAR(256),
  state VARCHAR(20),
  ip VARCHAR(16) NOT NULL UNIQUE,
  mac VARCHAR(18),
  vendor VARCHAR(256)
);

CREATE TABLE ports (
  id INT primary key AUTO_INCREMENT,
  portnumber INT NOT NULL,
  protocol VARCHAR(10) NOT NULL,
  state VARCHAR(20) NOT NULL,
  service VARCHAR(255),
  UNIQUE(portnumber,protocol,state,service)
);

CREATE TABLE ports_hosts (
  id INT primary key AUTO_INCREMENT,
  ports_id INT,
  hosts_id INT,
  FOREIGN KEY (ports_id) REFERENCES ports(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (hosts_id) REFERENCES hosts(id) ON DELETE CASCADE ON UPDATE CASCADE
);
