use radius;
alter table personaldata add column Exceso_Horas enum ('Facturar Excedente', 'Corte de Servicio') DEFAULT 'Facturar Excedente' NOT NULL after Estado;
alter table personaldata add column Ultimo_Mes_Pago date DEFAULT '0000-00-00' NOT NULL after Exceso_Horas;
