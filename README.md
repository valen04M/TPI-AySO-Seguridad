# Seguridad en Sistemas Operativos

**Trabajo Integrador – Arquitectura y Sistemas Operativos**
Tecnicatura Universitaria en Programación a Distancia (UTN)

| | |
|---|---|
| **Alumno** | Mangini, Valentino |
| **Materia** | Arquitectura y Sistemas Operativos |
| **Fecha de entrega** | 05/11/2026 |
| **Video explicativo** | [Ver en YouTube](https://youtu.be/PqYp4paliSM) |

## Descripción

Práctica de seguridad sobre **Linux (Ubuntu Server 24.04 LTS)** ejecutada en una máquina virtual (VirtualBox). Se simula un servidor que guarda información de Finanzas en `/seguro` y se prueban tres líneas de defensa complementarias:

1. **Control de acceso:** usuarios, grupos y permisos (`chown`, `chmod`) y delegación de privilegios mínimos con `sudo`.
2. **Auditoría:** registro de intentos de acceso no autorizado con `auditd` (`auditctl`, `ausearch`, `aureport`).
3. **Firewall:** política "denegar por defecto" con `ufw`, permitiendo solo lo necesario.

El informe completo (marco teórico, caso práctico, metodología, resultados y conclusiones) está en el PDF.

## Estructura del repositorio

```
.
├── TPI_AySO_Seguridad_final.pdf      # Informe completo
├── README.md
├── codigo/
│   ├── configuracion_seguridad.sh    # Crea usuarios, permisos, sudo, auditd y ufw
│   └── pruebas_seguridad.sh          # Ejecuta las pruebas para sacar las capturas
└── recursos/
    └── capturas/                     # Capturas de pantalla originales (figura1 a figura6)
```

## Requisitos

- Una **máquina virtual** con Ubuntu Server 24.04 LTS (2 GB de RAM, 2 CPU, 20 GB de disco).
- Red en modo **adaptador puente (Bridged)** si se quiere probar el firewall desde la PC anfitriona.
- Acceso a `sudo`.

> **Importante:** `auditd` necesita un kernel propio. No funciona en contenedores, en terminales en la nube que comparten kernel (como Google Cloud Shell) ni en WSL.

## Cómo ejecutarlo

> ⚠️ Los scripts modifican el sistema (crean usuarios, cambian permisos y activan el firewall). Ejecutarlos **solo dentro de la máquina virtual de pruebas**, de preferencia con un snapshot inicial.

```bash
# 1. Configurar usuarios, directorio protegido, sudo, auditd y ufw
sudo bash codigo/configuracion_seguridad.sh

# 2. Asignar contraseña a los usuarios de prueba
sudo passwd analista
sudo passwd invitado

# 3. Ejecutar las pruebas
sudo bash codigo/pruebas_seguridad.sh
```

El script de configuración permite SSH antes de activar el firewall para no perder el acceso a la máquina.

## Resultados

| Prueba | Resultado |
|---|---|
| Lectura de `analista` (grupo `finanzas`) | Permitida |
| Lectura de `invitado` (otros) | Denegada (`Permission denied`) |
| `sudo` fuera de la regla delegada | Rechazado |
| Intento no autorizado en `auditd` | Registrado con la clave `acceso_datos` (`exit=EACCES`) |
| Puerto 8080 sin regla en `ufw` | Bloqueado (timeout) |
| Puerto 8080 con regla en `ufw` | Accesible |

## Herramientas utilizadas

Oracle VirtualBox · Ubuntu Server 24.04 LTS · `auditd` · `ufw` · `openssh-server` · `sudo` · `chmod` / `chown`

## Autor

**Valentino Mangini** – Tecnicatura Universitaria en Programación a Distancia, UTN.
