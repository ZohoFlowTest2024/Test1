USE master

/* ======================================================================================
	  1. Creamos la base de datos Almacen con sus ficheros (principal y de transacción)
   ====================================================================================== */

	GO
	IF  EXISTS (
		SELECT name 
			FROM sys.databases 
			WHERE name = 'AlmacenScript'
	)
	DROP DATABASE AlmacenScript
	GO

	CREATE DATABASE AlmacenScript
	ON PRIMARY
		( NAME = almacenScript,
			FILENAME = 'C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data\AlmacenScript.mdf',
				SIZE = 5MB,
				MAXSIZE = unlimited,
				FILEGROWTH = 1MB)
	LOG ON
		( NAME = almacenScript_log,
		    FILENAME = 'C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data\almacenScript_log.ldf',
				SIZE = 1MB,
				MAXSIZE = unlimited,
				FILEGROWTH = 10%)
	GO

/* ======================================================================================
	  2. Creamos las tablas 
   ====================================================================================== */

   CREATE TABLE proveedor (
		CIF			    char(10)		NOT NULL,
		nombre			varchar(50)     NOT NULL
			CONSTRAINT IX_Proveedor_nombre
			unique,
		calle			tinyint,
		numero			tinyint,
		telefono		char(9)			NOT NULL
			CONSTRAINT CK_proveedor_telefono
			CHECK (telefono like '[6789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		email			varchar(50),

		CONSTRAINT PK_proveedor PRIMARY KEY (CIF)
  )
 /*
  primary key: clave primaria
  	- CONSTRAINT PK_proveedor PRIMARY KEY (CIF), pa uno solo
	- CONSTRAINT PK_articulo_pedido PRIMARY KEY (numAlbaran, numReferencia),

  Indices: literalmente indices joder
	- CONSTRAINT IX_Proveedor_nombre unique,

  Foreign key: claves foraneas
	- CONSTRAINT FK_articulo_proveedor foreign key references proveedor (CIF)

  Restricciones check: lo que mas da por culo
	- CONSTRAINT CK_articulo_descripcion
		check (descripcion LIKE '_____%'),
	- CONSTRAINT CK_cliente_telefono
			CHECK (telefono like '[6789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),

  valores defecto: default 0,
  */

   CREATE TABLE articulo (
		numReferencia	int				NOT NULL
			CONSTRAINT PK_articulo PRIMARY KEY,
		descripcion		varchar(50)     NOT NULL,
			CONSTRAINT CK_articulo_descripcion
			check (descripcion LIKE '_____%'),
--			check (LEN(descripcion) >= 5),
		precio			money			NOT NULL
			default 0,
		stock			int				NOT NULL
			default 0,
		cifProveedor	char(10)		NOT NULL
			CONSTRAINT FK_articulo_proveedor
--			foreign key references proveedor (CIF) no es CIFproveedor, es solo CIF
			references proveedor,
  )

  CREATE UNIQUE INDEX IX_articulo_descripcion
  ON articulo (descripcion)
  GO

  CREATE TABLE pedido (
		numAlbaran		int				NOT NULL
			IDENTITY (1, 1)
			CONSTRAINT PK_pedido PRIMARY KEY,
		nifCliente		char(10)		NOT NULL
			CONSTRAINT FK_pedido_cliente
			REFERENCES cliente,
		nifVendedor		char(10)		NOT NULL
			CONSTRAINT FK_pedido_vendedor
			REFERENCES vendedor,
  )	

  CREATE TABLE cliente (
		NIF				char(10)		NOT NULL
			CONSTRAINT PK_cliente
			PRIMARY KEY,
		nombre			varchar(50)		NOT NULL,
		calle			varchar(50)		NOT NULL,
		numero			smallint		NOT NULL,
		piso			tinyint			NOT NULL,
		telefono		char(9)			NOT NULL,
			CONSTRAINT CK_cliente_telefono
			CHECK (telefono like '[6789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		email			char(50),
		fecNacimiento	smalldatetime,
  )

  CREATE TABLE vendedor (
		NIF				char(10)
			CONSTRAINT PK_vendedor
			PRIMARY KEY,
		nombre			varchar(50),
		antiguedad		smalldatetime,
  )

  CREATE TABLE articulo_pedido (
		numAlbaran		int				NOT NULL
			CONSTRAINT FK_articulo_pedido_pedido
			REFERENCES pedido,
		numReferencia	int				NOT NULL
			CONSTRAINT FK_articulo_pedido_articulo
			REFERENCES articulo,
		cantidad		smallint		NOT NULL
			default 0,

		CONSTRAINT PK_articulo_pedido
			primary key (numAlbaran, numReferencia),
  )

  /* ======================================================================================
	  3. rellenamos las tablas 
   ====================================================================================== */

	--PROVEEDOR
    insert into proveedor
    ( CIF,nombre,calle,numero,telefono,email)
    VALUES ('0001','Paco','113','1','617777777','proveedorA@correo')

    insert into proveedor
    ( CIF,nombre,calle,numero,telefono,email)
    VALUES ('0002','Yoimiya','114','2','612777788','proveedorB@correo')

    insert into proveedor
    ( CIF,nombre,calle,numero,telefono,email)
    VALUES ('0003','Nahida','115','3','613777799','proveedorC@correo')

    --ARTICULOS
	insert into articulo
    ( numReferencia,descripcion,precio,stock,cifProveedor)
    VALUES ('1001','ARTICULO1','15','100','0001')

    insert into articulo
    ( numReferencia,descripcion,precio,stock,cifProveedor)
    VALUES ('1002','ARTICULO2',Default,default,'0002')

    insert into articulo
    ( numReferencia,descripcion,precio,stock,cifProveedor)
    VALUES ('1003','ARTICULO3',Default,default,'0003')


    --CLIENTES
    insert into cliente
    ( NIF,nombre,calle,numero,piso,telefono,email,fecNacimiento)
    VALUES ('C0001','Marius','AntonioSaura','11','5','693694505','guilirex@correo','31/12/2002')

    insert into cliente
    ( NIF,nombre,calle,numero,piso,telefono,email,fecNacimiento)
    VALUES ('C0002','Diegus','Bernabeus','2','1','691694525','diegus@correo','10/10/2001')

    --VENDEDORES
    insert into vendedor
    ( NIF,nombre,antiguedad)
    VALUES ('V0001','VINICIUS','18/01/1980')

    insert into vendedor
    ( NIF,nombre,antiguedad)
    VALUES ('V0002','RODRI','20/02/1985')

    --PEDIDOS
    insert into pedido
    ( nifCliente,nifVendedor)
    VALUES ('C0001','V0001')
    insert into pedido
    ( nifCliente,nifVendedor)
    VALUES ('C0002','V0002')

	--ARTICULOS_PEDIDOS
	insert into articulo_pedido
    ( numAlbaran,numReferencia,cantidad)
    VALUES ('1','1001','3')

    insert into articulo_pedido
    ( numAlbaran,numReferencia,cantidad)
    VALUES ('2','1002','10')

   /* ======================================================================================
	  4. Creamos las vistas 
   ====================================================================================== */

	USE AlmacenScript
	GO

	IF object_id('vistaArticulo', 'V') IS NOT NULL
		DROP VIEW vistaArticulo
	GO

	CREATE VIEW vistaArticulo 
	(numRef, nombre, proveedor, telefono) AS
	SELECT numReferencia, descripcion, nombre, telefono
	FROM articulo JOIN proveedor ON
	articulo.cifProveedor = proveedor.CIF
	GO

	SELECT * FROM vistaArticulo

	