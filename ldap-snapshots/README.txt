LDAP Snapshot – DCM4CHEE PACS
=============================

Overview
--------
This directory contains a complete LDAP snapshot (`ldap-snapshot.ldif`) of the
DCM4CHEE Archive configuration as it existed immediately after a full system
recovery in March 2026.

The snapshot represents a *known-good, canonical state* of the PACS LDAP tree.
It includes:

- The Archive device (dcm4chee-arc)
- All AE Titles
- All DICOM and HL7 network connections
- All TLS listeners
- All storage configuration
- All UI configuration
- All Keycloak/OIDC integration entries
- All system-level DICOM configuration objects

Why this snapshot exists
------------------------
The production PACS experienced a catastrophic loss of LDAP state. The Archive
device and its associated configuration were missing, and the container image
in use did not contain the bootstrap LDIFs required to rebuild it.

A temporary, isolated PACS stack was created solely to regenerate a clean LDAP
tree. That regenerated LDAP was exported and imported into the production
system, restoring the Archive device and returning the PACS to a functional
state.

This snapshot is the preserved output of that recovery process.

How to restore this snapshot
----------------------------
If LDAP becomes corrupted, empty, or misconfigured in the future, the entire
configuration can be restored using this file.

1. Stop the Archive container:

       docker stop arc

2. Import the snapshot into LDAP:

       ldapadd -x -H ldap://localhost:389 \
         -D "cn=admin,dc=dcm4che,dc=org" -W \
         -f ldap-snapshot.ldif

3. Restart the Archive container:

       docker start arc

After restart, WildFly will redeploy the Archive EAR and UI WAR using the
restored LDAP configuration.

Security note
-------------
This LDIF contains sensitive configuration, including passwords and internal
service credentials. Do not expose this file publicly. Keep it within the
private Git repository.

Versioning
----------
Any time significant PACS configuration changes are made (AE titles, storage
rules, network listeners, etc.), generate a new snapshot:

       docker exec -it ldap slapcat > ldap-snapshot.ldif

Commit the updated snapshot to Git with a clear message describing the change.

