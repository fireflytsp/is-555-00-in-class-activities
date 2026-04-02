"""
Generate synthetic datasets for EDA specification exercises.
Two datasets with embedded analytical challenges (Simpson's paradox, confounding, etc.)
"""

import numpy as np
import pandas as pd
from datetime import datetime, timedelta

np.random.seed(42)

# =============================================================================
# DATASET 1: GREENFIELD SAAS CHURN
# =============================================================================

print("Generating SaaS Churn dataset...")

n_customers = 8000
start_date = datetime(2022, 1, 1)
end_date = datetime(2024, 1, 1)

customer_data = []

for cust_id in range(1, n_customers + 1):
    # Signup date over 2 years
    days_offset = np.random.randint(0, (end_date - start_date).days)
    signup_date = start_date + timedelta(days=days_offset)

    # Plan tier distribution (enterprise less common)
    plan_tier = np.random.choice(
        ['free', 'starter', 'professional', 'enterprise'],
        p=[0.30, 0.40, 0.20, 0.10]
    )

    # Team size varies by plan
    if plan_tier == 'free':
        team_size = np.random.randint(1, 6)
    elif plan_tier == 'starter':
        team_size = np.random.randint(2, 15)
    elif plan_tier == 'professional':
        team_size = np.random.randint(5, 50)
    else:  # enterprise
        team_size = np.random.randint(20, 200)

    # Monthly usage hours (correlated with team size)
    base_usage = team_size * np.random.uniform(5, 15)
    monthly_usage_hours = np.random.normal(base_usage, base_usage * 0.3)
    monthly_usage_hours = max(0, monthly_usage_hours)

    # Industry
    industry = np.random.choice(
        ['tech', 'healthcare', 'finance', 'education', 'retail'],
        p=[0.30, 0.20, 0.20, 0.15, 0.15]
    )

    # Onboarding completed (higher for paid plans)
    if plan_tier == 'free':
        onboarding_completed = np.random.choice([True, False], p=[0.50, 0.50])
    else:
        onboarding_completed = np.random.choice([True, False], p=[0.85, 0.15])

    # ENGINEERING AHA #2: Onboarding effect is much stronger for starter/professional
    # Define churn base rate
    if plan_tier == 'free':
        base_churn_rate = 0.45
    elif plan_tier == 'starter':
        base_churn_rate = 0.30
    elif plan_tier == 'professional':
        base_churn_rate = 0.20
    else:  # enterprise
        base_churn_rate = 0.08

    # Onboarding reduces churn for starter/professional, not enterprise
    if not onboarding_completed:
        if plan_tier in ['starter', 'professional']:
            churn_prob = base_churn_rate * 1.4  # Big penalty
        elif plan_tier == 'enterprise':
            churn_prob = base_churn_rate * 1.1  # Minor, they get dedicated onboarding
        else:
            churn_prob = base_churn_rate * 1.3
    else:
        if plan_tier in ['starter', 'professional']:
            churn_prob = base_churn_rate * 0.6  # Big help
        elif plan_tier == 'enterprise':
            churn_prob = base_churn_rate * 0.95  # Almost no effect
        else:
            churn_prob = base_churn_rate * 0.9

    # ENGINEERING AHA #1: Simpson's paradox with support tickets
    # Overall: more tickets = higher churn
    # But within enterprise: more tickets = lower churn (they're engaged)

    if plan_tier == 'enterprise':
        # Enterprise with high support engagement are loyal
        support_base = np.random.normal(15, 4)
        support_tickets_last_90d = max(0, int(support_base))
        support_effect = 1.0 - (support_tickets_last_90d * 0.02)  # More tickets = LESS churn
    else:
        # For others, support tickets indicate struggle
        support_base = np.random.normal(5, 3)
        support_tickets_last_90d = max(0, int(support_base))
        support_effect = 1.0 + (support_tickets_last_90d * 0.04)  # More tickets = MORE churn

    churn_prob = churn_prob * support_effect
    churn_prob = np.clip(churn_prob, 0.01, 0.95)

    # ENGINEERING AHA #3: Temporal pattern - churn spikes at months 3 and 12
    days_since_signup = (datetime(2024, 1, 1) - signup_date).days
    months_since_signup = days_since_signup / 30.0

    if months_since_signup > 1:  # Only for customers with enough tenure
        month_of_tenure = int(months_since_signup) % 12
        if month_of_tenure in [3, 12]:  # Months 3 and 12
            churn_prob *= 2.5
        elif month_of_tenure in [2, 11]:
            churn_prob *= 1.8
        churn_prob = np.clip(churn_prob, 0.01, 0.95)
    else:
        churn_prob *= 0.3  # Very new customers unlikely to churn yet

    churned = np.random.rand() < churn_prob

    if churned:
        # Churn occurs within the customer's tenure
        days_tenure = (datetime(2024, 1, 1) - signup_date).days
        days_to_churn = np.random.randint(30, max(31, days_tenure))
    else:
        days_to_churn = np.nan

    # NPS score - ENGINEERING AHA #4: Missing not at random
    # Churned customers are less likely to provide NPS
    if churned:
        missing_prob = 0.40  # 40% of churned customers have missing NPS
    else:
        missing_prob = 0.08  # Only 8% of active customers have missing NPS

    if np.random.rand() < missing_prob:
        nps_score = np.nan
    else:
        # NPS correlated with churn likelihood
        if churned:
            nps_score = np.random.randint(0, 40)  # Low scores
        else:
            nps_score = np.random.randint(30, 100)  # Higher scores

    customer_data.append({
        'customer_id': cust_id,
        'signup_date': signup_date.strftime('%Y-%m-%d'),
        'plan_tier': plan_tier,
        'monthly_usage_hours': round(monthly_usage_hours, 2),
        'support_tickets_last_90d': support_tickets_last_90d,
        'team_size': team_size,
        'industry': industry,
        'nps_score': nps_score if pd.isna(nps_score) else int(nps_score),
        'onboarding_completed': onboarding_completed,
        'churned': churned,
        'days_to_churn': days_to_churn if not pd.isna(days_to_churn) else None
    })

df_churn = pd.DataFrame(customer_data)

# Save to CSV
churn_path = '/sessions/nice-bold-cori/mnt/data-science-portfolio-day/materials/data/saas_churn.csv'
df_churn.to_csv(churn_path, index=False)

print(f"SaaS Churn dataset created: {churn_path}")
print(f"Shape: {df_churn.shape}")
print(f"Churn rate: {df_churn['churned'].mean():.2%}")
print(f"NPS missing rate: {df_churn['nps_score'].isna().mean():.2%}")
print(f"NPS missing rate for churned: {df_churn[df_churn['churned']]['nps_score'].isna().mean():.2%}")
print()

# =============================================================================
# DATASET 2: METRO TRANSIT RIDERSHIP
# =============================================================================

print("Generating Metro Transit Ridership dataset...")

# Define 15 stations with characteristics
stations = {
    'STN001': {'name': 'Downtown Hub', 'zone': 1, 'type': 'downtown', 'base_ridership': 8000},
    'STN002': {'name': 'Central Terminal', 'zone': 1, 'type': 'downtown', 'base_ridership': 7500},
    'STN003': {'name': 'Financial District', 'zone': 1, 'type': 'downtown', 'base_ridership': 6500},
    'STN004': {'name': 'University North', 'zone': 2, 'type': 'university', 'base_ridership': 4500},
    'STN005': {'name': 'University South', 'zone': 2, 'type': 'university', 'base_ridership': 4200},
    'STN006': {'name': 'Midtown Plaza', 'zone': 2, 'type': 'mixed', 'base_ridership': 5000},
    'STN007': {'name': 'Harbor Station', 'zone': 2, 'type': 'mixed', 'base_ridership': 4800},
    'STN008': {'name': 'Tech Park', 'zone': 2, 'type': 'mixed', 'base_ridership': 5200},
    'STN009': {'name': 'Airport West', 'zone': 3, 'type': 'industrial', 'base_ridership': 2800},
    'STN010': {'name': 'Logistics Hub', 'zone': 3, 'type': 'industrial', 'base_ridership': 2500},
    'STN011': {'name': 'Industrial Park', 'zone': 3, 'type': 'industrial', 'base_ridership': 2300},
    'STN012': {'name': 'Riverside', 'zone': 2, 'type': 'mixed', 'base_ridership': 4600},
    'STN013': {'name': 'Market Street', 'zone': 1, 'type': 'downtown', 'base_ridership': 7000},
    'STN014': {'name': 'Arts District', 'zone': 2, 'type': 'mixed', 'base_ridership': 3800},
    'STN015': {'name': 'Waterfront', 'zone': 2, 'type': 'mixed', 'base_ridership': 4000},
}

transit_data = []

# Generate 2 years of daily data (730 days)
start_date = datetime(2022, 1, 1)
end_date = datetime(2024, 1, 1)
current_date = start_date

# Pre-generate weather patterns
dates_list = []
weather_data = {}
temp_trend = []
date_iter = start_date
while date_iter < end_date:
    dates_list.append(date_iter)
    date_iter += timedelta(days=1)

# Seasonal temperature pattern
for i, date in enumerate(dates_list):
    day_of_year = date.timetuple().tm_yday
    seasonal_temp = 55 + 25 * np.sin(2 * np.pi * day_of_year / 365.0)
    temp_noise = np.random.normal(0, 8)
    temp = seasonal_temp + temp_noise
    weather_data[date] = {
        'temp': np.clip(temp, -10, 100),
        'precip': max(0, np.random.exponential(0.05))
    }

for station_id, station_info in stations.items():
    current_date = start_date

    while current_date < end_date:
        date_str = current_date.strftime('%Y-%m-%d')
        day_of_week = current_date.strftime('%A')
        is_holiday = current_date.month == 12 and 24 <= current_date.day <= 25 or \
                     current_date.month == 1 and current_date.day == 1 or \
                     current_date.month == 7 and current_date.day == 4

        # Base ridership
        base = station_info['base_ridership']

        # Day-of-week effect
        if day_of_week == 'Saturday':
            dow_mult = 0.6 if station_info['type'] != 'industrial' else 0.3
        elif day_of_week == 'Sunday':
            dow_mult = 0.5 if station_info['type'] != 'industrial' else 0.25
        else:  # Weekday
            dow_mult = 1.0 if station_info['type'] != 'industrial' else 1.3

        # ENGINEERING AHA #1: Confounding - University stations have summer drop
        # due to academic calendar, not temperature
        if station_info['type'] == 'university':
            month = current_date.month
            if month in [6, 7, 8]:  # Summer break
                academic_mult = 0.4
            else:
                academic_mult = 1.0
        else:
            academic_mult = 1.0

        # Temperature effect (small in reality)
        temp = weather_data[current_date]['temp']
        temp_mult = 1.0 - (abs(temp - 70) / 100) * 0.15  # Ideal temp around 70F

        # Precipitation
        precip = weather_data[current_date]['precip']
        precip_mult = 1.0 - np.clip(precip * 0.3, 0, 0.3)

        # Holiday effect
        holiday_mult = 0.6 if is_holiday else 1.0

        # ENGINEERING AHA #2: Industrial zone stations have different patterns
        # (weekday heavy, no weekend traffic)
        if station_info['type'] == 'industrial':
            if day_of_week in ['Saturday', 'Sunday']:
                industrial_mult = 0.15
            else:
                industrial_mult = 1.3
        else:
            industrial_mult = 1.0

        # ENGINEERING AHA #4: Construction effect varies by zone
        # Construction reduces zone 1 (downtown) by ~25%, no effect zone 3
        construction_nearby = np.random.rand() < 0.15  # 15% of days have construction
        if construction_nearby:
            if station_info['zone'] == 1:
                construction_mult = 0.75
            elif station_info['zone'] == 3:
                construction_mult = 1.0  # No alternatives, captive riders
            else:
                construction_mult = 0.90
        else:
            construction_mult = 1.0

        # ENGINEERING AHA #3: Nearby events - effect strongest NEXT day
        nearby_events_today = np.random.poisson(0.3)  # Average 0.3 events per day

        # Check yesterday for event lag effect
        yesterday = current_date - timedelta(days=1)
        if yesterday in weather_data:
            # We'll track this separately; for now, add random component
            yesterday_events = np.random.poisson(0.3)
            event_mult = 1.0 + (yesterday_events * 0.08)  # Effect from yesterday
        else:
            event_mult = 1.0 + (nearby_events_today * 0.03)  # Weak same-day effect

        # Calculate ridership
        ridership = base * dow_mult * academic_mult * temp_mult * precip_mult * \
                    holiday_mult * industrial_mult * construction_mult * event_mult

        # Add noise
        ridership = int(ridership * np.random.normal(1.0, 0.08))
        ridership = max(10, ridership)  # Floor at 10

        transit_data.append({
            'date': date_str,
            'station_id': station_id,
            'station_name': station_info['name'],
            'daily_riders': ridership,
            'avg_temp_f': round(weather_data[current_date]['temp'], 1),
            'precipitation_inches': round(weather_data[current_date]['precip'], 2),
            'is_holiday': is_holiday,
            'day_of_week': day_of_week,
            'nearby_events': nearby_events_today,
            'construction_nearby': construction_nearby,
            'fare_zone': station_info['zone']
        })

        current_date += timedelta(days=1)

df_transit = pd.DataFrame(transit_data)

# Save to CSV
transit_path = '/sessions/nice-bold-cori/mnt/data-science-portfolio-day/materials/data/transit_ridership.csv'
df_transit.to_csv(transit_path, index=False)

print(f"Transit Ridership dataset created: {transit_path}")
print(f"Shape: {df_transit.shape}")
print(f"Date range: {df_transit['date'].min()} to {df_transit['date'].max()}")
print(f"Stations: {df_transit['station_id'].nunique()}")
print(f"Average daily riders: {df_transit['daily_riders'].mean():.0f}")
print()

# Summary statistics
print("=" * 70)
print("SUMMARY STATISTICS")
print("=" * 70)
print("\nSaaS Churn Dataset:")
print(df_churn.head())
print(f"\nChurned customers by plan tier:")
print(df_churn.groupby('plan_tier')['churned'].agg(['sum', 'count', 'mean']))
print(f"\nSupport tickets by plan tier (churned vs active):")
print(df_churn.groupby(['plan_tier', 'churned'])['support_tickets_last_90d'].mean().unstack())

print("\n" + "=" * 70)
print("\nTransit Ridership Dataset:")
print(df_transit.head())
print(f"\nDaily riders by station type:")
station_types = {v['name']: v['type'] for v in stations.values()}
df_transit['station_type'] = df_transit['station_name'].map({v['name']: v['type'] for v in stations.values()})
print(df_transit.groupby('station_type')['daily_riders'].agg(['mean', 'std', 'min', 'max']))
print(f"\nWeekday vs Weekend ridership:")
df_transit['is_weekend'] = df_transit['day_of_week'].isin(['Saturday', 'Sunday'])
print(df_transit.groupby('is_weekend')['daily_riders'].mean())
