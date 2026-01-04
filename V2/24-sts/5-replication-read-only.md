
---

# PHASE-2: MySQL Replication and ReadOnly 

> Assumptions

* StatefulSet name: `mysql`
* Primary: `mysql-0`
* Replicas: `mysql-1`, `mysql-2`
* Root password: `rootpass`
* Replication user: `repl / replpass`
* Database: `appdb`

---

## STEP 0: Preconditions (already done by you)

✔️ `log-bin` enabled
✔️ Unique `server-id` per pod
✔️ Pods stable
✔️ StorageClass + PVC working

---

## STEP 1: Create Replication User (PRIMARY ONLY)

```bash
kubectl exec -it mysql-0 -- mysql -uroot -prootpass
```

```sql
CREATE USER IF NOT EXISTS 'repl'@'%'
IDENTIFIED WITH mysql_native_password BY 'replpass';

GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

FLUSH PRIVILEGES;
EXIT;
```

---

## STEP 2: Take Initial Dump from PRIMARY (ONE TIME)

> Run from **your local machine**

```bash
kubectl exec mysql-0 -- sh -c \
"mysqldump -uroot -prootpass --single-transaction --databases appdb" \
> appdb.sql
```

---

## STEP 3: Restore Dump on REPLICAS

### mysql-1

```bash
kubectl exec -i mysql-1 -- mysql -uroot -prootpass < appdb.sql
```

### mysql-2

```bash
kubectl exec -i mysql-2 -- mysql -uroot -prootpass < appdb.sql
```

---

## STEP 4: Get CURRENT Binlog Position (PRIMARY)

```bash
kubectl exec mysql-0 -- mysql -uroot -prootpass -e "SHOW MASTER STATUS;"
```

Example output:

```
File: mysql-bin.000002
Position: 154
```

⚠️ **Note these values exactly**
(never reuse old ones)

---

## STEP 5: Configure Replication on mysql-1

```bash
kubectl exec -it mysql-1 -- mysql -uroot -prootpass
```

```sql
STOP SLAVE;
RESET SLAVE ALL;

CHANGE MASTER TO
  MASTER_HOST='mysql-0.mysql',
  MASTER_USER='repl',
  MASTER_PASSWORD='replpass',
  MASTER_LOG_FILE='mysql-bin.000002',
  MASTER_LOG_POS=154;

START SLAVE;

SHOW SLAVE STATUS\G
EXIT;
```

✅ Expect:

```
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
```

---

## STEP 6: Configure Replication on mysql-2

```bash
kubectl exec -it mysql-2 -- mysql -uroot -prootpass
```

```sql
STOP SLAVE;
RESET SLAVE ALL;

CHANGE MASTER TO
  MASTER_HOST='mysql-0.mysql',
  MASTER_USER='repl',
  MASTER_PASSWORD='replpass',
  MASTER_LOG_FILE='mysql-bin.000002',
  MASTER_LOG_POS=154;

START SLAVE;

SHOW SLAVE STATUS\G
EXIT;
```

---

## STEP 7: Verification Test (PRIMARY → REPLICA)

### On PRIMARY

```bash
kubectl exec -it mysql-0 -- mysql -uroot -prootpass
```

```sql
USE appdb;

CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100)
);

INSERT INTO users (name) VALUES ('replication is finally stable');
EXIT;
```

---

### On REPLICAS

```bash
kubectl exec mysql-1 -- mysql -uroot -prootpass -e "USE appdb; SELECT * FROM users;"
kubectl exec mysql-2 -- mysql -uroot -prootpass -e "USE appdb; SELECT * FROM users;"
```

✅ Data appears → **Replication SUCCESS**

---

# (NEXT – PHASE-2.5, STRONGLY RECOMMENDED)

## Make Replicas Read-Only (Prevent Future Errors)

### mysql-1

```bash
kubectl exec mysql-1 -- mysql -uroot -prootpass -e \
"SET GLOBAL read_only=ON; SET GLOBAL super_read_only=ON;"
```

### mysql-2

```bash
kubectl exec mysql-2 -- mysql -uroot -prootpass -e \
"SET GLOBAL read_only=ON; SET GLOBAL super_read_only=ON;"
```

### Verify

```bash
kubectl exec mysql-1 -- mysql -uroot -prootpass -e "SHOW VARIABLES LIKE 'read_only';"
kubectl exec mysql-2 -- mysql -uroot -prootpass -e "SHOW VARIABLES LIKE 'super_read_only';"
```

---


```

You now have a **production-grade MySQL StatefulSet with replication**.

---
