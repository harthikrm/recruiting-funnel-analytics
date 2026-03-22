import pytest
import pandas as pd
import os

@pytest.fixture
def clean_apps():
    # The application_lifecycle.csv is the processed clean version representing the funnel
    path = os.path.join(os.path.dirname(__file__), '../data/processed/application_lifecycle.csv')
    return pd.read_csv(path)

@pytest.fixture
def kpis():
    path = os.path.join(os.path.dirname(__file__), '../data/processed/recruiting_kpis_weekly.csv')
    return pd.read_csv(path)

# Test 1 — No duplicate applications in processed layer
def test_no_duplicate_applications(clean_apps):
    assert clean_apps.duplicated(subset=['application_id']).sum() == 0

# Test 2 — No null candidate IDs
def test_no_null_candidates(clean_apps):
    assert clean_apps['candidate_id'].isnull().sum() == 0

# Test 3 — Stage chronological order is valid 
def test_valid_stage_order(clean_apps):
    # applied_at should be <= screen_at if screened
    clean_apps['applied_at'] = pd.to_datetime(clean_apps['applied_at'])
    clean_apps['screen_at'] = pd.to_datetime(clean_apps['screen_at'])
    mask = clean_apps['screen_at'].notnull()
    assert (clean_apps.loc[mask, 'screen_at'] >= clean_apps.loc[mask, 'applied_at']).all()

# Test 4 — No negative time-to-hire
def test_no_negative_duration(clean_apps):
    clean_apps['applied_at'] = pd.to_datetime(clean_apps['applied_at'])
    clean_apps['hired_at'] = pd.to_datetime(clean_apps['hired_at'])
    mask = clean_apps['hired_at'].notnull()
    duration = (clean_apps.loc[mask, 'hired_at'] - clean_apps.loc[mask, 'applied_at']).dt.days
    assert (duration >= 0).all()

# Test 5 — Offer acceptance rate is always valid percentage
def test_offer_acceptance_rate(kpis):
    assert (kpis['offer_accept_rate'] >= 0).all()
    assert (kpis['offer_accept_rate'] <= 1).all()
