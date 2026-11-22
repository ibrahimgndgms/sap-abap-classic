<div align="center">

# SAP ABAP Classic Enterprise Projects

**End-to-End Classic SAP ABAP Applications • OO ABAP • Dynpro • Web Services • Forms**

[![SAP ABAP](https://img.shields.io/badge/SAP-ABAP-0FAAFF?style=for-the-badge&logo=sap&logoColor=white)]()
[![OO ABAP](https://img.shields.io/badge/Architecture-OO%20ABAP-005A9C?style=for-the-badge)]()
[![Dynpro & ALV](https://img.shields.io/badge/UI-Dynpro%20%26%20Container%20ALV-2E8B57?style=for-the-badge)]()
[![Forms](https://img.shields.io/badge/Output-SmartForms%20%26%20AdobeForms-D9534F?style=for-the-badge)]()
[![Web Services](https://img.shields.io/badge/Integration-HTTP%20%2F%20XML-F0AD4E?style=for-the-badge)]()

<br/>

[English](#english) • [Türkçe](#türkçe)

</div>

---

## English

A curated portfolio of production-grade **Classic SAP ABAP** enterprise projects. Built with clean **Object-Oriented ABAP** design, strict concurrency/authorization mechanisms, external HTTP/XML integrations, and automated background processing.

### Featured Projects

| # | Project & Link | T-Code | Key Highlights |
| :---: | :--- | :---: | :--- |
| **01** | 📋 [**Job Tracking Cockpit**](./01-ZIG_JOBS-Job-Tracking-Cockpit) | `ZIG_JOBS` | Multi-screen **Dynpro** (101–109), **Container ALV**, **SNRO** auto-numbering, **Lock Objects** (`ENQUEUE`/`DEQUEUE`), Role-Based **Authority-Check** (PBO/PAI), Custom Search Help |
| **02** | 💱 [**TCMB Exchange Rate Panel**](./02-ZIG_TCMB-Exchange-Rate-Panel) | `ZIG_TCMB` | Live Central Bank **XML Integration** (`IF_HTTP_CLIENT`), **Dual-Structure** ALV Design, Trend Icons, **`CL_BCS`** HTML Email + UTF-8 Excel, **SmartForms & AdobeForms**, **`SM36`** Daily Job |

### Core Technical Stack
* **Programming & UI:** Classic ABAP, Object-Oriented ABAP (`SE24`), Module Pool / Dynpro (`PBO`/`PAI`), `CL_GUI_ALV_GRID` (Container ALV)
* **Data Dictionary & Security:** Custom Tables, Structures, Help Views, Search Helps (`SE11`), Lock Objects, Number Ranges (`SNRO`), Authorization Objects (`SU21`)
* **Integration & Output:** `IF_HTTP_CLIENT` (REST/XML), `CL_BCS` Email Services, SmartForms, AdobeForms, Background Jobs (`SM36`)

---

## Türkçe

Temiz **Nesne Yönelimli ABAP (OO ABAP)** mimarisi, eşzamanlılık/yetkilendirme kontrolleri, harici HTTP/XML web servis entegrasyonları ve otomatik arka plan işleri kullanılarak uçtan uca geliştirilmiş **Klasik SAP ABAP** kurumsal proje portfolyosu.

### Öne Çıkan Projeler

| # | Proje ve Bağlantı | T-Code | Öne Çıkan Özellikler |
| :---: | :--- | :---: | :--- |
| **01** | [**İş Takip Kokpiti**](./01-ZIG_JOBS-Job-Tracking-Cockpit) | `ZIG_JOBS` | Çok ekranlı **Dynpro** (101–109), **Container ALV**, **SNRO** otomatik numara, **Kilit Nesneleri** (`ENQUEUE`/`DEQUEUE`), Rol Bazlı **Yetki Kontrolü** (PBO/PAI), Özel Search Help |
| **02** | [**TCMB Döviz Kuru Paneli**](./02-ZIG_TCMB-Exchange-Rate-Panel) | `ZIG_TCMB` | Canlı Merkez Bankası **XML Entegrasyonu** (`IF_HTTP_CLIENT`), **Çift Structure** ALV Mimarisi, Trend İkonları, **`CL_BCS`** HTML Mail + UTF-8 Excel, **SmartForms & AdobeForms**, **`SM36`** Job |

### Kullanılan Teknolojiler
* **Programlama ve Arayüz:** Klasik ABAP, Nesne Yönelimli ABAP (`SE24`), Module Pool / Dynpro (`PBO`/`PAI`), `CL_GUI_ALV_GRID` (Container ALV)
* **Veri Sözlüğü ve Güvenlik:** Özel Tablolar, Structure'lar, Help View & Search Help (`SE11`), Kilit Nesneleri, Numara Aralıkları (`SNRO`), Yetki Nesneleri (`SU21`)
* **Entegrasyon ve Çıktı:** `IF_HTTP_CLIENT` (REST/XML), `CL_BCS` E-Posta Servisleri, SmartForms, AdobeForms, Arka Plan İşleri (`SM36`)
