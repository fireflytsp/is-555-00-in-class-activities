# Scenario 1: SaaS Customer Churn

**Dataset:** Greenfield SaaS Customer Base (Jan 2023 - Dec 2024)

**Source:** Synthetic dataset generated for this exercise. Based on realistic patterns from public SaaS case studies, but all data is simulated.

---

## Business Scenario

You are a data analyst at Greenfield SaaS, a B2B software platform serving 6,000+ enterprise and mid-market customers. The VP of Customer Success just got board pressure about rising churn and asked your team to investigate patterns and risk factors. She needs findings by end of week for a board presentation.

She mentioned three specific things she's curious about:

1. **Onboarding impact:** Is the new onboarding program (launched Q3 2024) reducing churn for newer customers?
2. **Segment risk:** Which customer segments are most at risk? Where should we focus retention efforts first?
3. **Early warning signals:** Are there early indicators we could act on before customers churn? Can we identify at-risk customers before they leave?

**Key quote from VP:** "But don't just answer my questions. Tell me what I should be asking. I want the full picture of what's driving churn, not just a narrow answer to three questions."

---

## Data Dictionary

| Column | Type | Description |
|--------|------|-------------|
| customer_id | string | Unique customer identifier |
| signup_date | date | Account creation date |
| churn_date | date | Date customer churned (null if active) |
| days_active | integer | Days from signup to churn or end of period |
| plan_tier | categorical | Pricing tier: 'starter', 'growth', 'enterprise' |
| monthly_revenue | float | Monthly recurring revenue (USD) |
| support_tickets | integer | Total support tickets submitted |
| avg_response_time_hours | float | Average support response time |
| nps_score | float | Net Promoter Score (0-10 scale, nullable) |
| onboarding_completed | boolean | Whether customer completed new onboarding flow |
| onboarding_completion_date | date | Date onboarding marked complete (nullable) |
| modules_completed | integer | Number of training modules completed |
| days_since_last_usage | integer | Days since last product feature interaction |
| billing_changes_count | integer | Number of plan/billing modifications |
| payment_failures | integer | Failed payment attempts in observation period |

---

## Important Notes

These three questions are starting points, not the full scope of your analysis. Your EDA specification should identify deeper questions and relationships worth investigating. Think critically about what patterns might indicate churn risk and what the VP should actually be asking to make better decisions.

