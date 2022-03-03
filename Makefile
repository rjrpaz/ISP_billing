MYSQLUSER=root
MYSQLPASSWORD=4c0r4z4d0

PERL=/usr/bin/perl -wc

# Ubicacion de las paginas de Tickets
HTMLDIR=/usr/local/apache-root/radadm
SCRIPTDIR=/usr/local/apache-root/radadm
# perl -e 'print "@INC \n";'
PMDIR=/usr/local/lib/site_perl/i386-linux
WWWUSER=root
WWWGROUP=root

all: crypt
	/usr/bin/clear
	@echo
	$(PERL) freeradius.pm
	@echo
	$(PERL) index.html
	@echo
	$(PERL) menu.html
	@echo
	$(PERL) abm.html
	@echo
	$(PERL) alta.html
	@echo
	$(PERL) alta-confirmacion.html
	@echo
	$(PERL) alta-final.html
	@echo
	$(PERL) modificacion.html
	@echo
	$(PERL) modificacion-realizacion.html
	@echo
	$(PERL) modificacion-realizacion2.html
	@echo
	$(PERL) modificacion-final.html
	@echo
	$(PERL) cambiocontrasena.html
	@echo
	$(PERL) cambiocontrasena-realizacion.html
	@echo
	$(PERL) cambiocontrasena-final.html
	@echo
	$(PERL) baja.html
	@echo
	$(PERL) baja-confirmacion.html
	@echo
	$(PERL) baja-final.html
	@echo
	$(PERL) chequeo-password.html
	@echo
	$(PERL) conectados.html
	@echo
	$(PERL) maildir.html
	@echo
	$(PERL) maildir-consulta.html
	@echo
	$(PERL) listado.html
	@echo
	$(PERL) mailgrupo.html
	@echo
	$(PERL) individuales.html
	@echo
	$(PERL) totales.html
	@echo
	$(PERL) abm-planes.html
	@echo
	$(PERL) alta-plan.html
	@echo
	$(PERL) alta-plan-final.html
	@echo
	$(PERL) modificacion-plan.html
	@echo
	$(PERL) modificacion-plan-realizacion.html
	@echo
	$(PERL) modificacion-plan-final.html
	@echo
	$(PERL) baja-plan.html
	@echo
	$(PERL) baja-plan-confirmacion.html
	@echo
	$(PERL) baja-plan-final.html
	@echo
	$(PERL) abm-adm.html
	@echo
	$(PERL) alta-adm.html
	@echo
	$(PERL) alta-adm-final.html
	@echo
	$(PERL) modificacion-adm.html
	@echo
	$(PERL) modificacion-adm-realizacion.html
	@echo
	$(PERL) modificacion-adm-final.html
	@echo
	$(PERL) baja-adm.html
	@echo
	$(PERL) baja-adm-confirmacion.html
	@echo
	$(PERL) baja-adm-final.html
	@echo
	$(PERL) abm-grupos.html
	@echo
	$(PERL) alta-grupos.html
	@echo
	$(PERL) alta-grupos-final.html
	@echo
	$(PERL) modificacion-grupos.html
	@echo
	$(PERL) modificacion-grupos-realizacion.html
	@echo
	$(PERL) modificacion-grupos-final.html
	@echo
	$(PERL) baja-grupos.html
	@echo
	$(PERL) baja-grupos-confirmacion.html
	@echo
	$(PERL) baja-grupos-final.html
	@echo
	$(PERL) abm-agentes.html
	@echo
	$(PERL) alta-agentes.html
	@echo
	$(PERL) alta-agentes-final.html
	@echo
	$(PERL) modificacion-agentes.html
	@echo
	$(PERL) modificacion-agentes-realizacion.html
	@echo
	$(PERL) modificacion-agentes-final.html
	@echo
	$(PERL) baja-agentes.html
	@echo
	$(PERL) baja-agentes-confirmacion.html
	@echo
	$(PERL) baja-agentes-final.html
	@echo
	$(PERL) ingresar_pagos.pl
	@echo
	$(PERL) inhibe_morosos.pl
	@echo
	$(PERL) inhibe_excedidos.pl
	@echo
	$(PERL) blanquea_excedidos.pl
	@echo
	$(PERL) checkpassword
	@echo

crypt: crypt.c
	cc -o crypt crypt.c -lcrypt

install:
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) freeradius.pm $(PMDIR)/freeradius.pm
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) index.html $(SCRIPTDIR)/index.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) menu.html $(SCRIPTDIR)/menu.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) abm.html $(SCRIPTDIR)/abm.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta.html $(SCRIPTDIR)/alta.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta-confirmacion.html $(SCRIPTDIR)/alta-confirmacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta-final.html $(SCRIPTDIR)/alta-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion.html $(SCRIPTDIR)/modificacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-realizacion.html $(SCRIPTDIR)/modificacion-realizacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-realizacion2.html $(SCRIPTDIR)/modificacion-realizacion2.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-final.html $(SCRIPTDIR)/modificacion-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) cambiocontrasena.html $(SCRIPTDIR)/cambiocontrasena.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) cambiocontrasena-realizacion.html $(SCRIPTDIR)/cambiocontrasena-realizacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) cambiocontrasena-final.html $(SCRIPTDIR)/cambiocontrasena-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja.html $(SCRIPTDIR)/baja.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-confirmacion.html $(SCRIPTDIR)/baja-confirmacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-final.html $(SCRIPTDIR)/baja-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) chequeo-password.html $(SCRIPTDIR)/chequeo-password.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) conectados.html $(SCRIPTDIR)/conectados.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) maildir.html $(SCRIPTDIR)/maildir.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) maildir-consulta.html $(SCRIPTDIR)/maildir-consulta.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) abm-planes.html $(SCRIPTDIR)/abm-planes.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta-plan.html $(SCRIPTDIR)/alta-plan.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta-plan-final.html $(SCRIPTDIR)/alta-plan-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-plan.html $(SCRIPTDIR)/modificacion-plan.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-plan-realizacion.html $(SCRIPTDIR)/modificacion-plan-realizacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-plan-final.html $(SCRIPTDIR)/modificacion-plan-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-plan.html $(SCRIPTDIR)/baja-plan.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-plan-confirmacion.html $(SCRIPTDIR)/baja-plan-confirmacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-plan-final.html $(SCRIPTDIR)/baja-plan-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) individuales.html $(SCRIPTDIR)/individuales.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) listado.html $(SCRIPTDIR)/listado.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) mailgrupo.html $(SCRIPTDIR)/mailgrupo.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) totales.html $(SCRIPTDIR)/totales.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) abm-adm.html $(SCRIPTDIR)/abm-adm.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta-adm.html $(SCRIPTDIR)/alta-adm.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta-adm-final.html $(SCRIPTDIR)/alta-adm-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-adm.html $(SCRIPTDIR)/modificacion-adm.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-adm-realizacion.html $(SCRIPTDIR)/modificacion-adm-realizacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-adm-final.html $(SCRIPTDIR)/modificacion-adm-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-adm.html $(SCRIPTDIR)/baja-adm.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-adm-confirmacion.html $(SCRIPTDIR)/baja-adm-confirmacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-adm-final.html $(SCRIPTDIR)/baja-adm-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) abm-grupos.html $(SCRIPTDIR)/abm-grupos.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta-grupos.html $(SCRIPTDIR)/alta-grupos.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta-grupos-final.html $(SCRIPTDIR)/alta-grupos-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-grupos.html $(SCRIPTDIR)/modificacion-grupos.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-grupos-realizacion.html $(SCRIPTDIR)/modificacion-grupos-realizacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-grupos-final.html $(SCRIPTDIR)/modificacion-grupos-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-grupos.html $(SCRIPTDIR)/baja-grupos.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-grupos-confirmacion.html $(SCRIPTDIR)/baja-grupos-confirmacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-grupos-final.html $(SCRIPTDIR)/baja-grupos-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) abm-agentes.html $(SCRIPTDIR)/abm-agentes.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta-agentes.html $(SCRIPTDIR)/alta-agentes.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) alta-agentes-final.html $(SCRIPTDIR)/alta-agentes-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-agentes.html $(SCRIPTDIR)/modificacion-agentes.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-agentes-realizacion.html $(SCRIPTDIR)/modificacion-agentes-realizacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) modificacion-agentes-final.html $(SCRIPTDIR)/modificacion-agentes-final.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-agentes.html $(SCRIPTDIR)/baja-agentes.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-agentes-confirmacion.html $(SCRIPTDIR)/baja-agentes-confirmacion.html
	install -m 700 -D -o $(WWWUSER) -g $(WWWGROUP) baja-agentes-final.html $(SCRIPTDIR)/baja-agentes-final.html
	install -m 700 -D -o root -g root ingresar_pagos.pl /usr/sbin/ingresar_pagos
	install -m 700 -D -o root -g root inhibe_morosos.pl /usr/sbin/inhibe_morosos
	install -m 700 -D -o root -g root inhibe_excedidos.pl /usr/sbin/inhibe_excedidos
	install -m 700 -D -o root -g root blanquea_excedidos.pl /usr/sbin/blanquea_excedidos
	install -m 700 -D -o root -g root checkpassword /bin/checkpassword
	install -m 700 -D -o root -g root crypt /bin/crypt

