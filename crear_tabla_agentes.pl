#!/usr/bin/perl

use Mysql;

#######################################################################
# Este script genera la Tabla de los Datos Personales de los Usuarios #
#######################################################################

$host = "localhost";
$database = "radius";
$user = "root";
$password = "4c0r4z4d0";

$dbh = Mysql->connect($host, $database, $user, $password);

$table = "agentes";

$sql_statement = "DROP TABLE IF EXISTS $table";
$dbh->query($sql_statement);

$sql_statement = "CREATE TABLE IF NOT EXISTS $table ( \
					ID bigint (21) DEFAULT '0' NOT NULL auto_increment, \
					Nombre varchar(255) DEFAULT '' NOT NULL, \
					Direccion varchar (255) DEFAULT '' NOT NULL, \
					Telefono varchar (40) DEFAULT '' NOT NULL, \
					Localidad varchar (255) DEFAULT '' NOT NULL, \
					Descripcion varchar (255) DEFAULT '' NOT NULL, \
					Usuario_ID int (10) unsigned DEFAULT '0' NOT NULL, \
					PRIMARY KEY (ID), \
					UNIQUE ID (ID), \
					KEY Nombre (Nombre))";

#print "$sql_statement \n";

$dbh->query($sql_statement);

exit (0);
