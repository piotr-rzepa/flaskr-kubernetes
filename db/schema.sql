-- Initialize the database.
-- Drop any existing data and create empty tables.

DROP DATABASE IF EXISTS flaskr;

CREATE DATABASE flaskr;

USE flaskr;

DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS post;

CREATE TABLE user (
  id INT NOT NULL AUTO_INCREMENT,
  username VARCHAR(255) NOT NULL,
  password VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (username)
);

CREATE TABLE post (
  id INT NOT NULL AUTO_INCREMENT,
  author_id INT NOT NULL,
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (author_id) REFERENCES user(id)
);