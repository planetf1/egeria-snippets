# Summary of OMRS instances after cataloguing employee database

See [diagram](entities.png)
	
## RelationalColumn

### Instance names
id
hire_date
last_name
first_name
gender
birth_date

### qualifiedName
employees::employees::employee::<columnName>

### Properties/additionalProperties

All the relevant column info, catalod, table name, table schema

### Anchor

DeployedDatabaseSchema employees::employees::employees

### Classifications

LatestChange

### Relationships

NestedSchemaAttribute <- RelationalTable (ie employee)

TypeEmbeddedAttribute(qualifiedName=:employees::employees::employee::id:Type, schemaTypeName=PrimitiveSchemaType)
## RelationalTable

### Instance names

employee

### qualifiedName

:employees.employees.BASE.employee

### Properties/additionalProperties

### Anchor

-> DeployedDatabaseSchema

### Classifications

TypeEmbeddedAttribute (qualifiedName = :employees.employees.BASE.employee:tableType, schemaTypeName=RelationalTableType)

### Relationships

AttributeForSchema <-RelationalDBSchemaType
NestedSchemaAttribute -> RelationalColumn

## RelationalDBSchemaType

### Instance Names
employees::employees::employees

### qualifiedName

:SchemaOf:employees::employees:employees

### Properties/additionalProperties

### Anchor
 -> DeployedDatabaseSchema

### Classifications

LatestChange

### Relationships

AttributeForSchema -> RelationalTable

## RelationalDBSchemaType

### Instance Names

employees::employees::employees

### qualifiedName

employees::employees::employees

### Classifications

LatestChange

### Anchor

-none-

### Relationships

AssetSchemaType -> DeployedDatabaseSchema

## DeployedDatabaseSchema

### Instance Names

employees::employees::employees

### Fully Qualified Name

employees::employees::employees

### Classifications

LatestChange

### Relationships

AssetSchemaType -> RelationalDBSchemaType
DataContentForDataSet <- Database 

## Database

## Instance Names

employees

## Qualified Name

employees

## Classifications

LatestChange

## Relationships

DataContentForDataSet -> DeployedDatabaseSchema

Notes: In the above relationships, we also link to
postgres::employees::public (qn is same) - nothing extra here
postgres::employees::information_schema (qn is same) - this links into the full postgres information schema objects 
postgres::employees::pg_catalog (qn is same) - also links onwards to postgres


## DatabaseManager

### Instance Names

postgresql

### QualifiedName

postgresql

### Classifications

LatestChange

### Relationships

ServerAssetUse -> Database

Notes:
We also catalog the 'postgres' database - which has a lot of system-level information