<img width="1672" height="941" alt="STORE COVER" src="https://github.com/user-attachments/assets/acfb81d8-7657-4fa6-8206-13a821842c44" />


# 🛒 Retail Store Sales Analytics — End-to-End SQL Project

> **Transforming raw transactional data into actionable retail business intelligence using T-SQL on Microsoft SQL Server.**

---

## 📌 Project Overview

This project performs a complete **end-to-end SQL analysis** on a retail store's sales dataset — from raw data ingestion and cleaning to structured business insight extraction. It simulates the work of a data analyst solving real operational problems faced by a retail business: identifying demand patterns, tracking customer value, understanding cancellations, and uncovering revenue drivers.

The project is structured in two phases:
- **Phase 1 — Data Cleaning & Standardization**: Preparing raw CSV data for reliable analysis
- **Phase 2 — Business Insights Analysis**: Answering 11 critical business questions using advanced T-SQL

---

## 🎯 Business Problems Solved

| # | Business Question | Impact Area |
|---|-------------------|-------------|
| Q1 | Which products sell the most (by quantity)? | Inventory & Demand Planning |
| Q2 | Which products are most frequently cancelled? | Product Quality & Trust |
| Q3 | What time of day sees peak purchases? | Staffing & Marketing Scheduling |
| Q4 | Who are the top 5 highest-spending customers? | Customer Retention & Loyalty |
| Q5 | Which product categories generate maximum revenue? | Investment & Budget Allocation |
| Q6 | What are the top products within high-revenue categories? | Product Strategy & Promotions |
| Q7 | What is the return & cancellation rate by category? | Quality Control & Logistics |
| Q8 | What payment mode do customers prefer most? | Payment Infrastructure Optimization |
| Q9 | How does purchasing behavior vary by age group? | Demographic Marketing Campaigns |
| Q10 | What does the monthly revenue trend look like? | Demand Forecasting & Seasonality |
| Q11 | How do product preferences differ by gender? | Audience Segmentation & Ad Targeting |

---

## 📊 Key Findings (Actual Query Results)

| Insight | Finding |
|---------|---------|
| 🏆 Best-Selling Product | **Wardrobe** — 70 units sold |
| ❌ Most Cancelled Product | **Comics** — 24 cancellations |
| ⏰ Peak Shopping Time | **Evening** — 515 orders |
| 💰 Top Customer | **Darshit Mann** — ₹5,07,530 in total spend |
| 📦 Highest Revenue Category | **Accessories** — ₹1.03 Cr |
| 💳 Most Used Payment Mode | **Credit Card** — 648 transactions |
| 👥 Highest Spending Age Group | **30–49 years** — ₹2.66 Cr revenue |
| 📈 Peak Revenue Month | **October 2023** — ₹58,86,414 |
| 🔺 Highest Cancellation Rate | **Clothing** — 25.63% |
| 🔺 Highest Return Rate | **Accessories** — 31.50% |

---

## 🗂️ Dataset Schema

```sql
CREATE TABLE store (
    transaction_id     VARCHAR(15),
    customer_id        VARCHAR(15),
    customer_name      VARCHAR(100),
    customer_age       INT,
    gender             VARCHAR(10),
    product_id         VARCHAR(15),
    product_name       VARCHAR(50),
    product_category   VARCHAR(50),
    quantity           INT,
    price              DECIMAL(10,2),
    payment_mode       VARCHAR(20),
    purchase_date      DATE,
    time_of_purchase   TIME,
    status             VARCHAR(15)
);
```

**Dataset size:** ~2,000 transactions | **Time period:** Full Year 2023 | **Source format:** CSV

---

## 🧹 Data Cleaning Pipeline

The cleaning phase addresses 10 real-world data quality issues:

```
1. Duplicate Removal          → ROW_NUMBER() with PARTITION BY transaction_id
2. Column Renaming            → sp_rename for typo-corrected column names
3. Data Type Validation       → INFORMATION_SCHEMA.COLUMNS inspection
4. Dynamic NULL Audit         → STRING_AGG + sp_executesql across all columns
5. Invalid Record Removal     → Deleted rows with NULL transaction_id
6. Missing Customer ID Fix    → Targeted UPDATE by transaction reference
7. Missing Customer Details   → Manual backfill for known customer records
8. Gender Standardization     → CASE normalization → 'MALE' / 'FEMALE'
9. Payment Mode Cleanup       → 'CC' → 'Credit Card' standardization
10. Final Data Verification   → Full table scan post-cleaning
```

---

## 🔧 SQL Techniques Used

| Technique | Applied In |
|-----------|------------|
| `CTEs (WITH clause)` | Q3, Q9, Q10 — multi-step aggregation |
| `Window Functions (ROW_NUMBER)` | Duplicate detection and removal |
| `CASE Statements` | Time-of-day segmentation, age group bucketing, gender/payment normalization |
| `PIVOT` | Q11 — gender-based cross-tab product preferences |
| `Dynamic SQL (sp_executesql)` | Automated NULL audit across all columns |
| `BULK INSERT` | CSV data ingestion with date format handling |
| `Conditional Aggregation` | Q7 — cancellation and return rate calculation |
| `FORMAT()` | Indian currency locale formatting (₹) |
| `DATEPART / DATENAME` | Time and month extraction for trend analysis |
| `STRING_AGG` | Dynamic query construction for NULL analysis |

---

## 📁 Project Structure

```
retail-store-sql-analytics/
│
├── WALMART_ANALYSIS.sql          # Main SQL file (cleaning + analysis)
├── datasets/
│   └── sales_store.csv           # Raw transactional dataset
├── screenshots/
│   ├── Q1_top_products.png
│   ├── Q2_cancellations.png
│   ├── Q3_peak_time.png
│   ├── Q4_top_customers.png
│   ├── Q5_category_revenue.png
│   ├── Q6_top_products_by_category.png
│   ├── Q7_return_cancellation_rate.png
│   ├── Q8_payment_mode.png
│   ├── Q9_age_group_revenue.png
│   ├── Q10_monthly_trend.png
│   └── Q11_gender_preferences.png
└── README.md
```

---

## ⚙️ Setup & Usage

### Prerequisites
- Microsoft SQL Server (Express or Developer Edition)
- SQL Server Management Studio (SSMS)

### Steps to Run

**1. Clone the repository**
```bash
git clone https://github.com/yourusername/retail-store-sql-analytics.git
```

**2. Open SSMS and run the script**
```sql
-- Open WALMART_ANALYSIS.sql in SSMS
-- Update the BULK INSERT file path to match your local directory:

BULK INSERT store
FROM 'YOUR_LOCAL_PATH\datasets\sales_store.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
```

**3. Execute in order**
- Run the `DATABASE SETUP` section first
- Run `TABLE CREATION`
- Run `DATA IMPORT`
- Run `DATA CLEANING` (Steps 1–10 sequentially)
- Run any `BUSINESS INSIGHTS` query (Q1–Q11)

> ⚠️ Set `SET DATEFORMAT dmy;` before BULK INSERT to handle DD/MM/YYYY date format correctly.

---

## 💡 Business Impact Summary

This analysis enables a retail business to:

- **Reduce stockouts** by knowing the highest-demand products
- **Cut revenue loss** by identifying cancellation-prone products early
- **Optimize marketing spend** by targeting the 30–49 age group (highest spenders)
- **Improve payment infrastructure** by prioritizing Credit Card and EMI systems
- **Plan seasonal campaigns** around October–November peak revenue months
- **Address quality issues** in Accessories (31.5% return rate) and Clothing (25.6% cancellation rate)

---

## 🛠️ Tools & Environment

![SQL Server](https://img.shields.io/badge/Microsoft_SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![SSMS](https://img.shields.io/badge/SSMS-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-4479A1?style=for-the-badge&logo=databricks&logoColor=white)

- **Database:** Microsoft SQL Server 16.0 (Express)
- **IDE:** SQL Server Management Studio (SSMS)
- **Language:** T-SQL
- **Dataset Format:** CSV (comma-delimited)
- **Currency Locale:** Indian Rupee (en-IN)

---

## 👤 Author

**Sandip** — EDP Analyst | Aspiring Data Analyst  
📍 Nagpur, Maharashtra, India  
🔗 [LinkedIn](https://www.linkedin.com/in/sandipmandal52/) | [GitHub](https://github.com/SandipMandal-52)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

*If this project helped you, consider giving it a ⭐ on GitHub.*
