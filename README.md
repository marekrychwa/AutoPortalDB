# 🚗 AutoPortalDB

**AutoPortalDB** to przykładowa baza danych SQL Server stworzona dla portalu sprzedaży samochodów.  
Projekt ma na celu prezentację dobrze zaprojektowanej struktury relacyjnej bazy oraz praktyczne wykorzystanie różnych możliwości T‑SQL – takich jak widoki, transakcje, zapytania zagnieżdżone czy operacje na danych testowych.

---

## 🧩 Co zawiera projekt

-  **Użytkownicy** – tabela `Users` przechowuje informacje o sprzedawcach i kupujących  
-  **Samochody** – tabela `Cars` z danymi technicznymi (marka, model, przebieg, paliwo, cena)  
-  **Lokalizacje** – tabela `Locations` wskazująca miasto, region i kod pocztowy  
-  **Ogłoszenia** – tabela `Listings` łącząca użytkowników, samochody i lokalizacje  
-  **Zdjęcia** – tabela `Photos`, obsługa wielu zdjęć na jedno ogłoszenie  
-  **Zapytania klientów** – tabela `Inquiries` do przechowywania wiadomości od kupujących  
-  **Widoki i zapytania** – przykładowe operacje SELECT, JOIN, GROUP BY, CASE, HAVING itp.  
-  **Uprawnienia i role** – użytkownik z ograniczonym zestawem poleceń  

---

## ⚙️ Jak uruchomić projekt

1. Uruchom **SQL Server Management Studio (SSMS)** lub **Azure Data Studio**  
2. Otwórz plik: database\AutoPortalDB.sql
3. Uruchom cały skrypt (F5), aby utworzyć bazę danych `AutoPortalDB`
4. Sprawdź poprawność danych, uruchamiając np.:
```sql
SELECT * FROM Users;
SELECT * FROM Listings;
SELECT * FROM ActiveListingsView;
```
5. Gotowe ✅ — baza jest utworzona i gotowa do użycia

## 💡 Wymagania

- **Microsoft SQL Server 2019** lub nowszy  
- **SQL Server Management Studio (SSMS)** lub **Azure Data Studio**  
- Konto z uprawnieniami do tworzenia baz danych  
- (opcjonalnie) narzędzie do wizualizacji danych – np. **Power BI** lub **Excel**
