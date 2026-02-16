---
name: python-testing-standards
description: Enforce rigorous Python testing standards including meaningful assertions, minimum 75% code coverage, proper test isolation, edge case handling, and prevention of always-passing tests. Use when writing, reviewing, or improving Python test suites to ensure tests actually validate correctness rather than providing false confidence.
---

# Python Testing Standards

This skill ensures Python tests are rigorous, meaningful, and provide real confidence in code correctness. Apply these standards when writing or reviewing test code.

## Core Principles

**Tests must fail when code is broken.** A test that never fails provides false confidence and is worse than no test at all.

**Coverage without assertions is worthless.** Running code doesn't mean testing it. Every test must make meaningful assertions about behavior.

**Test the contract, not the implementation.** Tests should verify what the code does, not how it does it.

## Coverage Requirements

**Minimum 75% line coverage** is required for all production code. Measure using `pytest-cov`:

```bash
pytest --cov=myapp --cov-report=html --cov-report=term-missing
```

**Coverage targets by component:**
- Business logic: 90%+
- Data transformations: 85%+
- API endpoints: 80%+
- Utilities: 75%+
- UI/presentation layer: 60%+ (acceptable to be lower)

**What to exclude from coverage:**
- `if __name__ == "__main__":` blocks
- Defensive assertions that should never execute
- Deprecated code pending removal
- Third-party code

Configure in `pyproject.toml`:
```toml
[tool.coverage.run]
omit = [
    "*/tests/*",
    "*/migrations/*",
    "*/venv/*",
    "*/__main__.py"
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "if TYPE_CHECKING:",
    "class .*\\bProtocol\\):",
    "@(abc\\.)?abstractmethod"
]
```

## Avoiding Superfluous Tests

**Red flags for worthless tests:**

### 1. Always-Passing Tests

**BAD - Test passes even when code is broken:**
```python
def calculate_total(items: List[float]) -> float:
    """Sum a list of numbers."""
    return sum(items)

# WORTHLESS TEST - No assertion
def test_calculate_total():
    result = calculate_total([1.0, 2.0, 3.0])
    # Test passes whether result is 6.0, 0.0, or anything else!
```

**GOOD - Test actually validates behavior:**
```python
def test_calculate_total():
    result = calculate_total([1.0, 2.0, 3.0])
    assert result == 6.0, f"Expected 6.0, got {result}"
```

### 2. Tautological Tests

**BAD - Test just repeats the implementation:**
```python
def calculate_discount(price: float, pct: float) -> float:
    return price * (1 - pct)

# WORTHLESS - Just re-implements the function
def test_calculate_discount():
    price, pct = 100.0, 0.2
    expected = price * (1 - pct)  # Same logic as function!
    assert calculate_discount(price, pct) == expected
```

**GOOD - Test uses independent calculation:**
```python
def test_calculate_discount():
    # Clear business case: 20% off $100 is $80
    assert calculate_discount(100.0, 0.2) == 80.0
    
    # Edge case: 0% discount
    assert calculate_discount(100.0, 0.0) == 100.0
    
    # Edge case: 100% discount
    assert calculate_discount(100.0, 1.0) == 0.0
```

### 3. Tests Without Assertions

**BAD - Code runs but nothing is verified:**
```python
def test_process_data():
    data = pd.DataFrame({"value": [1, 2, 3]})
    result = process_data(data)
    # No assertion - test passes as long as no exception raised!
```

**GOOD - Verify the actual results:**
```python
def test_process_data():
    data = pd.DataFrame({"value": [1, 2, 3]})
    result = process_data(data)
    
    assert len(result) == 3, "Should preserve row count"
    assert "processed_value" in result.columns, "Should add processed column"
    assert result["processed_value"].sum() == 6, "Should double the values"
```

### 4. Overly Permissive Assertions

**BAD - Assertion is too weak to catch bugs:**
```python
def test_calculate_returns():
    returns = calculate_returns(prices)
    assert len(returns) > 0  # Way too weak!
    assert returns is not None  # Meaningless
    assert isinstance(returns, pd.Series)  # Type only, not correctness
```

**GOOD - Strong, specific assertions:**
```python
def test_calculate_returns():
    prices = pd.Series([100, 110, 105, 120])
    returns = calculate_returns(prices)
    
    # Verify specific values
    expected = pd.Series([0.10, -0.0455, 0.1429], index=prices.index[1:])
    pd.testing.assert_series_equal(returns, expected, atol=1e-4)
```

### 5. Mocking Everything

**BAD - Mocking obscures actual behavior:**
```python
@patch('myapp.calculate_risk')
@patch('myapp.get_prices')
def test_portfolio_value(mock_prices, mock_risk):
    mock_prices.return_value = pd.Series([100, 200])
    mock_risk.return_value = 0.15
    
    # This doesn't test anything real!
    result = calculate_portfolio_value()
    assert result > 0
```

**GOOD - Test real code paths with minimal mocking:**
```python
def test_portfolio_value():
    # Use real data and real functions
    prices = pd.Series([100, 200], index=['AAPL', 'GOOGL'])
    weights = pd.Series([0.6, 0.4], index=['AAPL', 'GOOGL'])
    
    result = calculate_portfolio_value(prices, weights)
    
    # Real calculation: 0.6 * 100 + 0.4 * 200 = 140
    assert result == 140.0
```

## Test Structure and Organization

**File naming:** `test_*.py` or `*_test.py`. Mirror source structure:
```
myapp/
├── portfolio.py
├── risk.py
tests/
├── test_portfolio.py
├── test_risk.py
```

**Test function naming:** Use `test_<function>_<scenario>` pattern:
```python
def test_calculate_var_with_insufficient_data_raises_error():
    """Test that VaR calculation raises error with too few data points."""
    pass

def test_calculate_var_parametric_method_returns_expected_value():
    """Test parametric VaR with known distribution."""
    pass

def test_calculate_var_historical_method_handles_extreme_outliers():
    """Test historical VaR with fat-tailed distribution."""
    pass
```

**Docstrings:** Every test needs a docstring explaining what it verifies:
```python
def test_portfolio_rebalance_maintains_target_weights():
    """Verify portfolio rebalancing adjusts positions to target weights.
    
    Given a portfolio that has drifted from target weights due to price
    changes, rebalancing should generate trades that restore the target
    allocation within tolerance.
    """
    pass
```

## Comprehensive Test Coverage

**Test these scenarios for every function:**

### 1. Happy Path
```python
def test_parse_trade_file_valid_input():
    """Test parsing well-formed trade file returns correct DataFrame."""
    file_content = "AAPL,100,150.25\nGOOGL,50,2800.50"
    
    result = parse_trade_file(file_content)
    
    assert len(result) == 2
    assert result.loc[0, "symbol"] == "AAPL"
    assert result.loc[0, "quantity"] == 100
    assert result.loc[0, "price"] == 150.25
```

### 2. Edge Cases
```python
def test_calculate_returns_empty_series():
    """Test returns calculation with empty price series."""
    prices = pd.Series([], dtype=float)
    returns = calculate_returns(prices)
    assert len(returns) == 0

def test_calculate_returns_single_price():
    """Test returns calculation with single price point."""
    prices = pd.Series([100.0])
    returns = calculate_returns(prices)
    assert len(returns) == 0  # Can't calculate returns from one price

def test_calculate_returns_identical_prices():
    """Test returns when all prices are the same."""
    prices = pd.Series([100.0, 100.0, 100.0])
    returns = calculate_returns(prices)
    assert (returns == 0.0).all()
```

### 3. Error Conditions
```python
def test_optimize_portfolio_infeasible_constraints():
    """Test portfolio optimization raises error when no solution exists."""
    returns = pd.DataFrame(...)
    
    # Impossible constraint: target 20% return with 0% risk
    with pytest.raises(OptimizationError) as exc_info:
        optimize_portfolio(returns, target_return=0.20, max_risk=0.0)
    
    assert "infeasible" in str(exc_info.value).lower()
    assert "constraints" in str(exc_info.value).lower()
```

### 4. Boundary Values
```python
def test_calculate_discount_boundary_values():
    """Test discount calculation at boundaries."""
    # Zero discount
    assert calculate_discount(100.0, 0.0) == 100.0
    
    # 100% discount
    assert calculate_discount(100.0, 1.0) == 0.0
    
    # Zero price
    assert calculate_discount(0.0, 0.5) == 0.0
    
    # Negative discount should raise
    with pytest.raises(ValueError):
        calculate_discount(100.0, -0.1)
    
    # > 100% discount should raise
    with pytest.raises(ValueError):
        calculate_discount(100.0, 1.1)
```

### 5. Type Validation
```python
def test_calculate_var_invalid_types():
    """Test VaR calculation rejects invalid input types."""
    with pytest.raises(TypeError):
        calculate_var("not a series")
    
    with pytest.raises(TypeError):
        calculate_var(pd.Series([1, 2, 3]), confidence="not a float")
```

## Assertion Best Practices

**Use specific assertion methods:**

```python
# pytest assertions
assert result == expected  # Basic equality
assert result != bad_value  # Inequality
assert result > threshold  # Comparison
assert result in valid_values  # Membership
assert callable(result)  # Callable check

# pytest.raises for exceptions
with pytest.raises(ValueError) as exc_info:
    risky_function()
assert "expected message" in str(exc_info.value)

# pytest.approx for floating point
assert result == pytest.approx(3.14159, rel=1e-5)

# pandas testing utilities
pd.testing.assert_frame_equal(result, expected, check_dtype=False)
pd.testing.assert_series_equal(result, expected, atol=1e-6)

# numpy testing utilities
np.testing.assert_array_equal(result, expected)
np.testing.assert_array_almost_equal(result, expected, decimal=4)
```

**Always include failure messages:**
```python
# BAD - No context when assertion fails
assert len(result) == 10

# GOOD - Clear context for debugging
assert len(result) == 10, (
    f"Expected 10 rows after filtering, got {len(result)}"
)

# GOOD - Show actual vs expected values
assert result["total"] == 150.0, (
    f"Portfolio total should be $150, got ${result['total']}"
)
```

**Multiple related assertions:**
```python
def test_portfolio_construction():
    """Test portfolio construction creates valid portfolio object."""
    portfolio = Portfolio(weights, prices)
    
    # Group related assertions together
    assert len(portfolio.positions) == len(weights), \
        "Position count should match number of weights"
    assert portfolio.total_value > 0, \
        "Portfolio must have positive value"
    assert abs(portfolio.weights.sum() - 1.0) < 1e-10, \
        "Weights must sum to 1.0"
    assert (portfolio.weights >= 0).all(), \
        "No short positions allowed"
```

## Test Isolation and Setup

**Use fixtures for shared setup:**
```python
@pytest.fixture
def sample_prices():
    """Provide sample price data for testing."""
    return pd.DataFrame({
        'AAPL': [150, 155, 152, 160],
        'GOOGL': [2800, 2850, 2820, 2900]
    }, index=pd.date_range('2024-01-01', periods=4))

@pytest.fixture
def portfolio_config():
    """Provide standard portfolio configuration."""
    return {
        'max_position': 0.3,
        'min_position': 0.05,
        'target_return': 0.12
    }

def test_optimization_with_constraints(sample_prices, portfolio_config):
    """Test portfolio optimization respects position limits."""
    returns = sample_prices.pct_change().dropna()
    weights = optimize_portfolio(returns, **portfolio_config)
    
    assert (weights <= portfolio_config['max_position']).all()
    assert (weights >= portfolio_config['min_position']).all()
```

**Ensure test isolation:**
```python
# BAD - Tests share mutable state
SHARED_DATA = []

def test_append_trade():
    SHARED_DATA.append("AAPL")  # Affects next test!
    assert "AAPL" in SHARED_DATA

# GOOD - Each test has independent data
def test_append_trade():
    trades = []  # Fresh data each time
    trades.append("AAPL")
    assert "AAPL" in trades
```

## Parameterized Tests

Use `pytest.mark.parametrize` to test multiple cases efficiently:

```python
@pytest.mark.parametrize("price,discount,expected", [
    (100.0, 0.0, 100.0),    # No discount
    (100.0, 0.1, 90.0),     # 10% off
    (100.0, 0.5, 50.0),     # 50% off
    (100.0, 1.0, 0.0),      # 100% off
    (50.0, 0.2, 40.0),      # Different price
])
def test_calculate_discount(price, discount, expected):
    """Test discount calculation with various inputs."""
    result = calculate_discount(price, discount)
    assert result == expected

@pytest.mark.parametrize("invalid_discount", [-0.1, 1.1, 2.0])
def test_calculate_discount_invalid_values(invalid_discount):
    """Test discount calculation rejects invalid discount rates."""
    with pytest.raises(ValueError):
        calculate_discount(100.0, invalid_discount)
```

## Testing Async Code

```python
@pytest.mark.asyncio
async def test_fetch_market_data():
    """Test async market data fetching."""
    async with MarketDataClient() as client:
        data = await client.fetch_prices(['AAPL', 'GOOGL'])
        
        assert len(data) == 2
        assert 'AAPL' in data
        assert data['AAPL'] > 0
```

## Testing Data Pipelines

**Test transformations preserve invariants:**
```python
def test_clean_prices_preserves_row_count():
    """Verify data cleaning doesn't drop valid rows."""
    raw_data = pd.DataFrame({
        'price': [100, 110, None, 120],  # One missing value
        'volume': [1000, 1100, 1200, None]  # One missing value
    })
    
    cleaned = clean_prices(raw_data, drop_missing=False)
    
    # Should preserve all rows when drop_missing=False
    assert len(cleaned) == len(raw_data)

def test_clean_prices_handles_outliers():
    """Verify outlier handling in price cleaning."""
    data = pd.DataFrame({
        'price': [100, 105, 9999, 102, 108]  # 9999 is obvious outlier
    })
    
    cleaned = clean_prices(data, remove_outliers=True, zscore_threshold=3)
    
    # Outlier should be removed or capped
    assert cleaned['price'].max() < 200
    assert 9999 not in cleaned['price'].values
```

## Property-Based Testing

For complex logic, use `hypothesis` for property-based testing:

```python
from hypothesis import given, strategies as st

@given(
    prices=st.lists(st.floats(min_value=0.01, max_value=10000), min_size=2),
    weights=st.lists(st.floats(min_value=0, max_value=1), min_size=2)
)
def test_portfolio_value_scales_linearly(prices, weights):
    """Test that doubling all prices doubles portfolio value."""
    # Normalize weights to sum to 1
    weights = np.array(weights[:len(prices)])
    weights = weights / weights.sum()
    
    value1 = calculate_portfolio_value(prices, weights)
    value2 = calculate_portfolio_value([p * 2 for p in prices], weights)
    
    assert value2 == pytest.approx(value1 * 2, rel=1e-6)
```

## Performance Testing

**Benchmark critical functions:**
```python
def test_optimization_performance(benchmark):
    """Verify portfolio optimization completes in reasonable time."""
    returns = generate_large_returns_matrix(1000, 252)  # 1000 assets
    
    result = benchmark(optimize_portfolio, returns, target_return=0.10)
    
    # Should complete in under 5 seconds
    assert benchmark.stats.mean < 5.0
    assert result is not None
```

## Integration Tests

**Test interactions between components:**
```python
def test_full_portfolio_optimization_pipeline():
    """Test complete workflow from data to optimized portfolio."""
    # 1. Load market data
    prices = load_historical_prices(['AAPL', 'GOOGL', 'MSFT'])
    
    # 2. Calculate returns
    returns = calculate_returns(prices)
    
    # 3. Estimate covariance
    cov_matrix = estimate_covariance(returns)
    
    # 4. Optimize
    weights = optimize_portfolio(returns, cov_matrix, target_return=0.12)
    
    # 5. Validate results
    assert abs(weights.sum() - 1.0) < 1e-10
    assert (weights >= 0).all()
    assert len(weights) == 3
    
    # 6. Calculate expected return
    expected_return = (weights * returns.mean() * 252).sum()
    assert expected_return == pytest.approx(0.12, rel=0.01)
```

## Test Quality Checklist

Before committing tests, verify:

- [ ] Every test has at least one meaningful assertion
- [ ] Tests fail when code is broken (verify by breaking code)
- [ ] Test names clearly describe what's being tested
- [ ] Every test has a docstring
- [ ] Edge cases are covered (empty, single item, boundary values)
- [ ] Error conditions are tested with `pytest.raises`
- [ ] No tests share mutable state
- [ ] Fixtures are used for common setup
- [ ] Coverage is ≥75% overall, ≥90% for business logic
- [ ] No tautological tests (re-implementing the function)
- [ ] Assertions include helpful failure messages
- [ ] Mocking is minimal and justified
- [ ] Tests are fast (< 1 second each for unit tests)
- [ ] No hardcoded dates or paths (use fixtures/temp directories)
- [ ] Float comparisons use `pytest.approx` or tolerance

## Coverage Analysis

**Review coverage report for gaps:**
```bash
pytest --cov=myapp --cov-report=html
# Open htmlcov/index.html to see line-by-line coverage
```

**Focus on:**
- Red lines (not covered) in critical business logic
- Branches not taken (if/else paths)
- Exception handlers never triggered
- Edge cases in loops and conditionals

**Don't chase 100% coverage blindly.** Some lines are legitimately hard to test (rare error conditions, defensive assertions). Focus on meaningful coverage of business logic.

## When to Apply This Skill

Use this skill when:
- Writing new test files or test functions
- Reviewing test code for quality and rigor
- Improving test coverage to meet 75% threshold
- Refactoring tests that are flaky or superficial
- Investigating why tests pass but bugs still occur
- Setting up testing infrastructure for new projects

The goal is a test suite that provides real confidence in code correctness, catches bugs reliably, and fails when the code is broken—not tests that just make coverage metrics look good.
