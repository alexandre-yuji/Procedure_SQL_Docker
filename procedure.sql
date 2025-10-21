--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;



SET default_tablespace = '';

SET default_with_oids = false;


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
    held_in TIMESTAMP NOT NULL DEFAULT NOW()
);

INSERT INTO clients (value_limit, balance)
VALUES
    (10000, 0),
    (80000, 0),
    (1000000, 0),
    (10000000, 0),
    (500000, 0);


CREATE OR REPLACE PROCEDURE execute_transaction(
    IN p_transaction_type CHAR(1),
    IN p_descript VARCHAR(10),
    IN p_value INTEGER,
    IN p_client_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    current_balance INTEGER;
    client_limit INTEGER;
    balance_after_transaction INTEGER;
BEGIN
    SELECT balance, value_limit INTO current_balance, client_limit
    FROM clients
    WHERE id = p_client_id;

    RAISE NOTICE 'Current client balance: %', current_balance;
    RAISE NOTICE 'Current client limit: %', client_limit;

    IF p_transaction_type = 'd' AND current_balance - p_value < -client_limit THEN
        RAISE EXCEPTION 'Minimum amount required to complete transaction.';
    END IF;

    UPDATE clients
    SET balance = balance + CASE WHEN p_transaction_type = 'd' THEN -p_value ELSE p_value END
    WHERE id = p_client_id;

    INSERT INTO transactions (transaction_type, descript, value_amount, client_id)
    VALUES (p_transaction_type, p_descript, p_value, p_client_id);

    SELECT balance INTO balance_after_transaction
    FROM clients
    WHERE id = p_client_id;

    RAISE NOTICE 'Balance after transaction: %', balance_after_transaction;
END;
$$;


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