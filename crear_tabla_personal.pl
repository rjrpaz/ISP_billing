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

$table = "personaldata";

$sql_statement = "DROP TABLE IF EXISTS $table";
$dbh->query($sql_statement);

$sql_statement = "CREATE TABLE IF NOT EXISTS $table ( \
					PersonalDataID bigint (21) DEFAULT '0' NOT NULL auto_increment, \
					UserName varchar(30) DEFAULT '' NOT NULL, \
					Nombre varchar(255) DEFAULT '' NOT NULL, \
					Sexo enum('Masculino','Femenino') DEFAULT 'Masculino' NOT NULL, \
					Documento varchar(255) DEFAULT '' NOT NULL, \
					Direccion varchar (255) DEFAULT '' NOT NULL, \
					Localidad varchar (255) DEFAULT '' NOT NULL, \
					CodigoPostal varchar (255) DEFAULT '' NOT NULL, \
					Telefono varchar (40) DEFAULT '' NOT NULL, \
					Tipo_IVA enum('Inscripto','No Inscripto','Consumidor Final','Excento','Monotributo') DEFAULT 'Excento' NOT NULL, \
					Cuit varchar (255) DEFAULT '' NOT NULL, \
					Estado enum('Activo', 'Inactivo') DEFAULT 'Activo' NOT NULL, \
					Exceso_Horas enum ('Facturar Excedente', 'Corte de Servicio') DEFAULT 'Facturar Excedente' NOT NULL, \
					Ultimo_Mes_Pago date DEFAULT '0000-00-00' NOT NULL, \
					Fecha_Alta date DEFAULT '0000-00-00' NOT NULL, \
					Fecha_Desconexion date DEFAULT '0000-00-00' NOT NULL, \
					Fecha_Reconexion date DEFAULT '0000-00-00' NOT NULL, \
					E_mails varchar (255) DEFAULT '' NOT NULL, \
					Plan_ID int (10) unsigned DEFAULT '0' NOT NULL, \
					Grupo_ID int (10) unsigned DEFAULT '0' NOT NULL, \
					Agente_ID int (10) unsigned DEFAULT '0' NOT NULL, \
					PRIMARY KEY (PersonalDataID), \
					UNIQUE PersonalDataID (PersonalDataID), \
					KEY UserName (UserName))";

#print "$sql_statement \n";

$dbh->query($sql_statement);

exit (0);
