
CREATE TABLE familiasarticulos
(
  id serial NOT NULL,
  codfamilia character varying(4) NOT NULL,
  idempresa integer NOT NULL,
  nombre character varying(250) NOT NULL,
  CONSTRAINT familiasarticulos_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);


CREATE TABLE subfamiliasarticulos
(
  id serial NOT NULL,
  idfamilia integer NOT NULL,
  codsubfamilia character varying(8) NOT NULL,
  nombre character varying(250) NOT NULL,
  CONSTRAINT subfamiliasarticulos_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);

CREATE TABLE articulos
(
  id serial,
  idempresa integer NOT NULL,
  idsubfamilia integer NOT NULL,
  referencia character varying(18) NOT NULL,
  nombre character varying(250) NOT NULL,
  descripcion text,
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
  idsubcuentairpfcom integer,
  CONSTRAINT articulos_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);

CREATE TABLE articulosprov
(
  id serial,
  idarticulo integer NOT NULL,
  idtercero integer NOT NULL,
  coddivisa character varying(3),
  refproveedor character varying(50),
  nombre character varying(250),
  descripcion text,
  coste double precision,
  costedivisaempresa double precision,
  fabricante character varying(100),
  CONSTRAINT articulosprov_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);

