#!/usr/local/bin/python3

from hive_metastore_client.builders import DatabaseBuilder
from hive_metastore_client.builders import ColumnBuilder
from hive_metastore_client.builders import TableBuilder
from hive_metastore_client import HiveMetastoreClient

HIVE_HOST = "158.176.175.141"
HIVE_PORT = 9083
DB_NAME = "hivetest"


with HiveMetastoreClient(HIVE_HOST, HIVE_PORT) as hive_client:

    # Creating database object using builder
    database = DatabaseBuilder(DB_NAME).build()

    # Creating new database from thrift table object
    hive_client.create_database_if_not_exists(database)

    # Create a table
    table = TableBuilder(
    table_name="orders",
    db_name="store").build()

    hive_client.create_table(table)

    columns = [
       ColumnBuilder(name="value", type="int", comment="a value").build()
    ]
    hive_client.add_columns_to_table(
        db_name=DB_NAME, table_name="example", columns=columns)

