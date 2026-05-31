# FinanceWholesaleBI - System Analityczny i Hurtownia Danych Ryzyka Finansowego

Kompleksowy projekt typu End-to-End realizujący wdrożenie lokalnej hurtowni danych w modelu gwiazdy (OLAP) na bazie kontenera PostgreSQL. Projekt obejmuje pełną automatyzację procesów ETL przy użyciu procedur składowanych PL/pgSQL oraz wdrożenie warstwy analityczno-raportowej w Microsoft Power BI ukierunkowanej na monitorowanie ryzyka kredytowego i faktoringowego.

## Struktura plików w projekcie

*   `docker-compose.yml` - Definicja i konfiguracja kontenera z bazą PostgreSQL.
*   `przygotowanie_danych.sql` - Skrypt czyszczący, tworzący tabele źródłowe (OLTP) i hurtowniane oraz zasilający bazę danymi testowymi.
*   `procedura_etl.sql` - Definicja funkcji klasyfikującej ryzyko oraz głównej procedury ETL.
*   `raport.pdf` - Gotowy plik raportu i dashboardu Power BI.

## Instrukcja uruchomienia krok po kroku

### Krok 1: Uruchomienie bazy danych w tle (Docker Compose)
W folderze głównym projektu, gdzie znajduje się plik `docker-compose.yml`, wykonaj w terminalu polecenie:
```bash
docker-compose up -d
```

Aby sprawdzić czy kontener z bazą wystartował używamy polecenia:
```bash
docker ps
```

### Krok 2: Inicjalizacja baz danych i struktur (OLTP & OLAP)
Uruchom skrypt, który wyczyści stare struktury, stworzy tabele źródłowe oraz docelowe tabele hurtowni danych, a na koniec zasili bazę danymi testowymi:
```bash
docker exec -i moj-postgres psql -U moj_user -d moja_baza <  przygotowanie_danych.sql
```

### Krok 3: Wdrożenie funkcji i procedury ETL
Uruchom skrypt implementujący logikę biznesową (funkcję klasyfikującą ryzyko DPD) oraz główną procedurę transformacji i ładowania danych do modelu gwiazdy:

```bash
docker exec -i moj-postgres psql -U moj_user -d moja_baza < procedura_etl.sql
```

### Krok 4: Uruchomienie procesu zasilania hurtowni (ETL)
```bash
docker exec -it moj-postgres psql -U moj_user -d moja_baza -c "CALL pr_run_etl();"
```

## Przygotowanie raportu w Power BI

### Połączenie z bazą danych

Aby odwzorować raport, połącz się z poziomu Power BI Desktop z lokalną bazą danych PostgreSQL (Host: localhost:5432, Baza: moja_baza, Użytkownik: moj_user, Hasło: mojeHaslo). Do modelu danych należy załadować wyłącznie tabele analityczne: dim_klient, dim_produkt, dim_czas oraz fact_transakcje_ryzyka.

### Kluczowe Metryki i Wykresy w Dashboardzie Ryzyka
Raport menedżerski został zaprojektowany pod kątem natychmiastowej oceny kondycji finansowej firmy:
#### Wskaźniki KPI (Główne kafelki):
##### Łączna ekspozycja portfela ($1,247 mln):
Suma wszystkich zaangażowanych środków finansowych w ramach przyznanych finansowań.
##### Wskaźnik NPL (27,15%):
Kluczowa metryka ryzyka (Non-Performing Loans). Pokazuje, jaki procent całkowitego zadłużenia stanowią transakcje zaklasyfikowane jako "Czerwone (Zagrożone)" (powyżej 30 dni opóźnienia).
#### Wskaźnik NPL (%) wg typu produktu:
Wykres pierścieniowy wskazujący źródło generowania strat. Najwyższy poziom ryzykownych należności generuje Kredyt Gotówkowy (65,03%), w dalszej kolejności Leasing Auto (50,00%) oraz najbezpieczniejszy Faktoring (10,90%).
#### Wskaźnik NPL (%) wg miesięcy:
Wykres liniowy trendu, ilustrujący gwałtowny wzrost toksycznych aktywów od miesiąca 1 do punktu szczytowego w miesiącu 4 (osiągającego 100% dla realizowanych transakcji), po czym następuje pożądany spadek w miesiącu 5.
#### Struktura Zadłużenia wg Miast i Segmentów Ryzyka:
Wykres kolumnowy skumulowany prezentujący jakość portfela w ujęciu geograficznym. Pozwala natychmiast zidentyfikować rynki krytyczne (np. Wrocław, Katowice, Łódź, gdzie 100% wolumenu zadłużenia stanowią klienci z grupy zagrożonej) w opozycji do rynków bezpiecznych (np. Gdańsk, Poznań, Warszawa - 100% portfela stabilnego).
