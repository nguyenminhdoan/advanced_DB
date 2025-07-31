# Oracle Database Docker Setup

## Quick Start

1. Start the Oracle Database:
```bash
docker-compose up -d
```

2. Wait for the database to initialize (first run takes 5-10 minutes)

3. Check container status:
```bash
docker-compose ps
```

## Connection Details

- **Host**: localhost
- **Port**: 1521
- **Service Name**: XE
- **Username**: system
- **Password**: OraclePass123 (configurable in .env)
- **Web Console**: http://localhost:5500/em

## Connection Examples

### SQL*Plus
```bash
docker exec -it oracle-xe-db sqlplus system/OraclePass123@XE
```

### JDBC URL
```
jdbc:oracle:thin:@localhost:1521:XE
```

### TNS Format
```
(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XE)))
```

## Commands

- Start: `docker-compose up -d`
- Stop: `docker-compose down`
- View logs: `docker-compose logs oracle-db`
- Remove volumes: `docker-compose down -v`

## Creating Development Users

```sql
-- Connect as system user first
CREATE USER dev IDENTIFIED BY devpass;
GRANT CONNECT, RESOURCE, DBA TO dev;
GRANT UNLIMITED TABLESPACE TO dev;
```