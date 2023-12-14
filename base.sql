DROP DATABASE meuble;

CREATE DATABASE meuble;
\c meuble

CREATE TABLE users(
    id serial PRIMARY KEY,
    password TEXT,
    pseudo TEXT,
    email TEXT
);
INSERT INTO users(password,pseudo,email) VALUES('root','achyl','achyl@root.mg');

CREATE TABLE style(
    idStyle serial PRIMARY KEY,
    nom TEXT
);
INSERT INTO style(nom) VALUES('royal');
INSERT INTO style(nom) VALUES('scandinave');
INSERT INTO style(nom) VALUES('oriental');

CREATE TABLE unite(
    idUnite serial PRIMARY KEY,
    nom TEXT
);
INSERT INTO unite(nom) VALUES('unites');
INSERT INTO unite(nom) VALUES('kg');
INSERT INTO unite(nom) VALUES('litres');

CREATE TABLE materiel(
    idMateriel serial PRIMARY KEY,
    idUnite int,
    nom TEXT,
    FOREIGN KEY (idUnite) REFERENCES unite(idUnite)
);
INSERT INTO materiel(nom) VALUES('hazo','2');
INSERT INTO materiel(nom) VALUES('plastique','2');
INSERT INTO materiel(nom) VALUES('marbre','2');
INSERT INTO materiel(nom) VALUES('cuire','2');

CREATE TABLE detailStyle(
    idDetail serial PRIMARY KEY,
    idStyle int,
    idMateriel int,
    FOREIGN KEY (idStyle) REFERENCES style(idStyle),
    FOREIGN KEY (idMateriel) REFERENCES materiel(idMateriel)
);

CREATE TABLE categorie(
    idCategorie serial PRIMARY KEY,
    nom TEXT
);
INSERT INTO categorie(nom) VALUES('seza');
INSERT INTO categorie(nom) VALUES('table');
INSERT INTO categorie(nom) VALUES('fandriana');

CREATE TABLE volume(
    idVolume serial PRIMARY KEY,
    nom TEXT,
    valeurMin double precision,
    valeurMax double precision
);
INSERT INTO volume(nom,valeurMin,valeurMax) VALUES('PM',1,10);
INSERT INTO volume(nom,valeurMin,valeurMax) VALUES('Medium',11,20);
INSERT INTO volume(nom,valeurMin,valeurMax) VALUES('GM',21,30);

CREATE TABLE meuble(
    idMeuble serial PRIMARY KEY,
    idStyle int,
    idCategorie int,
    idVolume int,
    nom VARCHAR(255),
    prix double precision, 
    FOREIGN KEY (idStyle) REFERENCES style(idStyle),
    FOREIGN KEY (idCategorie) REFERENCES categorie(idCategorie),
    FOREIGN KEY (idVolume) REFERENCES volume(idVolume)
);

CREATE TABLE meubleMateriel(
    idMM serial PRIMARY KEY,
    idMeuble int,
    idMateriel int,
    quantite double precision
);