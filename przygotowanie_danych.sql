-- ===============================
-- 1. CZYSZCZENIE STARYCH TABEL
-- ===============================

DROP TABLE IF EXISTS fact_transakcje_ryzyka CASCADE;
DROP TABLE IF EXISTS dim_klient CASCADE;
DROP TABLE IF EXISTS dim_produkt CASCADE;
DROP TABLE IF EXISTS dim_czas CASCADE;

DROP TABLE IF EXISTS src_transakcje CASCADE;
DROP TABLE IF EXISTS src_klienci CASCADE;
DROP TABLE IF EXISTS src_produkty CASCADE;


-- =================================
-- 2. TWORZENIE TABEL ŹRÓDŁOWYCH
-- ==================================

CREATE TABLE src_klienci (
    klient_id INT PRIMARY KEY,
    imie VARCHAR(50),
    nazwisko VARCHAR(50),
    miasto VARCHAR(50),
    data_rejestracji DATE
);

CREATE TABLE src_produkty (
    produkt_id INT PRIMARY KEY,
    typ_produktu VARCHAR(30), -- Kredyt, Faktoring, Leasing
    oprocentowanie NUMERIC(5,2)
);

CREATE TABLE src_transakcje (
    transakcja_id INT PRIMARY KEY,
    klient_id INT,
    produkt_id INT,
    kwota_finansowania NUMERIC(12,2),
    kwota_zadluzenia NUMERIC(12,2),
    dni_opoznienia INT, -- DPD
    data_operacji DATE
);

-- ========================================
-- 3. TWORZENIE TABEL HURTOWNI DANYCH
-- ========================================

CREATE TABLE dim_klient (
    klient_key INT PRIMARY KEY,
    pelne_nazwisko VARCHAR(105),
    miasto VARCHAR(50),
    segment_ryzyka VARCHAR(20)
);

CREATE TABLE dim_produkt (
    produkt_key INT PRIMARY KEY,
    typ_produktu VARCHAR(30),
    oprocentowanie_procent VARCHAR(10)
);

CREATE TABLE dim_czas (
    data_key DATE PRIMARY KEY,
    rok INT,
    kwartal INT,
    miesiac INT,
    dzien_tygodnia INT
);

CREATE TABLE fact_transakcje_ryzyka (
    transakcja_id INT PRIMARY KEY,
    klient_key INT REFERENCES dim_klient(klient_key),
    produkt_key INT REFERENCES dim_produkt(produkt_key),
    data_key DATE REFERENCES dim_czas(data_key),
    kwota_finansowania NUMERIC(12,2),
    kwota_zadluzenia NUMERIC(12,2),
    dpd_dni INT
);

-- ================================================
-- 4. DODANIE DANYCH TESTOWYCH DO TABELI ŹRÓDŁOWYCH
-- ================================================


-- DODANIE KLIENTÓW

INSERT INTO src_klienci (klient_id, imie, nazwisko, miasto, data_rejestracji) VALUES
(1, 'Jan', 'Kowalski', 'Warszawa', '2024-01-15'),
(2, 'Anna', 'Nowak', 'Kraków', '2024-03-22'),
(3, 'Marek', 'Zieliński', 'Gdańsk', '2024-06-10'),
(4, 'Katarzyna', 'Szymańska', 'Poznań', '2024-09-05'),
(5, 'Piotr', 'Wiśniewski', 'Wrocław', '2025-01-20'),
(6, 'Małgorzata', 'Wójcik', 'Warszawa', '2025-02-14'),
(7, 'Tomasz', 'Kamiński', 'Katowice', '2025-03-01'),
(8, 'Agnieszka', 'Lewandowska', 'Łódź', '2025-04-11'),
(9, 'Paweł', 'Zieliński', 'Kraków', '2025-05-03'),
(10, 'Barbara', 'Szymańska', 'Gdynia', '2026-01-10');




-- DODANIE PRODUKTOW

INSERT INTO src_produkty (produkt_id, typ_produktu, oprocentowanie) VALUES
(10, 'Kredyt Gotówkowy', 8.50),
(20, 'Faktoring', 4.25),
(30, 'Leasing Auto', 6.00),
(40, 'Kredyt Hipoteczny', 7.15);





-- DODANIE TRANSAKCJI RÓŻNE POZIOMY OPÓŹNIEŃ DPD

INSERT INTO src_transakcje (transakcja_id, klient_id, produkt_id, kwota_finansowania, kwota_zadluzenia, dni_opoznienia, data_operacji) VALUES

-- KLIENCI WZOROWI (DPD = 0)

(100, 1, 10, 50000.00, 42000.00, 0, '2026-01-15'),
(101, 3, 30, 150000.00, 135000.00, 0, '2026-02-10'),
(102, 5, 40, 500000.00, 490000.00, 0, '2026-03-01'),
(103, 8, 20, 30000.00, 10000.00, 0, '2026-04-20'),

-- KLIENCI W GRUPIE RYZYKA "ŻÓŁTEJ" (DPD MIĘDZY 1 A 30)
(104, 1, 30, 80000.00, 75000.00, 5, '2026-05-12'),
(105, 4, 10, 25000.00, 22000.00, 14, '2026-02-18'),
(106, 6, 20, 45000.00, 40000.00, 29, '2026-05-25'),  -- Małgorzata: 29 dni
(107, 9, 10, 15000.00, 12000.00, 3, '2026-03-14'),

-- KLIECI W GRUPIE RYZKA "CZERWONEJ" (DPD > 30)
(108, 2, 10, 12000.00, 11500.00, 45, '2026-01-22'),
(109, 7, 30, 220000.00, 210000.00, 92, '2026-04-05'), -- Tomasz: 92 dni
(110, 10, 20, 60000.00, 58000.00, 31, '2026-05-01'),

-- DODATKOWE TRANSAKCJE
(111, 3, 10, 20000.00, 18000.00, 0, '2026-05-15'),
(112, 2, 20, 40000.00, 35000.00, 12, '2026-05-20');
