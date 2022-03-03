#!/usr/bin/perl

# Este script se ejecuta el primer minuto de cada mes, y rehabilita a todos aquellos
# usuarios que habian sido inhabilitados por exceso en el consumo

use Mysql;

$host = "localhost";
$database = "radius";
$user = "root";
$password = "4c0r4z4d0";

@inhabilitados = ();
@e_mails_administrativos = ("ediperna", "juanfer", "tvicom", "monitoreo");
my $contador = 0;

$mes_pasado = `/bin/date --date="2 month ago" +%Y"-"%m"-00"`;
($mes_pasado) = ($mes_pasado =~ /([^\n]*)/);

$dbh = Mysql->connect($host, $database, $user, $password);

$sql_statement = "SELECT personaldata.PersonalDataID, personaldata.Ultimo_Mes_Pago, planes.Cantidad_Horas, sum(radacct.AcctSessionTime) FROM radacct LEFT JOIN personaldata ON (radacct.UserName = personaldata.UserName) LEFT JOIN planes ON (personaldata.Plan_ID = planes.ID) WHERE personaldata.Exceso_Horas LIKE 'Corte de Servicio' AND personaldata.Estado LIKE 'Inactivo' AND planes.Cantidad_Horas != 999 AND SUBSTRING(radacct.AcctStartTime,1,7) = SUBSTRING(DATE_SUB(curdate(), INTERVAL 1 DAY),1,7) GROUP BY radacct.UserName";
$sth = $dbh->query($sql_statement);

while (@arr = $sth->fetchrow)
{
#	print $arr[0],"\t", $arr[1],"\t", $arr[2],"\t", $arr[3],"\n";
	if (($arr[1] lt $mes_pasado) && ($arr[2] > ($arr[1] * 3600)))
	{
		$inhabilitados[$contador] = $arr[0];
		$contador++;
	}
}

if ($contador != 0)
{
	open (MAIL, "> /tmp/$$.mail");
	print MAIL "Los siguientes usuarios fueron rehabilitados para Uso del Servicio:\n\n";
	print MAIL "Nombre|Nombre de Usuario|Cuentas de Correo|Ultimo Mes Pago\n";

	foreach $inhabilitado (@inhabilitados)
	{
		$sql_statement = "UPDATE personaldata SET Estado = 'Activo' WHERE PersonalDataID = ".$inhabilitado;
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
