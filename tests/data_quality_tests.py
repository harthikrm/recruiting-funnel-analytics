# Test 1 — No duplicate applications
def test_no_duplicate_applications(df):
    assert df.duplicated(subset=['candidate_id', 'job_id']).sum() == 0

# Test 2 — No null candidate IDs
def test_no_null_candidates(df):
    assert df['candidate_id'].isnull().sum() == 0

# Test 3 — Stage order is valid
def test_valid_stage_order(df):
    assert (df['stage_order'] >= 0).all()

# Test 4 — No negative time-to-hire
def test_no_negative_duration(df):
    assert (df['days_in_stage'] >= 0).all()

# Test 5 — Offer acceptance rate is between 0 and 1
def test_offer_acceptance_rate(df):
    rate = df[df['stage'] == 'Offer']['accepted'].mean()
    assert 0 <= rate <= 1
