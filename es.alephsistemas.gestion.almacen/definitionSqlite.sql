
CREATE TABLE familiasarticulos
(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  codfamilia character varying(4) PRIMARY KEY,
  idempresa integer NOT NULL,
  nombre character varying(250) NOT NULL
);

CREATE TABLE subfamiliasarticulos
(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idfamilia int NOT NULL,
  codsubfamilia character varying(8) NOT NULL,
  nombre character varying(250) NOT NULL
);

CREATE TABLE articulos
(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idempresa integer NOT NULL,
  idsubfamilia integer NOT NULL,
  referencia character varying(18),
  nombre character varying(250) NOT NULL,
  description text,
  pvp double precision,
  idimpuestocompra integer,
  idimpuestoventa integer,
  secompra boolean,
  sevende boolean,
  codbarras character varying(18),
  tipocodigobarras character varying(8),
  imagen bytea,
  stockmax double precision,
  stockmin double precision,
  stockfis double precision,
  costemedio double precision,
  controlstock boolean,
  nostock boolean,
  observaciones text,
  codsubcuentacom character varying(15),
  idsubcuentacom integer,
  codsubcuentaven character varying(15),
  idsubcuentaven integer,
  codsubcuentairpfcom character varying(15),
  idsubcuentairpfcom integer
);

CREATE TABLE articulosprov
(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idarticulo integer NOT NULL,
  idtercero integer NOT NULL,
  coddivisa character varying(3),
  refproveedor character varying(50),
  nombre character varying(250),
  descripcion text,
  coste double precision,
  costedivisaempresa double precision,
  fabricante character varying(100)
);

