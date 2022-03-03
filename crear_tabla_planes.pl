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

$table = "planes";

#$sql_statement = "DROP TABLE IF EXISTS $table";
#$dbh->query($sql_statement);

$sql_statement = "CREATE TABLE IF NOT EXISTS $table ( \
					ID int (10) unsigned DEFAULT '0' NOT NULL auto_increment, \
					Nombre varchar(255) DEFAULT '' NOT NULL, \
					Primer_Vencimiento decimal (10,2) DEFAULT 0 NOT NULL, \
					Segundo_Vencimiento decimal (10,2) DEFAULT 0 NOT NULL, \
					Tercer_Vencimiento decimal (10,2) DEFAULT 0 NOT NULL, \
					Cantidad_Accesos_Simultaneos int (1) UNSIGNED DEFAULT 0 NOT NULL, \
					Cantidad_Horas int (3) UNSIGNED DEFAULT 0 NOT NULL, \
					Cantidad_E_mail int (1) UNSIGNED DEFAULT 0 NOT NULL, \
					Costo_Tiempo_Excedente decimal (10,2) DEFAULT 0 NOT NULL, \
					Navegacion enum('Si', 'No') DEFAULT 'Si' NOT NULL, \
					Hosting enum('Si', 'No') DEFAULT 'No' NOT NULL, \
					PRIMARY KEY (ID), \
					UNIQUE PersonalDataID (ID), \
					KEY Nombre (Nombre))";

#print "$sql_statement \n";

$dbh->query($sql_statement);

exit (0);
