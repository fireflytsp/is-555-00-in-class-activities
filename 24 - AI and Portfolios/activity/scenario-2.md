# Scenario 2: Metro Transit Ridership

**Dataset:** Metro Transit Authority Ridership (2019 - Present)

**Source:** Synthetic dataset generated for this exercise. Based on patterns from public transit data and case studies, but all data is simulated.

---

## Business Scenario

You are a data analyst at Metro Transit Authority. The planning director is preparing a budget request to secure funding for service expansion and infrastructure improvements. She needs to understand ridership patterns to justify new investments and make the case to city council and transit board members.

She is curious about three things:

1. **What drives ridership fluctuations:** Are ridership changes driven by seasonality, economic conditions, special events, or something else? What patterns repeat?
2. **Construction impact:** Several ongoing construction projects have reduced service on key corridors. Are these projects hurting ridership in measurable ways? How much is temporary vs. long-term impact?
3. **Station equity:** Which stations are underserved relative to demand? Which could benefit most from increased service investment?

**Key quote from planning director:** "I need the story the data tells, not just charts. I'm going to walk into a council meeting and say, 'Here's why we need this funding.' Help me tell that story with confidence."

---

## Data Dictionary

| Column | Type | Description |
|--------|------|-------------|
| station_id | string | Unique station identifier |
| station_name | string | Station name and line |
| service_line | categorical | Which transit line ('Red', 'Blue', 'Green', 'Orange') |
| date | date | Date of ridership observation |
| day_of_week | categorical | Day of week (Monday through Sunday) |
| is_holiday | boolean | Whether date is a recognized holiday or school break |
| total_entries | integer | Total passenger entries at station |
| total_exits | integer | Total passenger exits at station |
| peak_period_entries | integer | Entries during peak hours (7-9am, 5-7pm) |
| off_peak_entries | integer | Entries during off-peak hours |
| weather_condition | categorical | Weather: 'clear', 'rainy', 'snow', 'extreme' |
| temperature_fahrenheit | float | Average daily temperature |
| construction_active | boolean | Whether construction was active at this station |
| construction_type | categorical | Type of project: 'track_work', 'platform_upgrade', 'accessibility', 'other' |
| construction_start_date | date | When construction began (nullable) |
| construction_end_date | date | When construction ended (nullable) |
| service_changes | categorical | Major service changes: 'reduced_service', 'rerouted', 'increased_service', 'none' |
| special_event | string | Major event nearby: sports, concert, festival, etc. (nullable) |
| unemployment_rate | float | City unemployment rate in the month |
| gas_price_avg | float | Average gas price (USD per gallon) in the month |

---

## Important Notes

These three questions are starting points, not the full scope of your analysis. Your EDA specification should dig deeper into what patterns matter and how to tell a compelling, evidence-based story for the budget request. Think about what the council will ask and what data you need to answer credibly.

