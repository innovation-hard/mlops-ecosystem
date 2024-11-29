# Instalación de env conda
```bash
conda create -n mlops-env python=3.12
conda activate mlops-env
pip install mlflow
conda install -c conda-forge psycopg2
```
### *yo trato de utilizar entorno mlops-ecosystem que contiene todo*

# Definición de variables de entorno
Desde carpeta del repo

```bash
# Seteo de variables
export REPO_FOLDER=$(pwd)
set -o allexport && source .env && set +o allexport

# Verificarlo
echo $postgres_data_folder
```

# PSQL DB

### Bajar imagen
```bash
docker pull postgres
```

### Correr imagen
```bash
docker run -d \
    --name mlops-postgres \
    -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v $postgres_data_folder:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres
```

### Verificar funcionamiento, y manejo del contenedor
```bash
docker ps

docker ps -a

docker exec -it mlops-postgres /bin/bash

root@08487b094f8a$  psql -U postgres

postgres   exit

root@08487b094f8a$  exit
```

Si tiene instalado psql:
```bash
export PGPASSWORD=$POSTGRES_PASSWORD 
psql -U postgres -h localhost -p 5432

# Yo debo hacer:
docker exec -it mlops-postgres psql -U postgres -d nombre_base_de_datos -h localhost

```

### Create MLFLOW DB

```sql
CREATE DATABASE mlflow_db;
CREATE USER mlflow_user WITH ENCRYPTED PASSWORD 'mlflow_psw';
GRANT ALL PRIVILEGES ON DATABASE mlflow_db TO mlflow_user;
```


# Mlflow server


```bash
# desde la carpeta del proyecto

mlflow server --backend-store-uri postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$MLFLOW_POSTGRES_DB --default-artifact-root $MLFLOW_ARTIFACTS_PATH --host 0.0.0.0 --port 8002
```
Abrir browser en http://localhost:8002/

# Airbyte

### Tutorial
https://docs.airbyte.com/using-airbyte/getting-started/oss-quickstart

### Esto quedo obsoleto?
```bash
# clone Airbyte from GitHub
git clone --depth=1 https://github.com/airbytehq/airbyte.git

# switch into Airbyte directory
cd airbyte

# start Airbyte
./run-ab-platform.sh
```
Abrir browser en http://localhost:8000/

username: `airbyte`
password: `password`

## Creación de source (csvs)
https://raw.githubusercontent.com/mlops-itba/Datos-RS/main/data/peliculas_0.csv

https://raw.githubusercontent.com/mlops-itba/Datos-RS/main/data/usuarios_0.csv

https://raw.githubusercontent.com/mlops-itba/Datos-RS/main/data/scores_0.csv

## Creación de destination (psql)
IP localhost no funciona, usar ip local (192.x.x.x)


```bash
psql -U postgres -h localhost -p 5432

# Hice:
docker exec -it mlops-postgres psql -U postgres -h localhost
```

```sql
CREATE DATABASE mlops;
CREATE USER airbyte WITH ENCRYPTED PASSWORD 'airbyte';
GRANT ALL PRIVILEGES ON DATABASE mlops TO airbyte;
GRANT ALL ON SCHEMA public TO airbyte;
GRANT USAGE ON SCHEMA public TO airbyte;
ALTER DATABASE mlops OWNER TO airbyte;
```

```sql
# CREATE DATABASE mlops;
CREATE USER "jorge.aguirre@gmx.com" WITH ENCRYPTED PASSWORD 'airbyte';
GRANT ALL PRIVILEGES ON DATABASE mlops TO "jorge.aguirre@gmx.com";
GRANT ALL ON SCHEMA target TO "jorge.aguirre@gmx.com";
GRANT USAGE ON SCHEMA target TO "jorge.aguirre@gmx.com";
ALTER DATABASE mlops OWNER TO "jorge.aguirre@gmx.com";

\du 
```

# dbT
### Crear entorno

```bash
conda create -n mlops-dbt python=3.12
conda activate mlops-dbt
pip install dbt-postgres

dbt --version
```

Con el siguiente comando se crea el repo y se configura la db
```bash
dbt init db_postgres
cd db_postgres
```

Verificar archivo de configuración `~/.dbt/profiles.yml` 


```yaml
dbt_elt:
  outputs:
    dev:
      type: postgres
      threads: 1
      host: localhost
      port: 5432
      user: postgres
      pass: mysecretpassword
      dbname: mlops
      schema: target
```

### Testear conexión y correr
```bash
dbt debug

dbt run
```



# Mongo (Opcional)

### Desde cloud gratis
https://cloud.mongodb.com/v2/653ac4dcf923b06a3d61bfcc#/overview

### Desde docker
```bash

docker pull mongo
# En vez de lo anterior instalé mi propia imagen usando Dockerfile

docker run \
    --name mlops-mongo \
    -v $mongo_data_folder:/data/db \
    -p 27017:27017 \
    mongo
   # mlops-mongo-python y no necesito las 2 lineas siguientes

docker exec -it mlops-mongo /bin/bash

pip install pymongo

```

Se puede testear desde `source/test_mongo.py`

```bash
mongo
test> show dbs
test> use mlops
test> db.createUser({
    user: "airbyte",
    pwd: "airbyte",
    roles: [ { role: "userAdmin", db: "mlops" } ]
})

test> use admin
test> db.createUser(
  {
    user: "admin",
    pwd: "admin",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
```