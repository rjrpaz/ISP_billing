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

$table = "grupos";

$sql_statement = "DROP TABLE IF EXISTS $table";
$dbh->query($sql_statement);

$sql_statement = "CREATE TABLE IF NOT EXISTS $table ( \
					ID int (10) DEFAULT '0' NOT NULL auto_increment, \
					Nombre varchar(255) DEFAULT '' NOT NULL, \
					Dominio varchar(255) DEFAULT '' NOT NULL, \
					Descripcion varchar(255) DEFAULT '' NOT NULL, \
					PRIMARY KEY (ID), \
					UNIQUE ID (ID), \
					KEY Nombre (Nombre))";
$dbh->query($sql_statement);

exit (0);
