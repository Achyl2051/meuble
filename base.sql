CREATE DATABASE meuble;
\c meuble

CREATE TABLE style(
    idStyle serial PRIMARY KEY,
    nom TEXT
);
INSERT INTO style(nom) VALUES('royal');
INSERT INTO style(nom) VALUES('scandinave');
INSERT INTO style(nom) VALUES('oriental');

CREATE TABLE materiel(
    idMateriel serial PRIMARY KEY,
    nom TEXT
);
INSERT INTO materiel(nom) VALUES('hazo');
INSERT INTO materiel(nom) VALUES('plastique');
INSERT INTO materiel(nom) VALUES('marbre');
INSERT INTO materiel(nom) VALUES('cuire');

CREATE TABLE detailStyle(
    idDetail serial PRIMARY KEY,
    idStyle int,
    idMateriel int,
    FOREIGN KEY (idStyle) REFERENCES style(idStyle),
    FOREIGN KEY (idMateriel) REFERENCES materiel(idMateriel)
);

CREATE TABLE users(
    id serial PRIMARY KEY,
    password TEXT,
    pseudo TEXT,
    email TEXT
);
INSERT INTO users(password,pseudo,email) VALUES('root','achyl','achyl@root.mg');