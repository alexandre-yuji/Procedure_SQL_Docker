## Lesson 07 - Stored Procedures

* **Stored Procedures vs. Views**

Views and stored procedures are both powerful features in relational databases, but they have distinct purposes and functionalities.

**Views:**

* Views are query abstractions that allow users to define complex, frequently used queries as a single entity.
* They are essentially predefined SQL queries that are stored in the database and treated as virtual tables.
* Views simplify data access by hiding the complexity of the underlying queries and providing a consistent interface for users.
* They are useful for simplifying frequent queries, segmenting data access permissions, and abstracting the complexity of the underlying data model.

**Stored Procedures:**

* Stored procedures are transaction abstractions that consist of a set of precompiled SQL statements stored in the database. They are used to encapsulate more complex database operations, such as updates, inserts, deletes, and other transactions.
Stored Procedures can accept input parameters and return output values, making them highly flexible and reusable across different parts of an application.
They offer greater control over database operations and allow for the execution of business logic on the server side.

Creating a New Database

To illustrate the process, let's establish a new database that simulates a conventional banking environment.

We'll start by creating a new database. Then, we'll use the CREATE TABLE and INSERT INTO commands.

```sql
CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY NOT NULL,
    value_limit INTEGER NOT NULL,
    balance INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY NOT NULL,
    transaction_type CHAR(1) NOT NULL,
    descript VARCHAR(10) NOT NULL,
    value_amount INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    performed_on TIMESTAMP NOT NULL DEFAULT NOW()
);
```

If you want to use UUID (for production scenarios)

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS clients ( 
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), 
    value_limit INTEGER NOT NULL, 
    balance INTEGER NOT NULL
);
```


CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS clients (
id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
limite INTEGER NOT NULL,
balance INTEGER NOT NULL,
CHECK (balance >= limite)
);

**CREATE TABLE:**

* The `CREATE TABLE` command is used to create a new table in the database.
* The `IF NOT EXISTS` is an optional clause that ensures that the table will only be created if it does not already exist in the database, avoiding errors if the table already exists.
* Next, the table name is specified (`clients` and `transactions` in this case), followed by a list of columns and their definitions.
* Each column is defined with a name, a data type, and optionally other constraints, such as a `PRIMARY KEY` and the requirement that it not be null (`NOT NULL`).

```sql
INSERT INTO clients (value_limit, balance)
VALUES
    (10000, 0),
    (80000, 0),
    (1000000, 0),
    (10000000, 0),
    (500000, 0);
```

**INSERT INTO:**

* The `INSERT INTO` command is used to add new records to an existing table.
* In the `INSERT INTO` clause, the table name (`clients` in this case) is specified, followed by the list of columns in parentheses, if necessary.
* Next, the `VALUES` clause is used to specify the values ​​to be inserted into the corresponding columns.
* Each row of values ​​corresponds to a new record to be inserted into the table, with the values ​​in the same order as the columns were listed.

In short, these commands are essential for defining the structure and inserting data into database tables, thus creating the foundation for storing and manipulating information in an organized and efficient manner.

## Let's now simulate a bank transaction.

To purchase a car for R$80,000 for client 1.

We will perform this process in two steps.

The first will be an INSERT INTO command and then an UPDATE command.

```sql
INSERT INTO transactions (transaction_type, descript, value_limit, client_id)
VALUES ('d', 'Car purchase', 80000, 1)
```

```sql
UPDATE clients
SET balance = balance + CASE WHEN 'd' = 'd' THEN -80000 ELSE 80000 END
WHERE id = 1; -- Replace with the desired customer ID
```

* **Let's look at customer 1's situation now**

```sql
SELECT balance, value_limit
FROM clients
WHERE id = 1
```

## We'll need to fix this

The `DELETE` command is a SQL statement used to remove records from a table based on a specific condition. It allows you to delete data from a database table in a controlled and precise manner. Here are some key points about the `DELETE` command:

1. **Basic Syntax**: The basic syntax of the `DELETE` command is as follows:

```sql
DELETE FROM table_name
WHERE condition;
```

2. **WHERE Clause**: The `WHERE` clause is optional, but is typically used to specify which records to delete. If not specified, all records in the table will be deleted.

3. **Conditional Deletion**: You can use the `WHERE` clause to define a condition to determine which records will be deleted. Only records that meet this condition will be removed.

4. **Impact of Deletion**: The `DELETE` command permanently removes records from the table, meaning that deleted data cannot be recovered.

5. **Cautious Use**: It is important to use the `DELETE` command with caution, especially without a specific `WHERE` clause, as it can result in the deletion of all records in the table.

6. **Transactions**: Like other SQL data modification commands, such as `INSERT` and `UPDATE`, the `DELETE` command can be used within transactions to ensure data consistency and integrity.

In the example you provided:

```sql
DELETE FROM transactions
WHERE id = 1;
```

This command removes the record from the `transactions` table where `id` equals `1`. This will result in the permanent deletion of that specific record from the table. Always be sure to use the `DELETE` command carefully and double-check the condition before executing it to avoid accidentally deleting important data.

```sql
DELETE FROM transactions
WHERE id = 1;
```

We will also need to return the customer's current balance, which was 0.

```sql
UPDATE clients
SET balance = 0
WHERE id = 1;
```

## How to avoid this? Stored Procedures

Stored procedures are routines stored in the database that contain a series of SQL statements and can be executed by applications or users connected to the database. They offer several advantages, such as:

1. **Code reuse:** Stored procedures allow blocks of SQL code to be written once and reused in multiple parts of the application.

2. **Performance:** Because they are compiled and stored in the database, stored procedures can execute more efficiently than multiple SQL queries sent separately by the application.

3. **Security:** Stored procedures can help secure the database, as applications only need permission to execute the stored procedure, not to directly access the tables.

4. **Data abstraction:** They can be used to hide the complexity of the underlying data model, providing a simplified interface for users or applications.

5. **Transaction Control:** Stored procedures can include transaction control statements to ensure data integrity during complex operations.

Let's understand each part of the `execute_transaction` stored procedure:

1. **Procedure Creation:**

```sql
CREATE OR REPLACE PROCEDURE execute_transaction(
    IN p_transaction_type CHAR(1),
    IN p_descript VARCHAR(10),
    IN p_value INTEGER,
    IN p_client_id INTEGER
)
```

* This statement creates or replaces a stored procedure named `execute_transaction`.
* The procedure has four input parameters: `p_transaction_type`, `p_descript`, `p_value`, and `p_client_id`, each with its specified data type. 2. **Language Definition:**

Regarding languages, the PostgreSQL documentation lists four standard languages ​​available: PL/pgSQL (Chapter 43), PL/Tcl (Chapter 44), PL/Perl (Chapter 45), and PL/Python (Chapter 46).

```sql
LANGUAGE plpgsql
```

* Defines the stored procedure language as PL/pgSQL, which is a procedural language for PostgreSQL.
3. **Procedure Body:**

```sql
AS $$
DECLARE
    current_balance INTEGER;
    client_limit INTEGER;
    balance_after_transaction INTEGER;
BEGIN
-- Procedure body...
END;
$$;
```

* The stored procedure body is defined between `AS $$` and `$$;`.
* Within the body, we declare local variables using `DECLARE`. * The procedure execution occurs between `BEGIN` and `END;`.
4. **Data Retrieval:**

```sql
-- Gets the customer's current balance and limit
SELECT balance, value_limit INTO current_balance, client_limit
FROM clients
WHERE id = p_client_id;
```

* This part of the code executes a query to get the current balance and limit of the customer with the provided ID.
5. **Transaction Verification:**

```sql
-- Checks if the transaction is valid based on the balance and limit
IF p_transaction_type = 'd' AND current_balance - p_value < -client_limit THEN
RAISE EXCEPTION 'Insufficient balance to perform the transaction';
END IF;
```

* Here, a check is performed to ensure that the transaction is valid based on the transaction type ('d' for debit) and that the current balance minus the transaction amount is less than the account's credit limit.

Customer. If the condition is true, an exception is thrown.

6. **Balance Update:**

```sql
-- Updates the customer's balance
UPDATE clients
SET balance = balance + CASE WHEN p_type = 'd' THEN -p_value ELSE p_value END
WHERE id = p_client_id;
```

* In this section, the customer's balance is updated based on the transaction type. If it is a debit ('d'), the amount is subtracted from the current balance; otherwise, it is added.
7. **Transaction Insert:**

```sql
-- Inserts a new transaction
INSERT INTO transactions (transaction_type, descript, value_limit, customer_id)
VALUES (p_type, p_description, p_value, p_client_id);
```

* Finally, a new transaction is inserted into the `transactions` table with the provided details.

This stored procedure encapsulates the entire process of performing a bank transaction, from validating the customer's balance and limit to updating the balance and inserting the transaction. It offers a convenient and secure way to perform these operations in a consistent and controlled manner.

To call the `execute_transaction` stored procedure with the provided parameters, you can run the following SQL command in PostgreSQL:

```sql
CALL execute_transaction('d', 'carro', 80000, 1);
```

This will invoke the `execute_transaction` procedure with the provided parameters:

* `p_transaction_type`: 'd'
* `p_descript`: 'carro'
* `p_value`: 80000
* `p_client_id`: 1

Make sure to run this command in an environment where the `execute_transaction` stored procedure is defined and accessible.

## Challenge

Create a "ver_extrato" stored procedure to provide a detailed view of a customer's bank statement, including their current balance and information on the last 10 transactions. This operation takes the customer ID as input and returns a message with the customer's current balance and a list of the last 10 transactions, including the transaction ID, the transaction type (deposit or withdrawal), a brief description, the transaction amount, and the date it was made.

**Detailed Explanation:**

1. **Parameter Input:**

* The stored procedure receives the customer ID as an input parameter.
2. **Getting the Current Balance:**

* A query is performed on the "clients" table to obtain the customer's current balance based on the provided ID.
3. **Displaying the Current Balance:**

* The customer's current balance is displayed via a warning message.
4. **Getting the Last 10 Transactions:**

* A query is performed on the "transactions" table to obtain the customer's last 10 transactions, sorted by date in descending order.
5. **Displaying Transactions:**

* Using a `FOR` loop, each transaction is iterated over and its information is displayed via warning messages. * For each transaction, the transaction ID, the transaction type (deposit or withdrawal), a brief description of the transaction, the transaction amount, and the date it was made are displayed.
* The loop stops after displaying information for the last 10 transactions.

```sql
CREATE OR REPLACE PROCEDURE ver_extrato(
IN p_client_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    current_balance INTEGER;
    transact RECORD;
    count INTEGER := 0;
BEGIN
    -- Gets the customer's current balance
    SELECT balance INTO current_balance
    FROM clients
    WHERE id = p_client_id;

    -- Returns the customer's current balance
    RAISE NOTICE 'Current customer balance: %', current_balance;

    -- Returns the customer's last 10 transactions
    RAISE NOTICE 'Last 10 customer transactions:';
    FOR transaction IN
    SELECT *
    FROM transactions
    WHERE client_id = p_client_id
    ORDER BY performed_on DESC
    LIMIT 10
    LOOP
    count := count + 1;
    RAISE NOTICE 'ID: %, Type: %, Description: %, Amount: %, Date: %', transaction.id, transaction.type, transaction.descript, transaction.amount, transaction.performed_on;
    EXIT WHEN count >= 10;
    END LOOP;
END;
$$;
```

## Initial Configuration

### Manually

Use the provided SQL file, `trigger.sql`, to populate your database.

### With Docker and Docker Compose

**Pre-requisite**: Install Docker and Docker Compose

* [Getting started with Docker](https://www.docker.com/get-started)
* [Installing Docker Compose](https://docs.docker.com/compose/install/)

### Steps for configuration with Docker:

1. **Start Docker Compose** Run the command below to start the services:
    
    ```
    docker-compose up
    ```
    
    Wait for configuration messages, such as:
    
    ```csharp
    Creating network "northwind_psql_db" with driver "bridge"
    Creating volume "northwind_psql_db" with default driver
    Creating volume "northwind_psql_pgadmin" with default driver
    Creating pgadmin ... done
    Creating db      ... done
    ```
       
2. **Connect to PgAdmin** Access PgAdmin via the URL: [http://localhost:5050](http://localhost:5050), using the password `postgres`. 

Configure a new server in PgAdmin:
    
    * **General tab**:
        * Name: db
    * **Connection tab**:
        * Host name: db
        * Username: postgres
        * Password: postgres 
    Then select the trigger database.

3. **Stop Docker Compose** Stop the server started by the `docker-compose up` command using Ctrl-C and remove the containers with:
    
    ```
    docker-compose down
    ```
    
4. **Files and Persistence** Your modifications to the Postgres databases will be persisted in the Docker volume `postgresql_data` and can be recovered by restarting Docker Compose with `docker-compose up`. To delete the database data, run:
    
    ```
    docker-compose down -v
    ```