# HA PostgreSQL Cloud SQL

![Basic HA PG CloudSQL config](https://cloud.google.com/sql/images/ha-config.png)

[Docs](https://cloud.google.com/sql/docs/postgres)

Selected Docs:

- [About high availability](https://cloud.google.com/sql/docs/postgres/high-availability#normal)
- [General best practices](https://cloud.google.com/sql/docs/postgres/best-practices)
- [Cloud SQL permissions](https://cloud.google.com/sql/docs/postgres/iam-permissions)
- [Cloud SQL roles](https://cloud.google.com/sql/docs/postgres/iam-roles)
- [Learn about using private ip](https://cloud.google.com/sql/docs/postgres/private-ip)
  You can connect to private IP addresses across regions. You can also connect using a
  Shared VPC between projects.
- [Private service access](https://cloud.google.com/vpc/docs/private-services-access)
- [Private IPs for Cloud SQL](https://cloud.google.com/sql/docs/postgres/configure-private-ip)

During development, I usually allow full admin roles from clients.
In production, admin functionality will require dedicated resources.
See [Connecting...](https://cloud.google.com/sql/docs/postgres/connect-admin-ip).

![Private services access](https://cloud.google.com/sql/images/private-ip.svg)

Misc:

- [Enabling private service access](https://cloud.google.com/service-infrastructure/docs/enabling-private-services-access)
- [Configuring private service access](https://cloud.google.com/vpc/docs/configure-private-services-access)
- [Configuring private service access for cloudsql](https://cloud.google.com/sql/docs/postgres/configure-private-services-access)
- [Configure VPC Service Controls](https://cloud.google.com/sql/docs/postgres/admin-api/configure-service-controls)
- [Service Networking API](https://cloud.google.com/service-infrastructure/docs/service-networking/getting-started?hl=en_US&_ga=2.101279554.2105424830.1645090729-1280259004.1644967936)
  enables you to offer your managed services on internal IP addresses to service consumers

