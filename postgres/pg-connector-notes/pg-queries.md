List databases

SELECT VERSION(), * FROM pg_database WHERE datistemplate = false;

postgres=> SELECT VERSION(), * FROM pg_database WHERE datistemplate = false;
                                                version                                                 |  oid  |  datname  | datdba | encoding | datcollate  |  datctype   | datistemplate | datallowconn | datconnlimit | datlastsysoid | datfrozenxid | datminmxid | dattablespace |                           datacl                            
--------------------------------------------------------------------------------------------------------+-------+-----------+--------+----------+-------------+-------------+---------------+--------------+--------------+---------------+--------------+------------+---------------+-------------------------------------------------------------
 PostgreSQL 13.5 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 8.5.0 20210514 (Red Hat 8.5.0-4), 64-bit | 13434 | postgres  |     10 |        6 | en_US.utf-8 | en_US.utf-8 | f             | t            |           -1 |         13433 |          478 |          1 |          1663 | 
 PostgreSQL 13.5 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 8.5.0 20210514 (Red Hat 8.5.0-4), 64-bit | 16406 | employees |     10 |        6 | en_US.utf-8 | en_US.utf-8 | f             | t            |           -1 |         13433 |          478 |          1 |          1663 | {=Tc/postgres,postgres=CTc/postgres,employees=CTc/postgres}
(2 rows)


Note:
	• This includes the system table 'postgres'

Get schemas

SELECT *  FROM information_schema.schemata where catalog_name = 'postgres';

postgres=> SELECT *  FROM information_schema.schemata where catalog_name = 'postgres';
 catalog_name |    schema_name     | schema_owner | default_character_set_catalog | default_character_set_schema | default_character_set_name | sql_path 
--------------+--------------------+--------------+-------------------------------+------------------------------+----------------------------+----------
 postgres     | information_schema | postgres     |                               |                              |                            | 
 postgres     | public             | postgres     |                               |                              |                            | 
 postgres     | pg_catalog         | postgres     |                               |                              |                            | 
(3 rows)


Check if schema is in use

select count(table_schema) as rowcount from information_schema.tables where table_schema='information_schema';

postgres=> select count(table_schema) as rowcount from information_schema.tables where table_schema='information_schema';
 rowcount 
----------
       58
(1 row)


Note
	• Replace schema name as per previous results

Get a list of tables:

SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'information_schema' AND table_type = 'BASE TABLE';

