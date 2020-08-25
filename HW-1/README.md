# HW-1

## Part 1

### Text

Choose an application domain and, using a relational DBMS, build a database. This can be done in two ways:

 * (Our choice) Use an interesting existing dataset, i.e.:
    1. get interesting data from the Web or other sources (e.g., use the Web to look for a whole database, or data that can be easily imported into a relational DBMS) and build a relational database using such data
    2. formulate a set of SQL queries (about 8-10) over the relational schema
    3. execute such queries over the database and analyze the results
    4. NOTICE: all datasets are fine EXCEPT MOVIE DATASETS (too many projects used movie DBs in the previous years)
 * create the schema and the dataset from scratch, i.e.:
    1. define the relational schema (i.e., write SQL statements to create tables defining attributes, domains, and possibly integrity constaints);
    2. insert tuples into tables (through SQL statements)
    3. formulate a set of SQL queries (about 10) over the relational schema
    4. execute such queries over the database and analyze the results

## Part 1

### Text

Starting from the database developed in the first homework, every group has to identify at least 4 SQL queries that pose performance problems to the DBMS. The students have to show both the "slow" and the "fast" execution of the queries, where the fast version is obtained by:

  * adding integrity constraints to one or more tables
  * rewriting the SQL query (without changing its meaning)
  * adding indices to one or more tables
  * modifying the schema of the database
  * adding views or new (materialized) tables derived from the existing database tables

Ideally, these queries should be picked from the queries created for the first homework; however, new queries can be considered if none of the previous queries poses performance problems to the DBMS.