dcm4chee — PACS Deployment (Traefik + Keycloak + LDAP + Postgres)
=================================================================

This repository contains a fully working, production‑ready deployment of
**DCM4CHEE Archive 5.34.x** using:

- Traefik v3 as the reverse proxy
- Keycloak 26 for authentication (OIDC)
- PostgreSQL as the PACS database
- OpenLDAP (slapd-dcm4chee) for directory services
- WildFly-based dcm4chee-arc with UI2
- Optional MariaDB for Keycloak (unused in this configuration)

This stack has been validated end‑to‑end, including:

- PACS UI2 loading correctly
- OIDC login via Keycloak
- Correct redirect URIs
- Traefik routing with preserved path prefixes
- DICOM C‑STORE SCP operational
- Stable database and storage volumes

It represents a **known-good, reproducible baseline** for future development.

---

Architecture Overview
---------------------

::

                        ┌──────────────────────────┐
                        │        Traefik v3        │
                        │(HTTP + TCP reverse proxy)│
                        └─────────────┬────────────┘
                                      │
             ┌────────────────────────┼────────────────────────┐
             │                        │                        │
             ▼                        ▼                        ▼
     ┌────────────────┐     ┌────────────────────┐     ┌──────────────────┐
     │  Keycloak 26   │     │   dcm4chee-arc     │     │      LDAP        │
     │ auth.osirl.com │     │ pacs-ui.osirl.com  │     │  slapd-dcm4chee  │
     └────────────────┘     └────────────────────┘     └──────────────────┘
             │                        │                        │
             ▼                        ▼                        ▼
     ┌────────────────┐     ┌────────────────────┐     ┌──────────────────┐
     │   Postgres     │     │   Storage (FS)     │     │   LDAP storage   │
     └────────────────┘     └────────────────────┘     └──────────────────┘

---

Domains Used
------------

=================  ================================================
Service            Domain
=================  ================================================
PACS UI2           http://pacs-ui.osirl.com/dcm4chee-arc/ui2/
Keycloak           http://auth.osirl.com
Traefik Dashboard  http://<host>:8080/dashboard/
=================  ================================================

---

Prerequisites
-------------

- Docker 24+
- Docker Compose v2
- DNS entries for:

  - ``auth.osirl.com`` → host IP
  - ``pacs-ui.osirl.com`` → host IP

- Open ports: 80, 389, 636, 11112, 2762, 2575, 12575

---

Running the Stack
-----------------

Start everything::

    docker compose up -d

Check logs::

    docker compose logs -f

Stop::

    docker compose down

---

Keycloak Setup
--------------

This deployment uses:

- Realm: ``dcm4che``
- Client: ``dcm4chee-arc-ui``

Required Redirect URIs::

    http://pacs-ui.osirl.com/dcm4chee-arc/ui2/
    http://pacs-ui.osirl.com/dcm4chee-arc/ui2/*
    http://pacs-ui.osirl.com/dcm4chee-arc/ui2

Web Origins::

    http://pacs-ui.osirl.com

These settings are required for UI2 to authenticate correctly.

---

Traefik Routing
---------------

Traefik routes based on hostname + path prefix::

    traefik.http.routers.arc.rule=Host(`pacs-ui.osirl.com`) && PathPrefix(`/dcm4chee-arc`)

This ensures WildFly receives the **exact** servlet path::

    /dcm4chee-arc/ui2

No prefix stripping or rewriting is used.

---

Volumes
-------

Persistent data is stored under::

    /var/local/dcm4chee-arc/

Subdirectories:

- ``wildfly/`` — WildFly standalone configuration
- ``storage/`` — PACS image storage
- ``db/`` — PostgreSQL data
- ``ldap/`` — LDAP data
- ``slapd.d/`` — LDAP config

---

DICOM Services
--------------

======  ==========================
Port    Service
======  ==========================
11112   DICOM C‑STORE SCP
2762    HL7
2575    DICOM TLS
12575   DICOM WebSocket
======  ==========================

---

Troubleshooting
---------------

UI2 shows “Invalid parameter: redirect_uri”
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Check Keycloak client settings — ensure redirect URIs match exactly.

UI2 shows 401 Unauthorized
~~~~~~~~~~~~~~~~~~~~~~~~~~

Traefik may be rewriting or stripping the path.  
Ensure::

    PathPrefix(`/dcm4chee-arc`)

is preserved.

Keycloak 502 on startup
~~~~~~~~~~~~~~~~~~~~~~~

Traefik healthcheck may be too fast.  
Increase::

    healthcheck.interval
    healthcheck.timeout

---

Branching Strategy
------------------

- ``main`` — stable, working PACS deployment
- ``compose-pre-redirect-fix`` — development branch used to reach stability

``main`` now reflects the validated, production‑ready state.

---

License
-------

This repository contains configuration for open‑source components.  
Refer to each component’s upstream license for details.
