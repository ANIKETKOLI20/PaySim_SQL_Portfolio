# PaySim SQL Portfolio — Results & Insights

**Project:** PaySim SQL Portfolio  
**Analysis scope:** Q1–Q10  
**Status:** Phase 5 — Results & Insights  
**Dataset:** PaySim synthetic mobile-money transaction dataset  
**Database:** PostgreSQL

---

## 1. Executive Summary

This analysis examines 6,362,620 simulated transaction records across five transaction categories and 743 observed hourly simulation steps. The total recorded transaction amount is 1,144,392,944,759.77 monetary units.

The analysis identifies several distinct patterns:

- **Transaction frequency and monetary value are not interchangeable.** CASH_OUT has the highest transaction count, while TRANSFER has the highest total and average transaction amount.
- **Hourly activity is uneven.** Step 19 has the highest transaction count, while Step 304 has the highest total transaction amount.
- **Fraud labels are concentrated in CASH_OUT and TRANSFER.** TRANSFER has the higher within-category fraud-label rate, even though CASH_OUT has slightly more fraud-labelled records.
- **The existing fraud flag has very low recall against the dataset labels.** It flags 16 of 8,213 fraud-labelled records, producing 100% precision and approximately 0.19% recall.
- **Sender identifiers are overwhelmingly one-time in this dataset.** 6,344,009 of 6,353,307 sender identifiers appear once. Those one-time identifiers account for 99.7075% of transaction volume and 99.7021% of total transaction value.
- **Customer-coded recipient identifiers are fewer but account for most monetary value.** They represent 571,961 identifiers and 97.5451% of total transaction value; merchant-coded identifiers represent 2,150,401 identifiers and 2.4549% of value.
- **Transaction amount distributions differ by fraud label.** Fraud-labelled CASH_OUT and TRANSFER groups have higher average amounts than their corresponding non-fraud-labelled groups, although the labels are simulated and do not establish real-world fraud.
- **Recipient frequency and monetary value produce different rankings.** The top recipient by count is not the top recipient by received value.
- **Balance reconciliation requires direction-specific logic and careful scope.** The zero-floor formula substantially improves outgoing sender reconciliation, while recipient balance snapshots do not always reconcile at individual transaction level.

These are findings about the supplied synthetic dataset. They do not establish real-world UPI demand, actual customer behaviour, production fraud rates, transaction failures, financial losses, platform revenue or profit.

## 2. Dataset Overview and Control Totals

| Dataset measure | Verified result |
|---|---:|
| Transaction records | 6,362,620 |
| Transaction categories | 5 |
| Observed simulation steps | 743 |
| First observed step | 1 |
| Last observed step | 743 |
| Missing steps within 1–743 | 0 |
| Total transaction amount | 1,144,392,944,759.77 |
| Fraud-labelled transactions (`isFraud = 1`) | 8,213 |

The available hourly export contains one row for each consecutive simulation step from 1 through 743. It does not contain 744 observed steps. The `step` field is an hourly simulation index, not an exact calendar timestamp.

---

## 3. Results by Analytical Question

## Q1. Transaction Volume Distribution

**Business question:** Which transaction category has the highest transaction count, and what percentage of all transactions does each category represent?

### Actual results

| Transaction type | Transaction count | Share of transactions |
|---|---:|---:|
| CASH_OUT | 2,237,500 | 35.17% |
| PAYMENT | 2,151,495 | 33.81% |
| CASH_IN | 1,399,284 | 21.99% |
| TRANSFER | 532,909 | 8.38% |
| DEBIT | 41,432 | 0.65% |
| **Total** | **6,362,620** | **100.00%** |

### Key findings and interpretation

1. CASH_OUT is the largest transaction category by count, representing 35.17% of records.
2. PAYMENT is the second-largest category, representing 33.81%.
3. CASH_OUT and PAYMENT together account for 68.98% of all transaction records.
4. DEBIT has the lowest transaction count, at 0.65%.

The dataset's transaction frequency is concentrated in CASH_OUT and PAYMENT. This describes transaction counts only; it does not show which category contributes the greatest monetary value or platform revenue.

## Q2. Transaction Monetary Analysis

**Business question:** Which transaction category has the highest total and average transaction amount?

### Actual results

| Transaction type | Transaction count | Total transaction amount | Average transaction amount |
|---|---:|---:|---:|
| TRANSFER | 532,909 | 485,291,987,263.17 | 910,647.01 |
| CASH_OUT | 2,237,500 | 394,412,995,224.49 | 176,273.96 |
| CASH_IN | 1,399,284 | 236,367,391,912.46 | 168,920.24 |
| PAYMENT | 2,151,495 | 28,093,371,138.37 | 13,057.60 |
| DEBIT | 41,432 | 227,199,221.28 | 5,483.67 |
| **Total** | **6,362,620** | **1,144,392,944,759.77** | — |

### Key findings and interpretation

1. TRANSFER has the highest total transaction amount, approximately 42.41% of the dataset total.
2. TRANSFER also has the highest average transaction amount, at 910,647.01.
3. CASH_OUT has the highest transaction count but ranks second by total transaction amount.
4. PAYMENT accounts for 33.81% of transaction records but approximately 2.45% of total transaction amount.

Transaction frequency and monetary contribution exhibit different patterns. TRANSFER has fewer records than CASH_OUT and PAYMENT but contributes the largest aggregate monetary amount. Transaction amount is not platform revenue or profit.

## Q3. Hourly Transaction Trends

**Business question:** How do transaction counts and total transaction amounts change across simulation steps?

### Full hourly-output summary

| Measure | Result |
|---|---:|
| Hourly result rows | 743 |
| Simulation-step range | 1–743 |
| Total transactions across all steps | 6,362,620 |
| Total transaction amount across all steps | 1,144,392,944,759.77 |
| Average transactions per step | 8,563.42 |
| Median transactions per step | 529 |
| Steps with fewer than 1,000 transactions | 400 |
| Steps with at least 10,000 transactions | 199 |

### Selected activity points

| Observation | Step | Transaction count | Total transaction amount |
|---|---:|---:|---:|
| Highest transaction count | 19 | 51,352 | 7,103,846,529.97 |
| Lowest transaction count (tie) | 112 | 2 | 84,837.70 |
| Lowest transaction count (tie) | 662 | 2 | 2,936,608.70 |
| Highest total transaction amount | 304 | 26,697 | 24,963,550,343.94 |

### Key findings and interpretation

1. Transaction activity is highly uneven across the simulation steps: the median is 529 transactions per step, compared with an average of approximately 8,563.
2. Step 19 has the highest transaction count, with 51,352 records.
3. Step 304 has the highest total transaction amount, approximately 24.96 billion, despite having 26,697 records rather than the highest count.
4. Steps 112 and 662 have the lowest observed count, with two transactions each.

Transaction frequency and monetary throughput do not peak at the same simulation step. A step with fewer records can have a higher total transaction amount when the amounts in those records are larger.

## Q4. Ranking Transaction Activity

**Business question:** Which simulation steps rank highest by transaction count, using total transaction amount as a tie-breaker?

### Ranking rules

1. Transaction count — descending.
2. Total transaction amount — descending.
3. Simulation step — ascending.

`ROW_NUMBER()` assigns a unique ranking position to each observed simulation step.

### Actual results — top five steps

| Rank | Step | Transaction count | Total transaction amount |
|---:|---:|---:|---:|
| 1 | 19 | 51,352 | 7,103,846,529.97 |
| 2 | 18 | 49,579 | 7,255,071,578.26 |
| 3 | 187 | 49,083 | 7,391,259,249.56 |
| 4 | 235 | 47,491 | 7,298,145,078.92 |
| 5 | 307 | 46,968 | 8,512,005,039.48 |

### Key findings and interpretation

1. Step 19 ranks first because it has the highest transaction count.
2. Step 307 ranks fifth by transaction count but has the highest total transaction amount among the five displayed steps.
3. The ranking order changes when the analytical priority changes: Q4 prioritises transaction frequency, not monetary value.
4. The Q4 amounts above are consistent with the complete Q3 hourly export. The earlier written Q4 table in `analytical_questions.md` contains a factor-of-ten transcription error in the monetary values for steps 187, 235 and 307; the values in this results document use the values in the Q3 CSV and executed Q4 output.

Q4 prioritises the busiest simulation steps. It is a ranking of Q3's hourly aggregation, not an independent measure of a different type of activity.

## Q5. Fraud-Labelled Transaction Analysis

**Business question:** Which transaction categories contain the highest number and percentage of fraud-labelled transactions?

### Actual results

| Transaction type | Total transactions | Fraud-labelled count | Within-category fraud-label rate | Share of all fraud labels |
|---|---:|---:|---:|---:|
| CASH_OUT | 2,237,500 | 4,116 | 0.18% | 50.12% |
| TRANSFER | 532,909 | 4,097 | 0.77% | 49.88% |
| CASH_IN | 1,399,284 | 0 | 0.00% | 0.00% |
| DEBIT | 41,432 | 0 | 0.00% | 0.00% |
| PAYMENT | 2,151,495 | 0 | 0.00% | 0.00% |
| **Total** | **6,362,620** | **8,213** | — | **100.00%** |

### Key findings and interpretation

1. CASH_OUT has the highest fraud-labelled count, with 4,116 records.
2. TRANSFER has 4,097 fraud-labelled records, only 19 fewer than CASH_OUT.
3. TRANSFER has the higher within-category fraud-label rate: 0.77%, compared with 0.18% for CASH_OUT.
4. CASH_OUT accounts for 50.12% of all fraud-labelled records; TRANSFER accounts for 49.88%.
5. All fraud-labelled records in this dataset belong to CASH_OUT or TRANSFER.

The raw count and within-category rate answer different questions. CASH_OUT has the larger count, while TRANSFER has the higher rate because its fraud-labelled records are measured against a smaller category population. TRANSFER's rate is approximately 4.28 times the CASH_OUT rate, using the displayed rounded rates.

These are simulated labels in PaySim, not independently verified real-world fraud cases.

## Q6. Fraud Flag vs Fraud Label Analysis

**Business question:** How closely do the existing rule-based flags correspond to the simulated fraud labels?

### Confusion matrix

| Classification outcome | Transaction count |
|---|---:|
| True positives (TP) | 16 |
| False positives (FP) | 0 |
| False negatives (FN) | 8,197 |
| True negatives (TN) | 6,354,407 |
| **Total** | **6,362,620** |

### Performance metrics

| Metric | Result |
|---|---:|
| Precision | 100.00% |
| Recall | 0.19% |
| Fraud-labelled records not flagged | 99.81% |

### Key findings and interpretation

1. The existing flag marks 16 transactions; all 16 also carry the dataset's fraud label.
2. No false positives are observed in this dataset.
3. The flag does not identify 8,197 of the 8,213 fraud-labelled records.
4. The mechanism therefore has 100% precision but only approximately 0.19% recall against the simulated labels.

Precision alone would give an incomplete assessment. Although every flagged record matches the reference label, the mechanism identifies only a very small fraction of all fraud-labelled records. This evaluates the existing PaySim flag against `isFraud`; it does not measure a production fraud system or independently verified fraud outcomes.

## Q7. Sender Activity Distribution Analysis

**Business question:** How is transaction activity distributed between one-time and repeat-originator account identifiers, and what proportion of transaction volume and monetary value comes from each group?

### Sender population summary

| Measure | Result |
|---|---:|
| Distinct sender identifiers | 6,353,307 |
| One-time sender identifiers | 6,344,009 |
| Repeat sender identifiers | 9,298 |
| One-time sender share of distinct identifiers | 99.85% |
| Repeat sender share of distinct identifiers | 0.15% |
| Maximum transactions for one sender identifier | 3 |

### Actual results — sender activity segment summary

| Sender segment | Distinct sender accounts | Transaction count | Transaction volume share | Total transaction value | Monetary value share |
|---|---:|---:|---:|---:|---:|
| ONE_TIME | 6,344,009 | 6,344,009 | 99.7075% | 1,140,984,061,038.01 | 99.7021% |
| REPEAT | 9,298 | 18,611 | 0.2925% | 3,408,883,721.76 | 0.2979% |
| **Total** | **6,353,307** | **6,362,620** | **100.0000%** | **1,144,392,944,759.77** | **100.0000%** |

### Top 10 sender query — selected results

All ten displayed highest-ranked sender identifiers have three transactions. The first-ranked sender, `C545315117`, has a total transaction value of 2,485,461.64 and an average transaction amount of 828,487.21. Because the displayed top ten have the same transaction count, total transaction value determines their order under the query's sorting rules.

### Key findings and interpretation

1. Almost all sender identifiers appear in exactly one transaction in this dataset: 99.85% of distinct sender identifiers are classified as one-time.
2. Repeat sender identifiers account for 0.15% of distinct sender identifiers, 0.2925% of transaction volume and 0.2979% of total transaction value.
3. One-time sender identifiers account for 99.7075% of transaction volume and 99.7021% of monetary value.
4. No sender identifier appears in more than three transactions.
5. Equal transaction counts among the ten highest-ranked sender identifiers make monetary value the distinguishing ranking measure.

This describes the distribution of originating account identifiers in a synthetic dataset. It does not establish individual customer behaviour, customer engagement, retention or relationship quality.

### Independent validation

The Q7 validation output confirmed the sender population, segment account counts, segment transaction counts, transaction values, transaction-volume shares and monetary-value shares. All eight Boolean reconciliation checks returned TRUE. The validated controls include 6,353,307 distinct sender identifiers, 6,362,620 transactions and total transaction value of 1,144,392,944,759.77.

## Q8. Recipient Transaction Concentration

**Business question:** Which recipient identifiers receive the highest transaction counts and monetary values, and how does recipient activity differ between customer-coded and merchant-coded identifiers?

### Recipient population and top-ten concentration

| Measure | Result |
|---|---:|
| Distinct recipient identifiers | 2,722,362 |
| Top-ten recipient transaction count | 1,024 |
| Top-ten recipient transaction value | 638,423,920.67 |
| Top-ten share of all transaction records | 0.01609% |
| Top-ten share of total transaction value | 0.05579% |

### Actual results — recipient type segment summary

| Recipient type | Distinct recipient identifiers | Transaction count | Transaction volume share | Total transaction value | Average transaction amount | Monetary value share |
|---|---:|---:|---:|---:|---:|---:|
| CUSTOMER_CODED | 571,961 | 4,211,125 | 66.1854% | 1,116,299,573,621.40 | 265,083.46 | 97.5451% |
| MERCHANT_CODED | 2,150,401 | 2,151,495 | 33.8146% | 28,093,371,138.37 | 13,057.60 | 2.4549% |
| **Total** | **2,722,362** | **6,362,620** | **100.0000%** | **1,144,392,944,759.77** | **—** | **100.0000%** |

The dataset contained zero `OTHER_UNCLASSIFIED` recipient identifiers and zero NULL recipient identifiers in this classification.

### Key findings and interpretation

1. The recipient with the highest transaction count among the top ten is `C1286084959`, with 113 incoming records.
2. `C1789550256` has the highest total received value among the top ten, at 177,885,264.60 across 99 transactions, despite ranking seventh by transaction count.
3. The top ten recipients account for approximately 0.01609% of all transaction records and 0.05579% of total transaction value.
4. Merchant-coded identifiers account for 2,150,401 distinct recipient identifiers, compared with 571,961 customer-coded identifiers.
5. Customer-coded identifiers account for 66.1854% of transaction records and 97.5451% of total transaction value, despite representing a smaller recipient-identifier population.
6. The average transaction amount for customer-coded recipients is 265,083.46, compared with 13,057.60 for merchant-coded recipients.

The top-ten concentration is small relative to the full dataset. The C/M classifications are based on recipient identifier prefixes supplied by the dataset; they are not independent verification of a real customer's or merchant's identity. The segment comparison describes how records are distributed across those identifier classes and does not establish customer or merchant behaviour, risk or business importance.

### Independent validation

The Q8 validation output confirmed recipient population totals, transaction and monetary reconciliation, top-ten ranking, recipient-segment identifier counts, segment transaction counts, segment transaction values, average amounts and both share calculations. All 16 Boolean validation checks returned TRUE. No other/unclassified or NULL recipient identifiers were found.

## Q9. Transaction Amount Distribution Analysis

**Business question:** How does the distribution of transaction amounts differ across transaction categories and fraud labels?

### Actual results — grouped by transaction category and fraud label

| Transaction type | Fraud label (`is_fraud`) | Transaction count | Total transaction value | Average amount | Median amount | Minimum amount | Maximum amount |
|---|---:|---:|---:|---:|---:|---:|---:|
| CASH_OUT | 0 | 2,233,384 | 388,423,792,980.66 | 173,917.16 | 146,946.56 | 0.01 | 2,847,566.62 |
| PAYMENT | 0 | 2,151,495 | 28,093,371,138.37 | 13,057.60 | 9,482.19 | 0.02 | 238,637.98 |
| CASH_IN | 0 | 1,399,284 | 236,367,391,912.46 | 168,920.24 | 143,427.71 | 0.04 | 1,915,267.90 |
| TRANSFER | 0 | 528,812 | 479,224,774,079.16 | 906,229.01 | 486,521.91 | 2.60 | 92,445,516.64 |
| DEBIT | 0 | 41,432 | 227,199,221.28 | 5,483.67 | 3,048.99 | 0.55 | 569,077.51 |
| CASH_OUT | 1 | 4,116 | 5,989,202,243.83 | 1,455,102.59 | 435,516.91 | 0.00 | 10,000,000.00 |
| TRANSFER | 1 | 4,097 | 6,067,213,184.01 | 1,480,891.67 | 445,705.76 | 63.80 | 10,000,000.00 |
| **Total** | **—** | **6,362,620** | **1,144,392,944,759.77** | **—** | **—** | **0.00** | **92,445,516.64** |

### Mean–Median Comparison

| Transaction type | Fraud label | Average amount | Median amount | Mean–median difference |
|---|---:|---:|---:|---:|
| CASH_OUT | 0 | 173,917.16 | 146,946.56 | 26,970.60 |
| PAYMENT | 0 | 13,057.60 | 9,482.19 | 3,575.41 |
| CASH_IN | 0 | 168,920.24 | 143,427.71 | 25,492.53 |
| TRANSFER | 0 | 906,229.01 | 486,521.91 | 419,707.10 |
| DEBIT | 0 | 5,483.67 | 3,048.99 | 2,434.68 |
| CASH_OUT | 1 | 1,455,102.59 | 435,516.91 | 1,019,585.68 |
| TRANSFER | 1 | 1,480,891.67 | 445,705.76 | 1,035,185.91 |

### Key findings and interpretation

1. CASH_OUT with fraud label 0 has the highest transaction frequency, accounting for 2,233,384 records.
2. Fraud-labelled transactions appear in two transaction categories: CASH_OUT with 4,116 records and TRANSFER with 4,097 records.
3. Fraud-labelled CASH_OUT transactions have an average amount of 1,455,102.59, compared with 173,917.16 for records labelled 0.
4. Fraud-labelled TRANSFER transactions have an average amount of 1,480,891.67, compared with 906,229.01 for records labelled 0.
5. TRANSFER with fraud label 0 has the highest median transaction amount, at 486,521.91.
6. Fraud-labelled TRANSFER transactions have the largest mean–median difference, at 1,035,185.91.
7. The maximum transaction amount occurs in TRANSFER with fraud label 0, reaching 92,445,516.64.
8. The dataset contains 8,213 fraud-labelled transactions, approximately 0.1291% of all records.
9. The dataset contains 16 zero-amount transaction records, which were retained in the primary analysis.

The mean–median differences suggest that relatively high transaction values influence the arithmetic averages in these groups. They are descriptive indicators and do not, by themselves, prove outliers or a specific distribution shape. The median provides a complementary measure of the middle observation.

These results compare amount characteristics across the dataset's simulated fraud labels. They do not establish that transaction amount alone identifies fraudulent activity or predicts real-world fraud.

### Independent validation

The Q9 validation output confirmed:

- Total transaction records: 6,362,620.
- Total transaction value: 1,144,392,944,759.77.
- Distinct transaction categories: 5.
- Distinct fraud labels: 2.
- Fraud-labelled transactions: 8,213.
- Non-fraud-labelled transactions: 6,354,407.
- Actual transaction/fraud-label groups: 7.
- Matched expected groups: 7.
- Missing or unexpected groups: 0.
- Count or monetary-value mismatches: 0.
- Average or median mismatches: 0.
- Minimum or maximum mismatches: 0.
- Zero-amount transactions: 16.
- Average and median boundary violations: 0.

All ten independent Boolean validation checks returned TRUE.

## Q10. Balance Movement Analysis

**Business question:** How do observed sender balance movements vary across transaction categories and fraud labels, and how closely do sender movements for records labelled `isFraud = 0` reconcile with category-specific expected balance changes? For recipients, how do recorded balance movements compare with transaction amounts for `isFraud = 0` TRANSFER transactions involving tracked recipient accounts?

### Analytical scope

- Actual sender movements are summarised by transaction category and fraud label.
- Expected sender movements and sender reconciliation classifications apply to records labelled `isFraud = 0`.
- Recipient reconciliation is restricted to `isFraud = 0` TRANSFER records involving tracked recipients with available opening and closing balance fields.
- Fraud-labelled transfers are not included in ordinary recipient reconciliation.
- Merchant destination balances are treated as not tracked; recipient categories outside the eligible transfer scope are not applicable.

### Sender-side reconciliation results

The diagnostic investigation found that the zero-floor formula provides a substantially better empirical match for outgoing sender balance movements than the strict `old balance - amount` expectation.

For outgoing transactions, the expected closing balance uses:

```sql
GREATEST(old_balance - amount, 0)
```

CASH_IN is evaluated separately as an expected positive sender balance movement equal to the transaction amount.

| Transaction type | Fraud label | Transaction count | Exact matches | Minor variances | Material differences | Fraud-labelled records |
|---|---:|---:|---:|---:|---:|---:|
| CASH_IN | 0 | 1,399,284 | 1,186,107 | 213,144 | 33 | 0 |
| CASH_OUT | 0 | 2,233,384 | 2,216,411 | 16,969 | 4 | 0 |
| CASH_OUT | 1 | 4,116 | — | — | — | 4,116 |
| DEBIT | 0 | 41,432 | 40,323 | 1,109 | 0 | 0 |
| PAYMENT | 0 | 2,151,495 | 2,046,967 | 104,528 | 0 | 0 |
| TRANSFER | 0 | 528,812 | 526,712 | 2,099 | 1 | 0 |
| TRANSFER | 1 | 4,097 | — | — | — | 4,097 |

The dash indicates that fraud-labelled records were reported separately and were not assigned ordinary sender reconciliation classifications.

### Additional sender diagnostics

| CASH_IN movement pattern | Transaction count | Average absolute difference |
|---|---:|---:|
| Exact credit | 1,186,107 | 0.00 |
| Partial credit | 106,690 | 0.01 |
| Credit above transaction amount | 106,454 | 0.01 |
| No balance change | 33 | 213,633.48 |

The 213,144 one-cent CASH_IN variances are small relative to the 33 records with no recorded sender balance movement. The one-cent threshold is an analytical tolerance used in this project, not a universal accounting rule.

### Recipient-side TRANSFER reconciliation

The recipient comparison evaluates 528,812 non-fraud-labelled TRANSFER records involving tracked recipient accounts.

| Recipient movement classification | Transaction count | Share of evaluated transfers |
|---|---:|---:|
| Exact match | 370,964 | 70.15% |
| Minor variance | 103,879 | 19.64% |
| Material difference | 53,969 | 10.21% |
| **Total evaluated** | **528,812** | **100.00%** |

The underlying movement patterns were:

| Observed recipient movement pattern | Transaction count |
|---|---:|
| Exact credit | 370,964 |
| Unchanged balance | 106 |
| Partial balance increase | 65,534 |
| Recipient balance decrease | 3,930 |
| Increase above expected amount | 88,278 |
| **Total evaluated** | **528,812** |

### Key findings and interpretation

1. The zero-floor outgoing sender formula matches most non-fraud-labelled CASH_OUT, DEBIT, PAYMENT and TRANSFER records.
2. PAYMENT has 104,528 minor sender variances, the largest minor-variance count among outgoing categories.
3. CASH_IN contains 213,144 one-cent variances and 33 records with no recorded sender balance movement.
4. Recipient-side reconciliation finds 157,848 records with a non-zero observed difference from the individual transfer amount, or approximately 29.85% of evaluated transfers.
5. The largest recipient movement pattern after exact credits is an increase above the individual transaction amount, with 88,278 records.
6. Repeated transactions to the same recipient within one simulation hour can produce repeated or changing balance snapshots. The hourly `step` field does not provide the exact intra-hour sequence needed to explain every transaction-level difference.
7. Merchant destination balances are not available for the same recipient-side reconciliation and are not classified as failed credits.

The results show that sender and recipient balance reconciliation require different treatments. They do not prove that a recipient failed to receive funds, that a payment failed, or that a discrepancy represents fraud or financial loss.

### Independent validation

| Validation group | Checks passed |
|---|---:|
| Transaction count checks | 7 |
| Sender classification checks | 7 |
| Recipient classification checks | 7 |
| Overall dataset control checks | 5 |
| **Total** | **26 / 26** |

All 26 independent validation checks passed for the final Q10 implementation reported in the project records.

---

## 4. Cross-Question Insights

### 4.1 Transaction frequency and monetary throughput describe different things

Q1 identifies CASH_OUT as the largest category by transaction count. Q2 and Q9 show that TRANSFER has the highest total, average and median transaction amounts among the relevant groups. The distinction also appears in the hourly analysis: Step 19 has the highest transaction count, while Step 304 has the highest total transaction amount.

**Analytical implication:** Transaction monitoring should not rely on counts alone when the objective also concerns monetary throughput. Both activity volume and transaction amount are needed to describe the dataset.

### 4.2 Counts and rates can lead to different fraud-label conclusions

CASH_OUT has the greatest number of fraud-labelled records, but TRANSFER has the higher within-category fraud-label rate. Q6 adds a second distinction: the existing flag has 100% precision but only 0.19% recall against the simulation labels. Q9 further shows that fraud-labelled CASH_OUT and TRANSFER groups have higher average transaction amounts than their corresponding label-0 groups.

**Analytical implication:** Fraud-label analysis should report counts, category-level rates, amount distributions and classification coverage separately. These observations describe relationships with simulated labels, not independently verified fraud.

### 4.3 Sender and recipient identifier distributions are not interchangeable

Q7 shows that 99.85% of sender identifiers appear once. One-time sender identifiers account for 99.7075% of transactions and 99.7021% of total transaction value. Q8 shows a different recipient pattern: merchant-coded identifiers are more numerous, while customer-coded identifiers account for 66.1854% of transaction records and 97.5451% of total transaction value.

**Analytical implication:** Originating and destination account identifiers should be analysed separately. C/M prefix groups and one-time/repeat sender groups are dataset identifier classifications; they do not by themselves establish customer engagement, retention or actual merchant behaviour.

### 4.4 Average transaction amount can hide the influence of large records

The average amount exceeds the median in all seven Q9 transaction-type/fraud-label groups. TRANSFER with fraud label 1 has the largest mean–median difference, while TRANSFER with fraud label 0 has the highest maximum amount.

**Analytical implication:** Average transaction amount should be interpreted alongside the median and, where available, percentiles or distribution visualisations. Mean–median differences alone do not prove the presence of outliers.

### 4.5 Balance reconciliation depends on transaction direction and data availability

Q10 finds that outgoing sender movements are better explained by a zero-floor calculation, while CASH_IN requires a separate positive-movement rule. Recipient balance comparisons are more difficult because multiple transfers can share a recipient and hourly simulation step.

**Analytical implication:** A single balance formula should not be applied indiscriminately to all transaction directions and recipient types. Scope exclusions and balance-snapshot limitations must be explicit.

## 5. Business-Relevant Implications

The findings support the following analytical practices for a payments-data investigation:

1. **Monitor both transaction volume and monetary value.** The largest transaction category by count may not be the largest by aggregate value.
2. **Use both raw counts and normalized rates.** A category with more labelled records may have a lower within-category rate than a smaller category.
3. **Evaluate classification coverage, not precision alone.** The Q6 result demonstrates why recall and confusion-matrix counts are necessary alongside precision.
4. **Use robust distribution summaries.** Median and percentile measures help contextualise averages when transaction amounts vary substantially.
5. **Make reconciliation scope explicit.** Sender movement, recipient movement, merchant balance availability, fraud labels and hourly snapshots require different treatment.

These are analytical implications from the supplied PaySim results, not production recommendations validated against a live payment platform.

## 6. Dataset and Analytical Limitations

- **Synthetic data:** PaySim is a simulated mobile-money dataset. Results should not be generalised directly to real UPI activity, actual banks, merchants or customers.
- **Fraud labels:** `isFraud` is the dataset's simulated label, not independently confirmed real-world fraud ground truth.
- **Fraud flag:** `isFlaggedFraud` is a separate indicator. Its precision and recall here describe agreement with the PaySim labels only.
- **Simulation time:** `step` is an hourly simulation index, not a calendar timestamp. The available export contains 743 observed steps (1–743).
- **Monetary units:** The results use the dataset's recorded amount units. They should not be labelled as INR unless the dataset documentation explicitly establishes that interpretation.
- **Revenue and profit:** Transaction amount is not equivalent to platform revenue, fee income, profit or financial benefit.
- **Account identifiers:** Sender and recipient identifiers are simulated account identifiers and should not automatically be described as individual customers or merchants.
- **Recipient balance snapshots:** Multiple transfers to the same recipient within one simulation hour can complicate transaction-level reconciliation. Exact intra-hour transaction ordering is unavailable.
- **Merchant balances:** Merchant recipient balance information is not available for direct reconciliation in the same way as tracked customer destinations.
- **Variance threshold:** The 0.01 minor-variance threshold is a project-specific analytical tolerance, not a universal accounting standard.
- **Distribution detail:** Mean, median, minimum and maximum do not fully describe a distribution. Percentiles, interquartile range and plots would provide additional detail.

## 7. Remaining Analytical Coverage Decision Before Final Publication

The Q7, Q8 and Q9 scope gaps previously identified in this document have now been addressed by additional segment-level analysis, revised query outputs and independent validation. The current recorded evidence is:

| Question | Additional analysis completed | Independent validation |
|---|---|---:|
| Q7 | One-time vs repeat sender account, transaction-volume and monetary-value contribution | 8 checks passed |
| Q8 | Customer-coded vs merchant-coded recipient comparison, alongside top-ten concentration | 16 checks passed |
| Q9 | Transaction amount distribution grouped by transaction category and fraud label | 10 checks passed |

One documentation scope item remains to be checked against the latest `research/analytical_questions.md`:

| Question | Item to verify | Current evidence in this results document | Required decision |
|---|---|---|---|
| Q3 | Whether transaction type remains an intended analytical dimension in addition to hourly trends by simulation step. | The recorded hourly output aggregates all transaction types together by `step`. | Confirm that the Q3 business question and data requirements are limited to overall hourly trends, or add a transaction-type breakdown if that dimension remains in scope. |

The Q7–Q9 additions do not invalidate their earlier results. They extend the analyses so that the documented business questions are supported by the executed outputs. Final publication should also include a consistency check that the saved analytical SQL, validation SQL, result tables and README all reflect the same final versions.

## 8. Overall Conclusion

The PaySim SQL analysis demonstrates how transaction counts, monetary amounts, simulation-step activity, fraud labels, sender and recipient identifiers, transaction amount distributions and balance movements reveal different aspects of a transaction dataset.

The strongest cross-question conclusion is that **a single metric rarely describes payment activity adequately**. Transaction frequency differs from monetary throughput; fraud-label counts differ from category-level rates; precision differs from recall; sender and recipient identifier patterns differ; and recorded balance snapshots do not always provide a direct transaction-level reconciliation.

The Q7 sender-segment analysis shows that one-time sender identifiers dominate both transaction volume and monetary value. Q8 shows that customer-coded and merchant-coded recipient identifiers have materially different transaction and value distributions. Q9 demonstrates that transaction amount characteristics differ across transaction categories and simulated fraud labels.

The project also demonstrates the importance of validating aggregate totals, reconciling category and segment counts, defining denominators, separating analytical scopes and stating the limits of synthetic data.

The revised Q7, Q8 and Q9 implementations passed 8, 16 and 10 independent validation checks respectively. The recorded Q10 implementation passed all 26 independent validation checks. Before final portfolio publication, verify the remaining Q3 scope decision, cross-check all final saved outputs against their SQL files, and update the project README to reflect the completed analysis.

---

**Phase 5 status:** Q7–Q9 scope gaps have been resolved in the recorded analysis and independently validated. The consolidated results document has been updated. Confirm the remaining Q3 documentation scope item and perform the final repository/README consistency review before treating Phase 5 as fully closed.

