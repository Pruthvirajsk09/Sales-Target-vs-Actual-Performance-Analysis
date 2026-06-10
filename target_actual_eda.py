"""
Sales Target vs Actual Performance Analysis
Author: Pruthviraj Kadam
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import warnings
warnings.filterwarnings('ignore')

plt.rcParams.update({
    'figure.facecolor':'#F8F9FA','axes.facecolor':'#FFFFFF',
    'axes.spines.top':False,'axes.spines.right':False,
    'font.family':'DejaVu Sans','axes.titlesize':13,
})

df = pd.read_csv('data/sales_target_actual.csv')
print(f"Dataset: {len(df):,} rows")
print(f"Total Target : ₹{df['Target'].sum()/1e7:.1f} Cr")
print(f"Total Actual : ₹{df['Actual'].sum()/1e7:.1f} Cr")
print(f"Achievement  : {df['Actual'].sum()/df['Target'].sum()*100:.1f}%")

fig, axes = plt.subplots(2, 3, figsize=(18, 11))
fig.suptitle('Sales Target vs Actual — Performance Dashboard', fontsize=16, fontweight='bold')
fig.patch.set_facecolor('#F0F4F8')

# 1: Monthly trend
ax = axes[0,0]
monthly = df[df['Year']==2024].groupby('Month').agg(Target=('Target','sum'),Actual=('Actual','sum')).reset_index()
x = monthly['Month']
ax.bar(x-0.2, monthly['Target']/1e6, width=0.4, label='Target', color='#457B9D', alpha=0.8)
ax.bar(x+0.2, monthly['Actual']/1e6, width=0.4, label='Actual', color='#2A9D8F', alpha=0.8)
ax.set_xticks(range(1,13))
ax.set_xticklabels(['J','F','M','A','M','J','J','A','S','O','N','D'])
ax.set_ylabel('₹ Millions'); ax.set_title('Monthly Target vs Actual (2024)', fontweight='bold')
ax.legend(frameon=False)

# 2: Region performance
ax = axes[0,1]
reg = df.groupby('Region').apply(lambda x: x['Actual'].sum()/x['Target'].sum()*100).sort_values(ascending=True)
colors = ['#E63946' if v < 90 else '#2A9D8F' for v in reg.values]
bars = ax.barh(reg.index, reg.values, color=colors, height=0.5, edgecolor='white')
ax.axvline(100, color='gray', linestyle='--', alpha=0.7, label='Target (100%)')
for bar, val in zip(bars, reg.values):
    ax.text(val+0.3, bar.get_y()+bar.get_height()/2, f'{val:.1f}%', va='center', fontsize=10, fontweight='bold')
ax.set_xlabel('Achievement %'); ax.set_title('Achievement % by Region', fontweight='bold')
ax.legend(frameon=False)

# 3: Product achievement
ax = axes[0,2]
prod = df.groupby('Product').apply(lambda x: x['Actual'].sum()/x['Target'].sum()*100).sort_values(ascending=False)
colors_p = ['#2A9D8F' if v >= 100 else '#E9C46A' if v >= 90 else '#E63946' for v in prod.values]
bars = ax.bar(prod.index, prod.values, color=colors_p, edgecolor='white', width=0.55)
ax.axhline(100, color='gray', linestyle='--', alpha=0.7)
for bar, val in zip(bars, prod.values):
    ax.text(bar.get_x()+bar.get_width()/2, bar.get_height()+0.3, f'{val:.1f}%', ha='center', fontsize=10, fontweight='bold')
ax.set_ylabel('Achievement %'); ax.set_title('Product-wise Achievement', fontweight='bold')
ax.set_ylim(0, max(prod.values)*1.15)

# 4: YoY comparison
ax = axes[1,0]
yoy = df.groupby('Year').agg(Target=('Target','sum'), Actual=('Actual','sum')).reset_index()
x2 = [0,1]
ax.bar([i-0.2 for i in x2], yoy['Target']/1e7, width=0.35, label='Target (Cr)', color='#457B9D', edgecolor='white')
ax.bar([i+0.2 for i in x2], yoy['Actual']/1e7, width=0.35, label='Actual (Cr)', color='#2A9D8F', edgecolor='white')
ax.set_xticks(x2); ax.set_xticklabels(['2023','2024'])
ax.set_ylabel('₹ Crores'); ax.set_title('Year-over-Year Comparison', fontweight='bold')
ax.legend(frameon=False)
for i, row in yoy.iterrows():
    pct = row['Actual']/row['Target']*100
    ax.text(i, max(row['Target'],row['Actual'])/1e7+0.3, f'{pct:.1f}%', ha='center', fontsize=11, fontweight='bold', color='#333')

# 5: Quarterly waterfall-style
ax = axes[1,1]
qtr = df[df['Year']==2024].groupby('Quarter').agg(Target=('Target','sum'),Actual=('Actual','sum')).reset_index()
x3 = range(len(qtr))
ax.plot(x3, qtr['Target']/1e6, 'o--', color='#457B9D', linewidth=2, markersize=8, label='Target')
ax.plot(x3, qtr['Actual']/1e6, 'o-',  color='#2A9D8F', linewidth=2, markersize=8, label='Actual')
ax.fill_between(x3, qtr['Target']/1e6, qtr['Actual']/1e6,
                where=qtr['Actual']>=qtr['Target'], alpha=0.15, color='#2A9D8F', label='Surplus')
ax.fill_between(x3, qtr['Target']/1e6, qtr['Actual']/1e6,
                where=qtr['Actual']<qtr['Target'],  alpha=0.15, color='#E63946', label='Shortfall')
ax.set_xticks(x3); ax.set_xticklabels(qtr['Quarter'])
ax.set_ylabel('₹ Millions'); ax.set_title('Quarterly Target vs Actual Gap', fontweight='bold')
ax.legend(frameon=False, fontsize=9)

# 6: Status distribution
ax = axes[1,2]
status = df['Status'].value_counts()
colors_s = ['#2A9D8F','#E63946']
wedges, texts, autotexts = ax.pie(status.values, labels=status.index,
    autopct='%1.1f%%', colors=colors_s, startangle=90,
    wedgeprops={'edgecolor':'white','linewidth':2})
for at in autotexts:
    at.set_fontsize(12); at.set_fontweight('bold'); at.set_color('white')
ax.set_title('Target Achievement Status', fontweight='bold')

plt.tight_layout()
plt.savefig('docs/sales_dashboard.png', dpi=150, bbox_inches='tight', facecolor='#F0F4F8')
plt.close()
print("✅ Saved: docs/sales_dashboard.png")
print("\nKey Insights:")
print(f"  Best Region  : {df.groupby('Region').apply(lambda x: x['Actual'].sum()/x['Target'].sum()).idxmax()}")
print(f"  Best Product : {df.groupby('Product').apply(lambda x: x['Actual'].sum()/x['Target'].sum()).idxmax()}")
print(f"  Best Quarter : {df[df['Year']==2024].groupby('Quarter').apply(lambda x: x['Actual'].sum()/x['Target'].sum()).idxmax()}")
