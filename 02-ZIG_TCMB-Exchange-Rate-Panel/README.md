# ZIG_TCMB — Central Bank (TCMB) XML Exchange Rate Integration / TCMB Döviz Kuru Entegrasyonu

[English](#english) | [Türkçe](#türkçe)

---

## <a name="english"></a>English

**Main Program:** `ZIG_TCMB_RATE_PANEL` | **Transaction Code:** `ZIG_TCMB`  
An SAP ABAP integration panel that fetches daily XML exchange rates from the Central Bank of the Republic of Türkiye (TCMB), stores them in SAP, compares daily trends with visual icons, and exports selected rows via Email (`CL_BCS`), Excel, SmartForms, and AdobeForms.

### Dual-Structure Architecture (SE11)
* **`ZIGS_TCMB_RATE` (Service & DB Structure):** Stores raw XML values and email payloads with amount fields typed as `CHAR(10)`.
* **`ZIGS_TCMB_RATE_D` (Container ALV Display Structure):** Converts rates to `DEC(8,4)` for accurate numeric sorting and adds `STATUS` (`ICON_D`) for trend arrows.

### Object-Oriented ABAP Design (SE24)

| Class | Method(s) | Responsibility |
|---|---|---|
| `ZIGCL_GET_DAY_NUMBER` | `GET_DAY_NUMBER` | Determines day of the week (1–7) for weekend fallback and Monday comparison logic. |
| `ZIGCL_SET_TCMB_URL` | `SET_URL` | Dynamically builds the TCMB XML endpoint URL (e.g., `kurlar/202608/04082026.xml`). |
| `ZIGCL_TCMB_RATE_SERVICE` | `GET_DATA` | Fetches and parses current & previous business day XML rates via `IF_HTTP_CLIENT`. |
| `ZIGCL_TCMB_HELPER` | `SAVE_DB`, `DOWNLOAD_EXCEL`, `SEND_MAIL`, `CALL_ADOBEFORM`, `CALL_SMARTFORM` | Handles DB persistence (`ZIGT_TCMB_RATE`), UTF-8 Excel export, `CL_BCS` HTML email with attachment (`ZIGT_MAIL_ADRS`), and PDF/Form outputs (`ZIG_TCMB_RATE_AF` / `ZIG_TCMB_RATE_SF`). |

### Key Business Logic & Technical Highlights
* **Weekend & Monday Fallback:** Warns the user on weekends and fetches the latest Friday rates. On Mondays, trend comparisons are automatically calculated against Friday's rates.
* **Daily Trend Indicators:** Displays Green/Red trend arrows (`ICON_D`) in Container ALV based on day-over-day rate changes.
* **Selective Export:** Users can select specific rows in Container ALV to generate targeted AdobeForms/SmartForms, Excel files, or emails.
* **UTF-8 Turkish Character Fix:** Added **UTF-8 BOM (`0xEF, 0xBB, 0xBF`)** and Codepage `4110` to `CL_BCS` binary Excel attachments.
* **Automated Background Job (`SM36`):** Configured dynamic date variant (`SY-DATUM`) and scheduled daily job `ZIG_TCMB_JOB_DAILY`.

---

## <a name="türkçe"></a>Türkçe

**Ana Program:** `ZIG_TCMB_RATE_PANEL` | **İşlem Kodu (T-Code):** `ZIG_TCMB`  
Türkiye Cumhuriyet Merkez Bankası (TCMB) tarafından günlük yayınlanan XML döviz kurlarını web servis üzerinden SAP'ye çeken, veritabanına kaydeden, önceki iş günüyle kıyaslayarak trend ikonlarıyla sunan ve seçili satırları E-posta (`CL_BCS`), Excel, SmartForms ve AdobeForms olarak dışa aktaran entegrasyon paneli.

### Çift Structure Mimarisi (SE11)
* **`ZIGS_TCMB_RATE` (Servis & Veritabanı Yapısı):** Ham XML verilerinin çekilmesi, veritabanı kayıtları ve e-posta süreçleri için tüm tutar alanları `CHAR(10)` olarak tanımlanmıştır.
* **`ZIGS_TCMB_RATE_D` (Container ALV Gösterim Yapısı):** ALV'de doğru sayısal sıralama (sorting) yapılabilmesi için tutar alanları `DEC(8,4)` tipine çevrilmiş ve trend ikonları için `STATUS` (`ICON_D`) alanı eklenmiştir.

### Nesne Yönelimli ABAP Mimarisi (SE24)

| Sınıf | Metot(lar) | Sorumluluk |
|---|---|---|
| `ZIGCL_GET_DAY_NUMBER` | `GET_DAY_NUMBER` | Girilen tarihin haftanın hangi günü (1–7) olduğunu hesaplar (hafta sonu ve Pazartesi kontrolü). |
| `ZIGCL_SET_TCMB_URL` | `SET_URL` | Seçilen tarihe göre dinamik TCMB XML bağlantı adresini (ör. `kurlar/202608/04082026.xml`) üretir. |
| `ZIGCL_TCMB_RATE_SERVICE` | `GET_DATA` | `IF_HTTP_CLIENT` ile güncel ve önceki iş gününe ait XML kur verilerini okur. |
| `ZIGCL_TCMB_HELPER` | `SAVE_DB`, `DOWNLOAD_EXCEL`, `SEND_MAIL`, `CALL_ADOBEFORM`, `CALL_SMARTFORM` | Veritabanı kaydı (`ZIGT_TCMB_RATE`), UTF-8 Excel indirme, `CL_BCS` ile HTML özet tablolu mail (`ZIGT_MAIL_ADRS`) ve form çıktılarını (`ZIG_TCMB_RATE_AF` / `ZIG_TCMB_RATE_SF`) yönetir. |

### Öne Çıkan İş Kuralları ve Teknik Çözümler
* **Hafta Sonu ve Pazartesi Kıyaslama Mantığı:** Cumartesi/Pazar seçildiğinde kullanıcıyı uyararak en son Cuma kurlarını getirir. Pazartesi günleri kıyaslamayı otomatik olarak Cuma kurlarıyla yapar.
* **Günlük Değişim Trend İkonları:** Yükseliş, düşüş ve sabit kalma durumları `ICON_D` ile görsel oklar halinde sunulur.
* **Seçimli Çıktı Alma:** Container ALV'de yalnızca kullanıcının seçtiği kurlar için Excel, Mail, SmartForm veya AdobeForm üretilebilir.
* **Türkçe Karakter Çözümü:** `CL_BCS` e-posta eklerindeki Excel dosyalarında karakter bozulmasını önlemek için **UTF-8 BOM (`0xEF, 0xBB, 0xBF`)** ve Codepage `4110` uygulanmıştır.
* **Otomatik Arka Plan İşi (`SM36`):** Dinamik tarih varyantı (`SY-DATUM`) ile `ZIG_TCMB_JOB_DAILY` günlük arka plan işi tanımlanmıştır.

---

## Screenshots / Ekran Görüntüleri

### 1. Selection Screen (Date & ALV Format) / Seçim Ekranı
*Users can select a target date and switch between Container ALV and Reuse ALV formats.*  
*Kullanıcı tarih seçimi yapabilir ve Container ALV / Reuse ALV formatları arasında geçiş yapabilir.*
![Selection Screen](./images/01_selection_screen.png)

### 2. Container ALV Panel & Weekend Fallback / ALV Kur Paneli ve Trend İkonları
*When a weekend date (22.11.2026) is entered, the system automatically fetches the latest Friday rates (20.11.2026) with daily trend icons and toolbar actions (Save DB, Excel, Mail, AdobeForm, SmartForm).*  
*Hafta sonu tarihi (22.11.2026) girildiğinde sistem otomatik olarak en son Cuma kurlarını (20.11.2026) günlük trend ikonları ve üst menü aksiyonlarıyla (Veritabanına Kaydet, Excel, Mail, AF/SF Çıktısı) listeler.*
![Container ALV Panel](./images/02_container_alv.png)

### 3. SmartForm / AdobeForm PDF Output / Form Çıktısı
*Structured tabular form output generated for the selected currencies.*  
*Seçili döviz kurları için üretilen düzenli tablo formatında form çıktısı.*
![Form Output](./images/03_form_output.png)

### 4. Automated HTML Email & CSV Attachment (`CL_BCS` / `SOST`) / HTML Özet Tablolu E-Posta
*Automated email displaying an HTML summary table of popular currencies in the body along with the `Kurlar.csv` attachment.*  
*Gövdesinde popüler kurların HTML özet tablosunu ve ekinde `Kurlar.csv` dosyasını barındıran otomatik e-posta çıktısı.*
![Email Output](./images/04_email_sost.png)
