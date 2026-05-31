-- FUNKCJA KLASYFIKUJĄCA RYZYKO NA PODSTAWIE DPD

CREATE OR REPLACE FUNCTION okresl_ryzyko(dpd INT)
RETURNS VARCHAR AS $$
BEGIN 
	RETURN CASE
		WHEN dpd = 0 THEN 'Zielony (Bezpieczny)'
		WHEN dpd BETWEEN 1 AND 30 THEN 'Żółty (Monitorowany)'
		ELSE 'Czerwony (Zagrożony)'
	END;
END;
$$ LANGUAGE plpgsql;


-- GŁÓWNA PROCEDURA ETL OCZYSZCZAJĄCA II ŁADUJĄCA DANE DO HURTOWNI

CREATE OR REPLACE PROCEDURE pr_run_etl()
AS $$
BEGIN 
	-- Usuwamy stare dane
	TRUNCATE TABLE fact_transakcje_ryzyka CASCADE;
	TRUNCATE TABLE dim_klient CASCADE;
	TRUNCATE TABLE dim_produkt CASCADE;
	TRUNCATE TABLE dim_czas CASCADE;
	
	-- Dodajemy dane do tabeli wymiar klienta
	INSERT INTO dim_klient (klient_key, pelne_nazwisko, miasto, segment_ryzyka)
	SELECT 
		k.klient_id, 
		k.imie || ' ' || k.nazwisko, 
		k.miasto,
		okresl_ryzyko(MAX(t.dni_opoznienia))
	FROM src_klienci k
	LEFT JOIN src_transakcje t ON k.klient_id = t.klient_id
	GROUP BY k.klient_id, k.imie, k.nazwisko, k.miasto;

	-- Dodajemy dane do tabeli wymiar produkt
	INSERT INTO dim_produkt (produkt_key, typ_produktu, oprocentowanie_procent) 
	SELECT produkt_id, typ_produktu, oprocentowanie || '%' FROM src_produkty;

	-- Dodajemy dane do tabeli wymiar czasu
	INSERT INTO dim_czas (data_key, rok, kwartal, miesiac, dzien_tygodnia)
	SELECT DISTINCT 
		data_operacji,
		EXTRACT(YEAR FROM data_operacji),
		EXTRACT(QUARTER FROM data_operacji),
		EXTRACT(MONTH FROM data_operacji),
		EXTRACT(ISODOW FROM data_operacji)
	FROM src_transakcje;

	-- Dodajemy tabele faktów
	INSERT INTO fact_transakcje_ryzyka (transakcja_id, klient_key, produkt_key, data_key, kwota_finansowania, kwota_zadluzenia,dpd_dni)
	SELECT transakcja_id, klient_id, produkt_id, data_operacji, kwota_finansowania, kwota_zadluzenia, dni_opoznienia FROM src_transakcje;
	
	RAISE NOTICE 'Proces ETL zakończony sukcesem!';
END;
$$ LANGUAGE plpgsql;
