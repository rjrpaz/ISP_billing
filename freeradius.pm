package freeradius;

use strict;

require Exporter;
require Mysql;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

$VERSION     = 0.01;

@ISA         = qw(Exporter Mysql);
@EXPORT      = qw(&tail_html &head_html &chequeo_password &obtener_nivel &return_error_mysql &usuario_existente_radius &usuario_existente_so &usuario_existente_usuarios &usuario_existente_hosting &nombre_existente_agentes &usuario_tiene_agente_asociado &acomodar_case &obtener_tipo_acceso &obtener_password &obtener_nombre &alta_radcheck &baja_radcheck &alta_radreply &baja_radreply &alta_personaldata &desconectar_usuario &reconectar_usuario &baja_personaldata &alta_so &alta_assign &baja_so &baja_assign &alta_hosting &baja_hosting &plan_es_utilizado &insertar_log &menu_individuales &menu_totales &menu_conectados &menu_maildir &plan_existente &alta_plan &baja_plan &listar_planes &listar_niveles &alta_usuarios &baja_usuarios &grupo_existente &alta_grupos &baja_grupos &listar_grupos &obtener_grupo_usuario &alta_agentes &baja_agentes &listar_agentes &bajar_interface &menu_listado &menu_chequeo &segundos2hora $server $tamanio_minimo_contrasenia $host $database $dbuser $dbpass $mail_only_rules_name $grupo_default @tipo_de_iva $radwho $checkrad $naslist);

%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

@EXPORT_OK   = qw();
use vars qw($server $tamanio_minimo_contrasenia $host $database $dbuser $dbpass $mail_only_rules_name $radius_fecha_inicial $grupo_default @tipo_de_iva);

use vars qw(@parametro $ftpserver $sql_statement $sth $dbh $radwho $checkrad $naslist);

$server = "http://server.micasa.org:443";
#$server = "https://radius.tvicom.com.ar";
$ftpserver = "s1linux";
$tamanio_minimo_contrasenia = 4;
$host = "localhost";
$database = "radius";
$dbuser = "nobody";
$dbpass = "nobody";
$mail_only_rules_name = "mailonly";
$radius_fecha_inicial = "2002-03-07";
$grupo_default = "TVICom";
@tipo_de_iva = ('Inscripto', 'No Inscripto', 'Consumidor Final', 'Excento', 'Monotributo');
$radwho = "/usr/bin/radwho -ri";
$checkrad = "/usr/sbin/checkrad";
$naslist = "/etc/raddb/naslist";
my %OIDS = ();

sub head_html
{
# Parametros de la funcion
# parametro[0]: Cantidad en segundos del refresco de la pantalla
# parametro[1]: Titulo
# parametro[2]: Color del Background
	local (@parametro) = @_;

	print <<Eof_Head;
<HTML>
 <HEAD>
  <TITLE>
   $parametro[1]
  </TITLE>
Eof_Head
	if ($parametro[0] ne "")
	{
		print "  <META HTTP-EQUIV=\"REFRESH\" CONTENT=\"".$parametro[0]."\">\n";
	}
	print " </HEAD>\n";
	if ($parametro[2] ne "")
	{
		print " <BODY BGCOLOR=\"".$parametro[2]."\">\n";
	}
	else
	{
		print " <BODY BGCOLOR=\"#ffffff\">\n";
	}
}


sub tail_html
{
	local (@parametro) = @_;
	print <<Eof_Tail;
  <DIV ALIGN="center">
   <A HREF="$parametro[0]">
    <FONT FACE="Arial,Helvetica,Geneva,Swiss,SunSans-Regular" SIZE="3">
     <b>
      Volver a la p&aacute;gina principal
     </b>
    </FONT>
   </A>
  </DIV>
  <HR>
 </BODY>
</HTML>
Eof_Tail
}


sub chequeo_password
{
	my $host = "localhost";
	my $database = "radius";
	my $table = "usuarios";
	my $password_tabla = "";
	my $password_form = "";
	my $errmsg = "";

	local (@parametro) = @_;

	if (($parametro[0] eq "") || ($parametro[1] eq ""))
	{
		return 0;
	}

	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);
	$errmsg = Mysql->errmsg();

	if ($errmsg ne "")
	{
		&return_error_mysql ("Error en el proceso", "Existi&oacute; un error al intentarse la conexi&oacute;n con la Base de Datos.<BR>Consulte al Administrador de la misma.", $errmsg);
	}

	$sql_statement = "SELECT password FROM $table WHERE Username like '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error al Intentar obtener la palabra clave de la Base de Datos.<BR>Consulte al Administrador de la misma.", "");
	$password_tabla = $sth ->fetchrow;

	$password_form = $parametro[1];

	if ($password_tabla eq $password_form)
	{
		return 1;
	}
	return 0;
}


sub obtener_nivel
{
	my $host = "localhost";
	my $database = "radius";
	my $table = "usuarios";
	my $errmsg = "";

	local (@parametro) = @_;
	if ($parametro[0] eq "")
	{
		return;
	}

	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);
	$errmsg = Mysql->errmsg();

	if ($errmsg ne "")
	{
		&return_error_mysql ("Error en el proceso", "Existi&oacute; un error al intentarse la conexi&oacute;n con la Base de Datos.<BR>Consulte al Administrador de la misma.", $errmsg);
	}

	$sql_statement = "SELECT Nivel FROM $table WHERE Username like '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error al Intentar obtener la palabra clave de la Base de Datos.<BR>Consulte al Administrador de la misma.", "");
	return ($sth ->fetchrow);
}


sub return_error_mysql
{
	local (@parametro) = @_;
	print "  <DIV ALIGN=\"center\">\n";
	print "   <H1>\n";
	print "    $parametro[0]\n";
	print "   </H1>\n";
	print "   $parametro[1]\n";
	print "  </DIV>\n";
	print "  <BR>\n";
	print "  <BR>\n";
	if ($parametro[2] ne "")
	{
		print "  El mensaje de Error que devolvio la base de datos es:\n";
		print "  <BR>\n";
		print "  $parametro[2]\n";
	}

	&tail_html("/radadm/index.html");
	exit(1);
}


sub usuario_existente_radius
{
	my $table = "radcheck";

	local (@parametro) = @_;

	# Chequea en la Base de Datos
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT ID FROM $table WHERE UserName like '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	if ($sth->numrows != 0)
	{
		return 1;
	}
}


sub usuario_existente_so
{
	my $username = "";

	local (@parametro) = @_;

	# Chequea en el Sistema Operativo
	$username = (getpwnam($parametro[0]))[0];

	if ($username eq $parametro[0])
	{
		return 1;
	}

	return 0;
}


sub usuario_existente_usuarios
{
	my $table = "usuarios";

	local (@parametro) = @_;

	# Chequea en la Base de Datos
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT ID FROM $table WHERE UserName like '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	if ($sth->numrows != 0)
	{
		return $sth->fetchrow;
	}
	return 0;
}


sub usuario_existente_hosting
{
	my $ftp_database = "proftpd";
	my $table = "users";

	local (@parametro) = @_;

	# Chequea en la Base de Datos
	$dbh = Mysql->connect($host, $ftp_database, $dbuser, $dbpass);

	$sql_statement = "SELECT userid FROM $table WHERE userid like '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	return $sth->numrows;
}


sub nombre_existente_agentes
{
	my $table = "agentes";

	local (@parametro) = @_;

	# Chequea en la Base de Datos
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT ID FROM $table WHERE Nombre like '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	if ($sth->numrows != 0)
	{
		return $sth->fetchrow;
	}
	return 0;
}


sub usuario_tiene_agente_asociado
{
	local (@parametro) = @_;

	# Chequea en la Base de Datos
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT agentes.ID FROM agentes LEFT JOIN usuarios ON (agentes.Usuario_ID = usuarios.ID) WHERE usuarios.Username like '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	if ($sth->numrows != 0)
	{
		return $sth->fetchrow;
	}
	return 0;
}


sub acomodar_case
{
	my @linea_split = ();
	my $linea_split = "";
	my @largo = ();
	my $largo = "";
	my $contador = 0;

	local (@parametro) = @_;

	@linea_split = split /\s+/, $parametro[0];
	foreach $linea_split (@linea_split)
	{
		@largo = split //, $linea_split;
		$contador = 0;
		foreach $largo (@largo)
		{
			$contador++;
		}

		if ($contador > 2)
		{
			$linea_split = "\u\L$linea_split";
		}
	}
	$parametro[0] = join " ", @linea_split;

	return ($parametro[0]);
}


sub obtener_password
{
	my $table = "radcheck";

	local (@parametro) = @_;

	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT Value FROM $table WHERE (UserName like '".$parametro[0]."') AND (Attribute like 'Password')";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	if ($sth->numrows != 0)
	{
		return $sth->fetchrow;
	}
	else
	{
		return;
	}
}


sub obtener_nombre
{
	my $table = "personaldata";

	local (@parametro) = @_;

	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT Nombre FROM $table WHERE (UserName like '".$parametro[0]."')";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	return $sth->fetchrow;
}


sub alta_radcheck
{
	my $table = "radcheck";
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT id FROM $table WHERE (UserName LIKE '".$parametro[0]."' AND Attribute LIKE 'Password')";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	if ($sth->numrows == 0)
	{
		$sql_statement = "INSERT INTO $table (UserName, Attribute, Value) VALUES ('".$parametro[0]."', 'Password', '".$parametro[1]."')";
	}
	else
	{
		$sql_statement = "UPDATE $table SET Value =  '".$parametro[1]."' WHERE (UserName LIKE '".$parametro[0]."' AND Attribute LIKE 'Password')";
	}
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub baja_radcheck
{
	my $table = "radcheck";
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "DELETE FROM $table WHERE (UserName LIKE '".$parametro[0]."')";
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar eliminar en la tabla radcheck.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub alta_radreply
{
	my $table = "radreply";
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	# Primero se fija si el Usuario no es nulo
	if ($parametro[0] eq "")
	{
		return;
	}

	# Luego se fija si existe una entrada para ese usuario en la tabla radcheck, sino
	# no tiene sentido
	$sql_statement = "SELECT id FROM radcheck WHERE (UserName LIKE '".$parametro[0]."' AND Attribute LIKE 'Password')";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	if ($sth->numrows == 0)
	{
		return;
	}

	$sql_statement = "SELECT id FROM $table WHERE (UserName LIKE '".$parametro[0]."' AND Attribute LIKE 'Framed-Filter_Id' AND Value LIKE '".$mail_only_rules_name.".in')";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	if ($sth->numrows == 0)
	{
		$sql_statement = "INSERT INTO $table (UserName, Attribute, Value) VALUES ('".$parametro[0]."', 'Framed-Filter-Id', '".$mail_only_rules_name.".in')";
		$dbh->query($sql_statement)
		or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	}

	$sql_statement = "SELECT id FROM $table WHERE (UserName LIKE '".$parametro[0]."' AND Attribute LIKE 'Framed-Filter_Id' AND Value LIKE '".$mail_only_rules_name.".out')";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	if ($sth->numrows == 0)
	{
		$sql_statement = "INSERT INTO $table (UserName, Attribute, Value) VALUES ('".$parametro[0]."', 'Framed-Filter-Id', '".$mail_only_rules_name.".out')";
		$dbh->query($sql_statement)
		or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	}
}


sub baja_radreply
{
	my $table = "radreply";
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "DELETE FROM $table WHERE (UserName LIKE '".$parametro[0]."')";
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar eliminar en la tabla radreply.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub alta_personaldata
{
	my $table = "personaldata";
	my $usuario = "";
	my $apellido = "";
	my $nombre = "";
	my $sexo = "";
	my $documento = "";
	my $direccion = "";
	my $localidad = "";
	my $codigopostal = "";
	my $telefono = "";
	my $tipoiva = "";
	my $cuit = "";
	my $estado = "";
	my $mora = "";
	my $ultimo_mes_pago = "";
	my $fechaalta = "";
	my $e_mails = "";
	my $plan_id = "";
	my $grupo_id = "";
	my $agente_id = "";
	my $anio = "";
	my $mes = "";
	my $dia = "";
	my $arr = "";
	my $nro_cliente = 0;

	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$usuario = $parametro[0];
	$apellido = $parametro[1];
	$nombre = $parametro[2];
	$sexo = $parametro[3];
	$documento = $parametro[4];
	$direccion = $parametro[5];
	$localidad = $parametro[6];
	$codigopostal = $parametro[7];
	$telefono = $parametro[8];
	$tipoiva = $parametro[9];
	$cuit = $parametro[10];
	$estado = $parametro[11];
	$mora = $parametro[12];
	$ultimo_mes_pago = $parametro[13];
	$fechaalta = $parametro[14];
	$e_mails = $parametro[15];
	$plan_id = $parametro[16];
	$grupo_id = $parametro[17];
	$agente_id = $parametro[18];

	if (($apellido ne "") || ($nombre ne ""))
	{
		if ($nombre ne "")
		{
			$nombre = $apellido.", ".$nombre;
		}
		else
		{
			$nombre = $apellido;
		}
	}
	$nombre =~ s/'/\\'/g;

	($dia, $mes, $anio) = split /\//, $fechaalta;
	$anio = "20".$anio; 
	$fechaalta = join ("-", $anio, $mes, $dia); 

	if ($ultimo_mes_pago eq "")
	{
		$ultimo_mes_pago = `/bin/date --date="1 month ago" +%Y"-"%m"-01"`;
		($ultimo_mes_pago) = ($ultimo_mes_pago =~ /([^\n]*)/);
	}
	else
	{
		($dia, $mes, $anio) = split /\//, $ultimo_mes_pago;
		$anio = "20".$anio; 
		$ultimo_mes_pago = join ("-", $anio, $mes, $dia); 
	}

	$sql_statement = "SELECT PersonalDataID FROM $table WHERE UserName LIKE '".$usuario."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	if ($sth->numrows == 0)
	{
		$sql_statement = "INSERT INTO $table (UserName, Nombre, Sexo, Documento, Direccion, Localidad, CodigoPostal, Telefono, Tipo_IVA, Cuit, Estado, Exceso_Horas, Ultimo_Mes_Pago, Fecha_Alta, E_mails, Plan_ID, Grupo_ID, Agente_ID) VALUES ('".$usuario."', '".$nombre."', '".$sexo."', '".$documento."', '".$direccion."', '".$localidad."', '".$codigopostal."', '".$telefono."', '".$tipoiva."', '".$cuit."', '".$estado."', '".$mora."', '".$ultimo_mes_pago."', '".$fechaalta."', '".$e_mails."',".$plan_id.", ".$grupo_id.", ".$agente_id.")";
	}
	else
	{
		$nro_cliente = $sth->fetchrow;
		# Chequea si habilita o inhabilita un usuario
		$sql_statement = "SELECT Estado FROM $table WHERE UserName LIKE '".$usuario."'";
		$sth = $dbh->query($sql_statement)
		or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
		$arr = $sth->fetchrow;

		if ($estado ne $arr)
		{
			if ($estado eq "Activo")
			{
				&reconectar_usuario($usuario);
			}
			else
			{
				&desconectar_usuario($usuario);
			}
		}

		$sql_statement = "UPDATE $table SET Nombre = '".$nombre."', Sexo = '".$sexo."', Documento = '".$documento."', Direccion = '".$direccion."', Localidad = '".$localidad."', CodigoPostal = '".$codigopostal."', Telefono = '".$telefono."', Tipo_IVA = '".$tipoiva."', Cuit = '".$cuit."', Estado = '".$estado."', Exceso_Horas = '".$mora."', Ultimo_Mes_Pago = '".$ultimo_mes_pago."', Fecha_Alta = '".$fechaalta."', E_mails = '".$e_mails."',Plan_ID = ".$plan_id.", Grupo_ID = ".$grupo_id.", Agente_ID = ".$agente_id."  WHERE UserName like '".$usuario."'";
	}
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	if ($nro_cliente == 0)
	{
		$nro_cliente = $sth->insertid;
	}
	return $nro_cliente;
}


sub desconectar_usuario
{
	my $table = "personaldata";
	my $fecha_de_hoy = "";
	my $usuario = "";

	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);
	$usuario = $parametro[0];

	$fecha_de_hoy = `/bin/date +%Y-%m-%d`;
	($fecha_de_hoy) = ($fecha_de_hoy =~ /([^\n]*)/);

	$sql_statement = "UPDATE $table SET Fecha_Desconexion = '".$fecha_de_hoy."', Fecha_Reconexion = '0000-00-00' WHERE UserName like '".$usuario."'";
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub reconectar_usuario
{
	my $table = "personaldata";
	my $arr = "";
	my $fecha_de_hoy = "";
	my $usuario = "";

	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);
	$usuario = $parametro[0];

	$sql_statement = "SELECT Fecha_Desconexion FROM $table WHERE UserName LIKE '".$usuario."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	$arr = $sth->fetchrow;

	if ($arr ne "0000-00-00")
	{
		$fecha_de_hoy = `/bin/date +%Y-%m-%d`;
		($fecha_de_hoy) = ($fecha_de_hoy =~ /([^\n]*)/);

		$sql_statement = "UPDATE $table SET Fecha_Reconexion = '".$fecha_de_hoy."' WHERE UserName like '".$usuario."'";
		$dbh->query($sql_statement)
		or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	}
}


sub baja_personaldata
{
	my $table = "personaldata";
	my $arr = "";
	my $fecha_de_hoy = "";

	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "DELETE FROM $table WHERE (UserName LIKE '".$parametro[0]."')";
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar eliminar en la tabla radreply.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub alta_so
{
	my $comando = "";
	my $usuario = "";
	my $password = "";
	my $crypted_password = "";
	my $usuario_existe = 0;

	local (@parametro) = @_;

	$usuario = $parametro[0];
	$password = $parametro[1];

	my $username = (getpwnam($usuario))[0];
	if ($username eq $usuario)
	{
		$usuario_existe = 1;
	}

	if ($password eq "")
	{
		if ($usuario_existe)
		{
			$comando = "/usr/sbin/usermod -g internet -d /home/$usuario -s /bin/false -m $usuario";
		}
		else
		{
			$comando = "/usr/sbin/useradd -g internet -d /home/$usuario -s /bin/false -m $usuario";
		}
	}
	else
	{
		$crypted_password = `/bin/crypt $password`;
		$crypted_password =~ s/\$/\\\$/g;

		if ($usuario_existe)
		{
			$comando = "/usr/sbin/usermod -g internet -p \"$crypted_password\" -d /home/$usuario -s /bin/false -m $usuario";
		}
		else
		{
			$comando = "/usr/sbin/useradd -g internet -p \"$crypted_password\" -d /home/$usuario -s /bin/false -m $usuario";
		}
	}
	system ($comando);

	if ($usuario =~ /[A-Z]/)
	{
		&alta_assign($usuario);
	}
}


sub alta_assign
{
	# Paso necesario para usuarios que tengan alguna letra mayiscula en su nombre de usuario. Ver 
	# pagina de manual qmail-users(5).
	local (@parametro) = @_;

	my $assign_file = "/var/qmail/users/assign";
	my $uid = "";
	my $gid = "";
	my $homedir = "";
	my $comando = "";
	my @campos = ();

	open (ASSIGN, "< $assign_file");
	open (ASSIGNTMP, "> $assign_file.tmp");
	while (<ASSIGN>)
	{
		chop;
		if ($_ ne "\.")
		{
			# Identifica si la linea ya existe
			@campos = split /:/, $_;
			if ($campos[1] eq $parametro[0])
			{
				close (ASSIGNTMP);
				close (ASSIGN);
				$comando = "rm ".$assign_file.".tmp";
				system ($comando);
				return;
			}

			print ASSIGNTMP $_,"\n";
		}
	}
	($uid, $gid, $homedir) = (getpwnam ($parametro[0]))[2,3,7];
	print ASSIGNTMP "=",$parametro[0],":",$parametro[0],":",$uid,":",$gid,":",$homedir,":::\n";
	print ASSIGNTMP ".\n";
	close (ASSIGNTMP);
	close (ASSIGN);
	$comando = "mv ".$assign_file.".tmp ".$assign_file;
	system ($comando);
	$comando = "/var/qmail/bin/qmail-newu";
	system ($comando);
}


sub baja_so
{
	local (@parametro) = @_;

	if (($parametro[0]) eq "")
	{
		return;
	}

	my $date = `/bin/date +%y%m%d%H%M`;
	($date) = ($date =~ /([^\n]*)/);
	my $comando = "/bin/tar cvfz /var/backups/".$parametro[0]."_".$date.".tgz /home/$parametro[0] 1>/dev/null 2>/dev/null";
	system ($comando);
	$comando = "/usr/sbin/userdel -r $parametro[0]";
	system ($comando);
	if ($parametro[0] =~ /[A-Z]/)
	{
		&baja_assign($parametro[0]);
	}
}


sub baja_assign
{
	local (@parametro) = @_;

	my $assign_file = "/var/qmail/users/assign";
	my $comando = "";
	my $nombre = "";

	open (ASSIGN, "< $assign_file");
	open (ASSIGNTMP, "> $assign_file.tmp");
	while (<ASSIGN>)
	{
		chop;
		if ($_ ne "\.")
		{
			# Identifica la linea
			($nombre) = ($_ =~ /\=([^\:]*)/);
			if ($nombre ne $parametro[0])
			{
				print ASSIGNTMP $_,"\n";
			}
		}
	}
	print ASSIGNTMP ".\n";
	close (ASSIGNTMP);
	close (ASSIGN);
	$comando = "mv ".$assign_file.".tmp ".$assign_file;
	system ($comando);
	$comando = "/var/qmail/bin/qmail-newu";
	system ($comando);
}


sub alta_hosting
{
	my $ftp_database = "proftpd";
	my $table = "users";
	my $uid = "";
	my $gid = "";
	my $homedir = "";
	my $comando = "";
	my $crypted_password = "";

	local (@parametro) = @_;

	my $usuario = $parametro[0];

	$dbh = Mysql->connect($host, $ftp_database, $dbuser, $dbpass);

	$sql_statement = "SELECT userid FROM $table WHERE (userid LIKE '".$usuario."')";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	$comando = "grep \"^".$usuario.":\" /etc/shadow | cut -d: -f2";
	$crypted_password = `$comando`;
	($crypted_password) = ($crypted_password =~ /([^\n]*)/);

	if ($sth->numrows == 0)
	{
		($uid, $gid) = (getpwnam ($usuario)) [2,3];
		$homedir = "/home/".$usuario;
		$sql_statement = "INSERT INTO $table (userid, password, uid, gid, homedir, shell) VALUES ('".$usuario."', '".$crypted_password."', ".$uid.", ".$gid.", '".$homedir."', '/bin/false')";
		$comando = "/usr/local/bin/ssh $ftpserver mkdir /home/".$usuario;
		system($comando);
		$comando = "/usr/local/bin/ssh $ftpserver chown ".$uid.".".$gid." /home/".$usuario;
		system($comando);
	}
	else
	{
		$sql_statement = "UPDATE $table SET password =  '".$crypted_password."' WHERE (userid LIKE '".$usuario."')";
	}
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub baja_hosting
{
	my $ftp_database = "proftpd";
	my $table = "users";

	local (@parametro) = @_;

	my $usuario = $parametro[0];

	$dbh = Mysql->connect($host, $ftp_database, $dbuser, $dbpass);

	$sql_statement = "DELETE FROM $table WHERE (userid LIKE '".$usuario."')";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub plan_es_utilizado
{

	my $database = "radius";
	my $errmsg = "";

	local (@parametro) = @_;

	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);
	$errmsg = Mysql->errmsg();
	if ($errmsg ne "")
	{
		&return_error_mysql ("Error en el proceso", "Existi&oacute; un error al intentarse la conexi&oacute;n con la Base de Datos.<BR>Consulte al Administrador de la misma.", $errmsg);
	}

	$sql_statement = "SELECT count(*) FROM personaldata LEFT JOIN planes ON (personaldata.Plan_ID=planes.ID) WHERE planes.Nombre like '$parametro[0]'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error al Intentar obtener la palabra clave de la Base de Datos.<BR>Consulte al Administrador de la misma.", "");
	return ($sth ->fetchrow);
}


sub insertar_log
{
	my $hora = "";
	my $mensaje = "";
	my $log_mantenimiento = "/var/log/radadmin.log";
	local (@parametro) = @_;
	my $usuario = $parametro[0];
	my $operacion = $parametro[1];
	my $datos = $parametro[2];

	$hora = `/bin/date "+%Y-%m-%d %H:%M"`;
	($hora) = ($hora =~ /([^\n]*)/);

	$mensaje = $hora." Usuario: ".$usuario."\tOperacion: ".$operacion."\tDatos: ".$datos."\n";
	open (LOG_MANTENIMIENTO, ">> $log_mantenimiento");
	print LOG_MANTENIMIENTO  $mensaje;
	close LOG_MANTENIMIENTO;
}


sub menu_individuales
{
	my $contador = "0";
	my $resultado = "";
	my $i = "0";
	my $dia = "";
	my $mes = "";
	my @anios = ();
	my $anios = "";
	my $anio_inicial = "";
	my $dia_final = "";
	my $mes_final = "";
	my $anio_final = "";

	local (@parametro) = @_;

	$resultado = `/bin/date +%y%m%d`;
	($anio_final) = ($resultado =~ /(.{2})/);
	($mes_final) = ($resultado =~ /.{2}(.{2})/);
	($dia_final) = ($resultado =~ /.{4}(.{2})/);

	($anio_inicial) = ($radius_fecha_inicial =~ /.{2}(.{2})/);

	if ($parametro[0] eq "")
	{
		$parametro[0] = "1";
	}
	if ($parametro[1] eq "")
	{
		$parametro[1] = $mes_final;
	}
	if ($parametro[2] eq "")
	{
		$parametro[2] = $anio_final;
	}
	if ($parametro[3] eq "")
	{
		$parametro[3] = $dia_final;
	}
	if ($parametro[4] eq "")
	{
		$parametro[4] = $mes_final;
	}
	if ($parametro[5] eq "")
	{
		$parametro[5] = $anio_final;
	}

	print "     <tr height=\"20\">\n";
	print "      <td align=\"left\" colspan=\"3\" height=\"20\">\n";
	print "       &nbsp;\n";
	print "      </td>\n";
	print "     </tr>\n";

	print "     <TR bgcolor=\"#ffebcd\">\n";
	print "      <TD ALIGN=\"left\" COLSPAN=\"3\">\n";
	print "       <div ALIGN=\"center\">\n";
	print "        &nbsp;\n";
	print "        <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "         <B>\n";
	print "          Desde:\n";
	print "         </B>\n";
	print "        </FONT>\n";
	print "       </div>\n";
	print "      </TD>\n";
	print "     </TR>\n";

	$contador = 0;
	$i = $anio_inicial;
	while ($i <= $anio_final)
	{
		$anios[$contador] = sprintf("%02d",$i);
		$i++;
		$contador++;
	}
	print "     <TR bgcolor=\"#ffebcd\">\n";
	print "      <TD ALIGN=\"left\" WIDTH=\"150\" nowrap>\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          Dia: \n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"dia_inicial\">\n";
	for ($i=1; $i<32; $i++)
	{
		$dia=sprintf("%02d", $i);
		print "           <OPTION";
		if ($dia eq $parametro[0])
		{
			print " SELECTED";
		}
		print ">$dia\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";

	print "      <TD ALIGN=\"left\" valign=\"middle\" WIDTH=\"150\" nowrap>\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          Mes: \n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"mes_inicial\">\n";
	for ($i=1; $i<13; $i++)
	{
		$mes=sprintf("%02d", $i);
		print "           <OPTION";
		if ($mes eq $parametro[1])
		{
			print " SELECTED";
		}
		print ">$mes\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";

	print "      <TD ALIGN=\"left\" valign=\"center\" WIDTH=\"200\" nowrap>\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          A&ntilde;o:\n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"anio_inicial\">\n";
	foreach $anios (@anios)
	{
		print "           <OPTION";
		if ($anios eq $parametro[2])
		{
			print " SELECTED";
		}
		print ">20".$anios."\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";
	print "     </TR>\n";

	print "     <tr height=\"20\">\n";
	print "      <td colspan=\"3\" height=\"20\">\n";
	print "       &nbsp;\n";
	print "      </td>\n";
	print "     </tr>\n";

	print "     <TR bgcolor=\"#ffebcd\">\n";
	print "      <TD COLSPAN=\"3\">\n";
	print "       <div ALIGN=\"center\">\n";
	print "        &nbsp;\n";
	print "        <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "         <B>\n";
	print "          Hasta:\n";
	print "         </B>\n";
	print "        </FONT>\n";
	print "       </div>\n";
	print "      </TD>\n";
	print "     </TR>\n";

	print "     <TR bgcolor=\"#ffebcd\">\n";
	print "      <TD ALIGN=\"center\" valign=\"middle\" WIDTH=\"150\">\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          Dia: \n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"dia_final\">\n";
	for ($i=1; $i<32; $i++)
	{
		$dia=sprintf("%02d", $i);
		print "           <OPTION";
		if ($dia eq $parametro[3])
		{
			print " SELECTED";
		}
		print ">$dia\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";

	print "      <TD ALIGN=\"left\" valign=\"middle\" WIDTH=\"150\">\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          Mes: \n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"mes_final\">\n";
	for ($i=1; $i<13; $i++)
	{
		$mes=sprintf("%02d", $i);
		print "           <OPTION";
		if ($mes eq $parametro[4])
		{
			print " SELECTED";
		}
		print ">$mes\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";

	print "      <TD ALIGN=\"left\" valign=\"center\" WIDTH=\"200\">\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          A&ntilde;o: \n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"anio_final\">\n";
	foreach $anios (@anios)
	{
		print "           <OPTION";
		if ($anios eq $parametro[5])
		{
			print " SELECTED";
		}
		print ">20".$anios."\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";
	print "     </TR>\n";

	print "     <tr height=\"20\">\n";
	print "      <td align=\"center\" colspan=\"3\" height=\"20\">\n";
	print "       &nbsp;\n";
	print "      </td>\n";
	print "     </tr>\n";

	print "     <TR>\n";
	print "      <TD ALIGN=\"center\" COLSPAN=\"3\">\n";
	print "       <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"2\">\n";
	print "        <INPUT TYPE=\"submit\" VALUE=\"    Mostrar    \">\n";
	print "       </FONT>\n";
	print "      </TD>\n";
	print "     </TR>\n";
	print "    </FORM>\n";
	print "   </TABLE>\n";
	print "  </DIV>\n";
	print "  <BR>\n";
}


sub menu_totales
{
	my $contador = "0";
	my $resultado = "";
	my $i = "0";
	my $dia = "";
	my $mes = "";
	my @anios = ();
	my $anios = "";
	my $anio_inicial = "";
	my $dia_final = "";
	my $mes_final = "";
	my $anio_final = "";

	local (@parametro) = @_;

	$resultado = `/bin/date +%y%m%d`;
	($anio_final) = ($resultado =~ /(.{2})/);
	($mes_final) = ($resultado =~ /.{2}(.{2})/);
	($dia_final) = ($resultado =~ /.{4}(.{2})/);

	($anio_inicial) = ($radius_fecha_inicial =~ /.{2}(.{2})/);

	if ($parametro[0] eq "")
	{
		$parametro[0] = "1";
	}
	if ($parametro[1] eq "")
	{
		$parametro[1] = $mes_final;
	}
	if ($parametro[2] eq "")
	{
		$parametro[2] = $anio_final;
	}
	if ($parametro[3] eq "")
	{
		$parametro[3] = $dia_final;
	}
	if ($parametro[4] eq "")
	{
		$parametro[4] = $mes_final;
	}
	if ($parametro[5] eq "")
	{
		$parametro[5] = $anio_final;
	}

	print "     <tr height=\"20\">\n";
	print "      <td align=\"left\" colspan=\"3\" height=\"20\">\n";
	print "       &nbsp;\n";
	print "      </td>\n";
	print "     </tr>\n";

	print "     <TR bgcolor=\"#ffebcd\">\n";
	print "      <TD ALIGN=\"left\" COLSPAN=\"3\">\n";
	print "       <div ALIGN=\"center\">\n";
	print "        &nbsp;\n";
	print "        <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "         <B>\n";
	print "          Desde:\n";
	print "         </B>\n";
	print "        </FONT>\n";
	print "       </div>\n";
	print "      </TD>\n";
	print "     </TR>\n";

	$contador = 0;
	$i = $anio_inicial;
	while ($i <= $anio_final)
	{
		$anios[$contador] = sprintf("%02d",$i);
		$i++;
		$contador++;
	}
	print "     <TR bgcolor=\"#ffebcd\">\n";
	print "      <TD ALIGN=\"left\" WIDTH=\"150\" nowrap>\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          Dia: \n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"dia_inicial\">\n";
	for ($i=1; $i<32; $i++)
	{
		$dia=sprintf("%02d", $i);
		print "           <OPTION";
		if ($dia eq $parametro[0])
		{
			print " SELECTED";
		}
		print ">$dia\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";

	print "      <TD ALIGN=\"left\" valign=\"middle\" WIDTH=\"150\" nowrap>\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          Mes: \n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"mes_inicial\">\n";
	for ($i=1; $i<13; $i++)
	{
		$mes=sprintf("%02d", $i);
		print "           <OPTION";
		if ($mes eq $parametro[1])
		{
			print " SELECTED";
		}
		print ">$mes\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";

	print "      <TD ALIGN=\"left\" valign=\"center\" WIDTH=\"200\" nowrap>\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          A&ntilde;o:\n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"anio_inicial\">\n";
	foreach $anios (@anios)
	{
		print "           <OPTION";
		if ($anios eq $parametro[2])
		{
			print " SELECTED";
		}
		print ">20".$anios."\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";
	print "     </TR>\n";

	print "     <tr height=\"20\">\n";
	print "      <td colspan=\"3\" height=\"20\">\n";
	print "       &nbsp;\n";
	print "      </td>\n";
	print "     </tr>\n";

	print "     <TR bgcolor=\"#ffebcd\">\n";
	print "      <TD COLSPAN=\"3\">\n";
	print "       <div ALIGN=\"center\">\n";
	print "        &nbsp;\n";
	print "        <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "         <B>\n";
	print "          Hasta:\n";
	print "         </B>\n";
	print "        </FONT>\n";
	print "       </div>\n";
	print "      </TD>\n";
	print "     </TR>\n";

	print "     <TR bgcolor=\"#ffebcd\">\n";
	print "      <TD ALIGN=\"center\" valign=\"middle\" WIDTH=\"150\">\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          Dia: \n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"dia_final\">\n";
	for ($i=1; $i<32; $i++)
	{
		$dia=sprintf("%02d", $i);
		print "           <OPTION";
		if ($dia eq $parametro[3])
		{
			print " SELECTED";
		}
		print ">$dia\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";

	print "      <TD ALIGN=\"left\" valign=\"middle\" WIDTH=\"150\">\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          Mes: \n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"mes_final\">\n";
	for ($i=1; $i<13; $i++)
	{
		$mes=sprintf("%02d", $i);
		print "           <OPTION";
		if ($mes eq $parametro[4])
		{
			print " SELECTED";
		}
		print ">$mes\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";

	print "      <TD ALIGN=\"left\" valign=\"center\" WIDTH=\"200\">\n";
	print "       <div ALIGN=\"center\">\n";
	print "        <b>\n";
	print "         <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"3\">\n";
	print "          A&ntilde;o: \n";
	print "         </FONT>\n";
	print "         <font face=\"Courier New, Courier, Monaco\" size=\"3\">\n";
	print "          <SELECT NAME=\"anio_final\">\n";
	foreach $anios (@anios)
	{
		print "           <OPTION";
		if ($anios eq $parametro[5])
		{
			print " SELECTED";
		}
		print ">20".$anios."\n";
	}
	print "          </SELECT>\n";
	print "         </FONT>\n";
	print "        </b>\n";
	print "       </div>\n";
	print "      </TD>\n";
	print "     </TR>\n";

	print "     <tr height=\"20\">\n";
	print "      <td align=\"center\" colspan=\"3\" height=\"20\">\n";
	print "       &nbsp;\n";
	print "      </td>\n";
	print "     </tr>\n";

	print "     <TR>\n";
	print "      <TD ALIGN=\"center\" COLSPAN=\"3\">\n";
	print "       <font face=\"Arial, Helvetica, Geneva, Swiss, SunSans-Regular\" size=\"2\">\n";
	print "        <INPUT TYPE=\"submit\" VALUE=\"    Mostrar    \">\n";
	print "       </FONT>\n";
	print "      </TD>\n";
	print "     </TR>\n";
	print "    </FORM>\n";
	print "   </TABLE>\n\n";
	print "  </CENTER>\n";
	print "  <BR>\n";
}


sub menu_conectados
{
	my @campos = ();
	my $comando = "";
	my %ip_as = ();
	my %type = ();

	use Socket;

	local (@parametro) = @_;

	open (NASLIST, "< $naslist");
	while (<NASLIST>)
	{
		chop;
		next if ($_ =~ /^#/);
		next if ($_ =~ /^$/);
		@campos = split /\s+/, $_;
		$type{$campos[1]} = $campos[2];
		$ip_as{$campos[1]} = $campos[0];
	}
	close (NASLIST);

	print <<body;
  <FORM ACTION="conectados.html" METHOD="post">
   <INPUT TYPE="hidden" NAME="wwwuser" VALUE="$parametro[0]">
   <INPUT TYPE="hidden" NAME="wwwpass" VALUE="$parametro[1]">
   <TABLE COOL BORDER=1 CELLPADDING=0 CELLSPACING=0 ALIGN=center>
    <TR bgcolor="#ffebcd">
     <TD ALIGN="left" COLSPAN="6">
      <div ALIGN="center">
       &nbsp;
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <B>
         Usuarios Conectados Actualmente:
        </B>
       </FONT>
      </div>
     </TD>
    </TR>

    <TR bgcolor="#ffebcd">
     <TD ALIGN="center" WIDTH="150" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Desconectar
       </FONT>
      </b>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Usuario
       </FONT>
      </b>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Servidor de Acceso
       </FONT>
      </b>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Puerto
       </FONT>
      </b>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Direcci&oacute;n IP
       </FONT>
      </b>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Inicio de Sesi&oacute;n
       </FONT>
      </b>
     </TD>
    </TR>
body

	open (RADWHO, "$radwho |");
	while (<RADWHO>)
	{
		chop;
		@campos = split /,/, $_;
		next if ($campos[0] =~ /Login/);
		next if ($campos[2] !~ /PPP/);
	
		if ($ip_as{$campos[5]} eq '')
		{
			$ip_as{$campos[5]} = inet_ntoa(inet_aton($campos[5]));
		}

		($campos[3]) = ($campos[3] =~ /S(.*)/);
		$comando = "$checkrad $type{$campos[5]} $ip_as{$campos[5]} $campos[3] $campos[0] $campos[1]";

		if (system($comando))
		{
			print "    <INPUT TYPE=\"hidden\" NAME=\"".$campos[1]."_usuario\" VALUE=\"".$campos[0]."\">\n";
			print "    <INPUT TYPE=\"hidden\" NAME=\"".$campos[1]."_as\" VALUE=\"".$campos[5]."\">\n";
			print "    <INPUT TYPE=\"hidden\" NAME=\"".$campos[1]."_puerto\" VALUE=\"".$campos[3]."\">\n";
			print "    <INPUT TYPE=\"hidden\" NAME=\"".$campos[1]."_ip\" VALUE=\"".$campos[6]."\">\n";
			print "    <INPUT TYPE=\"hidden\" NAME=\"".$campos[1]."_sesion\" VALUE=\"".$campos[4]."\">\n";
			print <<body;
    <TR>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       <INPUT TYPE="checkbox" NAME="$campos[1]">
      </FONT>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       $campos[0]
      </FONT>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       $campos[5]
      </FONT>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       $campos[3]
      </FONT>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       $campos[6]
      </FONT>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       $campos[4]
      </FONT>
     </TD>
    </TR>
body
		}
	}

	print <<body;
    <TR HEIGHT="60">
     <TD ALIGN="center" COLSPAN="6" HEIGHT="60" CONTENT VALIGN="bottom">
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="2">
       <INPUT TYPE="submit" VALUE="    Desconectar    ">
      </FONT>
     </TD>
    </TR>
   </TABLE>
  </FORM>
body
}


sub menu_maildir
{
	my $maildir = "";
	my @maildir = ();
	my $mail = "";
	my $from = "";
	my $to = "";
	my $subject = "";
	my $date = "";
	my $tamanio = "";

	local (@parametro) = @_;

	print <<body;
  <FORM ACTION="maildir-consulta.html" METHOD="post">
   <INPUT TYPE="hidden" NAME="wwwuser" VALUE="$parametro[0]">
   <INPUT TYPE="hidden" NAME="wwwpass" VALUE="$parametro[1]">
   <INPUT TYPE="hidden" NAME="consultar" VALUE="$parametro[2]">
   <TABLE COOL BORDER=1 CELLPADDING=0 CELLSPACING=0 ALIGN=center>
    <TR bgcolor="#ffebcd">
     <TD ALIGN="left" COLSPAN="6">
      <div ALIGN="center">
       &nbsp;
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <B>
         Listado de Mails del usuario $parametro[2]:
        </B>
       </FONT>
      </div>
     </TD>
    </TR>

    <TR bgcolor="#ffebcd">
     <TD ALIGN="center" WIDTH="50" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Eliminar
       </FONT>
      </b>
     </TD>
     <TD ALIGN="center" WIDTH="50" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Tama&ntilde;o:
       </FONT>
      </b>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Fecha:
       </FONT>
      </b>
     </TD>
     <TD ALIGN="center" WIDTH="250" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        De:
       </FONT>
      </b>
     </TD>
     <TD ALIGN="center" WIDTH="250" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Para:
       </FONT>
      </b>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Asunto:
       </FONT>
      </b>
     </TD>
    </TR>
body

	$maildir[0] = "/home/".$parametro[2]."/Maildir/cur/";
	$maildir[1] = "/home/".$parametro[2]."/Maildir/new/";

	foreach $maildir (@maildir)
	{
		open (MAILLIST, "ls $maildir |");
		while (<MAILLIST>)
		{
			chop;
			$mail = $maildir.$_;

			$from = "";
			$to = "";
			$subject = "";
			$date = "";
			$tamanio = "";
			open (MAIL, $mail);
			while (<MAIL>)
			{
				chop;
				last if ($_ =~ /^$/);

				$_ =~ s/</&#060;/g;
				$_ =~ s/>/&#062;/g;
				(($from) = ($_ =~ /From:\s([^\n]*)/)) if ($_ =~ /^From:\s/);
				(($to) = ($_ =~ /To:\s([^\n]*)/)) if ($_ =~ /^To:\s/);
				(($subject) = ($_ =~ /Subject:\s(.*)/)) if ($_ =~ /^Subject:\s/);
				(($date) = ($_ =~ /Date:\s(.*)/)) if ($_ =~ /^Date:\s/);
			}
			close (MAIL);
			$tamanio = `du -sh $mail`;
			($tamanio) = ($tamanio =~ /([^\s]*)/);

			print <<body;
    <TR>
     <TD ALIGN="center" WIDTH="50" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       <INPUT TYPE="checkbox" NAME="$mail">
      </FONT>
     </TD>
     <TD ALIGN="center" WIDTH="50" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       $tamanio
      </FONT>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       $date
      </FONT>
     </TD>
     <TD ALIGN="center" WIDTH="250" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       $from
      </FONT>
     </TD>
     <TD ALIGN="center" WIDTH="250" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       $to
      </FONT>
     </TD>
     <TD ALIGN="center" WIDTH="150" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       $subject
      </FONT>
     </TD>
    </TR>
body
		}
		close (MAILLIST);
	}

	print <<body;
    <TR HEIGHT="60">
     <TD ALIGN="center" COLSPAN="6" HEIGHT="60" CONTENT VALIGN="bottom">
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="2">
       <INPUT TYPE="submit" VALUE="    Eliminar    ">
      </FONT>
     </TD>
    </TR>
   </TABLE>
  </FORM>
body
}


sub plan_existente
{
	my $table = "planes";
	my $nombre_plan = "";

	local (@parametro) = @_;

	# Primero chequea en la Base de Datos
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	($nombre_plan) = ($parametro[0] =~ /([^\:]*)/);

	$sql_statement = "SELECT ID FROM $table WHERE Nombre like '".$nombre_plan."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	if ($sth->numrows != 0)
	{
		return $sth->fetchrow;
	}

	return 0;
}


sub alta_plan
{
	my $table = "planes";

	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	my $nombre = $parametro[0];
	my $primer_vencimiento = $parametro[1];
	my $segundo_vencimiento = $parametro[2];
	my $tercer_vencimiento = $parametro[3];
	my $cantidad_accesos_simultaneos = $parametro[4];
	my $cantidad_horas = $parametro[5];
	my $cantidad_e_mail = $parametro[6];
	my $costo_tiempo_excedente = $parametro[7];
	my $incluye_navegacion = $parametro[8];
	my $incluye_hosting = $parametro[9];

	if ($segundo_vencimiento eq "")
	{
		$segundo_vencimiento = 0;
	}
	if ($tercer_vencimiento eq "")
	{
		$tercer_vencimiento = 0;
	}

	$sql_statement = "SELECT ID FROM $table WHERE Nombre LIKE '".$nombre."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	if ($sth->numrows == 0)
	{
		$sql_statement = "INSERT INTO $table (Nombre, Primer_Vencimiento, Segundo_Vencimiento, Tercer_Vencimiento, Cantidad_Accesos_Simultaneos, Cantidad_Horas, Cantidad_E_Mail, Costo_Tiempo_Excedente, Navegacion, Hosting) VALUES ('".$nombre."', ".$primer_vencimiento.", ".$segundo_vencimiento.", ".$tercer_vencimiento.", ".$cantidad_accesos_simultaneos.", ".$cantidad_horas.", ".$cantidad_e_mail.", ".$costo_tiempo_excedente.", '".$incluye_navegacion."', '".$incluye_hosting."')";
	}
	else
	{
		$sql_statement = "UPDATE $table SET Primer_Vencimiento = ".$primer_vencimiento.", Segundo_Vencimiento = ".$segundo_vencimiento.", Tercer_Vencimiento = ".$tercer_vencimiento.", Cantidad_Accesos_Simultaneos = ".$cantidad_accesos_simultaneos.", Cantidad_Horas = ".$cantidad_horas.", Cantidad_E_Mail = ".$cantidad_e_mail.", Costo_Tiempo_Excedente = ".$costo_tiempo_excedente.", Navegacion = '".$incluye_navegacion."', Hosting = '".$incluye_hosting."' WHERE Nombre LIKE '".$nombre."'";
	}

	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub baja_plan
{
	my $table = "planes";
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "DELETE FROM $table WHERE (Nombre LIKE '".$parametro[0]."')";
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar eliminar en la tabla $table.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub listar_planes
{
	my $table = "planes";
	my $contador = 0;
	my @planes= ();
	my @arr= ();

	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT Nombre, Cantidad_Accesos_Simultaneos, Cantidad_Horas, Cantidad_E_mail, Navegacion, Hosting FROM $table ORDER BY Nombre";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar eliminar en la tabla $table.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	while (@arr = $sth->fetchrow)
	{
		$planes[$contador] = $arr[0].": ".$arr[1]." Acceso";
		if ($arr[1] ne "1")
		{
			$planes[$contador] = $planes[$contador]."s";
		}
		if ($arr[2] eq "999")
		{
			$planes[$contador] = $planes[$contador].", Sin l&iacute;mite";
		}
		else
		{
			$planes[$contador] = $planes[$contador].", ".$arr[2]." Horas";
		}
		$planes[$contador] = $planes[$contador].", ".$arr[3]." E-mail";
		if ($arr[4] eq "Si")
		{
			$planes[$contador] = $planes[$contador].", Navegaci&oacute;n";
		}
		if ($arr[5] eq "Si")
		{
			$planes[$contador] = $planes[$contador].", Hosting";
		}

		$contador++;
	}
	return (@planes);
}


sub listar_niveles
{
	my $table = "usuarios";
	my $contador = 0;
	my @niveles= ();
	my $arr= "";

	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT DISTINCT Nivel FROM $table ORDER BY Nivel";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar eliminar en la tabla $table.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	while ($arr = $sth->fetchrow)
	{
		$niveles[$contador] = $arr;
		$contador++;
	}
	return (@niveles);
}


sub alta_usuarios
{
	my $table = "usuarios";
	my $grupo_id = 0;
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$grupo_id = &grupo_existente($parametro[4]);
	$sql_statement = "SELECT id FROM $table WHERE (Username LIKE '".$parametro[0]."')";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	if ($sth->numrows == 0)
	{
#		$sql_statement = "INSERT INTO $table (Username, Password, Nombre, Nivel, Grupo_ID) VALUES ('".$parametro[0]."', MD5('".$parametro[1]."'), '".$parametro[2]."', '".$parametro[3]."', ".$grupo_id.")";
		$sql_statement = "INSERT INTO $table (Username, Password, Nombre, Nivel, Grupo_ID) VALUES ('".$parametro[0]."', '".$parametro[1]."', '".$parametro[2]."', '".$parametro[3]."', ".$grupo_id.")";
	}
	else
	{
		if ($parametro[1] eq "")
		{
			$sql_statement = "UPDATE $table SET Nombre = '".$parametro[2]."', Nivel = '".$parametro[3]."', Grupo_ID = ".$grupo_id." WHERE (Username LIKE '".$parametro[0]."')";
		}
		else
		{
#			$sql_statement = "UPDATE $table SET Password =  MD5('".$parametro[1]."'), Nombre = '".$parametro[2]."', Nivel = '".$parametro[3]."', Grupo_ID = ".$grupo_id." WHERE (Username LIKE '".$parametro[0]."')";
			$sql_statement = "UPDATE $table SET Password =  '".$parametro[1]."', Nombre = '".$parametro[2]."', Nivel = '".$parametro[3]."', Grupo_ID = ".$grupo_id." WHERE (Username LIKE '".$parametro[0]."')";
		}
	}
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub baja_usuarios
{
	my $table = "usuarios";
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "DELETE FROM $table WHERE (Username LIKE '".$parametro[0]."')";
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar eliminar en la tabla radcheck.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub grupo_existente
{
	my $table = "grupos";

	local (@parametro) = @_;

	# Chequea en la Base de Datos
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT ID FROM $table WHERE Nombre like '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	if ($sth->numrows != 0)
	{
		return $sth->fetchrow;
	}

	return 0;
}


sub alta_grupos
{
	my $table = "grupos";
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT id FROM $table WHERE Nombre LIKE '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	if ($sth->numrows == 0)
	{
		$sql_statement = "INSERT INTO $table (Nombre, Dominio, Descripcion) VALUES ('".$parametro[0]."', '".$parametro[1]."', '".$parametro[2]."')";
	}
	else
	{
		$sql_statement = "UPDATE $table SET Dominio =  '".$parametro[1]."', Descripcion = '".$parametro[2]."' WHERE Nombre LIKE '".$parametro[0]."'";
	}
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub baja_grupos
{
	my $table = "grupos";
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "DELETE FROM $table WHERE Nombre LIKE '".$parametro[0]."'";
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar eliminar en la tabla radcheck.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub listar_grupos
{
	my $table = "grupos";
	my $contador = 0;
	my @grupos= ();
	my $arr= "";

	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT DISTINCT Nombre FROM $table ORDER BY Nombre";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar eliminar en la tabla $table.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	while ($arr = $sth->fetchrow)
	{
		$grupos[$contador] = $arr;
		$contador++;
	}
	return (@grupos);
}


sub obtener_grupo_usuario
{
	my $table = "usuarios";

	local (@parametro) = @_;

	# Chequea en la Base de Datos
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT Grupo_ID FROM $table WHERE Username like '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());

	if ($sth->numrows != 0)
	{
		return $sth->fetchrow;
	}

	return 0;
}


sub alta_agentes
{
	my $table = "agentes";
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT id FROM $table WHERE Nombre LIKE '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	if ($sth->numrows == 0)
	{
		$sql_statement = "INSERT INTO $table (Nombre, Direccion, Telefono, Localidad, Descripcion, Usuario_ID) VALUES ('".$parametro[0]."', '".$parametro[1]."', '".$parametro[2]."', '".$parametro[3]."', '".$parametro[4]."', ".$parametro[5].")";
	}
	else
	{
		$sql_statement = "UPDATE $table SET Direccion =  '".$parametro[1]."', Telefono = '".$parametro[2]."', Localidad = '".$parametro[3]."', Descripcion = '".$parametro[4]."' WHERE Nombre LIKE '".$parametro[0]."'";
	}
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub baja_agentes
{
	my $table = "agentes";
	my $username = "";
	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT Username FROM usuarios LEFT JOIN agentes ON (agentes.Usuario_ID = usuarios.ID) WHERE agentes.Nombre LIKE '".$parametro[0]."'";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	$username = $sth->fetchrow;

	&baja_usuarios($username);

	$sql_statement = "DELETE FROM $table WHERE Nombre LIKE '".$parametro[0]."'";
	$dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar eliminar en la tabla radcheck.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
}


sub listar_agentes
{
	my $contador = 0;
	my @agentes= ();
	my @arr= ();

	local (@parametro) = @_;
	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	$sql_statement = "SELECT agentes.Nombre FROM agentes LEFT JOIN usuarios ON (agentes.Usuario_ID = usuarios.ID) LEFT JOIN grupos ON (usuarios.Grupo_ID = grupos.ID)  WHERE usuarios.Nivel LIKE 'Tareas de Consulta' AND";
	if ($parametro[0] =~ /[^\d]/)
	{
		$sql_statement = $sql_statement." grupos.nombre LIKE '".$parametro[0]."'";
	}
	else
	{
		$sql_statement = $sql_statement." grupos.ID = ".$parametro[0];
	}
	$sql_statement = $sql_statement." ORDER BY agentes.Nombre";

	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Error al intentar obtener listado de agentes.<BR>Consulte al Administrador de la Base de Datos.", $dbh->errmsg());

	while (@arr = $sth->fetchrow)
	{
		$agentes[$contador] = $arr[0];
		$contador++;
	}
	return @agentes;
}


sub bajar_interface
{
	use SNMP_util;
	my $rwcommunity = "popularcito";
	my $response = "";
	my $contador = 0;
	my $bandera = "No";
	my $oid = "";
	my $port = "";

	local (@parametro) = @_;

	while ($bandera eq "No")
	{
		$contador++;
		$oid = "ifType.".$contador;
		($response) = snmpget("$rwcommunity\@$parametro[0]", $oid);
		if ($response)
		{
			if ($response eq "23")
			{
				$bandera = "Si"
			}
		}
		else
		{
			return 1;
		}
	}

	$port = $parametro[1] + $contador - 1;
	$oid = "ifAdminStatus.".$port;

	($response) = snmpset("$rwcommunity\@$parametro[0]", $oid, 'integer', 2);
	($response) = snmpset("$rwcommunity\@$parametro[0]", $oid, 'integer', 1);
	sleep(2);
	if ($response)
	{
		return 0;
	}
	return 1;
}


sub menu_listado
{
	my $contador = 5;
	my $arr = "";
	my $nivel = "";
	my @grupos = ();
	my $grupos = "";
	my @agentes = ();
	my $agentes = "";
	my @planes = ();
	my $planes = "";

	local (@parametro) = @_;

	my $wwwuser = $parametro[0];
	my $wwwpass = $parametro[1];
	my $grupo = $parametro[2];
	my $agente = $parametro[3];
	my $plan = $parametro[4];

	while ($contador < @parametro)
	{
		if (($parametro[$contador]) eq "on")
		{
			$parametro[$contador] = "checked";
		}
		$contador++;
	}
	my $activo = $parametro[5];
	my $inactivo = $parametro[6];
	my $facturar_excedente = $parametro[7];
	my $corte_de_servicio = $parametro[8];
	my $localidad = $parametro[9];
	my $mostrar_nro_cliente = $parametro[10];
	my $mostrar_sexo = $parametro[11];
	my $mostrar_documento = $parametro[12];
	my $mostrar_direccion = $parametro[13];
	my $mostrar_localidad = $parametro[14];
	my $mostrar_codpostal = $parametro[15];
	my $mostrar_telefono = $parametro[16];
	my $mostrar_tipoiva = $parametro[17];
	my $mostrar_cuit = $parametro[18];
	my $mostrar_fecha_pago = $parametro[19];
	my $mostrar_fecha_alta = $parametro[20];
	my $mostrar_cantidad_horas = $parametro[21];

	$nivel = &obtener_nivel($wwwuser);

	$dbh = Mysql->connect($host, $database, $dbuser, $dbpass);

	print <<body;
  <FORM ACTION="listado.html" METHOD="post">
   <INPUT TYPE="hidden" NAME="wwwuser" VALUE="$wwwuser">
   <INPUT TYPE="hidden" NAME="wwwpass" VALUE="$wwwpass">
   <INPUT TYPE="hidden" NAME="formato" VALUE="html">
   <TABLE COOL BORDER=1 CELLPADDING=0 CELLSPACING=0 ALIGN=center>
    <TR bgcolor="#ffebcd">
     <TD ALIGN="left" COLSPAN="2">
      <div ALIGN="center">
       &nbsp;
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <B>
         Seleccione los par&aacute;metro para generar el Listado:
        </B>
       </FONT>
      </div>
     </TD>
    </TR>
body

	if ($nivel eq "Acceso Total")
	{
		$grupos[0] = "Todos";
		$sql_statement = "SELECT Nombre FROM grupos ORDER BY nombre";
		$sth = $dbh->query($sql_statement)
		or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
		$contador = 1;
		while ($arr = $sth->fetchrow)
		{
			$grupos[$contador] = $arr;
			$contador++;
		}

		print <<body;
    <TR>
     <TD ALIGN="center" WIDTH="300" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       Grupo de Usuarios:
      </FONT>
     </TD>
     <TD ALIGN="left" WIDTH="400" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <SELECT NAME="grupo">
body
		foreach $grupos (@grupos)
		{
			print "         <OPTION";
			if ($grupos eq $grupo)
			{
				print " SELECTED";
			}
			print ">$grupos\n";
		}

		print <<body;
        </SELECT>
       </FONT>
      </b>
     </TD>
    </TR>
body
	}

	if ((&usuario_tiene_agente_asociado($wwwuser)) == 0)
	{
		print <<body;
    <TR>
     <TD ALIGN="center" WIDTH="300" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       Agente de Ventas:
      </FONT>
     </TD>
     </TD>
     <TD ALIGN="left" WIDTH="400" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <SELECT NAME="agente">
body

		$agentes[0] = "Todos";
		$sql_statement = "SELECT Nombre FROM agentes ORDER BY nombre";
		$sth = $dbh->query($sql_statement)
		or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
		$contador = 1;
		while ($arr = $sth->fetchrow)
		{
			$agentes[$contador] = $arr;
			$contador++;
		}

		foreach $agentes (@agentes)
		{
			print "         <OPTION";
			if ($agentes eq $agente)
			{
				print " SELECTED";
			}
			print ">$agentes\n";
		}

		print <<body;
        </SELECT>
       </FONT>
      </b>
     </TD>
    </TR>
body
	}

	print <<body;
    <TR>
     <TD ALIGN="center" WIDTH="300" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       Plan Contratado:
      </FONT>
     </TD>
     <TD ALIGN="left" WIDTH="400" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <SELECT NAME="plan">
body

	$planes[0] = "Todos";
	$sql_statement = "SELECT Nombre FROM planes ORDER BY nombre";
	$sth = $dbh->query($sql_statement)
	or die &return_error_mysql ("Error en el proceso", "Hubo un error en la consulta a la Base de Datos.<BR>Consulte al Administrador de la misma.", $dbh->errmsg());
	$contador = 1;
	while ($arr = $sth->fetchrow)
	{
		$planes[$contador] = $arr;
		$contador++;
	}

	foreach $planes (@planes)
	{
		print "         <OPTION";
		if ($planes eq $plan)
		{
			print " SELECTED";
		}
		print ">$planes\n";
	}

	print <<body;
        </SELECT>
       </FONT>
      </b>
     </TD>
    </TR>

    <TR>
     <TD ALIGN="center" WIDTH="300" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       Estado:
      </FONT>
     </TD>
     <TD ALIGN="left" WIDTH="400" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        Activo: &nbsp; <input type="checkbox" name="activo" $activo>
        &nbsp; &nbsp; &nbsp; &nbsp; 
        Inactivo: &nbsp; <input type="checkbox" name="inactivo" $inactivo>
       </FONT>
      </b>
     </TD>
    </TR>

    <TR>
     <TD ALIGN="center" WIDTH="300" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       Acci&oacute;n al excederse
       <BR>
       en el tiempo de consumo:
      </FONT>
     </TD>
     <TD ALIGN="left" WIDTH="400" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <input type="checkbox" name="facturar_excedente" $facturar_excedente> &nbsp; Facturar Excedente 
        <BR>
        <input type="checkbox" name="corte_de_servicio" $corte_de_servicio> &nbsp; Corte de Servicio
       </FONT>
      </b>
     </TD>
    </TR>

    <TR>
     <TD ALIGN="center" WIDTH="300" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       Localidad:
      </FONT>
     </TD>
     <TD ALIGN="left" WIDTH="400" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <input type="text" name="localidad" value="$localidad"size="30">
       </FONT>
      </b>
     </TD>
    </TR>

    <tr height="20">
     <td align="center" colspan="3" height="20">
      &nbsp;
     </td>
    </tr>

    <TR>
     <TD ALIGN="center" COLSPAN="3">
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="2">
       <INPUT TYPE="submit" VALUE="    Listar    ">
      </FONT>
     </TD>
    </TR>

    <tr height="20">
     <td align="center" colspan="3" height="20">
      &nbsp;
     </td>
    </tr>

    <TR>
     <TD ALIGN="center" WIDTH="300" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       Columnas que
       <BR>
       aparecer&aacute;n en
       <BR>
       el Listado:
      </FONT>
     </TD>
     <TD ALIGN="left" WIDTH="400" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <input type="checkbox" name="mostrar_nro_cliente" $mostrar_nro_cliente> &nbsp; Nro. de Cliente 
        <BR>
        <input type="checkbox" name="mostrar_sexo" $mostrar_sexo> &nbsp; Sexo 
        <BR>
        <input type="checkbox" name="mostrar_documento" $mostrar_documento> &nbsp; Documento
        <BR>
        <input type="checkbox" name="mostrar_direccion" $mostrar_direccion> &nbsp; Direcci&oacute;n
        <BR>
        <input type="checkbox" name="mostrar_localidad" $mostrar_localidad> &nbsp; Localidad
        <BR>
        <input type="checkbox" name="mostrar_codpostal" $mostrar_codpostal> &nbsp; C&oacute;digo Postal
        <BR>
        <input type="checkbox" name="mostrar_telefono" $mostrar_telefono> &nbsp; Tel&eacute;fono
        <BR>
        <input type="checkbox" name="mostrar_tipoiva" $mostrar_tipoiva> &nbsp; Tipo I.V.A.
        <BR>
        <input type="checkbox" name="mostrar_cuit" $mostrar_cuit> &nbsp; CUIT
        <BR>
        <input type="checkbox" name="mostrar_fecha_pago" $mostrar_fecha_pago> &nbsp; Ultima Fecha de Pago
        <BR>
        <input type="checkbox" name="mostrar_fecha_alta" $mostrar_fecha_alta> &nbsp; Fecha de Alta
        <BR>
        <input type="checkbox" name="mostrar_cantidad_horas" $mostrar_cantidad_horas> &nbsp; Cantidad de Horas
       </FONT>
      </b>
     </TD>
    </TR>

   </TABLE>
  </FORM>
  <BR>
body
}


sub menu_chequeo
{
	local (@parametro) = @_;

	my $wwwuser = $parametro[0];
	my $wwwpass = $parametro[1];
	my $usuario = $parametro[2];
	my $password = $parametro[3];

	print <<body;
  <FORM ACTION="chequeo-password.html" METHOD="post">
   <INPUT TYPE="hidden" NAME="wwwuser" VALUE="$wwwuser">
   <INPUT TYPE="hidden" NAME="wwwpass" VALUE="$wwwpass">
   <TABLE COOL BORDER=1 CELLPADDING=0 CELLSPACING=0 ALIGN=center>
    <TR bgcolor="#ffebcd">
     <TD ALIGN="left" COLSPAN="2">
      <div ALIGN="center">
       &nbsp;
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <B>
         Ingrese usuario y contrase&ntilde;a:
        </B>
       </FONT>
      </div>
     </TD>
    </TR>

    <TR>
     <TD ALIGN="center" WIDTH="300" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       Usuario:
      </FONT>
     </TD>
     <TD ALIGN="left" WIDTH="400" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <input type="text" name="usuario" value="$usuario" size="30">
       </FONT>
      </b>
     </TD>
    </TR>

    <TR>
     <TD ALIGN="center" WIDTH="300" nowrap>
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
       Contrase&ntilde;a:
      </FONT>
     </TD>
     <TD ALIGN="left" WIDTH="400" nowrap>
      <b>
       <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="3">
        <input type="text" name="password" value="$password" size="30">
       </FONT>
      </b>
     </TD>
    </TR>

    <tr height="20">
     <td align="center" colspan="3" height="20">
      &nbsp;
     </td>
    </tr>

    <TR>
     <TD ALIGN="center" COLSPAN="3">
      <font face="Arial, Helvetica, Geneva, Swiss, SunSans-Regular" size="2">
       <INPUT TYPE="submit" VALUE="    Chequear    ">
      </FONT>
     </TD>
    </TR>

   </TABLE>
  </FORM>
  <BR>
body
}


sub segundos2hora
{
	my @tiempo = ();
	my $resultado = "";
	local (@parametro) = @_;

	$tiempo[0] = $parametro[0] % 60;
	$parametro[0] = sprintf("%d",($parametro[0] / 60));
	$tiempo[1] = $parametro[0] % 60;
	$tiempo[2] = sprintf("%d",($parametro[0] / 60));

	$resultado = sprintf("%d",$tiempo[2]).":".sprintf("%02d",$tiempo[1]).":".sprintf("%02d",$tiempo[0]);
	return ($resultado);
}


END {};

1;
