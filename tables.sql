








-- --------------------------------------------------------
--
-- Structure de la table carte
--
CREATE SEQUENCE seq_contenu;
CREATE SEQUENCE seq_modele;
CREATE SEQUENCE seq_os;

CREATE TABLE Carte (
  num INT PRIMARY KEY,
  montantDepart DECIMAL(3,2) DEFAULT NULL,
  montantCourant DECIMAL(3,2) DEFAULT NULL,
  dateValidite date DEFAULT NULL
);

--- pour carte bancaire pourquoi juste num?
--- montant courant et depart aussi ?

CREATE VIEW vCarteBancaire AS SELECT num FROM carte WHERE dateValidite = NULL;

CREATE VIEW vCartePrepayee AS SELECT * FROM carte WHERE dateValidite != NULL;

-- --------------------------------------------------------

--
-- Structure de la table client
--

CREATE TABLE Client (
  login VARCHAR (20) PRIMARY KEY,
  mdp VARCHAR(20) CHECK(LENGTH(mdp) > 5),
  email VARCHAR(50) NOT NULL UNIQUE,
  nom VARCHAR(30) NOT NULL,
  prenom VARCHAR(30) NOT NULL,
  CHECK (email LIKE '%@%')
);

CREATE TABLE comptesAdministrateurs (
  login VARCHAR (20) UNIQUE ,
  mdp VARCHAR (20) CHECK (LENGTH (mdp) > 5)
);

CREATE TABLE comptesAnalystes (
  login VARCHAR (20) UNIQUE ,
  mdp VARCHAR (20) CHECK (LENGTH (mdp) > 5)
);


-- --------------------------------------------------------

--
-- Structure de la table constructeur_dev
--

CREATE TABLE Constructeur_dev (
  nom VARCHAR(50)PRIMARY KEY
);

-- --------------------------------------------------------

--
-- Structure de la table constructeur_os
--

CREATE TABLE Constructeur_os (
  nom VARCHAR(50) PRIMARY KEY
);

-- --------------------------------------------------------
--
-- Structure de la table editeur
--

CREATE TABLE Editeur (
  nom VARCHAR(50) PRIMARY KEY,
  contact VARCHAR(50) NOT NULL,
  url VARCHAR(100) NOT NULL,
  CHECK (url LIKE 'www.%.%')
);

-- --------------------------------------------------------
--
-- Structure de la table contenu

CREATE TABLE Contenu (
  id SERIAL PRIMARY KEY,
  titre VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  coutFixe DECIMAL(3,2) NOT NULL,
  editeur VARCHAR(50) REFERENCES Editeur(nom) NOT NULL
);

CREATE TABLE Application (
  idApp SERIAL PRIMARY KEY REFERENCES Contenu(id),
  coutPeriodique DECIMAL(3,2) NOT NULL
);

CREATE TABLE Ressource (
  idRessource SERIAL PRIMARY KEY REFERENCES Contenu(id),
  idApp INTEGER REFERENCES Application(idApp)
);
---contrainte : PROJ(Application, id) IN UNION(PROJ(Application, idApp), PROJ(Ressource, idRessource))

CREATE VIEW vApplication AS
  SELECT C.id, C.titre, C.description, C.coutFixe, C.editeur, A.coutPeriodique
  FROM Contenu C, Application A
  WHERE C.id=A.idApp;

CREATE VIEW vRessource AS
  SELECT C.id, C.titre, C.description, C.coutFixe, C.editeur, R.idApp
  FROM Contenu C, Ressource R
  WHERE C.id=R.idRessource;
-- --------------------------------------------------------;
--
-- Structure de la table transaction
--

CREATE TABLE Transaction (
  num SERIAL PRIMARY KEY,
  dateAchat DATE NOT NULL,
  montantTotal DECIMAL(3,2) NOT NULL,
  acheteur VARCHAR(20) NOT NULL REFERENCES Client(login),
  destinateur VARCHAR(20) NOT NULL REFERENCES Client(login),
  numCarte INT NOT NULL REFERENCES Carte(num)
);

--- type DECIMAL(3,2) dejà >=0 je pense
--- --------------------------------------------------------
--
-- Structure de la table contenuconcerne
--

CREATE TABLE DureeAcces (
  idcontenu INT NOT NULL REFERENCES Contenu(id),
  numTransaction INT NOT NULL REFERENCES transaction(num),
  dureePeriode INT DEFAULT NULL,
  renouvelement boolean DEFAULT NULL,
  CONSTRAINT unique_dureeacces UNIQUE(idcontenu,numTransaction)
) ;


-- --------------------------------------------------------

--
-- Structure de la table Os
--

CREATE TABLE Os (
  id SERIAL PRIMARY KEY ,
  version VARCHAR(50) NOT NULL,
  constructeur VARCHAR(50) NOT NULL REFERENCES Constructeur_os(nom)
) ;
-- --------------------------------------------------------

--
-- Structure de la table contenudisponiblesur
--

CREATE TABLE ContenuDisponibleSur (
  idContenu INT NOT NULL REFERENCES Contenu(id),
  idOs INT NOT NULL REFERENCES Os(id),
  PRIMARY KEY (idContenu,idOs)
) ;

-- --------------------------------------------------------


--
-- Structure de la table modele
--

CREATE TABLE Modele (
  id SERIAL PRIMARY KEY,
  designation VARCHAR(50) NOT NULL UNIQUE ,
  constructeur VARCHAR(50) NOT NULL REFERENCES Constructeur_dev(nom),
  idOs INT NOT NULL REFERENCES Os(id)
);

-- --------------------------------------------------------
--
-- Structure de la table terminal
--

CREATE TABLE Terminal (
  numSerie INT PRIMARY KEY,
  client VARCHAR(20) NOT NULL REFERENCES Client(login),
  idModele INT NOT NULL REFERENCES Modele(id)
);

--- num de serie plutot varchar que int je pense

-- --------------------------------------------------------
--
-- Structure de la table contenuinstallesur
--

CREATE TABLE Installation (
  idContenu INT NOT NULL REFERENCES Contenu(id),
  numSerieTerminal INT NOT NULL REFERENCES Terminal(numSerie),
  derniereInstallation DATE NOT NULL,
  PRIMARY KEY (idcontenu,numSerieTerminal)
);

-- --------------------------------------------------------


CREATE TABLE Avis (
  client VARCHAR(20) REFERENCES Client(login),
  idApplication INTEGER REFERENCES Application(idApp),
  note INTEGER,
  commentaire TEXT,
  PRIMARY KEY (client, idApplication),
  CHECK (LENGTH(commentaire) <= 500),
  CHECK (note <= 5)
);
