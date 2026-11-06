#!/usr/bin/env bash
# ---------------------------------------------------------------------
# TPI AySO - Seguridad en Sistemas Operativos
# Autor : Mangini Valentino
# Uso   : sudo bash pruebas_seguridad.sh
# Ejecuta las pruebas de permisos, sudo, auditoria y firewall para
# poder sacar las capturas del informe.
# ---------------------------------------------------------------------

titulo() { echo; echo "=================== $1 ==================="; }

titulo "PRUEBA 1: permisos de archivos"
ls -ld /seguro /seguro/datos.txt
id analista
id invitado
echo "--- analista (grupo finanzas) lee el archivo:"
sudo -u analista cat /seguro/datos.txt
echo "--- invitado (otros) intenta leerlo:"
sudo -u invitado cat /seguro/datos.txt \
  || echo ">> Acceso denegado, como se esperaba"

titulo "PRUEBA 2: privilegios delegados con sudo"
sudo -l -U analista

titulo "PRUEBA 3: auditoria con auditd"
auditctl -l
echo "--- eventos de la clave acceso_datos:"
ausearch -k acceso_datos -i | tail -n 25
echo "--- intentos denegados (EACCES):"
ausearch -k acceso_denegado -i | tail -n 25
echo "--- resumen de archivos con accesos fallidos:"
aureport -f -i --failed

titulo "PRUEBA 4: firewall"
ufw status verbose
echo "--- puertos en escucha:"
ss -tulpn
