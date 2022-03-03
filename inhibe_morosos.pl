#!/usr/bin/perl

# Este script se ejecuta el dia 16 de cada mes en primeras horas de la madrugada
# e inhabilita todos aquellos abonados que no hayan efectuado el pago.

use Mysql;

$host = "localhost";
$database = "radius";
$user = "root";
$password = "4c0r4z4d0";

@inhabilitados = ();
@e_mails_administrativos = ("ediperna", "juanfer", "tvicom");
my $contador = 0;

$mes_pasado = `/bin/date --date="1 month ago" +%Y"-"%m"-00"`;
($mes_pasado) = ($mes_pasado =~ /([^\n]*)/);

$dbh = Mysql->connect($host, $database, $user, $password);

$sql_statement = "SELECT PersonalDataID, Ultimo_Mes_Pago FROM personaldata WHERE Exceso_Horas LIKE 'Corte de Servicio' AND Estado LIKE 'Activo'";
$sth = $dbh->query($sql_statement);

while (@arr = $sth->fetchrow)
{
	if ($arr[1] lt $mes_pasado)
	{
		$inhabilitados[$contador] = $arr[0];
		$contador++;
	}
}

if ($contador != 0)
{
	open (MAIL, "> /tmp/$$.mail");
	print MAIL "Los siguientes usuarios fueron inhabilitados por mora en el pago:\n\n";
	print MAIL "Nombre|Nombre de Usuario|Cuentas de Correo|Ultimo Mes Pago\n";

	foreach $inhabilitado (@inhabilitados)
	{
		$sql_statement = "UPDATE personaldata SET Estado = 'Inactivo' WHERE PersonalDataID = ".$inhabilitado;
		$dbh->query($sql_statement);
		$sql_statement = "SELECT Nombre, UserName, E_mails, Ultimo_Mes_Pago FROM personaldata WHERE PersonalDataID = ".$inhabilitado;
		$sth = $dbh->query($sql_statement);
		@arr = $sth->fetchrow;

		print MAIL $arr[0],"|",$arr[1],"|",$arr[2],"|",$arr[3],"\n";
	}

	print MAIL "\nCantidad de Usuarios: $contador \n\n";
	close (MAIL);
	foreach $e_mail (@e_mails_administrativos)
	{
		$comando = "export QMAILUSER=administrador;export QMAILNAME=\"Administracion de TVICom\";cat /tmp/$$.mail | /var/qmail/bin/qmail-inject $e_mail";
		system($comando);
	}
	$comando = "rm -f /tmp/$$.mail";
	system($comando);
}

exit;
