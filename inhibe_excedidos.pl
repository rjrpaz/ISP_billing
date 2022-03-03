#!/usr/bin/perl

# Este script se ejecuta cada X cantidad de minutos, y va inhabilitando aquellos
# usuarios que exceden en su consumo

use Mysql;

$host = "localhost";
$database = "radius";
$user = "root";
$password = "4c0r4z4d0";

@inhabilitados = ();
@e_mails_administrativos = ("ediperna", "juanfer", "tvicom", "monitoreo");
my $contador = 0;

$dbh = Mysql->connect($host, $database, $user, $password);

$sql_statement = "SELECT personaldata.PersonalDataID, planes.Cantidad_Horas, sum(radacct.AcctSessionTime) FROM radacct LEFT JOIN personaldata ON (radacct.UserName = personaldata.UserName) LEFT JOIN planes ON (personaldata.Plan_ID = planes.ID) WHERE personaldata.Exceso_Horas LIKE 'Corte de Servicio' AND personaldata.Estado LIKE 'Activo' AND planes.Cantidad_Horas != 999 AND SUBSTRING(radacct.AcctStartTime,1,7) = SUBSTRING(curdate(),1,7) GROUP BY radacct.UserName";
$sth = $dbh->query($sql_statement);

while (@arr = $sth->fetchrow)
{
	if ($arr[2] > ($arr[1] * 3600))
	{
#		print $arr[0], "\t", $arr[1], "\t", $arr[2], "\n";
		$inhabilitados[$contador] = $arr[0];
		$contador++;
	}
}

if ($contador != 0)
{
	open (MAIL, "> /tmp/$$.mail");
	print MAIL "Los siguientes usuarios fueron inhabilitados por excederse en el consumo:\n\n";
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
