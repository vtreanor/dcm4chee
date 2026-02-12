S3‑Backed PACS Architecture (Mermaid)
====================================

.. code-block:: mermaid

   flowchart TB

       %% STYLE DEFINITIONS
       classDef svc fill:#1f77b4,stroke:#0d3a5a,stroke-width:1px,color:#fff;
       classDef db fill:#2ca02c,stroke:#145214,stroke-width:1px,color:#fff;
       classDef proxy fill:#ff7f0e,stroke:#8a4600,stroke-width:1px,color:#fff;
       classDef auth fill:#9467bd,stroke:#4b2a6a,stroke-width:1px,color:#fff;
       classDef storage fill:#8c564b,stroke:#4a2d1f,stroke-width:1px,color:#fff;
       classDef cloud fill:#1f9d55,stroke:#0f4d2c,stroke-width:1px,color:#fff;

       %% NODES
       TRAEFIK[Traefik v3<br/>Reverse Proxy]:::proxy

       KEYCLOAK[Keycloak 26<br/>auth.osirl.com]:::auth
       ARC[DCM4CHEE-ARC<br/>pacs-ui.osirl.com]:::svc
       LDAP[OpenLDAP<br/>slapd-dcm4chee]:::svc

       POSTGRES[(PostgreSQL<br/>pacsdb)]:::db
       STORAGE[(Local PACS Storage<br/>Filesystem)]:::storage
       S3[(Amazon S3<br/>DICOM Object Store)]:::cloud
       LDAPSTORE[(LDAP Storage)]:::storage

       %% CONNECTIONS
       TRAEFIK --> |HTTP 80| KEYCLOAK
       TRAEFIK --> |HTTP 80<br/>PathPrefix /dcm4chee-arc| ARC
       TRAEFIK --> |TCP 389/636| LDAP

       ARC --> POSTGRES
       ARC --> STORAGE
       ARC --> |WADO / C-STORE| S3

       KEYCLOAK --> POSTGRES

       LDAP --> LDAPSTORE
