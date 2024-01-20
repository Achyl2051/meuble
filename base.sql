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
    pu double precision,
    FOREIGN KEY (idUnite) REFERENCES unite(idUnite)
);
INSERT INTO materiel(nom,idUnite,pu) VALUES('hazo',2,100);
INSERT INTO materiel(nom,idUnite,pu) VALUES('plastique',2,100);
INSERT INTO materiel(nom,idUnite,pu) VALUES('marbre',2,500);
INSERT INTO materiel(nom,idUnite,pu) VALUES('cuire',2,300);

CREATE TABLE volume(
    idVolume serial PRIMARY KEY,
    nom TEXT
);
INSERT INTO volume(nom) VALUES('PM');
INSERT INTO volume(nom) VALUES('Medium');
INSERT INTO volume(nom) VALUES('GM');

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

CREATE TABLE meuble(
    idMeuble serial PRIMARY KEY,
    idStyle int,
    idCategorie int,
    nombreMpiasa int,
    FOREIGN KEY (idStyle) REFERENCES style(idStyle),
    FOREIGN KEY (idCategorie) REFERENCES categorie(idCategorie)
);

CREATE TABLE volumeMateriel(
    idVolumeMateriel serial PRIMARY KEY,
    idVolume int,
    idMateriel int,
    idMeuble int,
    quantite double precision,
    FOREIGN KEY (idVolume) REFERENCES volume(idVolume),
    FOREIGN KEY (idMateriel) REFERENCES materiel(idMateriel),
    FOREIGN KEY (idMeuble) REFERENCES meuble(idMeuble)
);

create view v_meuble_complet as(
    select m.*,c.nom as categorie,s.nom as style from meuble m 
    join style s on s.idStyle=m.idstyle 
    join categorie c on c.idcategorie=m.idcategorie
);

create view vmm as 
(select c.nom as categorie,s.nom as style,v.nom as volume,sum((pu*quantite)) as montant from volumemateriel vm 
join meuble m on m.idmeuble=vm.idmeuble join style s on m.idstyle=s.idstyle join categorie c on m.idcategorie=c.idcategorie 
join volume v on vm.idvolume=v.idvolume join materiel mat on mat.idmateriel=vm.idMateriel group by vm.idmeuble,m.idstyle,m.idcategorie,c.nom,s.nom,v.nom);

CREATE TABLE stock_entre(
    idEntre serial PRIMARY KEY,
    idMateriel int,
    quantite double precision,
    date_entre Date default now(),
    FOREIGN KEY (idMateriel) REFERENCES materiel(idMateriel)
);

CREATE TABLE stock_sortie(
    idSortie serial PRIMARY KEY,
    idMateriel int,
    quantite double precision,
    date_sortie Date default now(),
    FOREIGN KEY (idMateriel) REFERENCES materiel(idMateriel)
);

CREATE TABLE mpiasa(
    idMpiasa serial PRIMARY KEY,
    nom TEXT,
    tarif double precision
);

CREATE TABLE paramatreFabrication(
    idParametre serial PRIMARY KEY,
    idMeuble int,
    idVolume int,
    prixVente double precision,
    dureeFabrication double precision,
    FOREIGN KEY (idVolume) REFERENCES volume(idVolume),
    FOREIGN KEY (idMeuble) REFERENCES meuble(idMeuble)
);

CREATE TABLE meubleMpiasa(
    idMeubleMpiasa serial PRIMARY KEY,
    idMeuble int,
    idVolume int,
    idMpiasa int,
    nombre int,
    FOREIGN KEY (idMeuble) REFERENCES meuble(idMeuble),
    FOREIGN KEY (idVolume) REFERENCES volume(idVolume),
    FOREIGN KEY (idMpiasa) REFERENCES mpiasa(idMpiasa)
);

--meuble avec volume
create view v_meuble as( 
select v.idvolume,m.idmeuble,v.nom as volume,(concat(concat(c.nom, ' '),s.nom)) as meuble from volumemateriel vm 
join meuble m on vm.idmeuble=m.idmeuble 
join style s on s.idstyle=m.idstyle
join categorie c on c.idcategorie=m.idcategorie
join volume v on v.idvolume=vm.idvolume group by v.idvolume,m.idmeuble,v.nom,meuble);

--stock par meuble
create view v_stock_meuble as( 
select v.idvolume,mat.idMateriel,m.idmeuble,c.nom as categorie,s.nom as style,v.nom as volume,quantite,mat.nom as materiel from volumemateriel vm 
join meuble m on m.idmeuble=vm.idmeuble 
join style s on m.idstyle=s.idstyle 
join categorie c on m.idcategorie=c.idcategorie 
join volume v on vm.idvolume=v.idvolume 
join materiel mat on mat.idmateriel=vm.idMateriel); --where m.idmeuble=1 and v.idvolume=1;

-- Etat de stock
create or replace view v_etat_stock as( 
select entre.idmateriel,mat.nom as materiel,mat.pu,COALESCE(sum(quantite)-qtte,sum(quantite),0) as stock_actuel from stock_entre entre
left join 
    (select sortie.idmateriel,sum(sortie.quantite) as qtte from stock_sortie sortie 
    group by sortie.idmateriel) as s on s.idmateriel=entre.idmateriel
join
    materiel mat on mat.idmateriel=entre.idmateriel
group by entre.idmateriel,qtte,mat.nom,mat.pu); 

-- Meuble montant
create or replace view v_meuble_montant as(
    select c.nom as categorie,s.nom as style,v.nom as volume,sum((pu*quantite)) as montant from volumemateriel vm 
    join meuble m on m.idmeuble=vm.idmeuble 
    join style s on m.idstyle=s.idstyle 
    join categorie c on m.idcategorie=c.idcategorie 
    join volume v on vm.idvolume=v.idvolume 
    join materiel mat on mat.idmateriel=vm.idMateriel 
    group by vm.idmeuble,m.idstyle,m.idcategorie,c.nom,s.nom,v.nom
);

--Meuble montant avec tous les id
create or replace view v_meuble_montant_id as(
    select m.idmeuble,v.idvolume,c.nom as categorie,s.nom as style,v.nom as volume,sum((pu*quantite)) as montant from volumemateriel vm 
    join meuble m on m.idmeuble=vm.idmeuble 
    join style s on m.idstyle=s.idstyle 
    join categorie c on m.idcategorie=c.idcategorie 
    join volume v on vm.idvolume=v.idvolume 
    join materiel mat on mat.idmateriel=vm.idMateriel 
    group by vm.idmeuble,m.idstyle,m.idcategorie,c.nom,s.nom,v.nom,m.idmeuble,v.idvolume
);

-- Karama mpiasa
create or replace view v_karama_mpiasa as(
select mm.idmeuble,mm.idvolume,sum((mp.tarif*mm.nombre)) as karama from meubleMpiasa mm 
join mpiasa mp on mp.idmpiasa=mm.idmpiasa 
group by mm.idmeuble,mm.idvolume
);

-- benefice
create or replace view v_prix as(
select 
    pf.idmeuble,
    pf.idvolume,
    vm.meuble,
    vm.volume,
    pf.prixvente as prixVente,
    pf.dureeFabrication*vkm.karama+vmmi.montant as prixRevient,
    pf.prixvente-(pf.dureeFabrication*vkm.karama+vmmi.montant) as benefice 
from paramatreFabrication pf 

join v_karama_mpiasa vkm on vkm.idmeuble=pf.idmeuble and vkm.idvolume=pf.idvolume
join v_meuble_montant_id vmmi on vmmi.idmeuble=pf.idmeuble and vmmi.idvolume=pf.idvolume
join v_meuble vm on vm.idmeuble=pf.idmeuble and vm.idvolume=pf.idvolume
);