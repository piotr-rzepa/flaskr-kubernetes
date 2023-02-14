-- Initialize the database.
-- Drop any existing data and create empty tables.

DROP DATABASE IF EXISTS flaskr;

CREATE DATABASE flaskr;

USE flaskr;

CREATE TABLE user (
  id INT NOT NULL AUTO_INCREMENT,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (username),
);

CREATE TABLE post (
  id INT NOT NULL AUTO_INCREMENT,
  author_id INT NOT NULL,
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (author_id) REFERENCES user(id)
);
