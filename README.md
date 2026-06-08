# 📈 Sales Target vs Actual Performance Analysis

**Tools:** SQL (MySQL) · Python · Power BI  
**Domain:** FMCG & Pharma Sales Analytics  
**Dataset:** 2,280 records · 5 regions · 5 products · 2 years (2023–2024)  
**Author:** Pruthviraj Kadam  
🔗 [LinkedIn](https://www.linkedin.com/in/pruthviraj-kadam-patil/) | [GitHub](https://github.com/Pruthvirajsk09)

---

## 📌 Problem Statement

A FMCG & Pharma company's sales team is missing targets across multiple regions. The Sales Director needs to understand which regions, products, and salespersons are underperforming — and by how much — to make quarterly resource allocation decisions.

---

## 🎯 Business Objectives

| # | Business Question | Tool Used |
|---|---|---|
| 1 | What is our overall target achievement %? | SQL + Power BI KPI Card |
| 2 | Which region has the biggest shortfall? | SQL window functions + Bar Chart |
| 3 | Which product consistently underperforms? | SQL GROUP BY + Power BI |
| 4 | Which months are seasonally strong? | SQL trend analysis |
| 5 | Who are the top and bottom salespersons? | SQL RANK() + Power BI Table |

---

## 📊 Key Findings

| Insight | Finding |
|---|---|
| Overall Achievement | 92.7% — ₹158.1 Cr actual vs ₹170.6 Cr target |
| Total Shortfall | ₹12.5 Crore across 2 years |
| Best Performing Region | East region — highest achievement % |
| Best Product | Product B — consistently above target |
| Seasonal Peak | Q1 has highest achievement rate |
| Salesperson spread | Top performers at 100%+ vs bottom at under 80% |

---

## 🗂️ Project Structure

```
sales-target-actual-analysis/
│
├── data/
│   └── sales_target_actual.csv    ← 2,280 records
│
├── sql/
│   └── target_actual_analysis.sql ← 15+ SQL queries
│
├── target_actual_eda.py           ← Python EDA + visualizations
│
├── docs/
│   ├── sales_dashboard.png        ← Python dashboard
│   ├── powerbi_page1.png          ← Power BI Page 1
│   ├── powerbi_page2.png          ← Power BI Page 2
│   └── powerbi_page3.png          ← Power BI Page 3
│
└── README.md
```

---

## 🛠️ Tool 1 — SQL (MySQL)

**Sections covered:**
- Overall KPIs — target, actual, variance, achievement %
- Year over year comparison
- Regional performance — achievement % and shortfall ranking
- State level drill down
- Product and category analysis
- Monthly and quarterly trends
- Salesperson ranking using RANK() window function
- CTE — cumulative actual vs target by month

**Key query — Salesperson ranking with window function:**
```sql
WITH sp_perf AS (
    SELECT SalespersonID,
        ROUND(SUM(Target)/1e6, 2)             AS target_M,
        ROUND(SUM(Actual)/1e6, 2)             AS actual_M,
        ROUND(SUM(Actual)/SUM(Target)*100, 2) AS achievement_pct
    FROM employees
    GROUP BY SalespersonID
)
SELECT *,
    RANK() OVER (ORDER BY achievement_pct DESC) AS performance_rank,
    CASE
        WHEN achievement_pct >= 100 THEN 'Star Performer'
        WHEN achievement_pct >= 90  THEN 'Good'
        WHEN achievement_pct >= 80  THEN 'Average'
        ELSE 'Needs Improvement'
    END AS performance_band
FROM sp_perf
ORDER BY achievement_pct DESC;
```

**Why RANK() here?** RANK() assigns a rank to each salesperson based on achievement without needing a self-join. It's cleaner, faster, and shows SQL maturity.

---

## 🐍 Tool 2 — Python

**Libraries:** Pandas, NumPy, Matplotlib

```python
import pandas as pd
df = pd.read_csv('data/sales_target_actual.csv')

print(f"Total Target : ₹{df['Target'].sum()/1e7:.1f} Cr")
print(f"Total Actual : ₹{df['Actual'].sum()/1e7:.1f} Cr")
print(f"Achievement  : {df['Actual'].sum()/df['Target'].sum()*100:.1f}%")

# Region performance
df.groupby('Region').apply(
    lambda x: x['Actual'].sum()/x['Target'].sum()*100
).sort_values(ascending=False)

# Best product
df.groupby('Product').apply(
    lambda x: x['Actual'].sum()/x['Target'].sum()*100
).sort_values(ascending=False)
```

**6 Charts generated:**
1. Monthly Target vs Actual bar chart (2024)
2. Achievement % by Region — horizontal bar
3. Product-wise achievement
4. Year over Year comparison
5. Quarterly gap analysis — area fill chart
6. Achievement status donut

### Python Dashboard Preview
![Sales Dashboard](docs/sales_dashboard.png)

---

## 📊 Tool 3 — Power BI

**Power Query columns added:**
- `AchievementBand` — On Track / Near Target / Needs Attention
- `VariancePct` — (Actual - Target) / Target × 100
- `YearMonth` — for time intelligence

**DAX Measures:**
```dax
Total Target = SUM(sales_performance[Target])

Total Actual = SUM(sales_performance[Actual])

Achievement % =
DIVIDE([Total Actual], [Total Target], 0) * 100

Variance =
[Total Actual] - [Total Target]

YTD Actual =
CALCULATE([Total Actual], DATESYTD('Date'[Date]))
```

**Page 1 — Executive Overview**
- KPI Cards: Total Target, Total Actual, Achievement %, Total Variance
- Bar chart: Monthly Target vs Actual
- Bar chart: Achievement % by Region
- Slicers: Year, Quarter, Region, Product

**Page 2 — Drill Down Analysis**
- Matrix: Region × Product achievement % with conditional formatting
- Bar chart: State level performance
- Line chart: Quarterly trend — Target vs Actual
- Bar chart: Seasonal pattern by month

**Page 3 — Salesperson Performance**
- Table: Salesperson ranking with achievement % and performance band
- Bar chart: Top 10 vs Bottom 10 salespersons
- KPI Card: % of salespersons hitting target
- Conditional formatting: Green = achieved, Red = missed

---

## 💡 Business Recommendations

1. **Focus on underperforming regions** — Identify and replicate strategies from East region across other regions.
2. **Product mix review** — Underperforming products need pricing or positioning review.
3. **Seasonal planning** — Q1 is strongest. Allocate higher targets and resources in Q1. Build inventory ahead of peak.
4. **Salesperson coaching** — Bottom performers need structured training and weekly check-ins from managers.

---

## 🚀 How to Run

```bash
git clone https://github.com/Pruthvirajsk09/sales-target-actual-analysis
pip install pandas numpy matplotlib
python target_actual_eda.py
```

---

## 📬 Connect

**Pruthviraj Kadam** | 📧 pruthvirajkadam009@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/pruthviraj-kadam-patil/) | [GitHub](https://github.com/Pruthvirajsk09)
