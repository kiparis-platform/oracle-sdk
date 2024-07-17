# KIPARIS SDK for Oracle Database

KIPARIS SDK for Oracle Database is a set of objects that make it easy and intuitive to interact with the Oracle Database using the KIPARIS platform.

## Installation

1. Run the following command to install the SDK:

```bash
SQL > @install_sdk.sql
```

2. Run the following command to the create ACL:

```bash
SQL > @create_acl.sql
```

> **Note:** The ACL is required to allow the Oracle Database to interact with the KIPARIS platform. Prepare the `create_acl.sql` file with the correct IP address, port number and your database schema.
>

## Uninstallation

1. Run the following command to uninstall the SDK:

```bash
SQL > @uninstall_sdk.sql
```

2. Run the following command to the drop ACL:

```bash
SQL > @drop_acl.sql
```

> **Note:** Prepare the `drop_acl.sql` file with the correct IP address, port number and your database schema.