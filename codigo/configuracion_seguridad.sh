#!/usr/bin/env bash
# ---------------------------------------------------------------------
# TPI AySO - Seguridad en Sistemas Operativos
# Autor : Mangini Valentino
# Prueba: Ubuntu Server 24.04 LTS dentro de una maquina virtual
# Uso   : sudo bash configuracion_seguridad.sh
# Crea usuarios, directorio protegido, regla de sudo, reglas de
# auditoria (auditd) y firewall (ufw).
# ---------------------------------------------------------------------
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Ejecutar con sudo: sudo bash $0"
  exit 1
fi

echo "[1/6] Instalando paquetes..."
apt-get update -y
apt-get install -y auditd ufw openssh-server
systemctl enable --now auditd

echo "[2/6] Creando usuarios y grupo..."
getent group finanzas >/dev/null || groupadd finanzas
id analista &>/dev/null || useradd -m -s /bin/bash analista
id invitado &>/dev/null || useradd -m -s /bin/bash invitado
usermod -aG finanzas analista

echo "[3/6] Creando directorio protegido /seguro..."
mkdir -p /seguro
echo "informacion confidencial del area de Finanzas" > /seguro/datos.txt
chown root:finanzas /seguro /seguro/datos.txt
chmod 755 /seguro
chmod 660 /seguro/datos.txt

echo "[4/6] Delegando privilegios minimos con sudo..."
echo 'analista ALL=(root) /usr/bin/systemctl status ssh' \
  > /etc/sudoers.d/analista
chmod 440 /etc/sudoers.d/analista
visudo -cf /etc/sudoers.d/analista

echo "[5/6] Configurando reglas de auditoria permanentes..."
cat > /etc/audit/rules.d/tpi.rules <<'RULES'
-w /seguro/datos.txt -p rwxa -k acceso_datos
-w /etc/sudoers -p wa -k cambios_sudo
-w /etc/sudoers.d/ -p wa -k cambios_sudo
-a always,exit -F arch=b64 -S openat -F exit=-EACCES -k acceso_denegado
RULES
augenrules --load

echo "[6/6] Configurando firewall (ufw)..."
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH      # primero SSH, para no quedar afuera
ufw --force enable

echo
echo "Listo. Falta asignar contrasenas a los usuarios de prueba:"
echo "  sudo passwd analista"
echo "  sudo passwd invitado"
