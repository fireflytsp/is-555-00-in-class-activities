# EDA Specification Example: SaaS Churn Analysis

This example shows the **two-pass workflow** in action. Pass 1 (Prep Mode) is the specification itself, where you seed the conversation with your domain knowledge. Pass 2 (Challenge Mode) comes after initial results, where you use the AI to stress-test your findings.

**Dataset:** Greenfield SaaS Customer Base (Jan 2023 - Dec 2024)

**Team:** Example Team

**Date:** March 2026

---

## CONTEXT

We are analyzing 6,000+ customer records from Greenfield SaaS to understand patterns in customer churn. The VP of Customer Success is preparing for a board presentation and needs to explain rising churn rates and identify actionable risk factors. This analysis will inform resource allocation for retention initiatives, potential product changes, and customer success priorities. The board expects both pattern identification and forward-looking insights on which customers are most at risk.

---

## SCOPE

**High priority variables:**
- Churn outcome (dependent variable)
- Days active (tenure)
- Plan tier (indicates customer segment)
- Monthly recurring revenue (MRR)
- Support engagement (ticket count, response time)
- NPS score (customer satisfaction proxy)
- Onboarding completion date and modules completed
- Days since last product feature usage
- Billing changes in past 6 months

**Relationships to investigate first:**
- Support engagement vs. churn by plan tier (does support impact differ for SMB vs. enterprise?)
- Tenure vs. churn (are there specific risk windows, e.g., 6-12 months post-signup?)
- NPS score vs. churn (how predictive is satisfaction data?)
- Onboarding completion vs. churn (is the new program reducing churn for 2024 cohorts?)
- Billing volatility (downgrades, payment failures) vs. churn risk

**Explicitly out of scope:**
- Detailed feature adoption analysis (requires separate instrumentation)
- Competitive intelligence or market factors
- Pricing optimization (separate from churn drivers)
- Long-term forecasting beyond 6 months
- Analysis of accounts created before Jan 2023 (insufficient historical data)

---

## STANDARDS

**Missing data handling:**
- NPS scores are missing for ~12% of customers (often early churn, no survey). Do NOT drop these rows. Flag missing NPS separately and investigate whether missingness is associated with churn (may be early exit signal).
- Support ticket count: Treat zero as actual value, not missing. Lack of engagement is meaningful.
- Days since last feature usage: If null, mark as "never used" category and investigate separately.
- Billing history: Assume "no changes recorded" means stable, no missing imputation needed.

**Outlier treatment:**
- MRR: Retain extreme values (large deals and SMB accounts both legitimate). Visualize separately by plan tier. Do not remove.
- Tenure: No outliers to remove; early churn is the outcome we care about.
- Support tickets: A customer with 200+ tickets in 30 days may indicate a problem or very high engagement. Flag separately in analysis but retain; investigate whether this predicts churn.
- NPS: Values outside 0-10 are data entry errors; impute with null and treat as missing.

**Statistical validation:**
- Compare churn rates between groups using chi-squared tests (categorical vs. binary outcome). Report p-values.
- For continuous predictors (tenure, MRR, NPS), use logistic regression to estimate odds ratios. 95% confidence intervals required.
- For support engagement analysis by plan tier, use interaction tests to verify slope differences are significant.
- Missing data analysis: Conduct separate logistic regression on missingness indicator to test whether missing NPS is associated with churn (one example of deeper investigation).

---

## FORMAT

**Expected visualizations:**
1. Churn rate over time (line chart by month and cohort) to establish baseline trend
2. Churn by tenure (cumulative survival curve and bar chart by 6-month windows)
3. Churn by plan tier (grouped bar chart with counts and percentages)
4. Support engagement vs. churn scatter plot (separate colors/facets by plan tier)
5. NPS distribution split by churned vs. retained customers (overlaid histograms or violin plot)
6. Onboarding completion rates for 2024 cohort vs. earlier cohorts (side-by-side bar chart)

**How findings should be structured:**
- Executive summary: 2-3 key findings with concrete numbers (e.g., "SMB customers have 3.2x higher churn than enterprise; tenure window 6-12 months is highest risk period")
- Detailed findings section: One subsection per key discovery, including visualization, statistical test result, and interpretation
- Caveats and limitations: Explicitly state what we cannot conclude from this data
- Recommended next steps: Specific follow-up analyses or data collection needs

**Output format:**
- Jupyter notebook with executable code, markdown narrative, and embedded plots
- Single-page summary slide for board presentation (infographic style, no raw tables)
- CSV export of high-risk customer IDs for follow-up by customer success team

---

## GUARDRAILS

**Assumptions to avoid:**
- Do NOT assume correlation implies causation. For example, high support ticket count may indicate engaged customers OR customers in distress. This requires human judgment to untangle.
- Do NOT assume missing NPS data is random. It is likely concentrated in early churners and represents a signal, not noise.
- Do NOT generalize findings from 2023 data to 2024 (product and market conditions changed; cohort comparison required).
- Do NOT assume support response time from ticket-level data; we only have counts. Interpretation should be cautious.

**Domain-specific pitfalls:**
- SaaS churn is heavily influenced by economic conditions and customer budget cycles (Q4 and Q1 historically volatile). Any month-to-month comparison needs seasonal context.
- Onboarding program was launched in Q3 2024; early cohorts (<6 months tenure) are still in "honeymoon" period. Do not yet draw conclusions about long-term effectiveness.
- Plan tier is not a proxy for customer size or importance. Small monthly recurring revenue can be high-touch (high support needs) or high-risk.

**Findings requiring human review:**
- Any claim about causality (e.g., "support reduces churn"). We can only establish correlation.
- Identification of customers in high-risk segments for targeted retention. Customer success leader must validate these segments match their intuition before outreach.
- Conclusions about the onboarding program effectiveness. VP of Product and onboarding team should review before rolling out.
- Recommendations to deprioritize or reduce service to low-tenure cohorts based on churn rates (risk of self-fulfilling prophecy).

---

## PASS 2: CHALLENGE MODE

After the AI agent returns initial findings, use these prompts to stress-test the results. This is where you shift from Partnership to Agency, actively challenging the output rather than accepting it.

**Alternative explanations:**
- "The analysis shows higher churn in the starter tier. What alternative explanations could account for this besides plan quality? Could it be selection bias in who signs up for starter plans?"
- "NPS appears to predict churn. But could the causal direction be reversed, where customers who have already decided to leave give lower NPS scores?"

**Hidden risks:**
- "Are there Simpson's paradox risks in the tenure analysis? Could the overall trend mask opposite patterns within plan tiers?"
- "The onboarding program looks effective for 2024 cohorts. What confounds could explain this besides the program itself?"

**Completeness check:**
- "What patterns in this data did you not investigate that could be important for the VP's board presentation?"
- "Are there interaction effects between variables that a single-variable analysis would miss?"

**The test:** After this pass, close the AI chat. Can you explain every finding, its limitations, and why you trust (or do not trust) it? If not, you have recognized the output without truly comprehending it.

