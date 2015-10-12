CREATE TABLE efectospago
(
  id serial NOT NULL,
  idempresa integer NOT NULL,
  idejercicio integer NOT NULL,
  codigo character varying(15) NOT NULL,
  estado character varying(20) NOT NULL,
  importe double precision,
  fecha date,
  fechav date,
  idtercero integer,
  nombretercero character varying(250),
  idremesa integer,
  idfactura integer,
  numproveedor character varying(50),
  cifnif character varying(20),
  importedivisaempresa double precision,
  coddivisa character varying(3) NOT NULL,
  tasaconv double precision,
  idcuenta integer,
  descripcion character varying(100),
  ctaentidad character varying(4),
  ctaagencia character varying(4),
  dc character varying(2),
  cuenta character varying(10),
  iddirtercero integer,
  direccion character varying(250),
  codpostal character varying(10),
  poblacion character varying(100),
  provincia character varying(100),
  codpais character varying(20),
  texto text,
  numero int,
  CONSTRAINT efectospago_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);

CREATE TABLE pagosdevoluciones
(
  id serial NOT NULL,
  idefecto integer NOT NULL,
  idformapago integer NOT NULL,
  fecha date,
  importe double precision,
  tasaconv double precision,
  coddivisa character varying(3),
  importedivisaempresa double precision,
  tipo character varying(20),
  editable boolean,
  idcuenta integer,
  descripcion character varying(100),
  ctaentidad character varying(4),
  ctaagencia character varying(4),
  dc character varying(2),
  cuenta character varying(10),
  idasiento integer,
  codsubcuenta character varying(15),
  idsubcuenta integer,
  nogenerarasiento boolean,
  costedevolucion double precision,
  CONSTRAINT pagosdevoluciones_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);

CREATE TABLE efectoscobro
(
  id serial NOT NULL,
  idempresa integer NOT NULL,
  idejercicio integer NOT NULL,
  codigo character varying(15) NOT NULL,
  estado character varying(20) NOT NULL,
  idpedido integer,
  idfactura integer,
  numcliente character varying(50),
  importe double precision,
  fecha date,
  fechav date,
  idtercero integer,
  nombretercero character varying(250),
  idremesa integer,
  cifnif character varying(20),
  importedivisaempresa double precision,
  coddivisa character varying(3) NOT NULL,
  tasaconv double precision,
  idcuenta integer,
  descripcion character varying(100),
  ctaentidad character varying(4),
  ctaagencia character varying(4),
  dc character varying(2),
  cuenta character varying(10),
  iddirtercero integer,
  direccion character varying(250),
  codpostal character varying(10),
  poblacion character varying(100),
  provincia character varying(100),
  codpais character varying(3),
  texto text,
  numero int,
  CONSTRAINT efectoscobro_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);

CREATE TABLE cobrosdevoluciones
(
  id serial NOT NULL,
  idefecto integer NOT NULL,
  idformapago integer NOT NULL,
  fecha date,
  importe double precision,
  tasaconv double precision,
  coddivisa character varying(3),
  importedivisaempresa double precision,
  tipo character varying(20),
  editable boolean,
  idcuenta integer,
  descripcion character varying(100),
  ctaentidad character varying(4),
  ctaagencia character varying(4),
  dc character varying(2),
  cuenta character varying(10),
  idasiento integer,
  codsubcuenta character varying(15),
  idsubcuenta integer,
  nogenerarasiento boolean,
  costedevolucion double precision,
  CONSTRAINT cobrosdevoluciones_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=TRUE
);