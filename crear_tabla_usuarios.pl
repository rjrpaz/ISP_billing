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

$table = "usuarios";

$sql_statement = "DROP TABLE IF EXISTS $table";
$dbh->query($sql_statement);

$sql_statement = "CREATE TABLE IF NOT EXISTS $table ( \
					ID int (10) unsigned NOT NULL DEFAULT 0 auto_increment, \
					Username varchar(30) DEFAULT '' NOT NULL, \
					Password varchar(32) DEFAULT '' NOT NULL, \
					Nombre varchar(255) DEFAULT '' NOT NULL, \
					Nivel enum('Acceso Total', 'Tareas Operativas', 'Tareas de Consulta') DEFAULT 'Tareas de Consulta' NOT NULL, \
					Grupo_ID int(10) unsigned NOT NULL DEFAULT 0, \
					PRIMARY KEY (ID), \
					UNIQUE ID (ID), \
					KEY Username (Username))";
$dbh->query($sql_statement);

$sql_statement = "INSERT INTO $table (ID, Username, Password, Nombre, Nivel, Grupo_ID) VALUES (1, 'radadmin', MD5('webradius'), 'Usuario de Control Total', 'Acceso Total', 1)";
$dbh->query($sql_statement);

$sql_statement = "INSERT INTO $table (ID, Username, Password, Nombre, Nivel, Grupo_ID) VALUES (2, 'radadmin_operativas', MD5('webradius'), 'Usuario de Tareas Operativas', 'Tareas Operativas', 1)";
$dbh->query($sql_statement);

$sql_statement = "INSERT INTO $table (ID, Username, Password, Nombre, Nivel, Grupo_ID) VALUES (3, 'radadmin_consulta', MD5('webradius'), 'Usuario de Tareas de Consulta', 'Tareas de Consulta', 1)";
$dbh->query($sql_statement);


$database = "mysql";

$dbh = Mysql->connect($host, $database, $user, $password);
$sql_statement = "DELETE FROM user WHERE User LIKE 'nobody'";
$dbh->query($sql_statement);

$sql_statement = "INSERT INTO user (Host, User, Password, Select_priv, Insert_priv, Update_priv, Delete_priv) VALUES ('localhost', 'nobody', PASSWORD('nobody'), 'Y', 'Y', 'Y', 'Y')";
$dbh->query($sql_statement);
exit (0);
